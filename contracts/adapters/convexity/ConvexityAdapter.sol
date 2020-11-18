// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/IDiscreteOptionsProtocolAdapter.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IOptionsExchange.sol";
import "./interfaces/IoToken.sol";
import "../../libraries/strings.sol";

contract ConvexityAdapter is IDiscreteOptionsProtocolAdapter {
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

    function _getFilteredOptions(string memory _filter)
        internal
        view
        returns (address[] memory)
    {
        uint256 numOptionsContracts = _optionsFactory
            .getNumberOfOptionsContracts();

        // Options created by the OptionsFactory
        address[] memory createdOptions = new address[](numOptionsContracts);

        IoToken oToken;
        uint256 optionIndex = 0;
        for (uint256 i = 0; i < numOptionsContracts; i++) {
            address oTokenAddress = _optionsFactory.optionsContracts(i);
            oToken = IoToken(oTokenAddress);
            // Only add options that have not expired yet
            if (
                // Use the strings library functions: toSlice(), contains()
                (oToken.name().toSlice().contains(_filter.toSlice()) ||
                    oToken.symbol().toSlice().contains(_filter.toSlice())) &&
                !oToken.hasExpired()
            ) {
                createdOptions[optionIndex] = oTokenAddress;
                optionIndex = optionIndex.add(1);
            }
        }

        // Trim array removing zero addresses, just for simplicity when it's consumed.
        // No gas is saved anyways.
        address[] memory nonExpiredOptions = new address[](optionIndex);
        for (uint256 i = 0; i < optionIndex; i++) {
            nonExpiredOptions[i] = createdOptions[i];
        }

        return nonExpiredOptions;
    }

    function getPutOptions() external view override returns (address[] memory) {
        return _getFilteredOptions("Put");
    }

    function getCallOptions()
        external
        view
        override
        returns (address[] memory)
    {
        return _getFilteredOptions("Call");
    }

    function getPrice(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external view override returns (uint256) {
        return
            _optionsExchange.premiumToPay(
                optionAddress,
                paymentTokenAddress,
                amountToBuy
            );
    }

    function buyOptions(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external payable override {
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
        address optionAddress,
        address payoutTokenAddress,
        uint256 amountToSell
    ) external override {
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

    function exerciseOptions(address optionAddress, uint256 amountToExercise)
        external
        payable
        override
    {
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

        optionToken.exercise{value: msg.value}(
            amountToExercise,
            optionToken.getVaultOwners()
        );
    }
}
