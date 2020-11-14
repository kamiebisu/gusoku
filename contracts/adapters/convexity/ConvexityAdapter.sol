// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../interfaces/IOptionsAdapter.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IoToken.sol";
import "../../libraries/strings.sol";

contract ConvexityAdapter is IOptionsAdapter {
    using SafeMath for uint256;
    using strings for *;

    IOptionsFactory immutable optionsFactory;

    constructor() {
        optionsFactory = IOptionsFactory(
            0xcC5d905b9c2c8C9329Eb4e25dc086369D6C7777C
        );
    }

    function getPutOptions() external view override returns (address[] memory) {
        uint256 numOptionsContracts = optionsFactory
            .getNumberOfOptionsContracts();

        // Options created by the OptionsFactory
        address[] memory createdPutOptions = new address[](numOptionsContracts);

        IoToken oToken;
        uint256 optionIndex = 0;
        for (uint256 i = 0; i < numOptionsContracts; i++) {
            address oTokenAddress = optionsFactory.optionsContracts(i);
            oToken = IoToken(oTokenAddress);
            // Only add PUT options that have not expired yet
            if (
                // Use the strings library functions: toSlice(), contains()
                (oToken.name().toSlice().contains("Put".toSlice()) ||
                    oToken.symbol().toSlice().contains("Put".toSlice())) &&
                !oToken.hasExpired() &&
                oToken.expiry() > block.timestamp
            ) {
                createdPutOptions[optionIndex] = oTokenAddress;
                optionIndex = optionIndex.add(1);
            }
        }

        // Trim array removing zero addresses, just for simplicity when it's consumed.
        // No gas is saved anyways.
        address[] memory nonExpiredPutOptions = new address[](optionIndex);
        for (uint256 i = 0; i < optionIndex; i++) {
            nonExpiredPutOptions[i] = createdPutOptions[i];
        }

        return nonExpiredPutOptions;
    }
}
