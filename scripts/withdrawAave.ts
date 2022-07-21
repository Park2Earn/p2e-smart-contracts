import { aaveErc20Contract, park2EarnContract } from "./initialiseContract";

const { USDC_ADDRESS, PARK_TO_EARN_CONTRACT } = process.env;

async function main() {
  const contractBalance = await aaveErc20Contract.balanceOf(
    PARK_TO_EARN_CONTRACT!
  );

  const tx = await park2EarnContract.withdrawAave(
    USDC_ADDRESS!,
    contractBalance.toString()
  );

  console.log("Tx", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
