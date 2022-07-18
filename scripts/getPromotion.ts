import { ethers } from "hardhat";

const { PARK_TO_EARN_CONTRACT } = process.env;

async function main() {
  const park2Earn = await ethers.getContractAt(
    "Park2Earn",
    PARK_TO_EARN_CONTRACT!
  );

  const promotion = await park2Earn.getPromotion(1);
  console.log("Promotion", promotion);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
