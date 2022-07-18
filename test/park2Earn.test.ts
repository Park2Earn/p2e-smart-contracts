import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { Park2Earn } from "../typechain-types";

describe("Park2Earn tests", function () {
  let alice: SignerWithAddress;

  let gooddeedToken: ContractFactory;
  let park2EarnFactory: ContractFactory;
  let gooddeedTokenAddress: any;

  let park2EarnContract: Park2Earn;

  const _start = Math.round(Date.now() / 1000);
  const length = 60 * 60 * 8;

  before(async () => {
    [alice] = await ethers.getSigners();
    gooddeedToken = await ethers.getContractFactory("GooddeedToken");
    park2EarnFactory = await ethers.getContractFactory("Park2Earn");
  });

  beforeEach(async () => {
    const gooddeedTokenContract = await gooddeedToken.deploy();
    gooddeedTokenAddress = gooddeedTokenContract.address;

    park2EarnContract = (await park2EarnFactory.deploy()) as Park2Earn;
  });

  it("Should create and get promotion", async function () {
    await park2EarnContract.createPromotion(
      gooddeedTokenAddress,
      _start,
      length
    );

    const getPromo = await park2EarnContract.getPromotion(1);

    expect(getPromo.promoLength).to.equal(length);
  });

  it("Should create and get private good", async function () {
    await park2EarnContract.createPrivateGood(alice.address);

    const privateGood = await park2EarnContract.getPrivateGood(1);

    expect(privateGood.recipient).to.equal(alice.address);
  });
});
