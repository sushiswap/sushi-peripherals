// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "utils/Constants.sol";
import "chefs/servers/implementations/ArbitrumServer.sol";
import "chefs/servers/implementations/PosServer.sol";
import "chefs/servers/implementations/BobaGatewayServer.sol";
import "chefs/servers/implementations/MultichainServer.sol";
import "chefs/servers/implementations/CeloOpticsServer.sol";
import "chefs/servers/implementations/GnosisOmniServer.sol";
import "chefs/servers/implementations/MetisServer.sol";
import "chefs/servers/implementations/OptimismServer.sol";
import "chefs/servers/implementations/EoaServer.sol";


contract DeployServer is Script {
  Constants internal constants;
  address owner = vm.envAddress("OWNER_ADDRESS");
  address operator = vm.envAddress("OPERATOR_ADDRESS");
  address anyswapRouter = 0x765277EebeCA2e31912C9946eAe1021199B39C61;

  function run() external {
    constants = new Constants();

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    // deploys entire set of servers, unless commented out
    deployPolygonServer();
    deployBttcServer();
    deployBobaServer();
    deployBscServer();
    deployCeloServer();
    deployGnosisServer();
    deployMetisServer();
    deployOptimismServer();
    // EOA servers below
    deployAvalancheServer();
    deployFantomServer();
    deployFuseServer();
    deployMoonbeamServer();
    deployMoonriverServer();
    deployTelosServer();
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
  
  function deployAvalancheServer() public {
    address minichef = constants.getAddress("avalanche.minichef");
    uint256 pid = 361;

    EoaServer avaxServer = new EoaServer(pid, minichef, operator);
    avaxServer.transferOwnership(owner);
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
    uint256 chainId = 56;
    uint256 pid = 357;

    MultichainServer bscServer = new MultichainServer(pid, minichef, chainId, anyswapRouter);
    bscServer.transferOwnership(owner);
  }

  function deployCeloServer() public {
    address minichef = constants.getAddress("celo.minichef");
    address opticsBridgeV2 = 0x4fc16De11deAc71E8b2Db539d82d93BE4b486892;
    uint256 pid = 345;

    CeloOpticsServer celoServer = new CeloOpticsServer(pid, minichef, opticsBridgeV2);
    celoServer.transferOwnership(owner);
  }

  function deployFantomServer() public {
    address minichef = constants.getAddress("fantom.minichef");
    uint256 pid = 349;

    EoaServer fantomServer = new EoaServer(pid, minichef, operator);
    fantomServer.transferOwnership(owner);
  }

  function deployFuseServer() public {
    address minichef = constants.getAddress("fuse.minichef");
    uint256 pid = 363;

    EoaServer fuseServer = new EoaServer(pid, minichef, operator);
    fuseServer.transferOwnership(owner);
  }

  function deployGnosisServer() public {
    address minichef = constants.getAddress("gnosis.minichef");
    address omniBridge = 0x88ad09518695c6c3712AC10a214bE5109a655671;
    uint256 pid = 346;

    GnosisOmniServer gnosisServer = new GnosisOmniServer(pid, minichef, omniBridge);
    gnosisServer.transferOwnership(owner);
  }

  function deployKavaServer() public {
    address minichef = constants.getAddress("kava.minichef");
    uint256 chainId = 2222;
    uint256 pid = 358;

    MultichainServer kavaServer = new MultichainServer(pid, minichef, chainId, anyswapRouter);
    kavaServer.transferOwnership(owner);
  }

  function deployMetisServer() public {
    address minichef = constants.getAddress("metis.minichef");
    address bridgeAddr = 0x3980c9ed79d2c191A89E02Fa3529C60eD6e9c04b;
    uint256 pid = 359;
    
    MetisServer metisServer = new MetisServer(pid, minichef, bridgeAddr, operator);
    metisServer.transferOwnership(owner);
  }

  function deployMoonbeamServer() public {
    address minichef = constants.getAddress("moonbeam.minichef");
    uint256 pid = 364;

    EoaServer moonbeamServer = new EoaServer(pid, minichef, operator);
    moonbeamServer.transferOwnership(owner);
  }

  function deployMoonriverServer() public {
    address minichef = constants.getAddress("moonriver.minichef");
    uint256 pid = 365;

    EoaServer moonriverServer = new EoaServer(pid, minichef, operator);
    moonriverServer.transferOwnership(owner);
  }

  function deployOptimismServer() public {
    address minichef = constants.getAddress("optimism.minichef");
    address bridgeAddr = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;
    uint256 pid = 360;

    OptimismServer optimismServer = new OptimismServer(pid, minichef, bridgeAddr, operator);
    optimismServer.transferOwnership(owner);
  }

  function deployPolygonServer() public {
    address minichef = constants.getAddress("polygon.minichef");
    address posManager = 0xA0c68C638235ee32657e8f720a23ceC1bFc77C77;
    address ercBridge = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;
    uint256 pid = 344;

    PosServer polygonServer = new PosServer(pid, minichef, posManager, ercBridge);
    polygonServer.transferOwnership(owner);
  }

  function deployTelosServer() public {
    address minichef = constants.getAddress("telos.minichef");
    uint256 pid = 366;

    EoaServer telosServer = new EoaServer(pid, minichef, operator);
    telosServer.transferOwnership(owner);
  }
}

