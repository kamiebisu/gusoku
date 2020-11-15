// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OptionsAdapter.sol";

contract OptionsWarchest {
    using OptionsAdapter for Options;

    enum ProtocolNames {Convexity}

    Options[1] public optionsProtocols;

    constructor(address _convexity) {
        optionsProtocols[uint256(ProtocolNames.Convexity)] = Options(
            _convexity
        );
    }

    function getPutOptions(Options optionsProtocol)
        public
        view
        returns (address[] memory)
    {
        return optionsProtocol.getPutOptions();
    }

    function getCallOptions(Options optionsProtocol)
        public
        view
        returns (address[] memory)
    {
        return optionsProtocol.getCallOptions();
    }

    function getOptionPrice(
        Options optionsProtocol,
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) public view returns (uint256) {
        return
            optionsProtocol.getPrice(
                optionAddress,
                paymentTokenAddress,
                amountToBuy
            );
    }

    function buyOption(
        Options optionsProtocol,
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) public payable {
        // Ensure that the msg.sender has sufficient paymentTokens before buying the options
        uint256 premiumToPay = optionsProtocol.getPrice(
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

        optionsProtocol.buyOption(
            optionAddress,
            paymentTokenAddress,
            amountToBuy
        );
    }
}
