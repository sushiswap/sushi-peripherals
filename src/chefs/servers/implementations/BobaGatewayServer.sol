// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../BaseServer.sol";

interface IGatewayBridge {
  function depositERC20(
    address _l1Token,
    address _l2Token,
    uint256 _amount,
    uint32 _l2Gas,
    bytes calldata _data
  ) external;
}

/// @notice Contract bridges Sushi to boba chains using their gateway bridge
/// @dev takes an operator address in constructor to guard _bridge calls
contract BobaGatewayServer is BaseServer {
  address public gatewayAddr;
  address public operatorAddr;

  error NotAuthorizedToBridge();

  constructor(uint256 _pid, address _minichef, address _gatewayAddr, address _operatorAddr) BaseServer(_pid, _minichef) {
    gatewayAddr = _gatewayAddr;
    operatorAddr = _operatorAddr;
  }

  /// @dev internal bridge call
  /// @param data is used: address l2Token, uint32 l2Gas, bytes bridgeData
  function _bridge(bytes calldata data) internal override {
    if (msg.sender != operatorAddr) revert NotAuthorizedToBridge();

    (
      address l2Token,
      uint32 l2Gas,
      bytes memory bridgeData
    ) = abi.decode(data, (address, uint32, bytes));

    uint256 sushiBalance = sushi.balanceOf(address(this));
    IGatewayBridge(gatewayAddr).depositERC20(
      address(sushi),
      l2Token,
      sushiBalance,
      l2Gas,
      bridgeData
    );

    emit BridgedSushi(minichef, sushiBalance);
  }

  /// @dev set operator address, to guard _bridge calls
  function setOperatorAddr(address newAddy) external onlyOwner {
    operatorAddr = newAddy;
  }
}

