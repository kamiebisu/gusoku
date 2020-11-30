import {DeployFunction} from "hardhat-deploy/types";
import {HardhatRuntimeEnvironment} from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer} = await getNamedAccounts();

  const mockServiceAdapter = await deployments.get("MockServiceAdapterV2");

  const optionsAdapterV2 = await deployments.get("OptionsProtocolAdapterV2");

  await deploy("OptionsProtocolAdapterV2", {
    from: deployer,
    args: [mockServiceAdapter.address],
    libraries: {
      OptionsProtocolAdapterV2: optionsAdapterV2.address,
    },
    log: true,
    deterministicDeployment: true,
  });
};

export default func;
func.tags = ["ProtocolAdapterProxyV2"];
func.dependencies = ["MockServiceAdapterV2", "OptionsProtocolAdapterV2"];
