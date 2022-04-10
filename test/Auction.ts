import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet, Signer, utils, BigNumber } from "ethers";
import * as USDT from "../artifacts/contracts/mocks/MockUSDT.sol/MockUSDT.json";
import web3 from "web3";

describe("Auction contract", () => {
  let Auction,
    USDT,
    usdt: any,
    auction: any,
    deployer: any,
    addr1: any,
    addr2: any,
    coldWalletAddress: any,
    rewardDistributor: any;
  beforeEach(async () => {
    USDT = await ethers.getContractFactory("MockUSDT");
    usdt = await USDT.deploy();

    Auction = await ethers.getContractFactory("Auction");
    auction = await Auction.deploy(usdt.address);
    const wallets: any = await ethers.getSigners();

    deployer = wallets[0];
    addr1 = wallets[1];
    addr2 = wallets[2];
    coldWalletAddress = wallets[3];
    rewardDistributor = wallets[4];

    await usdt.mint(rewardDistributor.address, 100000);

    await usdt.connect(rewardDistributor).approve(addr1.address, 1000);

    // usdt.mint(addr1, 200);
  });
  describe("Deployment", () => {
    it("should set the right owner", async () => {
      // expect(await auction.owner()).to.equal(owner.address);
    });
  });

  describe("Transaction", () => {
    it("Test balanceOf", async () => {});
    it("test balanceOf usdt", async () => {
      await usdt.mint(addr1.address, 200);
      const balanceUSDT = await usdt.balanceOf(addr1.address);
      expect(balanceUSDT).to.equal(200);
      expect(await auction.balanceOf(addr1.address)).to.equal(200);
    });

    it("test bid success", async () => {
      await usdt.mint(addr1.address, 200);
      await auction.startAuction(1000, 20);
      await auction.bid("chi hieu", addr1.address, 30);
    });

    it("test end auction success", async () => {
      // await usdt.mint(addr1.address, 200);
      // await auction.startAuction(1000, 20);
      // await auction.bid("chi hieu", addr1.address, 30);
      // const balance = await auction.balanceOf(addr1.address);
      // console.log("balance: ", balance);
      // const victory = await auction.victoryPerson();
      // console.log("victory: ", victory);
      // console.log("result: ", await usdt.balanceOf(victory.account));
      // console.log("account1: ", victory.account);
      // console.log("account2: ", addr1.address);
      // // await usdt.connect(rewardDistributor).approve(addr1.address, 1000);
      // console.log("spender test: ", rewardDistributor.address);
      // await auction.endAuction();
      // const balanceOfBidder = await usdt.balanceOf(addr1.address);
      // console.log("balanceOfBidder: ", balanceOfBidder);
      // expect(balanceOfBidder).to.equal(170);
      // const balanceOfColdWallet = await usdt.balanceOf(coldWalletAddress);
      // expect(balanceOfColdWallet).to.equal(30);
    });
    // it("test get person victory", async () => {
    //   // const coldWalletAddress = "0xAA7740DB30dcE972a5F1eFD8970e2D37ADD75034";
    //   await usdt.mint(addr1.address, 200);
    //   await auction.startAuction(1000, 20);
    //   const balance = await auction.balanceOf(addr1.address);
    //   console.log("balance: ", balance);
    //   await auction.bid("chi hieu", 30);
    //   const victory = await auction.victoryPerson();
    //   console.log("victory: ", victory);
    //   console.log("sub: ", balance - victory.amount);
    // });
  });
});
