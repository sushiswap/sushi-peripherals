// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solbase/auth/Auth.sol";
import "interfaces/IPool.sol";

contract TridentUnwindooor is Auth {
  // Built for just stable and constant product pools

  error SlippageProtection();

  constructor(
    address owner,
    address user
  ) Auth(owner, user) {}

  function burnSinglePairs(
    address[] calldata pairs,
    uint256[] calldata amounts,
    bool[] calldata keepToken0,
    uint256[] calldata minimumOuts
  ) external onlyTrusted {
    for (uint256 i = 0; i < pairs.length; i++) {
      IPool pair = IPool(pairs[i]);
      pair.transfer(address(pair), amounts[i]);
      
      if (keepToken0) {
        bytes burnData = abi.encode(pair.token0(), address(this), true);
      } else {
        bytes burnData = abi.encode(pair.token1(), address(this), true);
      }

      uint256 amountOut = pair.burnSingle(burnData);
      if (amountOut < minimumOuts[i]) revert SlippageProtection();
    }
  }

  function burnPairs(
    address[] calldata pairs,
    uint256[] calldata amounts,
    uint256[] calldata minimumOut0,
    uint256[] calldata minimumOut1
  ) external onlyTrusted {
    for (uint256 i = 0; i < pairs.length; i++) {
      IPool pair = IPool(pairs[i]);
      pair.transfer(address(pair), amounts[i]);
      bytes burnData = abi.encode(address(this), true);
      
      IPool.TokenAmount[] memory withdrawnAmounts = pair.burn(burnData);
      if (withdrawnAmounts[0].amount < minimumOut0[i] || withdrawnAmounts[1].amount < minimumOut1[i]) revert SlippageProtection();
    }
  }
}