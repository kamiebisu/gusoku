// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

/// @title Options adapter interface
/// @author The Gusoku contributors
/// @notice Interface that allows uniformly interacting with different options protocols
/// @dev Every options protocol adapter MUST implement this interface
interface IOptionsProtocolAdapterV2 {
    ///@notice Query and return price for a given PUT or CALL option
    function getPrice(
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view returns (uint256);

    ///@notice Buy a given PUT or CALL option
    ///@dev The function is payable because it needs to be able to receive ETH as a paymentToken
    function buyOptions(
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable;

    ///@notice Exercise a given PUT or CALL option
    function exerciseOptions(
        uint256 optionID,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable;

    ///@notice should be false for AMM and true for discrete protocol
    //function isDiscrete() external view returns (bool);
}
