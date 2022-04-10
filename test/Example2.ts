import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet, Signer, utils, BigNumber } from "ethers";
import * as USDT from "../artifacts/contracts/mocks/MockUSDT.sol/MockUSDT.json";
import web3 from "web3";

describe("Auction contract", () => {
  let Example2,
    example2: any,
    owner: any,
    addr1: any,
    addr2: any,
    treasury: any;
  beforeEach(async () => {
    const wallets: any = await ethers.getSigners();

    owner = wallets[0];
    addr1 = wallets[1];
    addr2 = wallets[2];
    // treasury = wallets[3];
    Example2 = await ethers.getContractFactory("Example2");
    example2 = await Example2.deploy(owner.address);
  });

  describe("check mint function", async () => {
    it("check user can min token", async () => {
      await example2.connect(owner).mint(addr1.address, 30);
      expect(await example2.balanceOf(addr1.address)).to.equal(30);
    });

    // it("check user can't min token when not owner", async () => {
    //   await example2.connect(addr2).mint(addr1.address, 50);
    //   expect(await example2.balanceOf(addr1.address)).to.equal(0);
    // });
  });

  describe("check burn function", async () => {
    it("check user can burn token", async () => {
      await example2.connect(owner).mint(addr1.address, 50);
      await example2.connect(owner).burn(addr1.address, 30);
      expect(await example2.balanceOf(addr1.address)).to.equal(20);
    });

    // it("check user can't burn token when not owner", async () => {
    //   await example2.connect(owner).mint(addr1.address, 50);
    //   await example2.connect(owner).burn(addr1.address, 30);
    //   expect(await example2.balanceOf(addr1.address)).to.equal(20);
    // });
  });
  describe("check addBlackList function", async () => {
    it("check add user in back list", async () => {
      await example2.connect(owner).addToBackList(addr1.address);
      const dataBackList = await example2.getBackList();
      expect(dataBackList.length).to.equal(1);
    });
  });

  describe("check removeFromBlackList function", async () => {
    it("check remove user in back list", async () => {
      await example2.connect(owner).addToBackList(addr1.address);
      await example2.connect(owner).addToBackList(addr2.address);
      await example2.connect(owner).removeFromBackList(addr1.address);
      const dataBackList = await example2.getBackList();
      expect(dataBackList.length).to.equal(1);
    });
  });

  describe("check approve function", () => {
    it("check user approve", async () => {
      await example2
        .connect(owner)
        .approveInternal(owner.address, addr1.address, 100);

      const allowance = await example2.allowance(owner.address, addr1.address);
      expect(allowance).to.equal(105);
    });
  });

  describe("check transfer function", () => {
    it("check user transfer success", async () => {
      await example2.connect(owner).mint(addr1.address, 200);
      await example2
        .connect(owner)
        .approveInternal(owner.address, addr1.address, 100);
      console.log("addr2.address: ", addr2.address);

      await example2
        .connect(owner)
        .transferInternal(addr1.address, addr2.address, 100);
      expect(await example2.balanceOf(addr1.address)).to.equal(95);
      expect(await example2.balanceOf(addr2.address)).to.equal(100);
      console.log("balance1: ", await example2.balanceOf(addr2.address));
      console.log("balance2: ", await example2.balanceOf(owner.address));
      expect(await example2.balanceOf(owner.address)).to.equal(5);
    });
  });
});
