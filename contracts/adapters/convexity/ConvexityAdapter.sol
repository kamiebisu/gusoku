// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../interfaces/IOptionsAdapter.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IoToken.sol";

contract ConvexityAdapter is IOptionsAdapter {
    using SafeMath for uint256;

    IOptionsFactory immutable optionsFactory;

    constructor() {
        optionsFactory = IOptionsFactory(
            0xcC5d905b9c2c8C9329Eb4e25dc086369D6C7777C
        );
    }

    function getPutOptions() external view override returns (address[] memory) {
        uint256 numOptionsContracts = optionsFactory
            .getNumberOfOptionsContracts();

        IoToken oToken;
        address[] memory availablePutOptions;
        uint256 optionIndex = 0;
        for (uint256 i = 0; i < numOptionsContracts; i++) {
            address oTokenAddress = optionsFactory.optionsContracts(i);
            oToken = IoToken(oTokenAddress);
            if (!oToken.hasExpired() && oToken.expiry() > block.timestamp) {
                availablePutOptions[optionIndex] = oTokenAddress;
                optionIndex.add(1);
            }
        }

        return availablePutOptions;
    }
}
