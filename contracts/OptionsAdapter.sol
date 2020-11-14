// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Options {}

library OptionsAdapter {
    function getPutOptions(Options options)
        external
        view
        returns (address[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getPutOptions()")
        );
        require(success, "OptionsAdapter: getPutOptions staticcall failed");
        return abi.decode(result, (address[]));
    }
}