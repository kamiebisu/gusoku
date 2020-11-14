import {artifacts, deployments, ethers} from "hardhat";

describe("OptionsWarchest", () => {
  beforeEach(async () => {
    await deployments.fixture();
  });
  it("ConvexityAdapter should return available options", async () => {
    const OptionsWarchest = await deployments.get("OptionsWarchest");
    const optionsWarchestArtifact = await artifacts.readArtifact(
      "OptionsWarchest"
    );
    const optionsWarchest = new ethers.Contract(
      OptionsWarchest.address,
      optionsWarchestArtifact.abi,
      ethers.provider
    );

    const availablePutOptions = await optionsWarchest.getConvexityPutOptions();
    console.log("Put options:\n" + availablePutOptions);

    const availableCallOptions = await optionsWarchest.getConvexityCallOptions();
    console.log("Call options:\n" + availableCallOptions);
  });
});
