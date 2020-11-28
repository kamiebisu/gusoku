// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../interfaces/IDiscreteOptionsProtocolAdapterV2.sol";
import "../../libraries/strings.sol";
import "hardhat/console.sol";
import "../domain/OptionsModel.sol";

contract MockServiceAdapterV2 is IDiscreteOptionsProtocolAdapterV2 {
    using SafeMath for uint256;
    using strings for *;

    function getPutOptions()
        external
        override
        returns (OptionsModel.Option[] memory)
    {
        return new OptionsModel.Option[](1);
    }

    function getCallOptions()
        external
        override
        returns (OptionsModel.Option[] memory)
    {
        return new OptionsModel.Option[](1);
    }

    function getPrice(
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return 1;
    }

    function buyOptions(
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable override {
        //do nothing
    }

    function sellOptions(
        uint256 optionID,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external override {
        //do nothing
    }

    function exerciseOptions(
        uint256 optionID,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable override {
        //do nothing
    }
}
