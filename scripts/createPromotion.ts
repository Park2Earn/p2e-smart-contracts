import { park2EarnContract } from "./initialiseContract";

const { USDC_ADDRESS } = process.env;

async function main() {
  const _start = Math.round(Date.now() / 1000); // unix timestamp in seconds
  const length = 60 * 60 * 24 * 8; // 8 days

  const tx = await park2EarnContract.createPromotion(
    USDC_ADDRESS!,
    _start,
    length,
    "Best promotion",
    "Nice description"
  );

  console.log("tx:", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
