// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "utils/Constants.sol";
import "chefs/servers/implementations/ArbitrumServer.sol";

contract DeployServer is Script {
  Constants internal constants;

  function run() external {
    constants = new Constants();

    address masterChefV2 = constants.getAddress("mainnet.masterchefV2");
    uint256 pid = 350;
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    new ArbitrumServer(pid, masterChefV2);
  }
}

