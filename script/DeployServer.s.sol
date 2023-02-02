// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import "utils/Constants.sol";
import "chefs/servers/DummyToken.sol";
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

    DummyToken dummyToken;
    address server;
    //deployPolygonServer(); - using old
    //deployCeloServer(); - using old
    //deployGnosisServer(); - using old

    server = deployArbitrumOneServer();

    /*server = deployArbitrumNovaServer();
    dummyToken = new DummyToken("Nova Dummy Token", "NOVADUMMY");
    dummyToken.transfer(server, 1);

    server = deployBttcServer();
    dummyToken = new DummyToken("Bttc Dummy Token", "BTTCDUMMY");
    dummyToken.transfer(server, 1);

    server = deployBobaServer();
    dummyToken = new DummyToken("Boba Dummy Token", "BOBADUMMY");
    dummyToken.transfer(server, 1);

    server = deployBscServer();
    dummyToken = new DummyToken("Bsc Dummy Token", "BSCDUMMY");
    dummyToken.transfer(server, 1);

    server = deployKavaServer();
    dummyToken = new DummyToken("Kava Dummy Token", "KAVADUMMY");
    dummyToken.transfer(server, 1);

    server = deployMetisServer();
    dummyToken = new DummyToken("Metis Dummy Token", "METISDUMMY");
    dummyToken.transfer(server, 1);

    server = deployOptimismServer();
    dummyToken = new DummyToken("OP Dummy Token", "OPDUMMY");
    dummyToken.transfer(server, 1);
    */

    // EOA servers below
    //server = deployAvalancheServer();
    //server = deployFantomServer();
    //server = deployFuseServer();
    //server = deployMoonbeamServer();
    //server = deployMoonriverServer();
    //server = deployTelosServer();
    vm.stopBroadcast();
  }

  // indiviudal deployment functions for each deployed server
  // configured for individual network
  function deployArbitrumOneServer() public returns (address) {
    address minichef = constants.getAddress("arbitrum.minichef");
    address routerAddr = 0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef;
    address gatewayAddr = 0xa3A7B6F88361F48403514059F1F16C8E78d60EeC;
    uint256 pid = 350;

    ArbitrumServer arbiServer = new ArbitrumServer(pid, minichef, routerAddr, gatewayAddr, operator);
    arbiServer.transferOwnership(owner);
    return address(arbiServer);
  }

  function deployArbitrumNovaServer() public returns (address) {
    address minichef = constants.getAddress("nova.minichef");
    address routerAddr = 0xC840838Bc438d73C16c2f8b22D2Ce3669963cD48;
    address gatewayAddr = 0xB2535b988dcE19f9D71dfB22dB6da744aCac21bf;
    uint256 pid = 355;

    ArbitrumServer novaServer = new ArbitrumServer(pid, minichef, routerAddr, gatewayAddr, operator);
    novaServer.transferOwnership(owner);
    return address(novaServer);
  }

  function deployAvalancheServer() public returns (address) {
    address minichef = constants.getAddress("avalanche.minichef");
    uint256 pid = 361;

    EoaServer avaxServer = new EoaServer(pid, minichef, operator);
    avaxServer.transferOwnership(owner);
    return address(avaxServer);
  }

  function deployBttcServer() public returns (address) {
    address minichef = constants.getAddress("bttc.minichef");
    address posManager = 0xD06029b23e9d4CD24bAd01d436837Fa02B8f0dd9;
    address ercBridge = 0x89a93F94C0a3f388930C4A568430F5e8fFFfd3eC;
    uint256 pid = 356;

    PosServer bttcServer = new PosServer(pid, minichef, posManager, ercBridge);
    bttcServer.transferOwnership(owner);
    return address(bttcServer);
  }

  function deployBobaServer() public returns (address) {
    address minichef = constants.getAddress("boba.minichef");
    address bridgeAddr = 0xdc1664458d2f0B6090bEa60A8793A4E66c2F1c00;
    uint256 pid = 357;

    BobaGatewayServer bobaServer = new BobaGatewayServer(pid, minichef, bridgeAddr, operator);
    bobaServer.transferOwnership(owner);
    return address(bobaServer);
  }

  function deployBscServer() public returns (address) {
    address minichef = constants.getAddress("bsc.minichef");
    uint256 chainId = 56;
    uint256 pid = 358;

    MultichainServer bscServer = new MultichainServer(pid, minichef, chainId, anyswapRouter);
    bscServer.transferOwnership(owner);
    return address(bscServer);
  }

  function deployCeloServer() public returns (address) {
    address minichef = constants.getAddress("celo.minichef");
    address opticsBridgeV2 = 0x4fc16De11deAc71E8b2Db539d82d93BE4b486892;
    uint256 pid = 345;

    CeloOpticsServer celoServer = new CeloOpticsServer(pid, minichef, opticsBridgeV2);
    celoServer.transferOwnership(owner);
    return address(celoServer);
  }

  function deployFantomServer() public returns (address) {
    address minichef = constants.getAddress("fantom.minichef");
    uint256 pid = 349;

    EoaServer fantomServer = new EoaServer(pid, minichef, operator);
    fantomServer.transferOwnership(owner);
    return address(fantomServer);
  }

  function deployFuseServer() public returns (address) {
    address minichef = constants.getAddress("fuse.minichef");
    uint256 pid = 366;

    EoaServer fuseServer = new EoaServer(pid, minichef, operator);
    fuseServer.transferOwnership(owner);
    return address(fuseServer);
  }

  function deployGnosisServer() public returns (address) {
    address minichef = constants.getAddress("gnosis.minichef");
    address omniBridge = 0x88ad09518695c6c3712AC10a214bE5109a655671;
    uint256 pid = 346;

    GnosisOmniServer gnosisServer = new GnosisOmniServer(pid, minichef, omniBridge);
    gnosisServer.transferOwnership(owner);
    return address(gnosisServer);
  }

  function deployKavaServer() public returns (address) {
    address minichef = constants.getAddress("kava.minichef");
    uint256 chainId = 2222;
    uint256 pid = 359;

    MultichainServer kavaServer = new MultichainServer(pid, minichef, chainId, anyswapRouter);
    kavaServer.transferOwnership(owner);
    return address(kavaServer);
  }

  function deployMetisServer() public returns (address) {
    address minichef = constants.getAddress("metis.minichef");
    address bridgeAddr = 0x3980c9ed79d2c191A89E02Fa3529C60eD6e9c04b;
    uint256 pid = 360;

    MetisServer metisServer = new MetisServer(pid, minichef, bridgeAddr, operator);
    metisServer.transferOwnership(owner);
    return address(metisServer);
  }

  function deployMoonbeamServer() public returns (address) {
    address minichef = constants.getAddress("moonbeam.minichef");
    uint256 pid = 364;

    EoaServer moonbeamServer = new EoaServer(pid, minichef, operator);
    moonbeamServer.transferOwnership(owner);
    return address(moonbeamServer);
  }

  function deployMoonriverServer() public returns (address) {
    address minichef = constants.getAddress("moonriver.minichef");
    uint256 pid = 365;

    EoaServer moonriverServer = new EoaServer(pid, minichef, operator);
    moonriverServer.transferOwnership(owner);
    return address(moonriverServer);
  }

  function deployOptimismServer() public returns (address) {
    address minichef = constants.getAddress("optimism.minichef");
    address bridgeAddr = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;
    uint256 pid = 361;

    OptimismServer optimismServer = new OptimismServer(pid, minichef, bridgeAddr, operator);
    optimismServer.transferOwnership(owner);
    return address(optimismServer);
  }

  function deployPolygonServer() public returns (address) {
    address minichef = constants.getAddress("polygon.minichef");
    address posManager = 0xA0c68C638235ee32657e8f720a23ceC1bFc77C77;
    address ercBridge = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;
    uint256 pid = 344;

    PosServer polygonServer = new PosServer(pid, minichef, posManager, ercBridge);
    polygonServer.transferOwnership(owner);
    return address(polygonServer);
  }

  function deployTelosServer() public returns (address) {
    address minichef = constants.getAddress("telos.minichef");
    uint256 pid = 366;

    EoaServer telosServer = new EoaServer(pid, minichef, operator);
    telosServer.transferOwnership(owner);
    return address(telosServer);
  }
}
