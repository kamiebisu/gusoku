import {waffleChai} from "@ethereum-waffle/chai";
import chai, {expect} from "chai";
import {artifacts, deployments, ethers} from "hardhat";
chai.use(waffleChai);

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

    const availableCallOptions = await optionsWarchest.getConvexityCallOptions();

    if (availablePutOptions.length > 0) {
      expect(
        await optionsWarchest.getConvexityOptionPrice(
          availablePutOptions[0],
          ethers.constants.AddressZero,
          ethers.BigNumber.from("2")
        )
      ).to.gt(0);
    }

    if (availableCallOptions.length > 0) {
      expect(
        await optionsWarchest.getConvexityOptionPrice(
          availableCallOptions[0],
          ethers.constants.AddressZero,
          ethers.BigNumber.from(2)
        )
      ).to.gt(0);
    }
  });
});
