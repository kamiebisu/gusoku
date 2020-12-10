import {ethers} from "hardhat";
import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer} = await getNamedAccounts();

  const strings = await deployments.get("strings");

  const supportedExchangeTokens = [
    ethers.constants.AddressZero, // ETH
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // WETH
    "0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5", // cETH
    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", // USDC
    "0x39AA39c021dfbaE8faC545936693aC917d5E7563", // cUSDC
    "0x8ED9f862363fFdFD3a07546e618214b6D59F03d4", // ocUSDC (Opyn cUSDC Insurance)
    "0x6B175474E89094C44Da98b954EedeAC495271d0F", // Dai
    "0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359", // Sai
    "0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643", // cDai
    "0xF5DCe57282A584D2746FaF1593d3121Fcac444dC", // cSai
    "0x98CC3BD6Af1880fcfDa17ac477B2F612980e5e33", // ocDai (Opyn cDai Insurance)
  ];
  await deploy("ConvexityAdapter", {
    from: deployer,
    args: [supportedExchangeTokens],
    libraries: {
      strings: strings.address,
    },
    log: true,
    deterministicDeployment: true,
  });
};

export default func;
func.tags = ["ConvexityAdapter"];
func.dependencies = ["strings"];
