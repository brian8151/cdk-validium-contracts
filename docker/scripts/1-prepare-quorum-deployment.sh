#!/bin/bash
sudo rm -rf docker/gethData/geth_data
rm deployment/deploy_ongoing.json
# manual start quorum 
#DEV_PERIOD=1 docker-compose -f docker/docker-compose.geth.yml up -d geth
sleep 5

node docker/scripts/fund-accounts.js
cp docker/scripts/deploy_parameters_docker.json deployment/deploy_parameters.json
cp docker/scripts/genesis_docker.json deployment/genesis.json
echo "-- hardhat run deployment/quorum/prepareQuorum.js----"
npx hardhat run deployment/quorum/prepareQuorum.js --network localhost
echo "-- hardhat run deployment/2_deployCDKValidiumDeployer.js----"
npx hardhat run deployment/2_deployCDKValidiumDeployer.js --network localhost
echo "-- hardhat run deployment/3_deployContracts.js----"
npx hardhat run deployment/3_deployContracts.js --network localhost
mkdir docker/deploymentOutput
mv deployment/deploy_output.json docker/deploymentOutput

# manual shutdown quorum 
# docker-compose -f docker/docker-compose.geth.yml down

