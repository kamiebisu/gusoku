// SPDX-License-Identifier: MIT
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol. SEE BELOW FOR SOURCE. !!
pragma solidity ^0.7.5;
pragma abicoder v2;

interface IOracle {
    function getPrice(address asset) external view returns (uint256);

    function PriceOracle() external view returns (address);

    function isCETH(address asset) external view returns (bool);
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"inputs":[{"name":"asset","type":"address"}],"name":"getPrice","outputs":[{"name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"PriceOracle","outputs":[{"name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"name":"asset","type":"address"}],"name":"isCETH","outputs":[{"name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"name":"_oracleAddress","type":"address"}],"stateMutability":"nonpayable","type":"constructor"}]
*/
