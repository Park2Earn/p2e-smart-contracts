import { park2EarnContract, usdcErc20Contract } from "./initialiseContract";

async function main() {
  const amount = "1000000000";
  const tx = await usdcErc20Contract.approve(park2EarnContract.address, amount);

  console.log("Tx", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
