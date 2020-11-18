// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/IOptionsProtocolAdapter.sol";
import "./interfaces/IHegicOptions.sol";
import "../../libraries/strings.sol";
import "../domain/OptionsStore.sol";

contract HegicAdapter is OptionsStore {
    using SafeMath for uint256;
    using strings for *;

    //base asset => pool details
    mapping(address => HegicPool) internal _optionPools;

    struct HegicPool {
        address poolAddress;
        address settlementAsset; //WBTC or ETH
        address paymentAsset; //We always pay in ETH for options on Hegic
    }

    constructor() {
        //ETH option
        _optionPools[0x0000000000000000000000000000000000000000] = HegicPool(
            0xEfC0eEAdC1132A12c9487d800112693bf49EcfA2,
            0x0000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000
        );

        //WBTC option
        _optionPools[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = HegicPool(
            0x20DD9e22d22dd0a6ef74a520cb08303B5faD5dE7,
            0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
            0x0000000000000000000000000000000000000000
        );
    }

    function getPrice(
        uint256 optionID,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external view returns (uint256) {
        OptionAttributes memory attributes = _attributeDetails[optionID];

        //TODO: this address needs to not be hardcoded and come from a param...
        (uint256 total, , , ) = IHegicOptions(
            0x0000000000000000000000000000000000000000
        )
            .fees(
            attributes.expiryDate.sub(block.timestamp),
            amountToBuy,
            attributes.strikePrice,
            attributes.optionType == OptionType.PUT ? 1 : 2
        );

        return total;
    }

    function buyOptions(
        uint256 optionID,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external payable {
        OptionAttributes memory attributes = _attributeDetails[optionID];

        //TODO: this address needs to not be hardcoded and come from a param...
        //TODO: We need to store the return option id in the store as purchased option with details
        uint256 hegicOptionID = IHegicOptions(
            0x0000000000000000000000000000000000000000
        )
            .create(
            attributes.expiryDate.sub(block.timestamp),
            amountToBuy,
            attributes.strikePrice,
            attributes.optionType == OptionType.PUT ? 1 : 2
        );
    }

    function exerciseOptions(uint256 optionID, uint256 amountToExercise)
        external
        payable
    {
        //TODO: How do we control how much we exercise, hegic takes a single param...?

        //TODO: We need to fetch the hegicOptionID from the store as a purchased option with details
        //TODO: mocking for now.
        uint8 mockHegicOptionID = 0;

        //TODO: this address needs to not be hardcoded and come from a param...
        IHegicOptions(0x0000000000000000000000000000000000000000).exercise(
            mockHegicOptionID
        );
    }
}
