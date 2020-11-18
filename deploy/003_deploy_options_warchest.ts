import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer} = await getNamedAccounts();

  const convexityAdapter = await deployments.get("ConvexityAdapter");

  const optionsAdapter = await deployments.get("OptionsProtocolAdapter");

  await deploy("OptionsWarchest", {
    from: deployer,
    args: [convexityAdapter.address],
    libraries: {
      OptionsProtocolAdapter: optionsAdapter.address,
    },
    log: true,
    deterministicDeployment: true,
  });
};

export default func;
func.tags = ["OptionsWarchest"];
func.dependencies = ["ConvexityAdapter", "OptionsProtocolAdapter"];
