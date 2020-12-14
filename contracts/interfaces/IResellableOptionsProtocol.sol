// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "./IOptionsProtocol.sol";
import "../adapters/domain/OptionsModel.sol";

/// @title Interface for protocols that allow reselling of options on a secondary market
/// @author The Gusoku contributors
/// @notice For standardising functionality on resellable options
/// @dev See docs in repo for more details on interfaces
interface IResellableOptionsProtocol is IOptionsProtocol {
    ///@notice Sell a given PUT or CALL option
    function sellOptions(
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external;

    ///@notice Get available amount to sell for a certain baseAsset
    function getAvailableSellLiquidity(OptionsModel.Option memory option)
        external
        view
        returns (uint256);

    ///@notice Get amount of options available to sell at a certain price or higher
    function getAvailableSellLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 minPricePerOption,
        address payoutTokenAddress
    ) external view returns (uint256);

    ///@notice Get sell price for a given PUT or CALL option
    function getSellPrice(
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external view returns (uint256);
}
