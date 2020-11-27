// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../interfaces/IDiscreteOptionsProtocolAdapter.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IOptionsExchange.sol";
import "./interfaces/IoToken.sol";
import "../../libraries/strings.sol";
import "hardhat/console.sol";
import "../domain/OptionsStore.sol";
import "../domain/OptionsModel.sol";

contract ConvexityAdapter is IDiscreteOptionsProtocolAdapter, OptionsStore {
    using SafeMath for uint256;
    using strings for *;

    IOptionsFactory private immutable _optionsFactory;
    IOptionsExchange private immutable _optionsExchange;

    constructor() {
        _optionsFactory = IOptionsFactory(
            0xcC5d905b9c2c8C9329Eb4e25dc086369D6C7777C
        );
        _optionsExchange = IOptionsExchange(
            0x39246c4F3F6592C974EBC44F80bA6dC69b817c71
        );
    }

    function _updateOptionsStore() internal {
        uint256 numOptionsContracts = _optionsFactory
            .getNumberOfOptionsContracts();
        uint256 currentOptionIndex = this.currentOptionIndex();
        if (numOptionsContracts != currentOptionIndex) {
            for (uint256 i = currentOptionIndex; i < numOptionsContracts; i++) {
                // Get the oToken contract
                address oTokenAddress = _optionsFactory.optionsContracts(i);
                IoToken oToken = IoToken(oTokenAddress);

                // Differentiate between PUT and CALL options
                bool isPut = oToken.name().toSlice().contains("Put".toSlice());

                // Get the option strikePrice, handling negative exponents by considering
                // the number of decimals of the strikeAsset
                (uint256 value, int32 exponent) = oToken.strikePrice();
                address strikeAddress = oToken.strike();
                uint8 decimals;
                if (strikeAddress == address(0)) {
                    // strike is ETH
                    decimals = 18;
                } else {
                    ERC20 strikeAsset = ERC20(oToken.strike());
                    decimals = strikeAsset.decimals();
                }
                uint256 strikePrice = value * 10**uint256(exponent + decimals);

                // Create an Option struct and save it to the OptionsStore
                createOption(
                    OptionsModel.OptionMarket.CONVEXITY,
                    isPut
                        ? OptionsModel.OptionType.PUT
                        : OptionsModel.OptionType.CALL,
                    strikePrice,
                    oToken.expiry(),
                    oTokenAddress,
                    strikeAddress,
                    address(0) // Default to ETH for now
                );
            }
        }
    }

    function _getFilteredOptions(OptionsModel.OptionType _optionType)
        internal
        returns (OptionsModel.Option[] memory)
    {
        // First, update the options cache if necessary
        _updateOptionsStore();

        OptionsModel.Option[] memory currentOptions = new OptionsModel.Option[](
            currentOptionIndex
        );
        uint256 numFilteredOptions = 0;
        for (uint256 i = 0; i < currentOptionIndex; i++) {
            if (options[i].optionType == _optionType) {
                currentOptions[numFilteredOptions] = options[i];
                numFilteredOptions = numFilteredOptions.add(1);
            }
        }

        // Trim array removing zero addresses, just for simplicity when it's consumed.
        // No gas is saved anyways.


            OptionsModel.Option[] memory filteredOptions
         = new OptionsModel.Option[](numFilteredOptions);

        for (uint256 i = 0; i < numFilteredOptions; i++) {
            filteredOptions[i] = currentOptions[i];
        }

        return filteredOptions;
    }

    function getPutOptions()
        external
        view
        override
        returns (OptionsModel.Option[] memory)
    {
        return _getFilteredOptions(OptionsModel.OptionType.PUT);
    }

    function getCallOptions()
        external
        view
        override
        returns (OptionsModel.Option[] memory)
    {
        return _getFilteredOptions(OptionsModel.OptionType.CALL);
    }

    function getPrice(
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return
            _optionsExchange.premiumToPay(
                options[optionID].tokenAddress,
                paymentTokenAddress,
                amountToBuy
            );
    }

    function buyOptions(
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable override {
        address optionAddress = options[optionID].tokenAddress;
        // Need to approve any ERC20 before spending it
        IERC20 paymentToken = IERC20(paymentTokenAddress);
        if (
            paymentTokenAddress != address(0) &&
            paymentToken.allowance(address(this), address(_optionsExchange)) !=
            type(uint256).max
        ) {
            paymentToken.approve(address(_optionsExchange), type(uint256).max);
        }

        _optionsExchange.buyOTokens(
            address(this),
            optionAddress,
            paymentTokenAddress,
            amountToBuy
        );
    }

    function sellOptions(
        uint256 optionID,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external override {
        address optionAddress = options[optionID].tokenAddress;
        // Need to approve the oToken before spending it
        IoToken optionToken = IoToken(optionAddress);
        if (
            optionToken.allowance(address(this), address(_optionsExchange)) !=
            type(uint256).max
        ) {
            optionToken.approve(address(_optionsExchange), type(uint256).max);
        }

        _optionsExchange.sellOTokens(
            address(this),
            optionAddress,
            payoutTokenAddress,
            amountToSell
        );
    }

    function exerciseOptions(
        uint256 optionID,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable override {
        address optionAddress = options[optionID].tokenAddress;
        IoToken optionToken = IoToken(optionAddress);

        // Approve the oToken contract to transfer the caller's optionToken balance
        if (
            optionToken.allowance(address(this), optionAddress) !=
            type(uint256).max
        ) {
            optionToken.approve(optionAddress, type(uint256).max);
        }

        address underlyingAddress = optionToken.underlying();
        IERC20 underlyingToken = IERC20(underlyingAddress);

        // Approve the oToken contract to transfer the caller's underlyingToken balance
        if (
            underlyingAddress != address(0) &&
            underlyingToken.allowance(address(this), optionAddress) !=
            type(uint256).max
        ) {
            underlyingToken.approve(optionAddress, type(uint256).max);
        }

        uint256 underlyingAmountRequired = optionToken
            .underlyingRequiredToExercise(amountToExercise);

        require(
            optionToken.isExerciseWindow() == true,
            "ConvexityAdapter: can only exercise during the exericse window"
        );

        if (underlyingAddress == address(0)) {
            require(
                address(this).balance >= underlyingAmountRequired,
                "ConvexityAdapter: insufficient underlying (ETH) to exercise"
            );
        } else {
            require(
                underlyingToken.balanceOf(address(this)) >=
                    underlyingAmountRequired,
                "ConvexityAdapter: insufficient underlying to exercise"
            );
        }

        optionToken.exercise{value: msg.value}(amountToExercise, vaultOwners);
    }
}
