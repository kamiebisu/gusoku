// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

    function getConvexityOptionPrice(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) public view returns (uint256) {
        return
            convexity.getPrice(optionAddress, paymentTokenAddress, amountToBuy);
    }

    function convexityBuyOption(
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) public payable {
        // Ensure that the msg.sender has sufficient paymentTokens before buying the options
        uint256 premiumToPay = convexity.getPrice(
            optionAddress,
            paymentTokenAddress,
            amountToBuy
        );
        if (paymentTokenAddress == address(0)) {
            require(
                msg.sender.balance >= premiumToPay,
                "OptionsWarchest: msg.sender doesn't have a sufficient balance to buy the options"
            );
        } else {
            IERC20 paymentToken = IERC20(paymentTokenAddress);
            require(
                paymentToken.balanceOf(msg.sender) >= premiumToPay,
                "OptionsWarchest: msg.sender doesn't have a sufficient balance to buy the options"
            );
        }

        convexity.buyOption(optionAddress, paymentTokenAddress, amountToBuy);
    }
}
