import { ethers } from "hardhat";

async function main() {
  const park2Earn = await ethers.getContractFactory("Park2Earn");
  const gooddeedToken = await ethers.getContractFactory("GooddeedToken");

  const park2EarnDeploy = await park2Earn.deploy();
  console.log("Park2Earn deploy address", park2EarnDeploy.address);

  const gooddeedTokenDeploy = await gooddeedToken.deploy();
  console.log("Gooddeed deploy address", gooddeedTokenDeploy.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
