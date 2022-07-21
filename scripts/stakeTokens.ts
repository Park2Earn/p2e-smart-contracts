import { park2EarnContract } from "./initialiseContract";

const { USDC_ADDRESS } = process.env;

async function main() {
  const amount = "1000000000";
  const promotionId = 1;

  const tx = await park2EarnContract.stake(USDC_ADDRESS!, amount, promotionId);

  console.log("Tx", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
