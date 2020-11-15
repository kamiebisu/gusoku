// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/// @title Options adapter interface
/// @author The Gusoku contributors
/// @notice Interface that allows uniformly interacting with different options protocols
/// @dev Every options protocol adapter MUST implement this interface
interface IOptionsAdapter {
    ///@notice Query and return available PUT options
    function getPutOptions() external view returns (address[] memory);

    ///@notice Query and return available CALL options
    function getCallOptions() external view returns (address[] memory);

    ///@notice Query and return price for a given PUT or CALL option
    function getPrice(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external view returns (uint256);

    ///@notice Buy a given PUT or CALL option
    ///@dev The function is payable because it needs to be able to receive ETH as a paymentToken
    function buyOptions(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external payable;

    ///@notice Sell a given PUT or CALL option
    function sellOptions(
        address optionAddress,
        address payoutTokenAddress,
        uint256 amountToSell
    ) external;
}
