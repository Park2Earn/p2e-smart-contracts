import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { Park2Earn } from "../typechain-types";
import {
  MockContract,
  MockContractFactory,
  smock,
} from "@defi-wonderland/smock";
import { getAddress } from "ethers/lib/utils";

describe("Park2Earn tests", function () {
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;

  let park2EarnFactory: ContractFactory;
  let erc20Factory: MockContractFactory<ContractFactory>;
  let usdc: MockContract<Contract>;
  let usdt: MockContract<Contract>;

  let park2EarnContract: Park2Earn;

  const _start = Math.round(Date.now() / 1000);
  const promoLength = 60 * 60 * 8;
  // Initial mint 10,000
  const initialMint = "10000000000000000000000";
  // Staking amount 1000
  const stakingAmount = "1000000000000000000000";

  before(async () => {
    [alice, bob] = await ethers.getSigners();
    park2EarnFactory = await ethers.getContractFactory("Park2Earn");
    erc20Factory = await smock.mock("MockERC20");
  });

  beforeEach(async () => {
    park2EarnContract = (await park2EarnFactory.deploy()) as Park2Earn;

    usdc = await erc20Factory.deploy("Usdc token", "USDC", 18);
    usdt = await erc20Factory.deploy("Usdt token", "USDT", 18);
    await usdc.mint(bob.address, initialMint);
  });

  it("Should create and get promotion", async function () {
    await park2EarnContract.createPromotion(usdc.address, _start, promoLength);
    const getPromo = await park2EarnContract.getPromotion(1);

    expect(getPromo.promoLength).to.equal(promoLength);
    expect(getAddress(getPromo.token)).to.equal(usdc.address);
  });

  it("Should get promotions count", async function () {
    await park2EarnContract.createPromotion(usdc.address, _start, promoLength);
    await park2EarnContract.createPromotion(usdc.address, _start, promoLength);

    expect(await park2EarnContract.getPromotionsCount()).to.equal(2);
  });

  it("Should create and get private good", async function () {
    await park2EarnContract.createPrivateGood(alice.address);
    const privateGood = await park2EarnContract.getPrivateGood(1);

    expect(privateGood.recipient).to.equal(alice.address);
  });

  it("Should get private good count", async function () {
    await park2EarnContract.createPrivateGood(alice.address);
    await park2EarnContract.createPrivateGood(alice.address);

    expect(await park2EarnContract.getPrivateGoodsCount()).to.equal(2);
  });

  it("Should stake correct amount", async function () {
    await park2EarnContract.createPromotion(usdc.address, _start, promoLength);
    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);
    await park2EarnContract.connect(bob).stake(usdc.address, stakingAmount, 1);

    const amountStaked = await park2EarnContract.getAmountStaked(bob.address);

    expect(stakingAmount).to.equal(amountStaked);
  });

  it("Should not stake if promotion expired", async function () {
    await park2EarnContract.createPromotion(usdc.address, _start, promoLength);
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await ethers.provider.send("evm_increaseTime", [promoLength]);
    await ethers.provider.send("evm_mine", [timestampBefore + promoLength]);

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await expect(
      park2EarnContract.connect(bob).stake(usdc.address, stakingAmount, 1)
    ).to.be.revertedWith("Promotion expired!");
  });

  it("Should not stake if wrong promotion token", async function () {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await park2EarnContract.createPromotion(
      usdc.address,
      timestampBefore,
      promoLength
    );

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await expect(
      park2EarnContract.connect(bob).stake(usdt.address, stakingAmount, 1)
    ).to.be.revertedWith("Not promotion token");
  });

  it("Should not stake if amount zero", async function () {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await park2EarnContract.createPromotion(
      usdc.address,
      timestampBefore,
      promoLength
    );

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await expect(
      park2EarnContract.connect(bob).stake(usdc.address, 0, 1)
    ).to.be.revertedWith("Invalid amount");
  });

  it("Should revert if promotion still running", async function () {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await park2EarnContract.createPromotion(
      usdc.address,
      timestampBefore,
      promoLength
    );

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await park2EarnContract.connect(bob).stake(usdc.address, stakingAmount, 1);

    await expect(
      park2EarnContract.connect(bob).withdraw(stakingAmount, 1)
    ).to.be.revertedWith("Promotion still running!");
  });

  it("Should revert if amount is zero", async function () {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await park2EarnContract.createPromotion(
      usdc.address,
      timestampBefore,
      promoLength
    );

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await park2EarnContract.connect(bob).stake(usdc.address, stakingAmount, 1);

    await ethers.provider.send("evm_increaseTime", [promoLength]);
    await ethers.provider.send("evm_mine", [timestampBefore + promoLength]);

    await expect(
      park2EarnContract.connect(bob).withdraw(0, 1)
    ).to.be.revertedWith("Invalid amount!");
  });

  it("Should revert if not enough staked", async function () {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await park2EarnContract.createPromotion(
      usdc.address,
      timestampBefore,
      promoLength
    );

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await park2EarnContract.connect(bob).stake(usdc.address, stakingAmount, 1);

    await ethers.provider.send("evm_increaseTime", [promoLength]);
    await ethers.provider.send("evm_mine", [timestampBefore + promoLength]);

    await expect(
      park2EarnContract.connect(bob).withdraw(stakingAmount + 1, 1)
    ).to.be.revertedWith("Not enough staked!");
  });

  it("Should withdraw tokens", async function () {
    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await park2EarnContract.createPromotion(
      usdc.address,
      timestampBefore,
      promoLength
    );

    await usdc.connect(bob).approve(park2EarnContract.address, stakingAmount);

    await park2EarnContract.connect(bob).stake(usdc.address, stakingAmount, 1);

    await ethers.provider.send("evm_increaseTime", [promoLength]);
    await ethers.provider.send("evm_mine", [timestampBefore + promoLength]);

    await park2EarnContract.connect(bob).withdraw(stakingAmount, 1);

    expect(await park2EarnContract.getAmountStaked(bob.address)).to.be.equal(0);
  });
});
