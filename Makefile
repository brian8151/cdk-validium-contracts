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
	@echo Creating wallets.json
	@node wallets.js | tee wallets.json

./output/private_key: ./wallets.json
	@jq -r '.["Deployment Address"].PrvKey' wallets.json > ./output/private_key
	@echo "Private key: $$(cat ./output/private_key)"

# Create wallet, address mappings, and set admin address
./output/addresses.json: ./output/private_key
	@echo Creating deploy_parameters.json
	@python3 ./scripts/map_addresses.py ./wallets.json > ./output/addresses.json

./output/admin: ./output/addresses.json
	@jq -r '.admin' ./output/addresses.json > ./output/admin
	@read -p "Deposit some sepolia ETH to $$(cat ./output/admin) and press enter to continue"

# Update .env file with new deployer mnemonic
./.env: ./output/admin
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@jq -r '.["Deployment Address"].mnemonic' wallets.json > ./output/mnemonic
	@sed -i "s/MNEMONIC=.*/MNEMONIC=\"$$(cat ./output/mnemonic)\"/" .env
	@touch .env
	@read -p "Press enter"

./output/addresses_with_cdk_deployer.json: ./.env
	@echo "Deploying CDKValidiumDeployer"
	@npx hardhat run deployment/2_deployCDKValidiumDeployer.js --network sepolia 
	@sleep 60

./output/03_verify_cdk_validium_deployer: ./output/addresses_with_cdk_deployer.json
	@echo "Verifying CDKValidiumDeployer"
	@npx hardhat run deployment/verifyCDKValidiumDeployer.js --network sepolia 
	@touch ./output/03_verify_cdk_validium_deployer

./output/deploy_parameters_with_matic.json: ./output/03_verify_cdk_validium_deployer
	@echo "Preparing testnet"
	@npx hardhat run deployment/testnet/prepareTestnet.js --network sepolia

./deployment/genesis.json: ./output/deploy_parameters_with_matic.json
	@echo "Creating ./deployment/genesis.json"
	@node deployment/1_createGenesis.js 

./deployment/deploy_output.json: ./deployment/genesis.json
	@echo "Deploying contracts"
	@rm -f .openzeppelin/sepolia.json deployment/deploy_ongoing.json
	@npx hardhat run deployment/3_deployContracts.js --network sepolia 
	
./output/07_save_deployment: ./deployment/deploy_output.json
	@echo -n "Saving deployment... "
	@npm run saveDeployment:sepolia
	@echo "Done"
	@touch ./output/07_save_deployment

./deployments/sepolia: ./output/07_save_deployment
	@echo "Creating deployments/sepolia"
	@mkdir -p deployments/sepolia
	@cp output/deploy_parameters_with_matic.json deployments/sepolia/deploy_parameters.json
	@cp -r deployment/deploy_*.json deployments/sepolia
	@cp .openzeppelin/sepolia.json deployments/sepolia
	@cp deployment/genesis.json deployments/sepolia/genesis.original.json

./output/08_verify_cdk_validium: ./deployments/sepolia
	@echo "Verifying CDKValidium"
	# https://forum.openzeppelin.com/t/proxyadmin-verification-error/32421/4
	# https://github.com/OpenZeppelin/openzeppelin-upgrades/issues/674
	@npm run verify:CDKValidium:sepolia
	@touch ./output/08_verify_cdk_validium

# Update genesis with l1config object

./deployments/sepolia/genesis.json: ./output/08_verify_cdk_validium
	@echo "Creating ./deployments/sepolia/genesis.json"
	@python3 ./scripts/update_gen.py > ./deployments/sepolia/genesis.json

./deployment/dac.config.toml: ./deployments/sepolia/genesis.json
	@python3 ./scripts/toml_config.py
	@echo "Created ./deployment/dac.config.toml"
	@echo "Created ./deployment/bridge.config.toml"
	@echo "Created ./deployment/node.config.toml"

./deployments/sepolia/sequencer.keystore: ./deployment/dac.config.toml
	@echo "Creating sequencer and aggregator keystores"
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
