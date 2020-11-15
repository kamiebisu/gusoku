// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Options {}

library OptionsAdapter {
    function getPutOptions(Options options)
        external
        view
        returns (address[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getPutOptions()")
        );
        require(success, "OptionsAdapter: getPutOptions staticcall failed");
        return abi.decode(result, (address[]));
    }

    function getCallOptions(Options options)
        external
        view
        returns (address[] memory)
    {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature("getCallOptions()")
        );
        require(success, "OptionsAdapter: getCallOptions staticcall failed");
        return abi.decode(result, (address[]));
    }

    function getPrice(
        Options options,
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external view returns (uint256) {
        (bool success, bytes memory result) = address(options).staticcall(
            abi.encodeWithSignature(
                "getPrice(address,address,uint256)",
                optionAddress,
                paymentTokenAddress,
                amountToBuy
            )
        );
        require(success, "OptionsAdapter: getPrice staticcall failed");
        return abi.decode(result, (uint256));
    }

    function buyOptions(
        Options options,
        address optionAddress,
        address paymentTokenAddress,
        uint256 amountToBuy
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "buyOptions(address,address,uint256",
                optionAddress,
                paymentTokenAddress,
                amountToBuy
            )
        );
        require(success, "OptionsAdapter: buyOptions delegatecall failed");
    }

    function sellOptions(
        Options options,
        address optionAddress,
        address payoutTokenAddress,
        uint256 amountToSell
    ) external {
        (bool success, ) = address(options).delegatecall(
            abi.encodeWithSignature(
                "sellOptions(address,address,uint256",
                optionAddress,
                payoutTokenAddress,
                amountToSell
            )
        );
        require(success, "OptionsAdapter: sellOptions delegatecall failed");
    }
}
