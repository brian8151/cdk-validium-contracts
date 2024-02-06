#!/bin/bash

# install toml config 
# pip install pytoml

# cp .env.example .env
# cp deploy_parameters.json.example deploy_parameters.json
#

# Install dependencies
npm install

# Create wallet and address mappings
node wallets.js | tee wallets.json
python3 map_addresses.py
admin_address=$(jq -r '.admin' ./deployment/deploy_parameters.json)

# Manually send ETH to deployer address
echo "#########################"
echo "Send ETH to $admin_address"
echo "#########################"

# Create base environment file from the example
cp .env.example .env

# update .env file with new deployer mnemonic
new_prv_key=$(jq -r '.["Deployment Address"].mnemonic' wallets.json)
sed -i "s/MNEMONIC=.*/MNEMONIC=\"$new_prv_key\"/" .env

# Deposit ETH to L1 wallet (see first wallet in wallets.json)
#
read -p "Deposit some sepolia ETH to $admin_address and press enter to continue"

npx hardhat run deployment/2_deployCDKValidiumDeployer.js --network sepolia

npx hardhat run deployment/verifyCDKValidiumDeployer.js --network sepolia

# this is generating the genesis
npx hardhat run deployment/testnet/prepareTestnet.js --network sepolia
node deployment/1_createGenesis.js && npx hardhat run deployment/3_deployContracts.js --network sepolia && npm run saveDeployment:sepolia

mkdir -p deployments/sepolia && cp -r deployment/deploy_*.json deployments/sepolia && cp .openzeppelin/sepolia.json deployments/sepolia && cp deployment/genesis.json deployments/sepolia/genesis.original.json

npm run verify:CDKValidium:sepolia

# update genesis with l1config object
python3 update_gen.py

#update node, dac configs
python3 toml_config.py

# create keystores
jq '.["Trusted aggregator"].keystore' wallets.json > deployments/sepolia/aggregator.keystore
jq '.["Trusted sequencer"].keystore' wallets.json > deployments/sepolia/sequencer.keystore
