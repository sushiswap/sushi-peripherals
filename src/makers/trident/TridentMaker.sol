// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./TridentUnwindooor.sol";
import "interfaces/IBentoboxV1.sol";

// contract for selling built up fees
contract TridentMaker is TridentUnwindooor {
  
  IBentoBoxV1 public immutable bentoBox;

  constructor(
    address _owner,
    address user,
    address _bentoBox
  ) TridentUnwindooor(_owner, user) {
    bentoBox = IBentoBoxV1(_bentoBox);
  }

  function swap(
    address[] calldata tokensIn,
    address[] calldata swapPairs,
    uint256[] calldata amountsIn,
    uint256[] calldata minimumOuts
  ) external onlyTrusted {
    for (uint256 i = 0; i < tokensIn.length; i++) {
      IPool pair = IPool(swapPairs[i]);
      _safeTransfer(tokensIn[i], address(bentoBox), amountsIn[i]);
      bentoBox.deposit(tokensIn[i], address(bentoBox), address(pair), amountsIn[i], 0);
      bytes memory swapData = abi.encode(tokensIn[i], address(this), true);
      uint256 amountOut = pair.swap(swapData);
      if (amountOut < minimumOuts[i]) revert SlippageProtection();
    }
  }

  // todo: thinking bout setting this up for splitters / having default address for
  // where funds go. Maybe even setup mapping for which pairs go to certain addresses
  // or fee splitters w/ check to not let swaps happen on those pairs
  function withdraw(address token, address to, uint256 _value) onlyOwner external {
    if (token != address(0)) {
      _safeTransfer(token, to, _value);
    } else {
      (bool success, ) = to.call{value: _value}("");
      require(success);
    }
  }

  function doAction(address to, uint256 _value, bytes memory data) onlyOwner external {
    (bool success, ) = to.call{value: _value}(data);
    require(success);
  }
  receive() external payable {}
}