import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer} = await getNamedAccounts();

  const strings = await deployments.get("strings");

  await deploy("ConvexityAdapter", {
    from: deployer,
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
