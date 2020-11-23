// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

library OptionsModel {
    enum OptionStyle {ADDRESS, ATTRIBUTE}

    enum OptionType {CALL, PUT}

    enum OptionMarket {CONVEXITY, HEGIC}

    struct Option {
        //TODO: I dont think the consumer needs to be aware of option style anymore.
        //TODO: could probably remove this.
        OptionStyle optionStyle;
        OptionMarket optionMarket;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
        address tokenAddress;
        //address settlementAsset;
        //address paymentAsset;
    }
}
