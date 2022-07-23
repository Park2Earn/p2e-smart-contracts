import { park2EarnContract } from "./initialiseContract";

async function main() {
  const walletAddress = "";
  const promotionId = 1;
  const tx = await park2EarnContract.createPublicGood(
    walletAddress,
    promotionId,
    "Public good 1",
    "Public good 1 description"
  );

  console.log("tx:", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
