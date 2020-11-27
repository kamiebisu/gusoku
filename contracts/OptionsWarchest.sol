// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OptionsProtocolAdapter.sol";
import "./adapters/domain/OptionsModel.sol";

contract OptionsWarchest {
    using OptionsProtocolAdapter for Options;

    enum ProtocolNames {Convexity}

    Options[1] public optionsProtocols;

    constructor(address _convexity) {
        optionsProtocols[uint256(ProtocolNames.Convexity)] = Options(
            _convexity
        );
    }

    receive() external payable {}

    function getPutOptions(Options optionsProtocol)
        public
        view
        returns (OptionsModel.Option[] memory)
    {
        return optionsProtocol.getPutOptions();
    }

    function getCallOptions(Options optionsProtocol)
        public
        view
        returns (OptionsModel.Option[] memory)
    {
        return optionsProtocol.getCallOptions();
    }

    function getOptionPrice(
        Options optionsProtocol,
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) public view returns (uint256) {
        return
            optionsProtocol.getPrice(
                optionID,
                amountToBuy,
                paymentTokenAddress
            );
    }

    function buyOptions(
        Options optionsProtocol,
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) public payable {
        // Ensure that the OptionsWarchest have sufficient paymentTokens before buying the options
        uint256 premiumToPay = optionsProtocol.getPrice(
            optionID,
            amountToBuy,
            paymentTokenAddress
        );
        if (paymentTokenAddress == address(0)) {
            require(
                address(this).balance >= premiumToPay,
                "OptionsWarchest: insufficient ETH balance to buy the options"
            );
        } else {
            IERC20 paymentToken = IERC20(paymentTokenAddress);
            require(
                paymentToken.balanceOf(address(this)) >= premiumToPay,
                "OptionsWarchest: insufficient paymentToken balance to buy the options"
            );
        }

        optionsProtocol.buyOptions(optionID, amountToBuy, paymentTokenAddress);
    }

    function sellOptions(
        Options optionsProtocol,
        uint256 optionID,
        uint256 amountToSell,
        address payoutTokenAddress
    ) public {
        address optionAddress = optionsProtocol.options(optionID).tokenAddress;
        // Ensure that the OptionsWarchest holds enough options to sell
        IERC20 optionToken = IERC20(optionAddress);
        require(
            optionToken.balanceOf(address(this)) >= amountToSell,
            "OptionsWarchest: there's not enough options to sell"
        );

        optionsProtocol.sellOptions(optionID, amountToSell, payoutTokenAddress);
    }

    function exerciseOptions(
        Options optionsProtocol,
        uint256 optionID,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) public payable {
        optionsProtocol.exerciseOptions(
            optionID,
            amountToExercise,
            vaultOwners
        );
    }
}
