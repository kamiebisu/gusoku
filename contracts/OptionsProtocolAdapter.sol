// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "./adapters/domain/OptionsModel.sol";

library OptionsProtocolAdapter {
    function buyOptions(
        Options options,
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "buyOptions(uint256,uint256,address)",
                optionID,
                paymentTokenAddress,
                amountToBuy
            )
        );
        require(success, "OptionsAdapter: buyOptions delegatecall failed");
    }

    function sellOptions(
        Options options,
        uint256 optionID,
        uint256 amountToSell,
        address payoutTokenAddress
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "sellOptions(uint256,uint256,address)",
                optionID,
                amountToSell,
                payoutTokenAddress
            )
        );
        require(success, "OptionsAdapter: sellOptions delegatecall failed");
    }

    function exerciseOptions(
        Options options,
        uint256 optionID,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "exerciseOptions(uint256,uint256, address[])",
                optionID,
                amountToExercise,
                vaultOwners
            )
        );
        require(success, "OptionsAdapter: exerciseOptions delegatecall failed");
    }

    function getPutOptions(Options options)
        external
        returns (OptionsModel.Option[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getPutOptions()")
        );
        require(success, "OptionsAdapter: getPutOptions staticcall failed");
        return abi.decode(result, (OptionsModel.Option[]));
    }

    function getCallOptions(Options options)
        external
        returns (OptionsModel.Option[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getCallOptions()")
        );
        require(success, "OptionsAdapter: getCallOptions staticcall failed");
        return abi.decode(result, (OptionsModel.Option[]));
    }

    function getPrice(
        Options options,
        uint256 optionID,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getPrice(uint256,uint256,address)",
                optionID,
                paymentTokenAddress,
                amountToBuy
            )
        );
        require(success, "OptionsAdapter: getPrice staticcall failed");
        return abi.decode(result, (uint256));
    }

    function options(Options options, uint256 optionID)
        external
        view
        returns (OptionsModel.Option memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("options(uint256)", optionID)
        );
        require(success, "OptionsAdapter: options staticcall failed");
        return abi.decode(result, (OptionsModel.Option));
    }
}

contract Options {}
