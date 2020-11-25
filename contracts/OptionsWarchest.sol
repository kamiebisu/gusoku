// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OptionsProtocolAdapter.sol";
import "./adapters/domain/OptionsStore.sol";

contract OptionsWarchest {
    using OptionsProtocolAdapter for Options;

    enum ProtocolNames {Convexity}

    Options[1] public optionsProtocols;
    OptionsStore internal _optionsStore = new OptionsStore();

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

    function buyOptions(
        Options optionsProtocol,
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) public payable {
        // Ensure that the OptionsWarchest have sufficient paymentTokens before buying the options
        uint256 premiumToPay = optionsProtocol.getPrice(
            optionAddress,
            paymentTokenAddress,
            amountToBuy
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

        optionsProtocol.buyOptions(
            optionAddress,
            paymentTokenAddress,
            amountToBuy
        );
    }

    function sellOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        address payoutTokenAddress,
        uint256 amountToSell
    ) public {
        // Ensure that the OptionsWarchest holds enough options to sell
        IERC20 optionToken = IERC20(option.tokenAddress);
        require(
            optionToken.balanceOf(address(this)) >= amountToSell,
            "OptionsWarchest: there's not enough options to sell"
        );

        optionsProtocol.sellOptions(option, payoutTokenAddress, amountToSell);
    }

    function exerciseOptions(
        Options optionsProtocol,
        address optionAddress,
        uint256 amountToExercise
    ) public payable {
        optionsProtocol.exerciseOptions(optionAddress, amountToExercise);
    }
}
