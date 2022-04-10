import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  const balance = await deployer.getBalance();
  console.log(`Account balance: ${balance.toString()}`);
  const Example2 = await ethers.getContractFactory("Example2");
  const example2 = await Example2.deploy(
    "0xAA7740DB30dcE972a5F1eFD8970e2D37ADD75034"
  );
  console.log(`Token address: ${example2.address}`);
}

main().catch((error: any) => {
  console.error(error);
  process.exitCode = 1;
});
