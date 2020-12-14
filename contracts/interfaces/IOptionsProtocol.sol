// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "../adapters/domain/OptionsModel.sol";

/// @title Base options protocol interface
/// @author The Gusoku contributors
/// @notice Interface that allows uniformly interacting with different options protocols
/// @dev Every options protocol adapter MUST implement this interface
interface IOptionsProtocol {
    //@notice Get available amount to buy for a certain baseAsset. Should be called before buy
    function getAvailableBuyLiquidity(OptionsModel.Option memory option)
        external
        view
        returns (uint256);

    //@notice Get amount of options available at and below a certain price
    function getAvailableBuyLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 maxPricePerOption,
        address paymentTokenAddress
    ) external view returns (uint256);

    ///@notice Query and return price for a given PUT or CALL option
    function getBuyPrice(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view returns (uint256);

    ///@notice Buy a given PUT or CALL option
    ///@dev The function is payable because it needs to be able to receive ETH as a paymentToken
    function buyOptions(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable;

    ///@notice Exercise a given PUT or CALL option
    function exerciseOptions(
        OptionsModel.Option memory option,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable;
}
