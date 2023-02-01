// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../BaseServer.sol";

interface IxDaiBridge {
  function relayTokens(
    address token,
    address _receiver,
    uint256 _value
  ) external;
}

/// @notice Contract bridges Sushi to other chains through omni bridge
/// @dev uses omni bridge and address needs to be pass through the constructor
contract GnosisOmniServer is BaseServer {
  address public bridgeAddr;

  constructor(
    uint256 _pid,
    address _minichef,
    address _bridgeAddr
  ) BaseServer(_pid, _minichef) {
    bridgeAddr = _bridgeAddr;
  }

  /// @dev internal bridge call
  /// @param data is not used
  function _bridge(bytes calldata data) internal override {
    uint256 sushiBalance = sushi.balanceOf(address(this));

    sushi.approve(bridgeAddr, sushiBalance);
    IxDaiBridge(bridgeAddr).relayTokens(address(sushi), minichef, sushiBalance);
    emit BridgedSushi(minichef, sushiBalance);
  }
}
