// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./TridentUnwindooor.sol";
import "interfaces/IBentoboxV1.sol";

// contract for selling built up fees
contract TridentMaker is TridentUnwindooor {
  
  IBentoBoxV1 public immutable bentoBox;

  constructor(
    address owner,
    address _bentoBox
  ) TridentUnwindooor(owner) {
    bentoBox = IBentoBoxV1(_bentoBox);
  }

  function swap(
    address[] calldata tokensIn,
    address[] calldata swapPairs,
    uint256[] calldata amountsIn,
    uint256[] calldata minimumOuts
  ) external onlyOwner {
    for (uint256 i = 0; i < tokensIn.length; i++) {
      IPool pair = IPool(swapPairs[i]);
      _safeTransfer(tokensIn[i], address(bentoBox), amountsIn[i]);
      bentoBox.deposit(tokensIn[i], address(bentoBox), address(pair), amountsIn[i], 0);
      bytes memory swapData = abi.encode(tokensIn[i], address(this), true);
      uint256 amountOut = pair.swap(swapData);
      if (amountOut < minimumOuts[i]) revert SlippageProtection();
    }
  }
}