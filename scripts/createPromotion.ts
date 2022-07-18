import { ethers } from "hardhat";

const { PARK_TO_EARN_CONTRACT, GOODDEED_TOKEN } = process.env;

async function main() {
  const park2Earn = await ethers.getContractAt(
    "Park2Earn",
    PARK_TO_EARN_CONTRACT!
  );

  const startTime = "1658131359";
  const length = 60 * 60 * 8;

  const tx = await park2Earn.createPromotion(
    GOODDEED_TOKEN!,
    startTime,
    length
  );

  console.log("tx:", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
