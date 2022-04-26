import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Wallet, Signer, utils, BigNumber } from 'ethers';
import web3 from 'web3';

const { toWei, fromWei } = web3.utils;

describe('NftMarket', () => {
  let NFT, nft: any, owner: any, addr1: any, addr2: any;
  let USDT, usdt: any;
  beforeEach(async () => {
    const wallets: any = await ethers.getSigners();

    owner = wallets[0];
    addr1 = wallets[1];
    addr2 = wallets[2];

    // deploy erc20 token
    USDT = await ethers.getContractFactory('MockUSDT');
    usdt = await USDT.deploy();

    // treasury = wallets[3];
    NFT = await ethers.getContractFactory('NftMarket');
    nft = await NFT.deploy(owner.address, usdt.address);
  });

  describe('test mintNft function', async () => {
    it('check mintNft success', async () => {
      await nft.mintNft(addr1.address, 1, 'test', 20, 'abc');
      const counter = await nft.nftCounter();
      console.log('counter: ', counter);
      expect(counter).to.equal(1);
    });
  });

  describe('test transfer nft function', () => {
    it('check current owner of token after transfer', async () => {
      // mint usdt for address1
      await usdt.mint(addr1.address, BigNumber.from(toWei('20')));

      // mint usdt for address2
      await usdt.mint(addr2.address, BigNumber.from(toWei('20')));

      const balanceAddress2 = await usdt.balanceOf(addr2.address);
      console.log('addr2: ', balanceAddress2);
      console.log('addr2: ', addr2.address);
      console.log('addr1: ', addr1.address);
      console.log('owner: ', owner.address);

      // mint nft for address1
      await nft.mintNft(
        addr1.address,
        1,
        'test',
        BigNumber.from(toWei('20')),
        'abc',
      );

      // owner allow address1 use usdt
      await nft
        .connect(owner)
        .approveERC20(addr2.address, BigNumber.from(toWei('20')));

      // excute transfer
      await nft.connect(addr2).transferNft(1);

      // const balanceOfAdd1 = usdt.balanceOf(addr1.address);

      // expect(balanceOfAdd1).to.equal(BigNumber.from(toWei('40')));
    });
  });
});
