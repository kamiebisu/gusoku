// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../interfaces/IDiscreteOptionsProtocol.sol";
import "../../interfaces/IResellableOptionsProtocol.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IOptionsExchange.sol";
import "./interfaces/IoToken.sol";
import "./interfaces/IUniswapV1Factory.sol";
import "./interfaces/IUniswapV1Exchange.sol";
import "../../libraries/strings.sol";
import "../domain/OptionsStore.sol";
import "../domain/OptionsModel.sol";

contract ConvexityAdapter is
    IDiscreteOptionsProtocol,
    IResellableOptionsProtocol
{
    using SafeMath for uint256;
    using strings for *;

    IOptionsFactory private immutable _optionsFactory;
    IOptionsExchange private immutable _optionsExchange;
    IUniswapV1Factory private immutable _uniswapV1Factory;

    constructor() {
        _optionsFactory = IOptionsFactory(
            0xcC5d905b9c2c8C9329Eb4e25dc086369D6C7777C
        );
        _optionsExchange = IOptionsExchange(
            0x39246c4F3F6592C974EBC44F80bA6dC69b817c71
        );
        _uniswapV1Factory = IUniswapV1Factory(
            0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
        );
    }

    ///@notice Get the option strikePrice
    ///@dev Handles negative exponents by considering the number of decimals of the strikeAsset
    function _getStrikePrice(IoToken oToken)
        internal
        view
        returns (uint256 strikePrice)
    {
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
        strikePrice = value * 10**uint256(exponent + decimals);
    }

    function _getFilteredOptions(
        OptionsModel.OptionType _optionType,
        address baseAsset
    ) internal view returns (OptionsModel.Option[] memory) {
        uint256 numOptionsContracts = _optionsFactory
            .getNumberOfOptionsContracts();

        OptionsModel.Option[] memory currentOptions = new OptionsModel.Option[](
            numOptionsContracts
        );
        uint256 numFilteredOptions = 0;
        for (uint256 i = 0; i < numOptionsContracts; i++) {
            address oTokenAddress = _optionsFactory.optionsContracts(i);
            IoToken oToken = IoToken(oTokenAddress);
            string memory filter = _optionType == OptionsModel.OptionType.PUT
                ? "Put"
                : "Call";

            if (
                !oToken.hasExpired() &&
                ((_optionType == OptionsModel.OptionType.PUT &&
                    oToken.underlying() == baseAsset) ||
                    (_optionType == OptionsModel.OptionType.CALL &&
                        oToken.strike() == baseAsset)) &&
                (oToken.name().toSlice().contains(filter.toSlice()) ||
                    oToken.symbol().toSlice().contains(filter.toSlice()))
            ) {
                currentOptions[numFilteredOptions] = OptionsModel.Option({
                    optionMarket: OptionsModel.OptionMarket.CONVEXITY,
                    optionType: _optionType,
                    strikePrice: _getStrikePrice(oToken),
                    expiryDate: oToken.expiry(),
                    tokenAddress: oTokenAddress,
                    settlementAsset: oToken.strike(),
                    paymentAsset: address(0)
                });
                numFilteredOptions = numFilteredOptions.add(1);
            }
        }

        // Trim array removing zero addresses, just for simplicity when it's consumed.


            OptionsModel.Option[] memory filteredOptions
         = new OptionsModel.Option[](numFilteredOptions);

        for (uint256 i = 0; i < numFilteredOptions; i++) {
            filteredOptions[i] = currentOptions[i];
        }

        return filteredOptions;
    }

    function getPutOptions(address baseAsset)
        external
        view
        override
        returns (OptionsModel.Option[] memory)
    {
        return _getFilteredOptions(OptionsModel.OptionType.PUT, baseAsset);
    }

    function getCallOptions(address baseAsset)
        external
        view
        override
        returns (OptionsModel.Option[] memory)
    {
        return _getFilteredOptions(OptionsModel.OptionType.CALL, baseAsset);
    }

    function getAvailableBuyLiquidity(OptionsModel.Option memory option)
        external
        view
        override
        returns (uint256)
    {
        IoToken optionToken = IoToken(option.tokenAddress);
        return
            optionToken.balanceOf(
                _uniswapV1Factory.getExchange(option.tokenAddress)
            ) / 10**optionToken.decimals();
    }

    function getAvailableBuyLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 maxPriceToPay,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        // Payment token is ETH
        if (paymentTokenAddress == address(0)) {
            IoToken optionToken = IoToken(option.tokenAddress);
            IUniswapV1Exchange exchange = IUniswapV1Exchange(
                _uniswapV1Factory.getExchange(option.tokenAddress)
            );
            return exchange.getEthToTokenInputPrice(maxPriceToPay);
        }

        // Payment token is some ERC20
        uint256 oTokensToBuy = 1;
        while (
            _optionsExchange.premiumToPay(
                option.tokenAddress,
                paymentTokenAddress,
                oTokensToBuy
            ) <= maxPriceToPay
        ) {
            oTokensToBuy.add(1);
        }
        return oTokensToBuy;
    }

    function getBuyPrice(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return
            _optionsExchange.premiumToPay(
                option.tokenAddress,
                paymentTokenAddress,
                amountToBuy
            );
    }

    function buyOptions(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable override {
        // Need to approve any ERC20 before spending it
        IERC20 paymentToken = IERC20(paymentTokenAddress);
        if (
            paymentTokenAddress != address(0) &&
            paymentToken.allowance(address(this), address(_optionsExchange)) !=
            type(uint256).max
        ) {
            paymentToken.approve(address(_optionsExchange), 0);
            paymentToken.approve(address(_optionsExchange), type(uint256).max);
        }

        _optionsExchange.buyOTokens(
            address(this),
            option.tokenAddress,
            paymentTokenAddress,
            amountToBuy
        );
    }

    function exerciseOptions(
        OptionsModel.Option memory option,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable override {
        IoToken optionToken = IoToken(option.tokenAddress);

        // Approve the oToken contract to transfer the caller's optionToken balance
        if (
            optionToken.allowance(address(this), option.tokenAddress) !=
            type(uint256).max
        ) {
            optionToken.approve(option.tokenAddress, 0);
            optionToken.approve(option.tokenAddress, type(uint256).max);
        }

        address underlyingAddress = optionToken.underlying();
        IERC20 underlyingToken = IERC20(underlyingAddress);

        // Approve the oToken contract to transfer the caller's underlyingToken balance
        if (
            underlyingAddress != address(0) &&
            underlyingToken.allowance(address(this), option.tokenAddress) !=
            type(uint256).max
        ) {
            underlyingToken.approve(option.tokenAddress, 0);
            underlyingToken.approve(option.tokenAddress, type(uint256).max);
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
