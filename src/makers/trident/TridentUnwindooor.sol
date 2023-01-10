// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solmate/auth/Owned.sol";
import "interfaces/IPool.sol";
import "interfaces/Auth.sol";

/// @notice Contract for breaking down LP positions
/// @dev Built in mind for Trident LP positions (stable and constant product)
contract TridentUnwindooor is Auth {
  bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

  error SlippageProtection();
  error TransferFailed();

  constructor(
    address _owner,
    address user
  ) Auth(_owner, user) {}

  // Unwind pairs into a single token
  /// @dev burns pairs and unwinds position into one of the two tokens
  function burnSinglePairs(
    address[] calldata pairs,
    uint256[] calldata amounts,
    bool[] calldata keepTokens0,
    uint256[] calldata minimumOuts
  ) external onlyTrusted {
    for (uint256 i = 0; i < pairs.length; i++) {
      IPool pair = IPool(pairs[i]);
      _safeTransfer(address(pair), address(pair), amounts[i]);

      bytes memory burnData;
      if (keepTokens0[i]) {
        burnData = abi.encode(pair.token0(), address(this), true);
      } else {
        burnData = abi.encode(pair.token1(), address(this), true);
      }

      uint256 amountOut = pair.burnSingle(burnData);
      if (amountOut < minimumOuts[i]) revert SlippageProtection();
    }
  }

  // Unwind pairs into token0 and token1
  /// @dev burns pairs and unwinds position into both tokens
  function burnPairs(
    address[] calldata pairs,
    uint256[] calldata amounts,
    uint256[] calldata minimumOut0,
    uint256[] calldata minimumOut1
  ) external onlyTrusted {
    for (uint256 i = 0; i < pairs.length; i++) {
      IPool pair = IPool(pairs[i]);
      _safeTransfer(address(pair), address(pair), amounts[i]);
      bytes memory burnData = abi.encode(address(this), true);
      
      IPool.TokenAmount[] memory withdrawnAmounts = pair.burn(burnData);
      if (withdrawnAmounts[0].amount < minimumOut0[i] || withdrawnAmounts[1].amount < minimumOut1[i]) revert SlippageProtection();
    }
  }

  function _safeTransfer(address token, address to, uint value) internal {
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR, to, value));
    if (!success || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
  }
}