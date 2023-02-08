// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "auths/OwnedMulticall3.sol";

contract DeployOwnedMulticall is Script {
  address owner = vm.envAddress("OWNER_ADDRESS");

  //address owner = vm.envAddress("OPERATOR_ADDRESS");

  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);
    new OwnedMulticall3(owner);
    vm.stopBroadcast();
  }
}
