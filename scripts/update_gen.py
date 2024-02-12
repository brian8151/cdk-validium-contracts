import json
import os

genesis = {
    "l1Config": {
        "chainId": 0,
        "cdkValidiumAddress": "",
        "maticTokenAddress": "",
        "polygonZkEVMGlobalExitRootAddress": "",
        "cdkDataCommitteeContract": ""
    },
    "genesisBlockNumber": 0,
    "root": "",
    "genesis": []
}

# Load the deploy_output.json file
with open('./deployments/sepolia/deploy_output.json', 'r') as file:
    deploy_output_data = json.load(file)

with open('./deployments/sepolia/genesis.original.json', 'r') as file:
    genesis_data = json.load(file)

# Update the genesis object with values from deploy_output.json and genesis.json
genesis["l1Config"]["chainId"] = deploy_output_data.get("chainID")
genesis["l1Config"]["cdkValidiumAddress"] = deploy_output_data.get("cdkValidiumAddress")
genesis["l1Config"]["maticTokenAddress"] = deploy_output_data.get("maticTokenAddress")
genesis["l1Config"]["polygonZkEVMGlobalExitRootAddress"] = deploy_output_data.get("polygonZkEVMGlobalExitRootAddress")
genesis["l1Config"]["cdkDataCommitteeContract"] = deploy_output_data.get("cdkDataCommitteeContract")
genesis["genesisBlockNumber"] = deploy_output_data.get("deploymentBlockNumber")
genesis["root"] = genesis_data.get("root")
genesis["genesis"] = genesis_data.get("genesis")

output_json = json.dumps(genesis, indent=2)

print(output_json)
