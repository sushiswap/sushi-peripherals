// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./TridentUnwindooor.sol";

// contract for selling built up fees
contract TridentMaker is TridentUnwindooor {
  constructor(
    address owner
  ) TridentUnwindooor(owner) {}

  function swap(
    address[] calldata tokensIn,
    address[] calldata swapPairs,
    uint256[] calldata amountsIn,
    uint256[] calldata minimumOuts
  ) external onlyOwner {
    for (uint256 i = 0; i < tokensIn.length; i++) {
      IPool pair = IPool(swapPairs[i]);
      _safeTransfer(tokensIn[i], address(pair), amountsIn[i]);
      bytes memory swapData = abi.encode(tokensIn[i], address(this), true);
      uint256 amountOut = pair.swap(swapData);
      if (amountOut < minimumOuts[i]) revert SlippageProtection();
    }
  }
}