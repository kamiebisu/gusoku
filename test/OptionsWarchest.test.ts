import {waffleChai} from "@ethereum-waffle/chai";
import chai, {expect} from "chai";
import {artifacts, deployments, ethers} from "hardhat";
chai.use(waffleChai);

describe("OptionsWarchest", () => {
  const ProtocolNames = {Convexity: 0};

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

    const convexity = await optionsWarchest.optionsProtocols(
      ProtocolNames.Convexity
    );

    const availablePutOptions = await optionsWarchest.getPutOptions(convexity);

    const availableCallOptions = await optionsWarchest.getCallOptions(
      convexity
    );

    if (availablePutOptions.length > 0) {
      expect(
        await optionsWarchest.getOptionPrice(
          convexity,
          availablePutOptions[0],
          ethers.constants.AddressZero,
          ethers.BigNumber.from("2")
        )
      ).to.gt(0);
    }

    if (availableCallOptions.length > 0) {
      expect(
        await optionsWarchest.getOptionPrice(
          convexity,
          availableCallOptions[0],
          ethers.constants.AddressZero,
          ethers.BigNumber.from(2)
        )
      ).to.gt(0);
    }
  });
});
