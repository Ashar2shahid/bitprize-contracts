const hre = require("hardhat");

async function verify() {
  // Retrieve the deployed contract addresses
  const MockUSDC = await hre.deployments.get("MockUSDC");
  const Bit = await hre.deployments.get("Bit");
  const MockYieldContract = await hre.deployments.get("MockYieldContract");
  const RandomNumberGenerator = await hre.deployments.get("RandomNumberGenerator");
  const PrizePool = await hre.deployments.get("PrizePool");

  console.log("Verifying MockUSDC...");
  await hre.run("verify:verify", {
    address: MockUSDC.address,
    constructorArguments: [],
  });

  console.log("Verifying Bit...");
  await hre.run("verify:verify", {
    address: Bit.address,
    constructorArguments: [],
  });

  console.log("Verifying MockYieldContract...");
  await hre.run("verify:verify", {
    address: MockYieldContract.address,
    constructorArguments: [MockUSDC.address, (await hre.ethers.getSigners())[0].address],
  });

  console.log("Verifying RandomNumberGenerator...");
  await hre.run("verify:verify", {
    address: RandomNumberGenerator.address,
    constructorArguments: [Bit.address, (await hre.ethers.getSigners())[0].address],
  });

  console.log("Verifying PrizePool...");
  await hre.run("verify:verify", {
    address: PrizePool.address,
    constructorArguments: [
      MockUSDC.address,
      Bit.address,
      MockYieldContract.address,
      RandomNumberGenerator.address,
    ],
  });

  console.log("All contracts verified!");
}

module.exports = verify;
