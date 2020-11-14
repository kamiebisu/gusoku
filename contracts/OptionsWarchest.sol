// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./OptionsAdapter.sol";

contract OptionsWarchest {
    using OptionsAdapter for Options;

    Options convexity;

    constructor(address _convexity) {
        convexity = Options(_convexity);
    }

    function getConvexityPutOptions() public view returns (address[] memory) {
        return convexity.getPutOptions();
    }

    function getConvexityCallOptions() public view returns (address[] memory) {
        return convexity.getCallOptions();
    }
}
