// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "BoringSolidity/libraries/BoringRebase.sol";
import "interfaces/IStrategy.sol";

interface IFlashBorrower {
  /// @notice The flashloan callback. `amount` + `fee` needs to repayed to msg.sender before this call returns.
  /// @param sender The address of the invoker of this flashloan.
  /// @param token The address of the token that is loaned.
  /// @param amount of the `token` that is loaned.
  /// @param fee The fee that needs to be paid on top for this loan. Needs to be the same as `token`.
  /// @param data Additional data that was passed to the flashloan function.
  function onFlashLoan(
    address sender,
    address token,
    uint256 amount,
    uint256 fee,
    bytes calldata data
  ) external;
}

interface IBatchFlashBorrower {
  /// @notice The callback for batched flashloans. Every amount + fee needs to repayed to msg.sender before this call returns.
  /// @param sender The address of the invoker of this flashloan.
  /// @param tokens Array of addresses for ERC-20 tokens that is loaned.
  /// @param amounts A one-to-one map to `tokens` that is loaned.
  /// @param fees A one-to-one map to `tokens` that needs to be paid on top for each loan. Needs to be the same token.
  /// @param data Additional data that was passed to the flashloan function.
  function onBatchFlashLoan(
    address sender,
    address[] calldata tokens,
    uint256[] calldata amounts,
    uint256[] calldata fees,
    bytes calldata data
  ) external;
}

interface IBentoBoxV1 {
  function balanceOf(address, address) external view returns (uint256);

  function batch(bytes[] calldata calls, bool revertOnFail)
    external
    payable
    returns (bool[] memory successes, bytes[] memory results);

  function batchFlashLoan(
    IBatchFlashBorrower borrower,
    address[] calldata receivers,
    address[] calldata tokens,
    uint256[] calldata amounts,
    bytes calldata data
  ) external;

  function claimOwnership() external;

  function flashLoan(
    IFlashBorrower borrower,
    address receiver,
    address token,
    uint256 amount,
    bytes calldata data
  ) external;

  function deploy(
    address masterContract,
    bytes calldata data,
    bool useCreate2
  ) external payable returns (address);

  function deposit(
    address token_,
    address from,
    address to,
    uint256 amount,
    uint256 share
  ) external payable returns (uint256 amountOut, uint256 shareOut);

  function harvest(
    address token,
    bool balance,
    uint256 maxChangeAmount
  ) external;

  function masterContractApproved(address, address) external view returns (bool);

  function masterContractOf(address) external view returns (address);

  function nonces(address) external view returns (uint256);

  function owner() external view returns (address);

  function pendingOwner() external view returns (address);

  function pendingStrategy(address) external view returns (IStrategy);

  function permitToken(
    address token,
    address from,
    address to,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function registerProtocol() external;

  function setMasterContractApproval(
    address user,
    address masterContract,
    bool approved,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function setStrategy(address token, IStrategy newStrategy) external;

  function setStrategyTargetPercentage(address token, uint64 targetPercentage_) external;

  function strategy(address) external view returns (IStrategy);

  function strategyData(address)
    external
    view
    returns (
      uint64 strategyStartDate,
      uint64 targetPercentage,
      uint128 balance
    );

  function toAmount(
    address token,
    uint256 share,
    bool roundUp
  ) external view returns (uint256 amount);

  function toShare(
    address token,
    uint256 amount,
    bool roundUp
  ) external view returns (uint256 share);

  function totals(address) external view returns (Rebase memory totals_);

  function transfer(
    address token,
    address from,
    address to,
    uint256 share
  ) external;

  function transferMultiple(
    address token,
    address from,
    address[] calldata tos,
    uint256[] calldata shares
  ) external;

  function transferOwnership(
    address newOwner,
    bool direct,
    bool renounce
  ) external;

  function whitelistMasterContract(address masterContract, bool approved) external;

  function whitelistedMasterContracts(address) external view returns (bool);

  function withdraw(
    address token_,
    address from,
    address to,
    uint256 amount,
    uint256 share
  ) external returns (uint256 amountOut, uint256 shareOut);
}
