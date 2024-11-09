const hre = require("hardhat");

async function verify() {
  // Retrieve the deployed contract addresses
  const MockUSDC = await hre.deployments.get("MockUSDC");
  const Bit = await hre.deployments.get("Bit");
  const MockYieldContract = await hre.deployments.get("MockYieldContract");
  const AaveYieldSource = await hre.deployments.get("AaveYieldSource");
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

  console.log("Verifying AaveYieldSource...");
  await hre.run("verify:verify", {
    address: AaveYieldSource.address,
    constructorArguments: [
      "0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB",
      "0xf9cc4F0D883F1a1eb2c253bdb46c254Ca51E1F44",
      "0x2f6571d3Eb9a4e350C68C36bCD2afe39530078E2",
      "PoolBitAaveUSDC",
      "PoolBitAaveUSDC",
      6,
      (await hre.ethers.getSigners())[0].address,
    ],
  });

  console.log("Verifying PrizePool...");
  await hre.run("verify:verify", {
    address: PrizePool.address,
    constructorArguments: [
     "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
      Bit.address,
      AaveYieldSource.address,
      RandomNumberGenerator.address,
    ],
  });

  console.log("All contracts verified!");
}

module.exports = verify;
