// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

library OptionsModel {
    //TODO: Remove this and convert to address
    enum OptionMarket {CONVEXITY, HEGIC, MOCKSERVICE}

    enum OptionType {CALL, PUT}

    struct Option {
        OptionMarket optionMarket;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
        //TODO: add: address baseAsset
        //TODO: rename this to optionTokenAddress to be more explicit
        address tokenAddress;
        address settlementAsset;
        address paymentAsset;
    }

    //TODO: Could add this to option to prevent redundancy...
    struct OptionAttributes {
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
    }

    struct OwnedOption {
        Option option;
        uint256 optionsOwned;
        uint256 protocolOptionID; //only relevant for HEGIC, -1 if irrelevant
    }
}
