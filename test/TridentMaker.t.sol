// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "solbase/tokens/ERC20/ERC20.sol";
import "utils/BaseTest.sol";

contract TridentMaker is BaseTest {
  ERC20 public sushi;
  ERC20 public usdc;

  function setUp() public override {
    super.setUp();

    sushi = ERC20(constants.getAddress("mainnet.sushi"));
    usdc = ERC20(constants.getAddress("mainnet.usdc"));

    address sushiWhale = constants.getAddress("mainnet.whale.sushi");
  }

  function testHello() public {
    assertTrue(true);
  }

}