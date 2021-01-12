// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct opt {
    address asset;
    uint256 amount;
    uint256 strike;
    uint256 expire;
    uint256 optionType;
}

struct ostore {
    address asset;
    uint48 expire;
    uint8 call;
    uint256 amount;
    uint256 strike;
}

interface IDeriswapV1Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Created(
        uint256 id,
        address indexed owner,
        address indexed token,
        uint256 amount,
        uint256 strike,
        uint256 created,
        uint256 expire
    );
    event Exercised(
        uint256 id,
        address indexed owner,
        address indexed token,
        uint256 amount,
        uint256 strike,
        uint256 excercised,
        uint256 expire
    );
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function FACTORY() external view returns (address);

    function MINIMUM_LIQUIDITY() external view returns (uint256);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function TOKEN0() external view returns (address);

    function TOKEN1() external view returns (address);

    function allowance(address, address) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function callATM(
        address token,
        uint256 amount,
        uint256 t,
        uint256 maxFee
    ) external;

    function count() external view returns (uint256);

    function createCall(
        address token,
        uint256 amount,
        uint256 st,
        uint256 t,
        uint256 maxFee
    ) external;

    function createOption(
        address token,
        uint256 amount,
        uint256 st,
        uint256 t,
        uint256 optionType,
        uint256 maxFee
    ) external;

    function createPut(
        address token,
        uint256 amount,
        uint256 st,
        uint256 t,
        uint256 maxFee
    ) external;

    function decimals() external view returns (uint8);

    function excerciseOption(uint256 id) external;

    function exerciseOptionProfitOnly(uint256 id) external;

    function fee(
        address token,
        uint256 amount,
        uint256 st,
        uint256 t,
        uint256 optionType
    ) external view returns (uint256);

    function feeDetail(
        address token,
        uint256 st,
        uint256 t,
        uint256 optionType
    )
        external
        view
        returns (
            uint256 _call,
            uint256 _put,
            uint256 _fee
        );

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    function kLast() external view returns (uint256);

    function length() external view returns (uint256);

    function loansnft() external view returns (address);

    function mint(
        uint256 amount0,
        uint256 amount1,
        address to
    ) external returns (uint256 liquidity);

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function option(uint256 _id)
        external
        view
        returns (
            address asset,
            uint256 amount,
            uint256 strike,
            uint256 expire,
            uint256 optionType
        );

    function options(uint256 _id) external view returns (opt memory _option);

    function optionsnft() external view returns (address);

    function ostores(uint256)
        external
        view
        returns (
            address asset,
            uint48 expire,
            uint8 call,
            uint256 amount,
            uint256 strike
        );

    function period(uint256 t) external pure returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function points(uint256)
        external
        view
        returns (
            uint256 timestamp,
            uint256 price0Cumulative,
            uint256 price1Cumulative
        );

    function price(address token) external view returns (uint256);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function putATM(
        address token,
        uint256 amount,
        uint256 t,
        uint256 maxFee
    ) external;

    function quoteOption(address tokenIn, uint256 t)
        external
        view
        returns (uint256 call, uint256 put);

    function quoteOptionPrice(
        address tokenIn,
        uint256 t,
        uint256 sp,
        uint256 st
    ) external view returns (uint256 call, uint256 put);

    function quotePrice(address tokenIn, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function realizedVariance(
        address tokenIn,
        uint256 p,
        uint256 window
    ) external view returns (uint256);

    function realizedVolatility(
        address tokenIn,
        uint256 p,
        uint256 window
    ) external view returns (uint256);

    function sample(
        address tokenIn,
        uint256 amountIn,
        uint256 p,
        uint256 window
    ) external view returns (uint256[] memory);

    function store2opt(ostore memory _ostore)
        external
        pure
        returns (opt memory _option);

    function swap(
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function utilization(
        address token,
        uint256 optionType,
        uint256 amount
    ) external view returns (uint256);
}
