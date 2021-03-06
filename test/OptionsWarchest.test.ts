import ERC20 from "@openzeppelin/contracts/build/contracts/ERC20.json";
import {expect} from "chai";
import {BigNumber, Signer} from "ethers";
import {artifacts, deployments, ethers, network, waffle} from "hardhat";
import {OptionsWarchest} from "../typechain/OptionsWarchest";
import oToken from "./abis/convexity/IoToken.json";
import {getAllVaultsForOption} from "./utils/convexity/graph";

const provider = waffle.provider;

describe("OptionsWarchest", () => {
  const ProtocolNames = {Convexity: 0};

  let deployedOptionsWarchest;
  let optionsWarchestArtifact;
  let optionsWarchest: OptionsWarchest;
  let warchestOperator: Signer;
  let convexity: string;

  beforeEach(async () => {
    await deployments.fixture();

    deployedOptionsWarchest = await deployments.get("OptionsWarchest");
    optionsWarchestArtifact = await artifacts.readArtifact("OptionsWarchest");
    optionsWarchest = new ethers.Contract(
      deployedOptionsWarchest.address,
      optionsWarchestArtifact.abi,
      provider
    ) as OptionsWarchest;

    [warchestOperator] = await ethers.getSigners();

    convexity = await optionsWarchest.optionsProtocols(ProtocolNames.Convexity);

    // Send some funds to the OptionsWarchest instance
    await warchestOperator.sendTransaction({
      to: optionsWarchest.address,
      value: ethers.utils.parseEther("100"),
    });
  });

  it("ConvexityAdapter should be able to query, buy, sell and exercise PUT options", async () => {
    const availablePutOptions = await optionsWarchest.getPutOptions(convexity);

    if (availablePutOptions.length > 0) {
      // getOptionPrice should return a price > 0
      expect(
        await optionsWarchest.getOptionPrice(
          convexity,
          availablePutOptions[0],
          ethers.constants.AddressZero,
          ethers.BigNumber.from("2")
        )
      ).to.gt(0);

      // Test buying a put option. Use the most recent one so that the probability
      // of it not having expired yet is bigger
      const recentPutOption =
        availablePutOptions[availablePutOptions.length - 1];

      await optionsWarchest
        .connect(warchestOperator)
        .buyOptions(
          convexity,
          recentPutOption,
          ethers.constants.AddressZero,
          ethers.BigNumber.from("2")
        );

      const optionToken = new ethers.Contract(
        recentPutOption,
        oToken,
        provider
      );

      expect(await optionToken.balanceOf(optionsWarchest.address)).to.equal(2);

      // Test selling the option that was just purchased
      const warchestBalanceBeforeSelling = await provider.getBalance(
        optionsWarchest.address
      );
      await optionsWarchest
        .connect(warchestOperator)
        .sellOptions(
          convexity,
          recentPutOption,
          ethers.constants.AddressZero,
          BigNumber.from("1")
        );

      expect(await optionToken.balanceOf(optionsWarchest.address)).to.equal(1);
      expect(await provider.getBalance(optionsWarchest.address)).to.gt(
        warchestBalanceBeforeSelling
      );

      // Test exercising the option

      // Need to get some of the underlying token into the OptionsWarchest
      const underlyingAddress = await optionToken.underlying();
      if (underlyingAddress !== ethers.constants.AddressZero) {
        const underlyingToken = new ethers.Contract(
          underlyingAddress,
          ERC20.abi,
          provider
        );

        await network.provider.request({
          method: "hardhat_impersonateAccount",
          params: [underlyingAddress],
        });

        const underlyingSigner = await provider.getSigner(underlyingAddress);
        const underlyingDecimals = await underlyingToken.decimals();

        await underlyingToken
          .connect(underlyingSigner)
          .transferFrom(
            underlyingAddress,
            optionsWarchest.address,
            BigNumber.from((10 ** underlyingDecimals).toString())
          );
      }

      const vaults = await getAllVaultsForOption(recentPutOption);

      const owners: Array<string> = [];
      vaults.forEach((vault) => {
        if (vault.collateral != "0") {
          owners.push(vault.owner);
        }
      });

      await optionsWarchest
        .connect(warchestOperator)
        .exerciseOptions(
          convexity,
          recentPutOption,
          BigNumber.from("1"),
          owners
        );
    }
  });

  it("ConvexityAdapter should be able to query, buy, sell and exercise CALL options", async () => {
    const availableCallOptions = await optionsWarchest.getCallOptions(
      convexity
    );

    if (availableCallOptions.length > 0) {
      expect(
        await optionsWarchest.getOptionPrice(
          convexity,
          availableCallOptions[0],
          ethers.constants.AddressZero,
          ethers.BigNumber.from("2")
        )
      ).to.gt(0);

      // Test buying a call option. Use a recent one so that the probability
      // of it not having expired yet is bigger
      const recentCallOption =
        availableCallOptions[availableCallOptions.length - 2];

      await optionsWarchest
        .connect(warchestOperator)
        .buyOptions(
          convexity,
          recentCallOption,
          ethers.constants.AddressZero,
          ethers.BigNumber.from("2")
        );

      const optionToken = new ethers.Contract(
        recentCallOption,
        oToken,
        provider
      );

      expect(await optionToken.balanceOf(optionsWarchest.address)).to.equal(2);

      // Test selling the option that was just purchased
      const warchestBalanceBeforeSelling = await provider.getBalance(
        optionsWarchest.address
      );
      console.log(recentCallOption);
      await optionsWarchest
        .connect(warchestOperator)
        .sellOptions(
          convexity,
          recentCallOption,
          ethers.constants.AddressZero,
          BigNumber.from("1")
        );

      expect(await optionToken.balanceOf(optionsWarchest.address)).to.equal(1);
      expect(await provider.getBalance(optionsWarchest.address)).to.gt(
        warchestBalanceBeforeSelling
      );

      // TODO: Test exercising the option
    }
  });
});
