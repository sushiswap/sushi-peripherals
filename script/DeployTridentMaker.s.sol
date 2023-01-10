// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "makers/trident/TridentMaker.sol";

contract DeployTridentMaker is Script {
  function run() external {
    address owner = vm.envAddress("OWNER_ADDRESS");
    address user = vm.envAddress("USER_ADDRESS");
    address bentobox = vm.envAddress("BENTOBOX_ADDRESS");
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    TridentMaker maker = new TridentMaker(owner, user, bentobox);
  }
}