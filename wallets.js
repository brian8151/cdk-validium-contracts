const ethers = require('ethers');

async function main() {
  const arrayNames = [
    "Deployment Address",
    "Trusted sequencer",
    "Trusted aggregator",
  ];

  let output = {};

  for (let i = 0; i < arrayNames.length; i++) {
    const wallet = ethers.Wallet.createRandom();
    
    const keystoreJson = await wallet.encrypt("password");

    // Add wallet details to the output object
    output[arrayNames[i]] = {
      Address: wallet.address,
      PrvKey: wallet._signingKey().privateKey,
      mnemonic: wallet._mnemonic().phrase,
      keystore: JSON.parse(keystoreJson)
    };
  }

  // Print the structured JSON output
  console.log(JSON.stringify(output, null, 2));
}

main().catch(console.error);