// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./OptionsModel.sol";

contract OptionsStore {
    using SafeMath for uint256;

    uint256 public currentOptionIndex = 0;
    mapping(uint256 => OptionsModel.Option) public options;

    function createOption(
        OptionsModel.OptionStyle optionStyle,
        OptionsModel.OptionMarket optionMarket,
        OptionsModel.OptionType optionType,
        uint256 strikePrice,
        uint256 expiryDate,
        address tokenAddress
    ) public returns (uint256) {
        currentOptionIndex = currentOptionIndex.add(1);

        //clear any values if there are any (there shouldnt be)
        delete (options[currentOptionIndex]);

        options[currentOptionIndex] = OptionsModel.Option(
            optionStyle,
            optionMarket,
            optionType,
            strikePrice,
            expiryDate,
            tokenAddress
        );

        return currentOptionIndex;
    }

    function getOptionFromID(uint256 optionID)
        public
        view
        returns (OptionsModel.Option memory)
    {
        return options[optionID];
    }

    function getOptionCount() public view returns (uint256) {
        return currentOptionIndex;
    }
}
