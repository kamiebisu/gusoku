// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IHegicOptions.sol";
import "./../domain/OptionsModel.sol";
import "../../interfaces/IOptionsProtocol.sol";
import "./interfaces/IHegicPool.sol";

contract HegicAdapter is IOptionsProtocol {
    using SafeMath for uint256;

    struct HegicPoolInfo {
        address poolAddress;
        address settlementAsset; //WBTC or ETH
    }

    function getBuyPrice(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        (uint256 total, , , ) = IHegicOptions(option.tokenAddress).fees(
            option.expiryDate.sub(block.timestamp),
            amountToBuy,
            option.strikePrice,
            option.optionType == OptionsModel.OptionType.PUT ? 1 : 2
        );

        return total;
    }

    function buyOptions(
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external payable override returns (OptionsModel.OwnedOption memory) {
        uint256 hegicOptionID = IHegicOptions(option.tokenAddress).create(
            option.expiryDate.sub(block.timestamp),
            amountToBuy,
            option.strikePrice,
            option.optionType == OptionsModel.OptionType.PUT ? 1 : 2
        );

        return OptionsModel.OwnedOption(option, amountToBuy, hegicOptionID);
    }

    function exerciseOptions(
        OptionsModel.OwnedOption memory ownedOption,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external payable override {
        //TODO: We cant actually control how much we exercise... hegic takes a single param...?

        IHegicOptions(ownedOption.option.tokenAddress).exercise(
            ownedOption.protocolOptionID
        );
    }

    function getAvailableBuyLiquidity(OptionsModel.Option memory option)
        external
        view
        override
        returns (uint256)
    {
        //Hegic pool can only ever reach 80% pool utilization
        IHegicOptions optionsPool = IHegicOptions(option.tokenAddress);
        IHegicPool pool = IHegicPool(optionsPool.pool());
        uint256 unavailableLiquidity = pool.totalBalance().sub(
            pool.availableBalance()
        );
        return pool.totalBalance().mul(80).div(100).sub(unavailableLiquidity);
    }

    /**
     * Hegic is constant price so this is the same as the total buy liquidity available
     */
    function getAvailableBuyLiquidityAtPrice(
        OptionsModel.Option memory option,
        uint256 maxPriceToPay,
        address paymentTokenAddress
    ) external view override returns (uint256) {
        return this.getAvailableBuyLiquidity(option);
    }

    /**
     * Create an option given details about its attributes
     * @dev tokenAddress of the option will be the Hegic poolAddress
     */
    function _createOptionFromAttributes(
        address baseAsset,
        OptionsModel.OptionAttributes memory optionDetails,
        HegicPoolInfo memory poolInfo
    ) internal view returns (OptionsModel.Option memory) {
        return
            OptionsModel.Option(
                OptionsModel.OptionMarket.HEGIC,
                optionDetails.optionType,
                optionDetails.strikePrice,
                optionDetails.expiryDate,
                poolInfo.poolAddress,
                poolInfo.settlementAsset,
                address(0) //all options are paid for in ETH on Hegic
            );
    }

    function createOptionsFromAttributes(
        address baseAsset,
        OptionsModel.OptionAttributes[] memory optionAttributeList
    ) public view returns (OptionsModel.Option[] memory) {
        HegicPoolInfo memory poolInfo = getHegicPoolInfo(baseAsset);
        OptionsModel.Option[] memory options = new OptionsModel.Option[](
            optionAttributeList.length
        );

        for (uint256 i = 0; i < optionAttributeList.length; i++) {
            _createOptionFromAttributes(
                baseAsset,
                optionAttributeList[i],
                poolInfo
            );
        }

        return options;
    }

    function getHegicPoolInfo(address baseAsset)
        public
        view
        returns (HegicPoolInfo memory)
    {
        //ETH option
        if (baseAsset == address(0)) {
            return
                HegicPoolInfo(
                    0xEfC0eEAdC1132A12c9487d800112693bf49EcfA2,
                    address(0)
                );
        }

        //WBTC option
        if (baseAsset == 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599) {
            return
                HegicPoolInfo(
                    0x20DD9e22d22dd0a6ef74a520cb08303B5faD5dE7,
                    0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
                );
        }

        //TODO: Option doesnt exist so throw?
        return HegicPoolInfo(address(0), address(0));
    }
}
