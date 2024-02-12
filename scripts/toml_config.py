import json
import pytoml as toml

# Paths to the files
deploy_output_file = 'deployment/deploy_output.json'
node_config_toml = 'deployment/node.config.example.toml'
bridge_config_toml = 'deployment/bridge.config.example.toml'
dac_config_toml = 'deployment/dac.config.example.toml'

# Load the JSON file to get the trustedAggregator value
with open(deploy_output_file, 'r') as file:
    deploy_output = json.load(file)
trusted_aggregator = deploy_output.get('trustedAggregator')
deployerAddress = deploy_output.get('deployerAddress')
trustedSequencerURL = deploy_output.get('trustedSequencerURL')
l2ChainID = deploy_output.get('chainID')
genBlockNumber = deploy_output.get('deploymentBlockNumber')
polygonZkEVMBridgeAddress = deploy_output.get('polygonZkEVMBridgeAddress')
polygonZkEVMGlobalExitRootAddress = deploy_output.get('polygonZkEVMGlobalExitRootAddress')

cdkValidiumAddress = deploy_output.get('cdkValidiumAddress')
cdkDataCommitteeContract = deploy_output.get('cdkDataCommitteeContract')

# Load node.config.example.toml file
with open(node_config_toml, 'r') as file:
    node_toml_config = toml.load(file)

# Load bridge.config.example.toml file
with open(bridge_config_toml, 'r') as file:
    bridge_toml_config = toml.load(file)

# Load dac.config.example.toml file
with open(dac_config_toml, 'r') as file:
    dac_toml_config = toml.load(file)

# Update config values in node config toml
if trusted_aggregator and 'Aggregator' in node_toml_config:
    node_toml_config['Aggregator']['SenderAddress'] = trusted_aggregator

if deployerAddress and 'SequenceSender' in node_toml_config:
    node_toml_config['SequenceSender']['L2Coinbase'] = deployerAddress

if trustedSequencerURL and 'Synchronizer' in node_toml_config:
    node_toml_config['Synchronizer']['TrustedSequencerURL'] = trustedSequencerURL

if trustedSequencerURL and 'RPC' in node_toml_config:
    node_toml_config['RPC']['SequencerNodeURI'] = trustedSequencerURL

if l2ChainID and 'Etherman' in node_toml_config:
    node_toml_config['Etherman']['L2ChainID'] = l2ChainID
    bridge_toml_config['Etherman']['L2ChainID'] = l2ChainID

# Update config values in bridge toml
if genBlockNumber and 'NetworkConfig' in bridge_toml_config:
    bridge_toml_config['NetworkConfig']['GenBlockNumber'] = genBlockNumber

if polygonZkEVMBridgeAddress and 'NetworkConfig' in bridge_toml_config:
    bridge_toml_config['NetworkConfig']['PolygonBridgeAddress'] = polygonZkEVMBridgeAddress

if polygonZkEVMGlobalExitRootAddress and 'NetworkConfig' in bridge_toml_config:
    bridge_toml_config['NetworkConfig']['PolygonZkEVMGlobalExitRootAddress'] = polygonZkEVMGlobalExitRootAddress

if polygonZkEVMGlobalExitRootAddress and 'NetworkConfig' in bridge_toml_config:
    bridge_toml_config['NetworkConfig']['L2PolygonBridgeAddresses'] = polygonZkEVMGlobalExitRootAddress

# Update dac toml
if cdkValidiumAddress and 'L1' in dac_toml_config:
    dac_toml_config['L1']['CDKValidiumAddress'] = cdkValidiumAddress
 
if cdkDataCommitteeContract and 'L1' in dac_toml_config:
    dac_toml_config['L1']['DataCommitteeAddress'] = cdkDataCommitteeContract
 
# Write the updated TOML data back to the file
with open('deployment/node.config.toml', 'w') as file:
    toml.dump(node_toml_config, file)

with open('deployment/bridge.config.toml', 'w') as file:
    toml.dump(bridge_toml_config, file)

with open('deployment/dac.config.toml', 'w') as file:
    toml.dump(dac_toml_config, file)
