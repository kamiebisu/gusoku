// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract OptionsStore {
    using SafeMath for uint256;

    uint256 internal _currentOptionIndex = 0;
    mapping(uint256 => Option) internal _options;
    mapping(uint256 => address) internal _addressDetails;
    mapping(uint256 => OptionAttributes) internal _attributeDetails;

    enum OptionStyle {ADDRESS, ATTRIBUTE}

    enum OptionType {CALL, PUT}

    enum OptionMarket {CONVEXITY, HEGIC}

    struct OptionAttributes {
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
    }

    struct Option {
        //TODO: these values will always be the same for each pair so we dont need both
        OptionStyle optionStyle;
        OptionMarket optionMarket;
    }

    function _createAddressOption(
        OptionMarket optionMarket,
        address optionAddress
    ) internal returns (uint256) {
        currentOptionIndex = currentOptionIndex.add(1);

        //clear any values if there are any (there shouldnt be)
        delete (options[currentOptionIndex]);
        delete (addressDetails[currentOptionIndex]);
        delete (attributeDetails[currentOptionIndex]);

        options[currentOptionIndex] = Option(OptionStyle.ADDRESS, optionMarket);
        addressDetails[currentOptionIndex] = optionAddress;

        return currentOptionIndex;
    }

    function _createAttributeOption(
        OptionMarket optionMarket,
        OptionType optionType,
        uint256 strikePrice,
        uint256 expiryDate
    ) internal returns (uint256) {
        currentOptionIndex = currentOptionIndex++;

        //clear any values if there are any (there shouldnt be)
        delete (options[currentOptionIndex]);
        delete (addressDetails[currentOptionIndex]);
        delete (attributeDetails[currentOptionIndex]);

        options[currentOptionIndex] = Option(
            OptionStyle.ATTRIBUTE,
            optionMarket
        );
        OptionAttributes memory attributes = OptionAttributes(
            optionType,
            strikePrice,
            expiryDate
        );
        attributeDetails[currentOptionIndex] = attributes;

        return currentOptionIndex;
    }
}
