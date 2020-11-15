// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../interfaces/IOptionsAdapter.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IOptionsExchange.sol";
import "./interfaces/IoToken.sol";
import "../../libraries/strings.sol";

contract ConvexityAdapter is IOptionsAdapter {
    using SafeMath for uint256;
    using strings for *;

    IOptionsFactory immutable optionsFactory;
    IOptionsExchange immutable optionsExchange;

    constructor() {
        optionsFactory = IOptionsFactory(
            0xcC5d905b9c2c8C9329Eb4e25dc086369D6C7777C
        );
        optionsExchange = IOptionsExchange(
            0x39246c4F3F6592C974EBC44F80bA6dC69b817c71
        );
    }

    function getFilteredOptions(string memory _filter)
        internal
        view
        returns (address[] memory)
    {
        uint256 numOptionsContracts = optionsFactory
            .getNumberOfOptionsContracts();

        // Options created by the OptionsFactory
        address[] memory createdOptions = new address[](numOptionsContracts);

        IoToken oToken;
        uint256 optionIndex = 0;
        for (uint256 i = 0; i < numOptionsContracts; i++) {
            address oTokenAddress = optionsFactory.optionsContracts(i);
            oToken = IoToken(oTokenAddress);
            // Only add options that have not expired yet
            if (
                // Use the strings library functions: toSlice(), contains()
                (oToken.name().toSlice().contains(_filter.toSlice()) ||
                    oToken.symbol().toSlice().contains(_filter.toSlice())) &&
                !oToken.hasExpired() &&
                oToken.expiry() > block.timestamp
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
        return getFilteredOptions("Put");
    }

    function getCallOptions()
        external
        view
        override
        returns (address[] memory)
    {
        return getFilteredOptions("Call");
    }

    function getPrice(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external view override returns (uint256) {
        return
            optionsExchange.premiumToPay(
                optionAddress,
                paymentTokenAddress,
                amountToBuy
            );
    }

    function buyOption(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external payable override {
        optionsExchange.buyOTokens(
            msg.sender,
            optionAddress,
            paymentTokenAddress,
            amountToBuy
        );
    }
}
