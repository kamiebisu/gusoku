// SPDX-License-Identifier: MIT
/* solhint-disable */
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../interfaces/IDiscreteOptionsProtocol.sol";
import "../../interfaces/IResellableOptionsProtocol.sol";
import "../../libraries/strings.sol";
import "hardhat/console.sol";
import "../domain/OptionsModel.sol";
import "./MockServiceParams.sol";

contract MockServiceAdapterV2 is
    IDiscreteOptionsProtocol,
    IResellableOptionsProtocol
{
    using SafeMath for uint256;
    using strings for *;

    //these methods just store call params in case we want to fetch the values in tests
    MockServiceParams.GetPutOptionsParams[] getPutOptionsCalls;
    MockServiceParams.GetCallOptionsParams[] getCallOptionsCalls;
    MockServiceParams.BuyOptionParams[] buyOptionCalls;
    MockServiceParams.SellOptionParams[] sellOptionCalls;
    MockServiceParams.ExerciseOptionParams[] exerciseOptionCalls;

    function getPutOptions(address baseAsset)
        external
        view
        override
        returns (OptionsModel.Option[] memory)
    {
        getPutOptionsCalls.push(
            MockServiceParams.GetPutOptionsParams(baseAsset)
        );
        OptionsModel.Option[] memory putOptions = new OptionsModel.Option[](1);
        putOptions[0] = OptionsModel.Option(
            OptionsModel.OptionMarket.MOCKSERVICE,
            OptionsModel.OptionType.PUT,
            1,
            2,
            address(0),
            address(0),
            address(0)
        );
        return putOptions;
    }

    function getCallOptions(address baseAsset)
        external
        view
        override
        returns (OptionsModel.Option[] memory)
    {
        getCallOptionsCalls.push(
            MockServiceParams.GetCallOptionsParams(baseAsset)
        );
        OptionsModel.Option[] memory callOptions = new OptionsModel.Option[](1);
        callOptions[0] = OptionsModel.Option(
            OptionsModel.OptionMarket.MOCKSERVICE,
            OptionsModel.OptionType.CALL,
            3,
            4,
            address(0),
            address(0),
            address(0)
        );
        return callOptions;
    }

    function getBuyPrice(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return 1;
    }

    function getSellPrice(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return 1;
    }

    function buyOptions(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable override returns (OptionsModel.OwnedOption memory) {
        buyOptionCalls.push(
            MockServiceParams.BuyOptionParams(
                option,
                amountToBuy,
                paymentTokenAddress
            )
        );

        OptionsModel.Option memory mockOption = OptionsModel.Option(
            OptionsModel.OptionMarket.MOCKSERVICE,
            OptionsModel.OptionType.CALL,
            3,
            4,
            address(0),
            address(0),
            address(0)
        );

        OptionsModel.OwnedOption memory ownedOption = OptionsModel.OwnedOption(
            mockOption,
            1,
            1
        );

        return ownedOption;
    }

    function sellOptions(
        OptionsModel.OwnedOption memory ownedOption,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external override {
        sellOptionCalls.push(
            MockServiceParams.SellOptionParams(
                ownedOption,
                amountToSell,
                payoutTokenAddress
            )
        );
    }

    function exerciseOptions(
        OptionsModel.OwnedOption memory ownedOption,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable override {
        exerciseOptionCalls.push(
            MockServiceParams.ExerciseOptionParams(
                ownedOption,
                amountToExercise,
                vaultOwners
            )
        );
    }

    function getAvailableBuyLiquidity(OptionsModel.Option memory option)
        external
        view
        override
        returns (uint256)
    {
        return 1;
    }

    function getAvailableBuyLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 minPricePerOption,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return 1;
    }

    function getAvailableSellLiquidity(OptionsModel.Option memory option)
        external
        view
        override
        returns (uint256)
    {
        return 1;
    }

    function getAvailableSellLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 minPricePerOption,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return 1;
    }
}
/* solhint-disable */
