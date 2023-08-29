<div align="center">
<h1>Polygon CDK Validium Contracts</h1>
<h3>Core Contracts for the Polygon CDK Validium</h3>

</div>

<p align="left">
  The cdk-validium-contracts repository contains the smart contract implementations designed for use with CDK chains configured with Validium.
</p>

<!-- TOC -->

- [Overview of Validium](#overview-of-validium)
- [Important Note](#important-note)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Activate github hook](#activate-github-hook)
- [Install](#install)
- [Run tests](#run-tests)
- [Linting](#linting)
- [Build dockers](#build-dockers)
- [Note](#note)
- [Verify Deployed Smart Contracts](#verify-deployed-smart-contracts)
- [License](#license)

## Overview of Validium

For a full overview of the Polygon CDK Validium, please reference the [CDK documentation](https://wiki.polygon.technology/docs/cdk/).

The CDK Validium solution is made up of several components; start with the [CDK Validium Node](https://github.com/0xPolygon/cdk-validium-node). For quick reference, the complete list of components are outlined below:

| Component                                                                     | Description                                                          |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [CDK Validium Node](https://github.com/0xPolygon/cdk-validium-node)           | Node implementation for the CDK networks in Validium mode            |
| [CDK Validium Contracts](https://github.com/0xPolygon/cdk-validium-contracts) | Smart contract implementation for the CDK networks in Validium mode |
| [CDK Data Availability](https://github.com/0xPolygon/cdk-data-availability)   | Data availability implementation for the CDK networks          |
| [Prover / Executor](https://github.com/0xPolygonHermez/zkevm-prover)          | zkEVM engine and prover implementation                               |
| [Bridge Service](https://github.com/0xPolygonHermez/zkevm-bridge-service)     | Bridge service implementation for CDK networks                       |
| [Bridge UI](https://github.com/0xPolygonHermez/zkevm-bridge-ui)               | UI for the CDK networks bridge                                       |

---

## Important Note

The private keys and mnemonics included in this repository are intended solely for internal testing. **Do not use them in production environments.**

## Prerequisites

- Node.js version: 16.x
- npm version: 7.x

## Repository Structure

- `contracts`: Core contracts
  - `PolygonZkEVMBridge.sol`: Facilitates asset transfers between chains
    - `PolygonZkEVMGlobalExitRoot.sol`: Manages the global exit root on L1
    - `PolygonZkEVMGlobalExitRootL2.sol`: Manages the global exit root on L2
  - `CDKValidium.sol`: Consensus algorithm for Validium CDK chains
- `docs`: Specifications and useful resources
- `test`: Contract test suites

## Activate github hook

To activate the GitHub hook, run the following command:

```bash
git config --local core.hooksPath .githooks/
```

## Install

```bash
npm i
```

## Run tests

Execute the test suite with:

```bash
npm run test
```

## Linting

To check for linting errors, run:

```bash
npm run lint
```

To automatically fix linting errors, run:

```bash
npm run lint:fix
```

## Build dockers

To build the Docker image, run:

```bash
npm run docker:contracts
```

This will create a new Docker image named `hermeznetwork/geth-cdk-validium-contracts`, which includes a Geth node with the deployed contracts. The deployment output can be found at `docker/deploymentOutput/deploy_output.json`.

To run the Docker container, use:

```bash
docker run -p 8545:8545 hermeznetwork/geth-cdk-validium-contracts
```

## Note

For testing purposes, the following private keys are being used. These keys are not intended for production use:

- **Private key**: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
- **Address**: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
- **Private key**: 0xdfd01798f92667dbf91df722434e8fbe96af0211d4d1b82bbbbc8f1def7a814f
- **Address**: 0xc949254d682d8c9ad5682521675b8f43b102aec4

## Verify Deployed Smart Contracts

To confirm that the smart contracts in this repository match those deployed on the mainnet, please follow the instructions in this [document](verifyMainnetDeployment/verifyDeployment.md)

The smart contract used for proof verification is generated from zkEVM Rom and Pil constraints.

## License

The cdk-validium-contracts project is licensed under the [GNU Affero General Public License](LICENSE) free software license.
