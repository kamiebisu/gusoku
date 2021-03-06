import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer} = await getNamedAccounts();

  await deploy("OptionsProtocolAdapterV2", {
    from: deployer,
    log: true,
    deterministicDeployment: true,
  });
};

export default func;
func.tags = ["OptionsProtocolAdapterV2"];
