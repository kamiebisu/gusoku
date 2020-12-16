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

    function getPutOptions(Options optionsProtocol, address baseAsset)
        public
        view
        returns (OptionsModel.Option[] memory)
    {
        return optionsProtocol.getPutOptions(baseAsset);
    }

    function getCallOptions(Options optionsProtocol, address baseAsset)
        public
        view
        returns (OptionsModel.Option[] memory)
    {
        return optionsProtocol.getCallOptions(baseAsset);
    }

    function buyOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) public payable {
        // Ensure that the OptionsWarchest have sufficient paymentTokens before buying the options
        uint256 premiumToPay = optionsProtocol.getBuyPrice(
            option,
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

        optionsProtocol.buyOptions(option, amountToBuy, paymentTokenAddress);
    }

    function sellOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) public {
        address optionAddress = option.tokenAddress;
        // Ensure that the OptionsWarchest holds enough options to sell
        IERC20 optionToken = IERC20(optionAddress);
        require(
            optionToken.balanceOf(address(this)) >= amountToSell,
            "OptionsWarchest: there's not enough options to sell"
        );

        optionsProtocol.sellOptions(option, amountToSell, payoutTokenAddress);
    }

    function exerciseOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) public payable {
        optionsProtocol.exerciseOptions(option, amountToExercise, vaultOwners);
    }
}
