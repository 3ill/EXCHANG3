const { ethers } = require('hardhat');

const main = async () => {
  const SingleSwap = await ethers.getContractFactory('SingleSwap');
  const singleSwap = await SingleSwap.deploy();

  contractAddress = await singleSwap.getAddress();

  console.log(`Contract Deployed at => ${contractAddress}`);
};

main().catch((error) => {
  process.exitCode = 1;
  console.error(error);
});
