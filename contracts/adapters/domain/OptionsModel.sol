// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

library OptionsModel {
    enum OptionMarket {CONVEXITY, HEGIC, MOCKSERVICE}

    enum OptionType {CALL, PUT}

    struct Option {
        OptionMarket optionMarket;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
        address tokenAddress;
        address settlementAsset;
        address paymentAsset;
    }
}
