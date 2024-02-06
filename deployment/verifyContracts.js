/* eslint-disable import/no-dynamic-require, no-await-in-loop, no-restricted-syntax, guard-for-in */
require('dotenv').config();
const path = require('path');
const hre = require('hardhat');
const { expect } = require('chai');
const { ethers } = require('hardhat');

const pathDeployOutputParameters = path.join(__dirname, './deploy_output.json');
const pathDeployParameters = path.join(__dirname, './deploy_parameters.json');
const deployOutputParameters = require(pathDeployOutputParameters);
const deployParameters = require(pathDeployParameters);

const delay = ms => new Promise(resolve => setTimeout(resolve, ms))

async function main() {
    // load deployer account
    if (typeof process.env.ETHERSCAN_API_KEY === 'undefined') {
        throw new Error('Etherscan API KEY has not been defined');
    }

    console.log('Verifying contracts on Etherscan');
    console.log('Verifying matic token contract...');

    // verify maticToken
    const maticTokenName = 'Matic Token';
    const maticTokenSymbol = 'MATIC';
    const maticTokenInitialBalance = ethers.utils.parseEther('20000000');
    try {
        // verify governance
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.maticTokenAddress,
                constructorArguments: [
                    maticTokenName,
                    maticTokenSymbol,
                    deployOutputParameters.deployerAddress,
                    maticTokenInitialBalance,
                ],
            },
        );
    } catch (error) {
        // expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }

    await delay(1000)

    console.log('Verifying verifier contract...');
    // verify verifier
    try {
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.verifierAddress,
            },
        );
    } catch (error) {
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }

    await delay(1000)

    console.log('Verifying timelock contract...');

    const { minDelayTimelock } = deployParameters;
    const { timelockAddress } = deployParameters;
    try {
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.timelockContractAddress,
                constructorArguments: [
                    minDelayTimelock,
                    [timelockAddress],
                    [timelockAddress],
                    timelockAddress,
                    deployOutputParameters.cdkValidiumAddress,
                ],
            },
        );
    } catch (error) {
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }

    await delay(1000)
    console.log('Verifying proxy admin contract...');

    // verify proxy admin
    try {
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.proxyAdminAddress,
            },
        );
    } catch (error) {
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }

    await delay(1000)
    console.log('Verifying cdk validium contract...');

    // verify cdkValidium address
    try {
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.cdkValidiumAddress,
                constructorArguments: [
                    deployOutputParameters.polygonZkEVMGlobalExitRootAddress,
                    deployOutputParameters.maticTokenAddress,
                    deployOutputParameters.verifierAddress,
                    deployOutputParameters.polygonZkEVMBridgeAddress,
                    deployOutputParameters.cdkDataCommitteeContract,
                    deployOutputParameters.chainID,
                    deployOutputParameters.forkID,
                ],
            },
            );
    } catch (error) {
        console.log(error.message.toLowerCase());
        expect(error.message.toLowerCase().includes('proxyadmin')).to.be.equal(true);
    }

    await delay(1000)
    console.log('Verifying global exit root address...');
        
    // verify global exit root address
    try {
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.polygonZkEVMGlobalExitRootAddress,
                constructorArguments: [
                    deployOutputParameters.cdkValidiumAddress,
                    deployOutputParameters.polygonZkEVMBridgeAddress,
                ],
            },
        );
    } catch (error) {
        console.log(error.message.toLowerCase());
        expect(error.message.toLowerCase().includes('proxyadmin')).to.be.equal(true);
    }

    await delay(1000)
    console.log('Verifying polygon zk evm bridge ...');

    try {
        await hre.run(
            'verify:verify',
            {
                address: deployOutputParameters.polygonZkEVMBridgeAddress,
            },
        );
    } catch (error) {
        console.log(error.message.toLowerCase());
        expect(error.message.toLowerCase().includes('proxyadmin')).to.be.equal(true);
    }
    
}

main()
    .then(() => { 
        console.log("finished");
        process.exit(0);
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
