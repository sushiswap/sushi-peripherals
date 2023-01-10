// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./TridentUnwindooor.sol";
import "interfaces/IBentoboxV1.sol";
import "solmate/tokens/ERC20.sol";

/// @notice Contract for withdrawing Trident LP positions
/// @dev Can set tokenFeeTo to serve fees to set addresses with serveFees
contract TridentMaker is TridentUnwindooor { 
  IBentoBoxV1 public immutable bentoBox;
  mapping(address => address) public tokenFeeTo;

  constructor(
    address _owner,
    address user,
    address _bentoBox
  ) TridentUnwindooor(_owner, user) {
    bentoBox = IBentoBoxV1(_bentoBox);
  }

  // Perform swap
  /// @dev swaps amountsIn of tokensIn through the swapPairs, with slippage protection set in minimumOuts
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

  // Set feeTo for token/pair
  /// @dev sets tokenFeeTo for a token to direct where it will be served to
  function setTokenFeeTo(address token, address feeTo) external onlyOwner {
    tokenFeeTo[token] = feeTo;
  }

  /// serve the fees
  /// @dev external function to serve fees for all tokens passed in where feeTo is set
  function serveFees(address[] calldata tokens) external {
    for (uint256 i = 0; i < tokens.length; i++) {
      address token = tokens[i];
      address feeTo = tokenFeeTo[token];
      if (feeTo != address(0)) {
        uint256 balance = ERC20(token).balanceOf(address(this));
        _safeTransfer(token, feeTo, balance);
      }
    }
  }

  // withdraw tokens
  /// @dev onlyOwner call to withdraw tokens from the contract
  function withdraw(address token, address to, uint256 _value) onlyOwner external {
    if (token != address(0)) {
      _safeTransfer(token, to, _value);
    } else {
      (bool success, ) = to.call{value: _value}("");
      require(success);
    }
  }
  
  // do any action
  ///@dev onlyOwner call to perform any action, can be used for emergencies or performing operations not supported thru contract
  function doAction(address to, uint256 _value, bytes memory data) onlyOwner external {
    (bool success, ) = to.call{value: _value}(data);
    require(success);
  }
  receive() external payable {}
}