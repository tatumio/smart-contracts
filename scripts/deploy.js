async function main() {
  // We get the contract to deploy
  const CustodialFullTokenWalletWithBatch = await ethers.getContractFactory("CustodialFullTokenWalletWithBatch");
  console.log("Deploying CustodialFullTokenWalletWithBatch...");
  const box = await CustodialFullTokenWalletWithBatch.deploy();
  await box.deployed();
  console.log("CustodialFullTokenWalletWithBatch deployed to:", box.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
