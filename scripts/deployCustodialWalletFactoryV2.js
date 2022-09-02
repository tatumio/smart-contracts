async function main() {
    // We get the contract to deploy
    const CustodialWalletFactoryV2Factory = await ethers.getContractFactory("CustodialWalletFactoryV2");
    console.log("Deploying CustodialWalletFactoryV2...");
    const box = await CustodialWalletFactoryV2Factory.deploy();
    await box.deployed();
    console.log("CustodialWalletFactoryV2 deployed to:", box.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
  