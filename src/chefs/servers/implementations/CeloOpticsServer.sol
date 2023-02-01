// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../BaseServer.sol";

interface ICeloOpticsBridge {
  function send(
    address _token,
    uint256 _amount,
    uint32 _destination,
    bytes32 _recipient
  ) external;
}

/// @notice Contract bridges Sushi to celo through the Optics bridge
/// @dev uses optics bridge and address needs to be passed through the constructor
contract CeloOpticsServer is BaseServer {
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
    ICeloOpticsBridge(bridgeAddr).send(address(sushi), sushiBalance, 1667591279, bytes32(uint256(uint160(minichef))));
    emit BridgedSushi(minichef, sushiBalance);
  }
}
