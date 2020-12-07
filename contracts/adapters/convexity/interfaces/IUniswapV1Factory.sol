// SPDX-License-Identifier: MIT
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol. SEE BELOW FOR SOURCE. !!
pragma solidity ^0.7.5;
pragma abicoder v2;

interface IUniswapV1Factory {
    event NewExchange(address indexed token, address indexed exchange);

    function initializeFactory(address template) external;

    function createExchange(address token) external returns (address out);

    function getExchange(address token) external view returns (address out);

    function getToken(address exchange) external view returns (address out);

    function getTokenWithId(uint256 token_id)
        external
        view
        returns (address out);

    function exchangeTemplate() external view returns (address out);

    function tokenCount() external view returns (uint256 out);
}

// THIS FILE WAS AUTOGENERATED FROM THE FOLLOWING ABI JSON:
/*
[{"name":"NewExchange","inputs":[{"type":"address","name":"token","indexed":true},{"type":"address","name":"exchange","indexed":true}],"anonymous":false,"type":"event"},{"name":"initializeFactory","outputs":[],"inputs":[{"type":"address","name":"template"}],"type":"function","gas":35725,"stateMutability":"nonpayable"},{"name":"createExchange","outputs":[{"type":"address","name":"out"}],"inputs":[{"type":"address","name":"token"}],"type":"function","gas":187911,"stateMutability":"nonpayable"},{"name":"getExchange","outputs":[{"type":"address","name":"out"}],"inputs":[{"type":"address","name":"token"}],"type":"function","gas":715,"stateMutability":"view"},{"name":"getToken","outputs":[{"type":"address","name":"out"}],"inputs":[{"type":"address","name":"exchange"}],"type":"function","gas":745,"stateMutability":"view"},{"name":"getTokenWithId","outputs":[{"type":"address","name":"out"}],"inputs":[{"type":"uint256","name":"token_id"}],"type":"function","gas":736,"stateMutability":"view"},{"name":"exchangeTemplate","outputs":[{"type":"address","name":"out"}],"inputs":[],"type":"function","gas":633,"stateMutability":"view"},{"name":"tokenCount","outputs":[{"type":"uint256","name":"out"}],"inputs":[],"type":"function","gas":663,"stateMutability":"view"}]
*/