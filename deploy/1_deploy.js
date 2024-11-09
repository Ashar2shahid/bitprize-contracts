const hre = require("hardhat");

module.exports = async () => {
  const deployer = (await hre.ethers.getSigners())[0];

  console.log("Deploying contracts with the account:", deployer.address);

  const MockUSDC = await hre.deployments.deploy("MockUSDC", {
    args: [],
    from: deployer.address,
    log: true,
  });

  console.log("MockUSDC deployed to:", MockUSDC.address);

  // deploy Bit contract
  const bit = await hre.deployments.deploy("Bit", {
    args: [],
    from: deployer.address,
    log: true,
  });

  console.log("Bit deployed to:", bit.address);

  // deploy Yield contract
  const yieldContract = await hre.deployments.deploy("MockYieldContract", {
    args: [MockUSDC.address, deployer.address],
    from: deployer.address,
    log: true,
  });

  console.log("MockYieldContract deployed to:", yieldContract.address);

  // deploy RandomNumberGenerator contract
  const rngContract = await hre.deployments.deploy("RandomNumberGenerator", {
    args: [bit.address, deployer.address],
    from: deployer.address,
    log: true,
  });

  console.log("RandomNumberGenerator deployed to:", rngContract.address);

  // deploy PrizePool contract
  const prizePool = await hre.deployments.deploy("PrizePool", {
    args: [MockUSDC.address, bit.address, yieldContract.address, rngContract.address],
    from: deployer.address,
    log: true,
  });

  console.log("PrizePool deployed to:", prizePool.address);

  // set yeild prize pool
  const Yield = await hre.deployments.get("MockYieldContract");
  const yield = await hre.ethers.getContractAt("MockYieldContract", Yield.address, deployer);
  await yield.setPrizePool(prizePool.address);

  console.log("PrizePool set on MockYieldContract");

  // set rng prize pool
  const RNG = await hre.deployments.get("RandomNumberGenerator");
  const rng = await hre.ethers.getContractAt("RandomNumberGenerator", RNG.address, deployer);
  await rng.setPrizePool(prizePool.address);

  console.log("PrizePool set on RandomNumberGenerator");

  // set bit owner to prize pool if needed
  const Bit = await hre.deployments.get("Bit");
  const bitContract = await hre.ethers.getContractAt("Bit", Bit.address, deployer);
  if ((await bitContract.owner()) !== prizePool.address) {
    await bitContract.transferOwnership(prizePool.address);
    console.log("Bit ownership transferred to PrizePool");
  }

  // deploy 100 USDC to yield contract
  const MockUSDCContract = await hre.deployments.get("MockUSDC");
  const usdc = await hre.ethers.getContractAt("MockUSDC", MockUSDCContract.address, deployer);

  await usdc.approve(yield.address, hre.ethers.utils.parseUnits("100", 18));

  await yield.depositYield(hre.ethers.utils.parseUnits("100", 18));

  console.log("100 USDC deposited to MockYieldContract");
};
module.exports.tags = ["deploy"];
