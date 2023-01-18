-include .env.defaults
-include .env
export

SCRIPT_DIR = ./script
TEST_DIR = ./test

build:
	forge build
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
remappings:
	forge remappings > remappings.txt

playground: FOUNDRY_TEST:=playground
playground:
	forge test --match-path playground/Playground.t.sol -vv
playground-trace: FOUNDRY_TEST:=playground
playground-trace:
	forge test --match-path playground/Playground.t.sol -vvvv --gas-report

deploy-server:
	forge script ./script/DeployServer.s.sol --broadcast --verify --rpc-url ${MAINNET_RPC_URL}

.PHONY: test playground