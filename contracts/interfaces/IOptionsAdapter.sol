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
}
