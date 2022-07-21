import { ethers } from "hardhat";

const { AAVE_LENDING_POOL_POLYGON } = process.env;

async function main() {
  const park2Earn = await ethers.getContractFactory("Park2Earn");

  const park2EarnDeploy = await park2Earn.deploy(AAVE_LENDING_POOL_POLYGON!);
  console.log("Park2Earn deploy address", park2EarnDeploy.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
