import { ethers } from "hardhat";

async function main() {
  const factory = await ethers.getContractFactory("EquityFactory");
  const Factory = await factory.deploy();

  await Factory.deployed();

  console.log("Factory deployed to:", Factory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
