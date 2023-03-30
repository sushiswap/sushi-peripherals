-include .env.defaults
-include .env
export

SCRIPT_DIR = ./script
TEST_DIR = ./test

build:
	forge build --skip .old.sol
rebuild: clean build
install: init
init:
	git submodule update --init --recursive
	git update-index --assume-unchanged playground/*
	forge install
test:
	forge test -vv
test-gas-report:
	forge test -vv --gas-report
trace:
	forge test -vvvv
deploy-servers:
	forge script ./script/DeployServer.s.sol --broadcast --slow --optimize --optimizer-runs 999999 --names --verify --rpc-url ${MAINNET_RPC_URL}
deploy-ownedMulticall:
	forge script ./script/DeployOwnedMulticall.s.sol --broadcast --slow --optimize --optimizer-runs 999999 --names --verify --rpc-url ${MAINNET_RPC_URL}

playground: FOUNDRY_TEST:=playground
playground:
	forge test --match-path playground/Playground.t.sol -vv
playground-trace: FOUNDRY_TEST:=playground
playground-trace:
	forge test --match-path playground/Playground.t.sol -vvvv --gas-report

multi-build:
	./tools/multibuild.sh 0.5.0 0.8.15

.PHONY: test playground