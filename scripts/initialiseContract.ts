import { ethers } from "hardhat";
import { MockERC20__factory, Park2Earn__factory } from "../typechain-types";

const {
  PRIVATE_KEY,
  PARK_TO_EARN_CONTRACT,
  INFURA_PROJECT_ID,
  USDC_ADDRESS,
  AAVE_USDC_ADDRESS,
} = process.env;

export const provider = new ethers.providers.JsonRpcProvider(
  `https://polygon-mumbai.infura.io/v3/${INFURA_PROJECT_ID!}`,
  {
    chainId: Number(80001),
    name: "mumbai",
  }
);

const wallet = new ethers.Wallet(PRIVATE_KEY as any, provider);

export const park2EarnContract = Park2Earn__factory.connect(
  PARK_TO_EARN_CONTRACT!,
  wallet
);

export const usdcErc20Contract = MockERC20__factory.connect(
  USDC_ADDRESS!,
  wallet
);

export const aaveErc20Contract = MockERC20__factory.connect(
  AAVE_USDC_ADDRESS!,
  wallet
);
