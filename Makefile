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

./wallets.json:
	@node wallets.js | tee wallets.json > ./wallets.json
	$(eval NEW_PRIV_KEY_HEX := $(shell jq -r '.["Deployment Address"].PrvKey' wallets.json))
	@echo "Private key: $(NEW_PRIV_KEY_HEX)"

# Create wallet, address mappings, and set admin address
./deployment/deploy_parameters.json: ./wallets.json
	python3 ./scripts/map_addresses.py ./wallets.json > ./deployment/deploy_parameters.json

./output/01_deposit: ./deployment/deploy_parameters.json
	@read -p "Deposit some sepolia ETH to $(shell jq -r '.admin' ./deployment/deploy_parameters.json) and press enter to continue"
	touch ./output/01_deposit

# Update .env file with new deployer mnemonic
./.env: ./output/01_deposit
	if [ ! -f .env ]; then cp .env.example .env; fi
	$(eval NEW_PRIV_KEY := $(shell jq -r '.["Deployment Address"].mnemonic' wallets.json))
	@sed -i "s/MNEMONIC=.*/MNEMONIC=\"$(NEW_PRIV_KEY)\"/" .env

./output/02_deploy_cdk_validium: ./.env
	npx hardhat run deployment/2_deployCDKValidiumDeployer.js --network sepolia 
	touch ./output/02_deploy_cdk_validium
	sleep 60

./output/03_verify_cdk_validium_deployer: ./output/02_deploy_cdk_validium
	npx hardhat run deployment/verifyCDKValidiumDeployer.js --network sepolia 
	touch ./output/03_verify_cdk_validium_deployer

./output/04_prepare_testnet: ./output/03_verify_cdk_validium_deployer
	npx hardhat run deployment/testnet/prepareTestnet.js --network sepolia 
	touch ./output/04_prepare_testnet
	# since deoloy_parameters are updated, we need to update the timestamp so we don't have dependency recursion
	python3 scripts/touch.py ./output/deposit ./deployment/deploy_parameters.json
	python3 scripts/touch.py ./deployment/deploy_parameters.json ./wallets.json

./output/05_create_genesis: ./output/04_prepare_testnet
	node deployment/1_createGenesis.js 
	touch ./output/05_create_genesis

./output/06_deploy_contracts: ./output/05_create_genesis
	npx hardhat run deployment/3_deployContracts.js --network sepolia 
	touch ./output/06_deploy_contracts
	
./output/07_save_deployment: ./output/06_deploy_contracts
	@echo -n "Saving deployment to .openzeppelin/sepolia.json... "
	@npm run saveDeployment:sepolia
	@echo "Done"
	touch ./output/07_save_deployment

./deployments/sepolia: 07_save_deployment
	mkdir -p deployments/sepolia
	cp -r deployment/deploy_*.json deployments/sepolia
	cp .openzeppelin/sepolia.json deployments/sepolia
	cp deployment/genesis.json deployments/sepolia/genesis.original.json

./output/08_verify_cdk_validium: ./deployments/sepolia
	# https://forum.openzeppelin.com/t/proxyadmin-verification-error/32421/4
	# https://github.com/OpenZeppelin/openzeppelin-upgrades/issues/674
	npm run verify:CDKValidium:sepolia
	touch ./output/08_verify_cdk_validium

# Update genesis with l1config object

./deployments/sepolia/genesis.json: ./output/08_verify_cdk_validium
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
		./output/*

.PHONY: all install_dependencies update_env clean deposit
