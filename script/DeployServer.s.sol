// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "utils/Constants.sol";
import "chefs/servers/implementations/ArbitrumServer.sol";
import "chefs/servers/implementations/PosServer.sol";
import "chefs/servers/implementations/BobaGatewayServer.sol";
import "chefs/servers/implementations/MultichainServer.sol";


contract DeployServer is Script {
  Constants internal constants;
  address owner = vm.envAddress("OWNER_ADDRESS");
  address operator = vm.envAddress("OPERATOR_ADDRESS");

  function run() external {
    constants = new Constants();

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    // deploys entire set of servers, unless commented out
    deployPolygonServer();
    deployBttcServer();
    deployBobaServer();
    deployBscServer();
  }



  // indiviudal deployment functions for each deployed server
  // configured for individual network
  function deployArbitrumOneServer() public {
    address minichef = constants.getAddress("arbitrum.minichef");
    address bridgeAddr = 0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef;
    uint256 pid = 350;

    ArbitrumServer arbiServer = new ArbitrumServer(pid, minichef, bridgeAddr, operator);
    arbiServer.transferOwnership(owner);
  }

  function deployArbitrumNovaServer() public {
    address minichef = constants.getAddress("nova.minichef");
    address bridgeAddr = 0xC840838Bc438d73C16c2f8b22D2Ce3669963cD48;
    uint256 pid = 356;
    
    ArbitrumServer novaServer = new ArbitrumServer(pid, minichef, bridgeAddr, operator);
    novaServer.transferOwnership(owner);
  }

  function deployBttcServer() public {
    address minichef = constants.getAddress("bttc.minichef");
    address posManager = 0xD06029b23e9d4CD24bAd01d436837Fa02B8f0dd9;
    address ercBridge = 0x89a93F94C0a3f388930C4A568430F5e8fFFfd3eC;
    uint256 pid = 355;

    PosServer bttcServer = new PosServer(pid, minichef, posManager, ercBridge);
    bttcServer.transferOwnership(owner);
  }

  function deployBobaServer() public {
    address minichef = constants.getAddress("boba.minichef");
    address bridgeAddr = 0xdc1664458d2f0B6090bEa60A8793A4E66c2F1c00;
    uint256 pid = 356;

    BobaGatewayServer bobaServer = new BobaGatewayServer(pid, minichef, bridgeAddr, operator);
    bobaServer.transferOwnership(owner);
  }

  function deployBscServer() public {
    address minichef = constants.getAddress("bsc.minichef");
    address router = 0x765277EebeCA2e31912C9946eAe1021199B39C61;
    uint256 chainId = 56;
    uint256 pid = 357;

    MultichainServer bscServer = new MultichainServer(pid, minichef, chainId, router);
    bscServer.transferOwnership(owner);
  }







  function deployPolygonServer() public {
    address minichef = constants.getAddress("polygon.minichef");
    address posManager = 0xA0c68C638235ee32657e8f720a23ceC1bFc77C77;
    address ercBridge = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;
    uint256 pid = 344;

    PosServer polygonServer = new PosServer(pid, minichef, posManager, ercBridge);
    polygonServer.transferOwnership(owner);
  }


}

