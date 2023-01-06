// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "solbase/tokens/ERC20/ERC20.sol";
import "utils/BaseTest.sol";
import "interfaces/IBentoBoxV1.sol";
import "interfaces/Ipool.sol";

contract TridentMaker is BaseTest {
  IBentoBoxV1 public bentoBox;
  ERC20 public wmatic;
  ERC20 public usdc;
  ERC20 public usdt;
  IPool public pair0;
  IPool public pair1;

  function setUp() public override {
    forkPolygon(37729882);
    super.setUp();

    //sushi = ERC20(constants.getAddress("mainnet.sushi"));
    //usdc = ERC20(constants.getAddress("mainnet.usdc"));
    //address sushiWhale = constants.getAddress("mainnet.whale.sushi");

    bentoBox = IBentoBoxV1(constants.getAddress("polygon.bentobox"));

    wmatic = ERC20(constants.getAddress("polygon.wmatic"));
    usdc = ERC20(constants.getAddress("polygon.usdc"));
    usdt = ERC20(constants.getAddress("polygon.usdt"));
  
    pair0 = IPool(0x846Fea3D94976ef9862040d9FbA9C391Aa75A44B); //wmatic-usdc 0.05% 
    pair1 = IPool(0x231BA46173b75E4D7cEa6DCE095A6c1c3E876270); //usdc-usdt 0.01%

    // deploy TridentMaker



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

}