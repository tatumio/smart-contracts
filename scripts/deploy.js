async function main() {
  // We get the contract to deploy
  const ProassetzToken = await ethers.getContractFactory("ProassetzToken");
  console.log("Deploying ProassetzToken...");
  const box = await ProassetzToken.deploy();
  await box.deployed();
  console.log("ProassetzToken deployed to:", box.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
