import {artifacts, deployments, ethers} from "hardhat";

describe("OptionsWarchest", () => {
  beforeEach(async () => {
    await deployments.fixture([
      "ConvexityAdapter",
      "OptionsAdapter",
      "OptionsWarchest",
    ]);
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

    const availableOptions = await optionsWarchest.getConvexityPutOptions();
    console.log(availableOptions);
  });
});
