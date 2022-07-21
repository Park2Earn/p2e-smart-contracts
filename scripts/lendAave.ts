import { park2EarnContract } from "./initialiseContract";

const { USDC_ADDRESS } = process.env;

async function main() {
  const amount = "1000000000";
  const referralCode = "0x0000000000000000000000000000000000000000";
  const tx = await park2EarnContract.depositAave(
    USDC_ADDRESS!,
    amount,
    referralCode
  );

  console.log("Tx", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
