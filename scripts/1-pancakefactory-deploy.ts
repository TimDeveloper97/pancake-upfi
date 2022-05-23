// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

const ACCOUNT_TEST_ADDRESS_DUYANH = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

async function main() {
    await deploy();
}

async function deploy() {
    await deployerInfo()
    const PancakeFactory = await ethers.getContractFactory("PancakeFactory");
    const pancakeFactory = await PancakeFactory.deploy(ACCOUNT_TEST_ADDRESS_DUYANH);
    await pancakeFactory.deployed();
    console.log("PancakeFactory deployed to:", pancakeFactory.address);
}

async function deployerInfo() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
