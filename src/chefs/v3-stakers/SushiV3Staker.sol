// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "./interfaces/ISushiV3Staker.sol";
import "./libraries/IncentiveId.sol";
import "./libraries/RewardMath.sol";
import "./libraries/NFTPositionInfo.sol";
import "./libraries/TransferHelperExtended.sol";

import "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-core/contracts/interfaces/IERC20Minimal.sol";

import "v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "v3-periphery/contracts/base/Multicall.sol";

/// @title Sushi V3 canonical staking interface
contract SushiV3Staker is ISushiV3Staker, Multicall {
  /// @notice Represents a staking incentive
  struct Incentive {
    uint256 totalRewardUnclaimed;
    uint256 totalRewardLocked;
    uint160 totalSecondsClaimedX128;
    uint96 numberOfStakes;
  }

  /// @notice Represents the deposit of a liquidity NFT
  struct Deposit {
    address owner;
    uint48 numberOfStakes;
    int24 tickLower;
    int24 tickUpper;
  }

  /// @notice Represents a staked liquidity NFT
  struct Stake {
    uint160 secondsPerLiquidityInsideInitialX128;
    uint32 secondsInsideInitial;
    uint64 liquidityNoOverflow;
    uint128 liquidityIfOverflow;
  }

  /// @inheritdoc ISushiV3Staker
  IUniswapV3Factory public immutable override factory;
  /// @inheritdoc ISushiV3Staker
  INonfungiblePositionManager public immutable override nonfungiblePositionManager;

  /// @inheritdoc ISushiV3Staker
  uint256 public immutable override maxIncentiveStartLeadTime;
  /// @inheritdoc ISushiV3Staker
  uint256 public immutable override maxIncentiveDuration;

  /// @dev bytes32 refers to the return value of IncentiveId.compute
  mapping(bytes32 => Incentive) public override incentives;

  /// @dev deposits[tokenId] => Deposit
  mapping(uint256 => Deposit) public override deposits;

  /// @dev stakes[tokenId][incentiveHash] => Stake
  mapping(uint256 => mapping(bytes32 => Stake)) private _stakes;

  /// @inheritdoc ISushiV3Staker
  function stakes(
    uint256 tokenId,
    bytes32 incentiveId
  )
    public
    view
    override
    returns (uint160 secondsPerLiquidityInsideInitialX128, uint32 secondsInsideInitial, uint128 liquidity)
  {
    Stake storage stake = _stakes[tokenId][incentiveId];
    secondsPerLiquidityInsideInitialX128 = stake.secondsPerLiquidityInsideInitialX128;
    secondsInsideInitial = stake.secondsInsideInitial;
    liquidity = stake.liquidityNoOverflow;
    if (liquidity == type(uint64).max) {
      liquidity = stake.liquidityIfOverflow;
    }
  }

  /// @dev rewards[rewardToken][owner] => uint256
  /// @inheritdoc ISushiV3Staker
  mapping(IERC20Minimal => mapping(address => uint256)) public override rewards;

  /// @param _factory the Sushi V3 factory
  /// @param _nonfungiblePositionManager the NFT position manager contract address
  /// @param _maxIncentiveStartLeadTime the max duration of an incentive in seconds
  /// @param _maxIncentiveDuration the max amount of seconds into the future the incentive startTime can be set
  constructor(
    IUniswapV3Factory _factory,
    INonfungiblePositionManager _nonfungiblePositionManager,
    uint256 _maxIncentiveStartLeadTime,
    uint256 _maxIncentiveDuration
  ) {
    factory = _factory;
    nonfungiblePositionManager = _nonfungiblePositionManager;
    maxIncentiveStartLeadTime = _maxIncentiveStartLeadTime;
    maxIncentiveDuration = _maxIncentiveDuration;
  }

  /// @inheritdoc ISushiV3Staker
  function createIncentive(IncentiveKey memory key, uint256 reward) external override {
    require(reward > 0, "SushiV3Staker::createIncentive: reward must be positive");
    require(
      block.timestamp <= key.startTime,
      "SushiV3Staker::createIncentive: start time must be now or in the future"
    );
    require(
      key.startTime - block.timestamp <= maxIncentiveStartLeadTime,
      "SushiV3Staker::createIncentive: start time too far into future"
    );
    require(key.startTime < key.endTime, "SushiV3Staker::createIncentive: start time must be before end time");
    require(
      key.endTime - key.startTime <= maxIncentiveDuration,
      "SushiV3Staker::createIncentive: incentive duration is too long"
    );

    require(
      key.vestingPeriod <= key.endTime - key.startTime,
      "SushiV3Staker::createIncentive: vesting time must be lte incentive duration"
    );

    require(key.refundee != address(0), "SushiV3Staker::createIncentive: refundee must be a valid address");

    bytes32 incentiveId = IncentiveId.compute(key);

    incentives[incentiveId].totalRewardUnclaimed += reward;

    TransferHelperExtended.safeTransferFrom(address(key.rewardToken), msg.sender, address(this), reward);

    emit IncentiveCreated(
      key.rewardToken,
      key.pool,
      key.startTime,
      key.endTime,
      key.vestingPeriod,
      key.refundee,
      reward
    );
  }

  /// @inheritdoc ISushiV3Staker
  function endIncentive(IncentiveKey memory key) external override returns (uint256 refund) {
    require(block.timestamp >= key.endTime, "SushiV3Staker::endIncentive: cannot end incentive before end time");

    bytes32 incentiveId = IncentiveId.compute(key);
    Incentive storage incentive = incentives[incentiveId];

    refund = incentive.totalRewardUnclaimed + incentive.totalRewardLocked;

    require(refund > 0, "SushiV3Staker::endIncentive: no refund available");
    require(
      incentive.numberOfStakes == 0,
      "SushiV3Staker::endIncentive: cannot end incentive while deposits are staked"
    );

    // issue the refund
    incentive.totalRewardUnclaimed = 0;
    incentive.totalRewardLocked = 0;
    TransferHelperExtended.safeTransfer(address(key.rewardToken), key.refundee, refund);

    // note we never clear totalSecondsClaimedX128

    emit IncentiveEnded(incentiveId, refund);
  }

  /// @notice Upon receiving a Sushi V3 ERC721, creates the token deposit setting owner to `from`. Also stakes token
  /// in one or more incentives if properly formatted `data` has a length > 0.
  /// @inheritdoc IERC721Receiver
  function onERC721Received(
    address,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external override returns (bytes4) {
    require(msg.sender == address(nonfungiblePositionManager), "SushiV3Staker::onERC721Received: not a univ3 nft");

    (, , , , , int24 tickLower, int24 tickUpper, , , , , ) = nonfungiblePositionManager.positions(tokenId);

    deposits[tokenId] = Deposit({owner: from, numberOfStakes: 0, tickLower: tickLower, tickUpper: tickUpper});
    emit DepositTransferred(tokenId, address(0), from);

    if (data.length > 0) {
      if (data.length == 192) {
        _stakeToken(abi.decode(data, (IncentiveKey)), tokenId);
      } else {
        IncentiveKey[] memory keys = abi.decode(data, (IncentiveKey[]));
        for (uint256 i = 0; i < keys.length; i++) {
          _stakeToken(keys[i], tokenId);
        }
      }
    }
    return this.onERC721Received.selector;
  }

  /// @inheritdoc ISushiV3Staker
  function transferDeposit(uint256 tokenId, address to) external override {
    require(to != address(0), "SushiV3Staker::transferDeposit: invalid transfer recipient: (address 0)");
    require(to != address(this), "SushiV3Staker::transferDeposit: invalid transfer recipient (staker address)");
    address owner = deposits[tokenId].owner;
    require(owner == msg.sender, "SushiV3Staker::transferDeposit: can only be called by deposit owner");
    deposits[tokenId].owner = to;
    emit DepositTransferred(tokenId, owner, to);
  }

  /// @inheritdoc ISushiV3Staker
  function withdrawToken(uint256 tokenId, address to, bytes memory data) external override {
    require(to != address(this), "SushiV3Staker::withdrawToken: cannot withdraw to staker");
    Deposit memory deposit = deposits[tokenId];
    require(deposit.numberOfStakes == 0, "SushiV3Staker::withdrawToken: cannot withdraw token while staked");
    require(deposit.owner == msg.sender, "SushiV3Staker::withdrawToken: only owner can withdraw token");

    delete deposits[tokenId];
    emit DepositTransferred(tokenId, deposit.owner, address(0));

    nonfungiblePositionManager.safeTransferFrom(address(this), to, tokenId, data);
  }

  /// @inheritdoc ISushiV3Staker
  function stakeToken(IncentiveKey memory key, uint256 tokenId) external override {
    require(deposits[tokenId].owner == msg.sender, "SushiV3Staker::stakeToken: only owner can stake token");

    _stakeToken(key, tokenId);
  }

  /// @inheritdoc ISushiV3Staker
  function unstakeToken(IncentiveKey memory key, uint256 tokenId) external override {
    Deposit memory deposit = deposits[tokenId];
    // anyone can call unstakeToken if the block time is after the end time of the incentive
    if (block.timestamp < key.endTime) {
      require(
        deposit.owner == msg.sender,
        "SushiV3Staker::unstakeToken: only owner can withdraw token before incentive end time"
      );
    }

    bytes32 incentiveId = IncentiveId.compute(key);

    (uint160 secondsPerLiquidityInsideInitialX128, uint32 secondsInsideInitial, uint128 liquidity) = stakes(
      tokenId,
      incentiveId
    );

    require(liquidity != 0, "SushiV3Staker::unstakeToken: stake does not exist");

    Incentive storage incentive = incentives[incentiveId];

    deposits[tokenId].numberOfStakes--;
    incentive.numberOfStakes--;

    (, uint160 secondsPerLiquidityInsideX128, uint32 secondsInside) = key.pool.snapshotCumulativesInside(
      deposit.tickLower,
      deposit.tickUpper
    );
    (uint256 reward, uint256 maxReward, uint160 secondsInsideX128) = RewardMath.computeRewardAmount(
      RewardMath.ComputeRewardAmountParams(
        incentive.totalRewardUnclaimed,
        incentive.totalSecondsClaimedX128,
        key.startTime,
        key.endTime,
        key.vestingPeriod,
        liquidity,
        secondsPerLiquidityInsideInitialX128,
        secondsPerLiquidityInsideX128,
        secondsInsideInitial,
        secondsInside,
        block.timestamp
      )
    );

    // if this overflows, e.g. after 2^32-1 full liquidity seconds have been claimed,
    // reward rate will fall drastically so it's safe
    incentive.totalSecondsClaimedX128 += secondsInsideX128;
    // reward is never greater than total reward unclaimed
    incentive.totalRewardUnclaimed -= maxReward;

    // if not all reward is payed to owner, add difference to locked amount to be withdrawable at end of incentive
    if (maxReward > reward) {
      incentive.totalRewardLocked += maxReward - reward;
    }

    // this only overflows if a token has a total supply greater than type(uint256).max
    rewards[key.rewardToken][deposit.owner] += reward;

    Stake storage stake = _stakes[tokenId][incentiveId];
    delete stake.secondsPerLiquidityInsideInitialX128;
    delete stake.secondsInsideInitial;
    delete stake.liquidityNoOverflow;
    if (liquidity >= type(uint64).max) delete stake.liquidityIfOverflow;
    emit TokenUnstaked(tokenId, incentiveId);
  }

  /// @inheritdoc ISushiV3Staker
  function claimReward(
    IERC20Minimal rewardToken,
    address to,
    uint256 amountRequested
  ) external override returns (uint256 reward) {
    reward = rewards[rewardToken][msg.sender];
    if (amountRequested != 0 && amountRequested < reward) {
      reward = amountRequested;
    }

    rewards[rewardToken][msg.sender] -= reward;
    TransferHelperExtended.safeTransfer(address(rewardToken), to, reward);

    emit RewardClaimed(rewardToken, to, reward);
  }

  /// @inheritdoc ISushiV3Staker
  function getRewardInfo(
    IncentiveKey memory key,
    uint256 tokenId
  ) external view override returns (uint256 reward, uint256 maxReward, uint160 secondsInsideX128) {
    bytes32 incentiveId = IncentiveId.compute(key);

    (uint160 secondsPerLiquidityInsideInitialX128, uint32 secondsInsideInitial, uint128 liquidity) = stakes(
      tokenId,
      incentiveId
    );
    require(liquidity > 0, "SushiV3Staker::getRewardInfo: stake does not exist");

    Deposit memory deposit = deposits[tokenId];
    Incentive memory incentive = incentives[incentiveId];

    (, uint160 secondsPerLiquidityInsideX128, uint32 secondsInside) = key.pool.snapshotCumulativesInside(
      deposit.tickLower,
      deposit.tickUpper
    );

    (reward, maxReward, secondsInsideX128) = RewardMath.computeRewardAmount(
      RewardMath.ComputeRewardAmountParams(
        incentive.totalRewardUnclaimed,
        incentive.totalSecondsClaimedX128,
        key.startTime,
        key.endTime,
        key.vestingPeriod,
        liquidity,
        secondsPerLiquidityInsideInitialX128,
        secondsPerLiquidityInsideX128,
        secondsInsideInitial,
        secondsInside,
        block.timestamp
      )
    );
  }

  /// @dev Stakes a deposited token without doing an ownership check
  function _stakeToken(IncentiveKey memory key, uint256 tokenId) private {
    require(block.timestamp >= key.startTime, "SushiV3Staker::stakeToken: incentive not started");
    require(block.timestamp < key.endTime, "SushiV3Staker::stakeToken: incentive ended");

    bytes32 incentiveId = IncentiveId.compute(key);

    require(incentives[incentiveId].totalRewardUnclaimed > 0, "SushiV3Staker::stakeToken: non-existent incentive");
    require(_stakes[tokenId][incentiveId].liquidityNoOverflow == 0, "SushiV3Staker::stakeToken: token already staked");

    (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) = NFTPositionInfo.getPositionInfo(
      factory,
      nonfungiblePositionManager,
      tokenId
    );

    require(pool == key.pool, "SushiV3Staker::stakeToken: token pool is not the incentive pool");
    require(liquidity > 0, "SushiV3Staker::stakeToken: cannot stake token with 0 liquidity");

    deposits[tokenId].numberOfStakes++;
    incentives[incentiveId].numberOfStakes++;

    (, uint160 secondsPerLiquidityInsideX128, uint32 secondsInside) = pool.snapshotCumulativesInside(
      tickLower,
      tickUpper
    );

    if (liquidity >= type(uint64).max) {
      _stakes[tokenId][incentiveId] = Stake({
        secondsPerLiquidityInsideInitialX128: secondsPerLiquidityInsideX128,
        secondsInsideInitial: secondsInside,
        liquidityNoOverflow: type(uint64).max,
        liquidityIfOverflow: liquidity
      });
    } else {
      Stake storage stake = _stakes[tokenId][incentiveId];
      stake.secondsPerLiquidityInsideInitialX128 = secondsPerLiquidityInsideX128;
      stake.secondsInsideInitial = secondsInside;
      stake.liquidityNoOverflow = uint64(liquidity);
    }

    emit TokenStaked(tokenId, incentiveId, liquidity);
  }
}
