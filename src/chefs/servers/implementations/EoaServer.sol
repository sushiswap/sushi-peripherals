// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../BaseServer.sol";

interface BasicERC20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
}

/// @notice Contract that stakes dummy tokens to accumulate sushi for an EOA to transfer to alternate chain
/// @dev harvests sushi from masterchef, and then _bridge sends that sushi to operator eoa
contract EoaServer is BaseServer {
  address operatorAddr;

  constructor(
    uint256 _pid,
    address _minichef,
    address _operatorAddr
  ) BaseServer(_pid, _minichef) {
    operatorAddr = _operatorAddr;
  }

  /// @dev internal bridge call
  /// @param data is not used
  function _bridge(bytes calldata data) internal override {
    uint256 sushiBalance = sushi.balanceOf(address(this));

    sushi.transfer(operatorAddr, sushiBalance);
    emit BridgedSushi(operatorAddr, sushiBalance);
  }

  /// @dev set operator address, to guard _bridge call
  function setOperatorAddr(address newAddy) external onlyOwner {
    operatorAddr = newAddy;
  }
}
