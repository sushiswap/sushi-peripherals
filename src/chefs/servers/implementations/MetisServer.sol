// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../BaseServer.sol";

interface IMetisBridge {
  function depositERC20To(
    address _l1Token,
    address _l2Token,
    address _to,
    uint256 _amount,
    uint32 _l2Gas,
    bytes calldata _data
  ) external;
}

/// @notice Contract bridges Sushi to metis using their official bridge.
/// @dev takes and operator address in constructor to guard _bridge calls
contract MetisServer is BaseServer {
  address public constant metisSushiToken = 0x17Ee7E4dA37B01FC1bcc908fA63DF343F23B4B7C;
  address public bridgeAddr;
  address public operatorAddr;

  error NotAuthorizedToBridge();

  constructor(
    uint256 _pid,
    address _minichef,
    address _bridgeAddr,
    address _operatorAddr
  ) BaseServer(_pid, _minichef) {
    bridgeAddr = _bridgeAddr;
    operatorAddr = _operatorAddr;
  }

  /// @dev internal bridge call
  /// @param data is used: uint32 l2Gas
  function _bridge(bytes calldata data) internal override {
    if (msg.sender != operatorAddr) revert NotAuthorizedToBridge();

    uint32 l2Gas = abi.decode(data, (uint32));

    uint256 sushiBalance = sushi.balanceOf(address(this));
    sushi.approve(bridgeAddr, sushiBalance);
    IMetisBridge(bridgeAddr).depositERC20To(address(sushi), metisSushiToken, minichef, sushiBalance, l2Gas, "");

    emit BridgedSushi(minichef, sushiBalance);
  }

  /// @dev set operator address, to guard _bridge call
  function setOperatorAddr(address newAddy) external onlyOwner {
    operatorAddr = newAddy;
  }
}
