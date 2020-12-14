// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../domain/OptionsModel.sol";

library MockServiceParams {
    struct GetPutOptionsParams {
        address baseAsset;
    }

    struct GetCallOptionsParams {
        address baseAsset;
    }

    struct GetPriceParams {
        OptionsModel.Option option;
        uint256 amountToBuy;
        address paymentTokenAddress;
    }

    struct BuyOptionParams {
        OptionsModel.Option option;
        uint256 amountToBuy;
        address paymentTokenAddress;
    }

    struct SellOptionParams {
        OptionsModel.OwnedOption option;
        uint256 amountToSell;
        address payoutTokenAddress;
    }

    struct ExerciseOptionParams {
        OptionsModel.OwnedOption option;
        uint256 amountToExercise;
        address[] vaultOwners;
    }
}
