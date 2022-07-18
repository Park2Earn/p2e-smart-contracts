import * as dotenv from "dotenv";

import { task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

const { PRIVATE_KEY } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

export default {
  solidity: "0.8.9",
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      chainId: 1337,
    },
    polygonMumbai: {
      chainId: 80001,
      url: "https://polygon-mumbai.infura.io/v3/31b6ae371a0c41c388ea3698de2bff46",
      accounts: [PRIVATE_KEY],
    },
  },
};
