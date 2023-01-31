# Sushi Peripherals

## Prerequisites
- Foundry
- Make

## Getting Started
Initialize
```sh
make init
```

Copy `.env.example` to `.env` and set the RPCs for deploying contracts, then source `.env`

```sh
cp .env.example .env
source .env
```

Build & Test

```sh
make build
make test
```

## Chefs


## Makers



## Servers

Arbitrum -> ArbitrumServer implementation
Arbitrum Nova -> ArbitrumServer implementation
Avalanche -> EoaServer implementation
BitTorrent -> BitTorrentServer implementation
Boba -> BobaGatewayServer implementation
Bsc -> MultichainServer implementation
Celo -> CeloServer implementation
Fantom -> EoaServer implementation
Fuse -> EoaServer implementation
Gnosis -> GnosisOmniServer implementation
Kava -> MultichainServer implementation
Metis -> MetisServer implementation
MoonBeam -> EoaServer implementation
MoonRiver -> EoaServer implementation
Optimism -> OptimisticServer implementation
Polygon -> PolygonPosServer implementation
Telos -> EoaServer implementation