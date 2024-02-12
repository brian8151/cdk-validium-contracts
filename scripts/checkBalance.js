const { ethers } = require('ethers');

// Use environment variables for the provider URL and admin address
const providerUrl = process.env.RPC_URL; // Ensure URL is set in your environment variables
const adminAddress = process.env.ADMIN_ADDRESS; // Ensure ADMIN_ADDRESS is set in your environment variables

if (!providerUrl || !adminAddress) {
    console.error("Please set both URL and ADMIN_ADDRESS environment variables.");
    process.exit(1);
}

const provider = new ethers.providers.JsonRpcProvider(providerUrl);

async function checkAdminBalance() {
    const balance = await provider.getBalance(adminAddress);
    const balanceInEth = ethers.utils.formatEther(balance);

    console.log(`Balance of ${adminAddress} is: ${balanceInEth} ETH`);

    if(balance.gt(0)) {
        console.log("ADMIN address has a zero ETH balance.");
    }
}

checkAdminBalance().catch(console.error);
