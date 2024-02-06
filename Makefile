# Define shell
SHELL := /bin/bash

RPC_URL ?= "https://sepolia.infura.io/v3/7caeba2e31cf4da5affd871a3cbeae31"
ETHERSCAN_API_KEY ?= "8NHTDUAHZKTP7R7ANT9MSHCC5X8CXQZGIP"
INFURA_PROJECT_ID ?= "7caeba2e31cf4da5affd871a3cbeae31"

# Default target
all: ./deployments/sepolia/sequencer.keystore

# Install npm and Python dependencies
install_dependencies:
	npm install
	pip install pytoml

./wallets.json: install_dependencies
	node wallets.js | tee wallets.json > ./wallets.json

# Create wallet, address mappings, and set admin address
./deployment/deploy_parameters.json: ./wallets.json
	python3 ./scripts/map_addresses.py ./wallets.json > ./deployment/deploy_parameters.json

deposit: ./deployment/deploy_parameters.json
	@read -p "Deposit some sepolia ETH to $(shell jq -r '.admin' ./deployment/deploy_parameters.json) and press enter to continue"

# Update .env file with new deployer mnemonic
update_env: deposit
	if [ ! -f .env ]; then cp .env.example .env; fi
	$(eval NEW_PRIV_KEY := $(shell jq -r '.["Deployment Address"].mnemonic' wallets.json))
	sed -i "s/MNEMONIC=.*/MNEMONIC=\"$(NEW_PRIV_KEY)\"/" .env

./output/deploy_cdk_validium.log: update_env
	npx hardhat run deployment/2_deployCDKValidiumDeployer.js --network sepolia > ./output/deploy_cdk_validium.log
	cat ./output/deploy_cdk_validium.log
	sleep 60

./output/verify_cdk_validium_deployer.log: ./output/deploy_cdk_validium.log
	npx hardhat run deployment/verifyCDKValidiumDeployer.js --network sepolia > ./output/verify_cdk_validium_deployer.log
	cat ./output/verify_cdk_validium_deployer.log

./output/prepare_testnet.log: ./output/verify_cdk_validium_deployer.log
	npx hardhat run deployment/testnet/prepareTestnet.js --network sepolia > ./output/prepare_testnet.log
	cat ./output/prepare_testnet.log

./output/create_genesis.log: ./output/prepare_testnet.log
	node deployment/1_createGenesis.js > ./output/create_genesis.log
	cat ./output/create_genesis.log

./output/deploy_contracts.log: ./output/create_genesis.log
	npx hardhat run deployment/3_deployContracts.js --network sepolia > ./output/deploy_contracts.log
	cat ./output/deploy_contracts.log

.openzeppelin/sepolia.json: ./output/deploy_contracts.log
	npm run saveDeployment:sepolia

./deployments/sepolia: .openzeppelin/sepolia.json
	mkdir -p deployments/sepolia
	cp -r deployment/deploy_*.json deployments/sepolia
	cp .openzeppelin/sepolia.json deployments/sepolia
	cp deployment/genesis.json deployments/sepolia/genesis.original.json

./output/verify_cdk_validium.log: ./deployments/sepolia
	# https://forum.openzeppelin.com/t/proxyadmin-verification-error/32421/4
	# https://github.com/OpenZeppelin/openzeppelin-upgrades/issues/674
	npm run verify:CDKValidium:sepolia > ./output/verify_cdk_validium.log
	cat ./output/verify_cdk_validium.log

# Update genesis with l1config object

./deployments/sepolia/genesis.json: ./output/verify_cdk_validium.log
	@python3 ./scripts/update_gen.py > ./deployments/sepolia/genesis.json
	@echo "Created ./deployments/sepolia/genesis.json"

./deployment/dac.config.toml: ./deployments/sepolia/genesis.json
	@python3 ./scripts/toml_config.py
	@echo "Created ./deployment/dac.config.toml"
	@echo "Created ./deployment/bridge.config.toml"
	@echo "Created ./deployment/node.config.toml"

./deployments/sepolia/sequencer.keystore: ./deployment/dac.config.toml
	@jq '.["Trusted aggregator"].keystore' wallets.json > deployments/sepolia/aggregator.keystore
	@jq '.["Trusted sequencer"].keystore' wallets.json > deployments/sepolia/sequencer.keystore
	@echo Created ./deployments/sepolia/aggregator.keystore
	@echo Created ./deployments/sepolia/sequencer.keystore

# Clean up targets (if necessary)
clean:
	@rm -rf \
		deployment/bridge.config.toml \
		deployment/dac.config.toml \
		deployment/node.config.toml \
		deployment/deploy_ongoing.json \
		new_genesis.json \
		wallets.json \
		deployment/deploy_parameters.json \
		./deployments/sepolia/genesis.json \
		.openzeppelin/sepolia.json \
		./deployments/sepolia \
		./output \


lastlog:
	cat ./output/deploy_cdk_validium.log
	cat ./output/verify_cdk_validium_deployer.log
	cat ./output/prepare_testnet.log
	cat ./output/create_genesis.log
	cat ./output/deploy_contracts.log
	cat ./output/verify_cdk_validium.log

.PHONY: all install_dependencies update_env clean deposit lastlog
