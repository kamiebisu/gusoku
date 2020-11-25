// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

library OptionsModel {
    enum OptionType {CALL, PUT}

    enum OptionMarket {CONVEXITY, HEGIC}

    struct Option {
        OptionMarket optionMarket;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
        address tokenAddress;
        //address settlementAsset;
        //address paymentAsset;
    }
}
