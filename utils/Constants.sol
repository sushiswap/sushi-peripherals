// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Vm.sol";

contract Constants {
  mapping(string => address) private addressMap;
  mapping(string => bytes32) private pairCodeHash;
  //byteCodeHash for trident pairs

  string[] private addressKeys;

  constructor() {
    //setAddress("sushiDeployer", )

    // Mainnet
    setAddress("mainnet.bentobox", 0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);
    setAddress("mainnet.weth", 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    setAddress("mainnet.sushi", 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    setAddress("mainnet.usdc", 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    setAddress("mainnet.usdt", 0xdAC17F958D2ee523a2206206994597C13D831ec7);
    setAddress("mainnet.chainlink.usdc.eth", 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4); // usdc/eth
    setAddress("mainnet.chainlink.sushi.eth", 0xe572CeF69f43c2E488b33924AF04BDacE19079cf); // sushi/eth
    setAddress("mainnet.chainlink.usdc", 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6); // usdc/usd
    setAddress("mainnet.oracle.chainlinkV2", 0x00632CFe43d8F9f8E6cD0d39Ffa3D4fa7ec73CFB);
    setAddress("mainnet.whale.sushi", 0xcBE6B83e77cdc011Cc18F6f0Df8444E5783ed982);
    setAddress("mainnet.whale.usdc", 0x55FE002aefF02F77364de339a1292923A15844B8);

    setAddress("mainnet.masterchef", 0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    setAddress("mainnet.masterchefV2", 0xEF0881eC094552b2e128Cf945EF17a6752B4Ec5d);

    setAddress("mainnet.kashiV1.usdc.sushi", 0x263716dEe5b74C5Baed665Cb19c6017e51296fa2);
    setAddress("mainnet.kashiV1.swapperV1", 0x1766733112408b95239aD1951925567CB1203084);
    // Optimism
    setAddress("optimism.bentobox", 0xc35DADB65012eC5796536bD9864eD8773aBc74C4);
    setAddress("optimism.weth", 0x4200000000000000000000000000000000000006);
    setAddress("optimism.usdc", 0x7F5c764cBc14f9669B88837ca1490cCa17c31607);
    setAddress("optimism.usdt", 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58);
    setAddress("optimism.op", 0x4200000000000000000000000000000000000042);
    setAddress("optimism.trident.factory.constant", 0x93395129bd3fcf49d95730D3C2737c17990fF328);
    setAddress("optimism.trident.factory.stable", 0x827179dD56d07A7eeA32e3873493835da2866976);

    // Arbitrum

    // Polygon
    setAddress("polygon.bentobox", 0x0319000133d3AdA02600f0875d2cf03D442C3367);
    setAddress("polygon.wmatic", 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    setAddress("polygon.usdc", 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    setAddress("polygon.usdt", 0xc2132D05D31c914a87C6611C10748AEb04B58e8F);

    // Fantom

    // MiniChefs
    setAddress("arbitrum.minichef", 0xF4d73326C13a4Fc5FD7A064217e12780e9Bd62c3);
    setAddress("nova.minichef", 0xC09756432dAD2FF50B2D40618f7B04546DD20043);
    setAddress("avalanche.minichef", 0xe11252176CEDd4a493Aec9767192C06A04A6B04F);
    setAddress("bttc.minichef", 0xC09756432dAD2FF50B2D40618f7B04546DD20043);
    setAddress("boba.minichef", 0x75f52766A6a23F736edEfCD69dfBE6153a48c3F3);
    setAddress("bsc.minichef", 0x5219C5E32b9FFf87F29d5A833832c29134464aaa);
    setAddress("celo.minichef", 0x8084936982D089130e001b470eDf58faCA445008);
    setAddress("fantom.minichef", 0xf731202A3cf7EfA9368C2d7bD613926f7A144dB5);
    setAddress("fuse.minichef", 0x182CD0C6F1FaEc0aED2eA83cd0e160c8Bd4cb063);
    setAddress("gnosis.minichef", 0xdDCbf776dF3dE60163066A5ddDF2277cB445E0F3);
    setAddress("kava.minichef", 0xf731202A3cf7EfA9368C2d7bD613926f7A144dB5);
    setAddress("metis.minichef", 0x1334c8e873E1cae8467156e2A81d1C8b566B2da1);
    setAddress("optimism.minichef", 0xB25157bF349295a7Cd31D1751973f426182070D6);
    //setAddress("moonbeam.minichef", );
    setAddress("moonriver.minichef", 0x3dB01570D97631f69bbb0ba39796865456Cf89A5);
    //setAddress("optimism.minichef", );
    setAddress("polygon.minichef", 0x0769fd68dFb93167989C6f7254cd0D766Fb2841F);
    //setAddress("telos.minichef", );

    pairCodeHash["mainnet.sushiV2"] = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
    // bytescodehashes for trident pool types
  }

  function initAddressLabels(Vm vm) public {
    for (uint256 i = 0; i < addressKeys.length; i++) {
      string memory key = addressKeys[i];
      vm.label(addressMap[key], key);
    }
  }

  function setAddress(string memory key, address value) public {
    require(addressMap[key] == address(0), string.concat("address already exists: ", key));
    addressMap[key] = value;
    addressKeys.push(key);
  }

  function getAddress(string calldata key) public view returns (address) {
    require(addressMap[key] != address(0), string.concat("address not found: ", key));
    return addressMap[key];
  }

  function getPairCodeHash(string calldata key) public view returns (bytes32) {
    require(pairCodeHash[key] != "", string.concat("pairCodeHash not found: ", key));
    return pairCodeHash[key];
  }
}
