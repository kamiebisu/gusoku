// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./IOptionsProtocolAdapter.sol";
import "../adapters/domain/OptionsModel.sol";

/// @title Options adapter interface
/// @author The Gusoku contributors
/// @notice Interface that allows uniformly interacting with different options protocols
/// @dev Every options protocol adapter MUST implement this interface
interface IDiscreteOptionsProtocolAdapter is IOptionsProtocolAdapter {
    ///@notice Query and return available PUT options
    function getPutOptions()
        external
        view
        returns (OptionsModel.Option[] memory);

    ///@notice Query and return available CALL options
    function getCallOptions()
        external
        view
        returns (OptionsModel.Option[] memory);

    ///@notice Sell a given PUT or CALL option
    function sellOptions(
        OptionsModel.Option memory option,
        address payoutTokenAddress,
        uint256 amountToSell
    ) external;
}
