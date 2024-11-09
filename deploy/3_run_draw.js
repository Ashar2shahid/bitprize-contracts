const hre = require("hardhat");

module.exports = async () => {
  const deployer = (await hre.ethers.getSigners())[0];

  // Retrieve the deployed contract addresses
  const MockUSDC = await hre.deployments.get("MockUSDC");
  const Bit = await hre.deployments.get("Bit");
  const MockYieldContract = await hre.deployments.get("MockYieldContract");
  const RandomNumberGenerator = await hre.deployments.get("RandomNumberGenerator");
  const PrizePool = await hre.deployments.get("PrizePool");
  const PrizePoolContract = await hre.ethers.getContractAt("PrizePool", PrizePool.address, deployer);
  const BitContract = await hre.ethers.getContractAt("Bit", Bit.address, deployer);

  // approve PrizePool to spend USDC
  console.log("Approving PrizePool to spend USDC...");
  const USDC = await hre.ethers.getContractAt("MockUSDC", MockUSDC.address, deployer);
  await USDC.approve(PrizePool.address, hre.ethers.utils.parseEther("10"));

  // initialize draw
  console.log("Initializing draw...");
  await PrizePoolContract.startDraw();

  console.log("Depositing into PrizePool...");
  await PrizePoolContract.deposit(hre.ethers.utils.parseEther("10"));

  // send 1/3 bit to 0x8BD0e959E9a7273D465ac74d427Ecc8AAaCa55D8 and 1/3 to 0xcB37FD92D2e3Bbbe614aA8707B35AEeB158E1aFE
  console.log("Sending 1/3 Bit to 0x8BD0e959E9a7273D465ac74d427Ecc8AAaCa55D8...");
  await BitContract.transfer("0x8BD0e959E9a7273D465ac74d427Ecc8AAaCa55D8", hre.ethers.utils.parseEther("3.333333333333333333"));

  console.log("Sending 1/3 Bit to 0xcB37FD92D2e3Bbbe614aA8707B35AEeB158E1aFE...");
  await BitContract.transfer("0xcB37FD92D2e3Bbbe614aA8707B35AEeB158E1aFE", hre.ethers.utils.parseEther("3.333333333333333333"));
}

module.exports.tags = ["intialize-draw"];
