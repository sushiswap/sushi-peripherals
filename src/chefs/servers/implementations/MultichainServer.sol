// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../BaseServer.sol";

interface IMultichainBridge {
    function anySwapOutUnderlying(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;
}

/// @notice Contract bridges Sushi to other chains through multichain anyswap
/// @dev uses multichain router w/ destination chainId and routerAddr set in the constructor
contract MultichainServer is BaseServer {
    address public routerAddr;
    uint256 public immutable chainId;

    constructor(
        uint256 _pid,
        address _minichef,
        uint256 _chainId,
        address _routerAddr
    ) BaseServer(_pid, _minichef) {
        chainId = _chainId;
        routerAddr = _routerAddr;
    }

    /// @dev internal bridge call
    /// @param data is not used
    function _bridge(bytes calldata data) internal override {
        uint256 sushiBalance = sushi.balanceOf(address(this));

        sushi.approve(routerAddr, sushiBalance);
        IMultichainBridge(routerAddr).anySwapOutUnderlying(
            address(sushi),
            minichef,
            sushiBalance,
            chainId
        );

        emit BridgedSushi(minichef, sushiBalance);
    }
}