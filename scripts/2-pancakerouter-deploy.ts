// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

const ACCOUNT_TEST_ADDRESS_DUYANH = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
const PANCAKE_FACTORY_ADDRESS = "0x5E0399B4C3c4C31036DcA08d53c0c5b5c29C113e"
const PANCAKE_ROUTER_ADDRESS = " 0x512a0E8bAeb6Ac3D52A11780c92517627005b0b1"

const CONTRACTS_ADDRESS = {
    UPFI: '0x43E7A150FABdBB613dA446b07DB42dcAa3a1ef1c',
    UPO: '0x0F3C47a687960eCBad9E969Ea483E5E8b4D22Fb1',
    USDC: '0xfe2c9efd1A63aA254ACaE60Bd4F37e657413f4E6',
    BTC: '0xB0104dfC501b0C0aAd7d394692a1c9Dbd5C72b4E',
    ETH: '0x627670a7f376E6f8B502Bce7D2bbbFEdAa7cCaa8',
    ROSE: '0xA5b83F3808b597FD030801007Bc975E1d227C054',
    TREASURY: '0x2715abDBD52ec08576a14764A51C22Aa21C8CC9d',
    MINT_REDEEM: '0x9cc449142243947D70933bA9e19F6100Ac54d29B'
}

async function main() {
    await deploy();
}

async function deploy() {
    await deployerInfo()
    const PancakeRouter01 = await ethers.getContractFactory("PancakeRouter01");
    const pancakeRouter01 = await PancakeRouter01.deploy(PANCAKE_FACTORY_ADDRESS, CONTRACTS_ADDRESS.UPFI);
    await pancakeRouter01.deployed();
    console.log("PancakeRouter01 deployed to:", pancakeRouter01.address);
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
