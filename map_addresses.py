import json
import os

def parse_input(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)

    # Construct the output dictionary
    output_data = {
        "realVerifier": True,
        "trustedSequencerURL": "http://cdk-validium-json-rpc:8123",
        "networkName": "cdk-vc",
        "version": "0.0.2",
        "trustedSequencer": data["Trusted sequencer"]["Address"],
        "chainID": 4321,
        "trustedAggregator": data["Trusted aggregator"]["Address"],
        "trustedAggregatorTimeout": 604799,
        "pendingStateTimeout": 604799,
        "forkID": 6,
        "admin": data["Deployment Address"]["Address"],
        "cdkValidiumOwner": data["Deployment Address"]["Address"],
        "timelockAddress": data["Deployment Address"]["Address"],
        "minDelayTimelock": 10,
        "salt": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "initialCDKValidiumDeployerOwner": data["Deployment Address"]["Address"],
        "cdkValidiumDeployerAddress": "",
        "maticTokenAddress": "",
        "setupEmptyCommittee": True,
        "committeeTimelock": False
    }

    return output_data

# Replace 'input.json' with the path to your JSON file
output_data = parse_input('wallets.json')

# Convert the output to JSON format
output_json = json.dumps(output_data, indent=2)

# Print the JSON data
print(output_json)

full_path = os.path.join('deployment', "deploy_parameters.json")
with open(full_path, "w") as file:
    file.write(output_json)

print(f"Output written to {full_path}")

