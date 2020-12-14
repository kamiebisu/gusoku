// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../interfaces/IDiscreteOptionsProtocol.sol";
import "../../interfaces/IResellableOptionsProtocol.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IOptionsExchange.sol";
import "./interfaces/IoToken.sol";
import "./interfaces/IUniswapV1Factory.sol";
import "./interfaces/IUniswapV1Exchange.sol";
import "./interfaces/IOracle.sol";
import "../../libraries/strings.sol";
import "../domain/OptionsStore.sol";
import "../domain/OptionsModel.sol";

contract ConvexityAdapter is
    IDiscreteOptionsProtocol,
    IResellableOptionsProtocol
{
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using strings for *;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IOptionsFactory private immutable _optionsFactory;
    IOptionsExchange private immutable _optionsExchange;
    IUniswapV1Factory private immutable _uniswapV1Factory;
    IOracle private immutable _compoundOracle;

    // Tokens that can be used as paymentToken and payoutToken throughout Opyn V1
    // Trying to call functions with tokens not in this set could revert with:
    // "execution reverted: No payout exchange"
    EnumerableSet.AddressSet private _supportedExchangeTokens;

    address private constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(address[] memory supportedTokens) {
        _optionsFactory = IOptionsFactory(
            0xcC5d905b9c2c8C9329Eb4e25dc086369D6C7777C
        );
        _optionsExchange = IOptionsExchange(
            0x39246c4F3F6592C974EBC44F80bA6dC69b817c71
        );
        _uniswapV1Factory = IUniswapV1Factory(
            0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
        );
        _compoundOracle = IOracle(0x7054e08461e3eCb7718B63540adDB3c3A1746415);

        for (uint8 i = 0; i < supportedTokens.length; i++) {
            _supportedExchangeTokens.add(supportedTokens[i]);
        }
    }

    ///@notice Get the option strikePrice
    ///@dev Handles negative exponents by considering oToken.decimals() and strike.decimals()
    function _getStrikePrice(IoToken oToken, OptionsModel.OptionType optionType)
        internal
        view
        returns (uint256 strikePrice)
    {
        (uint256 value, int32 exponent) = oToken.strikePrice();

        uint8 strikeDecimals;
        if (oToken.strike() != address(0)) {
            ERC20 strike = ERC20(oToken.strike());
            strikeDecimals = strike.decimals();
        } else {
            // strike is ETH
            strikeDecimals = 18;
        }

        if (optionType == OptionsModel.OptionType.PUT) {
            strikePrice = value.mul(
                10 **
                    uint256(
                        int256(exponent).add(oToken.decimals()).add(
                            strikeDecimals
                        )
                    )
            );
        } else {
            // oToken is a CALL option
            strikePrice = (10 **
                uint256(
                    int256(exponent).mul(-1).sub(oToken.decimals()).add(
                        strikeDecimals
                    )
                ))
                .div(value);
        }
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
                    strikePrice: _getStrikePrice(oToken, _optionType),
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

    ///@notice Checks if a given token is valid to be used as paymentToken and payoutToken
    function _checkTokenValidity(address token)
        internal
        view
        returns (bool isValid)
    {
        isValid =
            _supportedExchangeTokens.contains(token) ||
            _compoundOracle.getPrice(token) != 0;
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

    function _getAvailableLiquidity(OptionsModel.Option memory option)
        internal
        view
        returns (uint256)
    {
        IoToken optionToken = IoToken(option.tokenAddress);
        return
            optionToken
                .balanceOf(
                _uniswapV1Factory.getExchange(option.tokenAddress)
                // subtract 1 since trying to get/use all the liquidity
                // would raise a 'invalid jump destination' error
            )
                .sub(1);
    }

    function getAvailableBuyLiquidity(OptionsModel.Option memory option)
        external
        view
        override
        returns (uint256)
    {
        return _getAvailableLiquidity(option);
    }

    function _getAvailableLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 optionPrice,
        address tokenAddress
    ) internal view returns (uint256 availableLiquidity) {
        // Make sure price is in ETH
        if (tokenAddress != address(0) && tokenAddress != _WETH) {
            optionPrice = optionPrice.mul(
                _compoundOracle.getPrice(tokenAddress)
            );
        }

        // Get the reserve of ETH in the Uniswap V1 ETH <-> oToken pair
        address exchange = _uniswapV1Factory.getExchange(option.tokenAddress);
        uint256 reserveETH = exchange.balance;

        // Get the reserve of options (oToken)
        IoToken oToken = IoToken(option.tokenAddress);
        uint256 reserveOptions = oToken.balanceOf(exchange);

        // An explanation for how the following formula was derived can be found at:
        // https://ipfs.io/ipfs/bafybeid4u5dib37kbikwa77u6v2u3fzfhiu3r4zg4hxqjzhmnekpk3bspq
        availableLiquidity = (
            uint256(1000).mul(reserveOptions).mul(optionPrice)
        )
            .div((uint256(997).mul(reserveETH.sub(optionPrice))));
    }

    function getAvailableBuyLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 maxPricePerOption,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        require(
            _checkTokenValidity(paymentTokenAddress),
            "ConvexityAdapter.getAvailableBuyLiquidityAtPrice: paymentTokenAddress is not supported"
        );

        return
            _getAvailableLiquidityAtPrice(
                option,
                maxPricePerOption,
                paymentTokenAddress
            );
    }

    function getBuyPrice(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        require(
            _checkTokenValidity(paymentTokenAddress),
            "ConvexityAdapter.getBuyPrice: paymentTokenAddress is not supported"
        );

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
        require(
            _checkTokenValidity(paymentTokenAddress),
            "ConvexityAdapter.buyOptions: paymentTokenAddress is not supported"
        );

        // Need to approve any ERC20 before spending it
        IERC20 paymentToken = IERC20(paymentTokenAddress);
        if (paymentTokenAddress != address(0)) {
            paymentToken.safeApprove(address(_optionsExchange), 0);
            paymentToken.safeApprove(address(_optionsExchange), amountToBuy);
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

        address underlyingAddress = optionToken.underlying();
        IERC20 underlyingToken = IERC20(underlyingAddress);
        uint256 underlyingAmountRequired = optionToken
            .underlyingRequiredToExercise(amountToExercise);

        // Perform checks required for the exercising of options to succeed
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

        // Approve the oToken contract to spend amountToExercise from the caller's balance
        IERC20(option.tokenAddress).safeApprove(option.tokenAddress, 0);
        IERC20(option.tokenAddress).safeApprove(
            option.tokenAddress,
            amountToExercise
        );

        // Approve the oToken contract to spend the caller's underlyingToken balance
        if (underlyingAddress != address(0)) {
            underlyingToken.safeApprove(option.tokenAddress, 0);
            underlyingToken.safeApprove(
                option.tokenAddress,
                underlyingAmountRequired
            );
        }

        optionToken.exercise{value: msg.value}(amountToExercise, vaultOwners);
    }

    function sellOptions(
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external override {
        require(
            _checkTokenValidity(payoutTokenAddress),
            "ConvexityAdapter.sellOptions: payoutTokenAddress is not supported"
        );

        IERC20(option.tokenAddress).safeApprove(address(_optionsExchange), 0);
        IERC20(option.tokenAddress).safeApprove(
            address(_optionsExchange),
            amountToSell
        );

        _optionsExchange.sellOTokens(
            address(this),
            option.tokenAddress,
            payoutTokenAddress,
            amountToSell
        );
    }

    function getAvailableSellLiquidity(OptionsModel.Option memory option)
        external
        view
        override
        returns (uint256)
    {
        return _getAvailableLiquidity(option);
    }

    function getAvailableSellLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 minPricePerOption,
        address payoutTokenAddress
    ) external view override returns (uint256) {
        require(
            _checkTokenValidity(payoutTokenAddress),
            "ConvexityAdapter.getAvailableSellLiquidityAtPrice: payoutTokenAddress is not supported"
        );

        return
            _getAvailableLiquidityAtPrice(
                option,
                minPricePerOption,
                payoutTokenAddress
            );
    }

    function getSellPrice(
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external view override returns (uint256) {
        require(
            _checkTokenValidity(payoutTokenAddress),
            "ConvexityAdapter.getSellPrice: payoutTokenAddress is not supported"
        );

        return
            _optionsExchange.premiumReceived(
                option.tokenAddress,
                payoutTokenAddress,
                amountToSell
            );
    }
}
