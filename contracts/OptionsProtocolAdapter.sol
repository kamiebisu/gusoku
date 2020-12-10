// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "./adapters/domain/OptionsModel.sol";

library OptionsProtocolAdapter {
    function buyOptions(
        Options options,
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "buyOptions(OptionsModel.Option,uint256,address)",
                option,
                paymentTokenAddress,
                amountToBuy
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: buyOptions delegatecall failed"
        );
    }

    function sellOptions(
        Options options,
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "sellOptions(OptionsModel.Option,uint256,address)",
                option,
                amountToSell,
                payoutTokenAddress
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: sellOptions delegatecall failed"
        );
    }

    function exerciseOptions(
        Options options,
        OptionsModel.Option memory option,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "exerciseOptions(OptionsModel.Option,uint256, address[])",
                option,
                amountToExercise,
                vaultOwners
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: exerciseOptions delegatecall failed"
        );
    }

    function getPutOptions(Options options, address baseAsset)
        external
        view
        returns (OptionsModel.Option[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getPutOptions(address)", baseAsset)
        );
        require(
            success,
            "OptionsProtocolAdapter: getPutOptions staticcall failed"
        );
        return abi.decode(result, (OptionsModel.Option[]));
    }

    function getCallOptions(Options options, address baseAsset)
        external
        view
        returns (OptionsModel.Option[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getCallOptions(address)", baseAsset)
        );
        require(
            success,
            "OptionsProtocolAdapter: getCallOptions staticcall failed"
        );
        return abi.decode(result, (OptionsModel.Option[]));
    }

    function getAvailableBuyLiquidity(
        Options options,
        OptionsModel.Option memory option
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getAvailableBuyLiquidity(OptionsModel.Option)",
                option
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: getAvailableBuyLiquidity staticcall failed"
        );
        return abi.decode(result, (uint256));
    }

    function getAvailableBuyLiquidityAtPrice(
        Options options,
        OptionsModel.Option memory option,
        uint256 maxOptionPrice,
        address paymentTokenAddress
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getAvailableBuyLiquidityAtPrice(OptionsModel.Option,uint256,address)",
                option,
                maxOptionPrice,
                paymentTokenAddress
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: getAvailableBuyLiquidityAtPrice staticcall failed"
        );
        return abi.decode(result, (uint256));
    }

    function getBuyPrice(
        Options options,
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getBuyPrice(OptionsModel.Option,uint256,address)",
                option,
                amountToBuy,
                paymentTokenAddress
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: getBuyPrice staticcall failed"
        );
        return abi.decode(result, (uint256));
    }

    function getAvailableSellLiquidity(
        Options options,
        OptionsModel.Option memory option
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getAvailableSellLiquidity(OptionsModel.Option)",
                option
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: getAvailableSellLiquidity staticcall failed"
        );
        return abi.decode(result, (uint256));
    }

    function getAvailableSellLiquidityAtPrice(
        Options options,
        OptionsModel.Option memory option,
        uint256 minOptionPrice,
        address payoutTokenAddress
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getAvailableSellLiquidityAtPrice(OptionsModel.Option,uint256,address)",
                option,
                minOptionPrice,
                payoutTokenAddress
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: getAvailableSellLiquidityAtPrice staticcall failed"
        );
        return abi.decode(result, (uint256));
    }

    function getSellPrice(
        Options options,
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getSellPrice(OptionsModel.Option,uint256,address)",
                option,
                amountToSell,
                payoutTokenAddress
            )
        );
        require(
            success,
            "OptionsProtocolAdapter: getSellPrice staticcall failed"
        );
        return abi.decode(result, (uint256));
    }
}

contract Options {}
