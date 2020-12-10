// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "./IOptionsProtocol.sol";
import "../adapters/domain/OptionsModel.sol";

/// @title Interface for protocols with a discrete set of options
/// @author The Gusoku contributors
/// @notice Interface that adds functionality for fetching list of calls and puts
/// @dev Options protocols with a discrete set of options should implement this. see docs
interface IDiscreteOptionsProtocol is IOptionsProtocol {
    ///@notice Query and return available PUT options
    function getPutOptions(address baseAsset)
        external
        view
        returns (OptionsModel.Option[] memory);

    ///@notice Query and return available CALL options
    function getCallOptions(address baseAsset)
        external
        view
        returns (OptionsModel.Option[] memory);
}
