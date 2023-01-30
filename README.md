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
Avalanche -> AvalancheCoreServer implementation
BitTorrent -> BitTorrentServer implementation
Boba -> BobaGatewayServer implementation
Boba Avax -> BobaGatewayServer implementation
Boba BNB -> BobaGatewayServer implementation
Bsc -> MultichainServer implementation
Celo -> CeloServer implementation
Fantom -> MultichainServer implementation
Fuse -> FuseVoltageServer implementation
Gnosis -> GnosisOmniServer implementation
Kava -> MultichainServer implementation
Metis -> MetisServer implementation
MoonRiver -> MultichainServer implementation
Optimism -> OptimisticServer implementation
Polygon -> PolygonPosServer implementation