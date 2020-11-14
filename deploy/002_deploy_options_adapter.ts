import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer} = await getNamedAccounts();

  await deploy("OptionsAdapter", {
    from: deployer,
    log: true,
    deterministicDeployment: true,
  });
};

export default func;
func.tags = ["OptionsAdapter"];
func.dependencies = ["ConvexityAdapter"];
