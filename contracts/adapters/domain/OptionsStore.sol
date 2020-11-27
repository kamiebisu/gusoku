// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./OptionsModel.sol";

contract OptionsStore {
    using SafeMath for uint256;

    uint256 public currentOptionIndex = 0;
    mapping(uint256 => OptionsModel.Option) public options;

    function createOption(
        OptionsModel.OptionMarket optionMarket,
        OptionsModel.OptionType optionType,
        uint256 strikePrice,
        uint256 expiryDate,
        address tokenAddress,
        address settlementAsset,
        address paymentAsset
    ) public returns (uint256) {
        currentOptionIndex = currentOptionIndex.add(1);

        //clear any values if there are any (there shouldnt be)
        delete (options[currentOptionIndex]);

        options[currentOptionIndex] = OptionsModel.Option(
            optionMarket,
            optionType,
            strikePrice,
            expiryDate,
            tokenAddress,
            settlementAsset,
            paymentAsset
        );

        return currentOptionIndex;
    }
}
