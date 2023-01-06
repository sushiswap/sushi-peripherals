// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "solbase/tokens/ERC20/ERC20.sol";
import "utils/BaseTest.sol";
import "interfaces/IBentoBoxV1.sol";
import "makers/trident/TridentMaker.sol";

import {console2} from "forge-std/console2.sol";

contract TridentMakeTest is BaseTest {
  TridentMaker public tridentMaker;

  IBentoBoxV1 public bentoBox;
  ERC20 public wmatic;
  ERC20 public usdc;
  ERC20 public usdt;
  IPool public pair0;
  IPool public pair1;

  function setUp() public override {
    forkPolygon(37729882);
    super.setUp();

    bentoBox = IBentoBoxV1(constants.getAddress("polygon.bentobox"));

    wmatic = ERC20(constants.getAddress("polygon.wmatic"));
    usdc = ERC20(constants.getAddress("polygon.usdc"));
    usdt = ERC20(constants.getAddress("polygon.usdt"));

    pair0 = IPool(0x846Fea3D94976ef9862040d9FbA9C391Aa75A44B); //wmatic-usdc 0.05%
    pair1 = IPool(0x231BA46173b75E4D7cEa6DCE095A6c1c3E876270); //usdc-usdt 0.01%
    ERC20 pairToken0 = ERC20(0x846Fea3D94976ef9862040d9FbA9C391Aa75A44B); //wmatic-usdc 0.05% 
    ERC20 pairToken1 = ERC20(0x231BA46173b75E4D7cEa6DCE095A6c1c3E876270); //usdc-usdt 0.01%

    // deploy TridentMaker
    tridentMaker = new TridentMaker(address(this));

    // fill maker w/ wmatic-usdc & usdc-usdt
    address pranker = 0x4bb4c1B0745ef7B4642fEECcd0740deC417ca0a0;
    vm.startPrank(pranker);
    pairToken0.transfer(address(tridentMaker), pairToken0.balanceOf(pranker));
    pairToken1.transfer(address(tridentMaker), pairToken1.balanceOf(pranker));
    vm.stopPrank();
  }

  function testHello() public {
    address usdcWhale = 0xF977814e90dA44bFA03b6295A0616a897441aceC;
    vm.startPrank(usdcWhale);
    usdc.approve(address(bentoBox), 100 gwei);
    bentoBox.deposit(address(usdc), usdcWhale, usdcWhale, 100 gwei, 0);
    vm.stopPrank();
    
    uint256 helloBalance = bentoBox.balanceOf(address(usdc), usdcWhale);
    assertEq(helloBalance, bentoBox.toShare(address(usdc), 100 gwei, false));

    //assertEq(testPair0.token0(), address(weth));
  }

  function testBurnSinglePairs() public {
    // test burn for single token with 1 gwei of pair0
    ERC20 token0 = ERC20(pair0.token0());
    ERC20 token1 = ERC20(pair0.token1());

    address[] memory pairs = new address[](1);
    uint256[] memory amounts = new uint256[](1);
    bool[] memory keepTokens0 = new bool[](1);
    uint256[] memory minAmounts = new uint256[](1);
    pairs[0] = address(pair0);
    amounts[0] = 1 gwei;
    keepTokens0[0] = true;
    minAmounts[0] = 0; // no slippage protection

    tridentMaker.burnSinglePairs(pairs, amounts, keepTokens0, minAmounts);
    uint256 firstBurnToken0Amount = token0.balanceOf(address(tridentMaker));
    assertGt(token0.balanceOf(address(tridentMaker)), 0);
    assertEq(token1.balanceOf(address(tridentMaker)), 0);

    keepTokens0[0] = false;
    tridentMaker.burnSinglePairs(pairs, amounts, keepTokens0, minAmounts);
    assertEq(token0.balanceOf(address(tridentMaker)), firstBurnToken0Amount);
    assertGt(token1.balanceOf(address(tridentMaker)), 0);

  }

  function testBurnPairs() public {
    // test burn for both tokens with 1 gwei of pair0
    ERC20 token0 = ERC20(pair0.token0());
    ERC20 token1 = ERC20(pair0.token1());

    address[] memory pairs = new address[](1);
    uint256[] memory amounts = new uint256[](1);
    uint256[] memory minAmounts0 = new uint256[](1);
    uint256[] memory minAmounts1 = new uint256[](1);
    pairs[0] = address(pair0);
    amounts[0] = 1 gwei;
    minAmounts0[0] = 0; // no slippage protection
    minAmounts1[0] = 0;

    tridentMaker.burnPairs(pairs, amounts, minAmounts0, minAmounts1);
    assertGt(token0.balanceOf(address(tridentMaker)), 0);
    assertGt(token1.balanceOf(address(tridentMaker)), 0);
  }

  function testSwap() public {
    // burn pair0 for both tokens swap token1 (usdc) for token1 of pair1 (usdt)
    // something funky happening with this
    // todo: lets do token0 to token1, since we know it's liquid
    ERC20 token0 = ERC20(pair0.token0());
    ERC20 token1 = ERC20(pair0.token1());

    console2.log(ERC20(address(pair0)).balanceOf(address(tridentMaker)));

    address[] memory pairs = new address[](1);
    uint256[] memory amounts = new uint256[](1);
    uint256[] memory minAmounts0 = new uint256[](1);
    uint256[] memory minAmounts1 = new uint256[](1);
    pairs[0] = address(pair0);
    amounts[0] = ERC20(address(pair0)).balanceOf(address(tridentMaker));
    minAmounts0[0] = 0; // no slippage protection
    minAmounts1[0] = 0;
    tridentMaker.burnPairs(pairs, amounts, minAmounts0, minAmounts1);

    // swap token1 (usdc) for token1 of pair1 (usdt)
    uint256 token1Amount = 10000; // 0.01 usdc
    ERC20 swapToken = ERC20(pair1.token1());
    address[] memory tokensIn = new address[](1);
    address[] memory swapPairs = new address[](1);
    uint256[] memory amountsIn = new uint256[](1);
    uint256[] memory minimumOuts = new uint256[](1);
    tokensIn[0] = address(token1);
    swapPairs[0] = address(pair1);
    amountsIn[0] = token1Amount;
    minimumOuts[0] = 0; // no slippage protection

    tridentMaker.swap(tokensIn, swapPairs, amountsIn, minimumOuts);

    assertGt(swapToken.balanceOf(address(tridentMaker)), 0);


  }
}