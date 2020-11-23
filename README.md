# Gusoku: Options-based IL protection

## Goal

Deliver impermanent loss protection to liquidity providers of AMMs in an automated and transparent fashion using options. [This video](https://www.youtube.com/watch?v=GSIlF5q4eUk&t=4s) captures the idea we want to automate in a smart contract.

## Options Warchest Contract

1. User deposits
   - Routing % into liquidity pool vs. what % to keep in warchest.
   - Pause additional deposits if coverage percent drops below 100% and/or we can't source more options to buy.
2. Purchase options
   - Aggregate option purchases -- how much coverage do we need per deposit amount.
   - Cap price willing to pay.
3. Exercise options
   - When close to expiry and profitable.
4. User withdrawal
   - Track each user's entry price in pool to determine payout (if IL suffered) on withdrawal.
5. Take fees from profits of the liquidity pool
   - As options expire out-of-the-money the warchest will deplete. Need on-going ability to tax profits in Eth/Stable pool to purchase new options.

#3,4,7 will need to be triggered either via Keep3r or incentivized users.

## Options Abstraction and Integration Contracts

### Core Protocol

- **OptionsWarchest** - Implements the core logic behind Gusoku. Handles user deposits, options purchasing, options exercising, user withdrawal, and taking fees from protected pools.

- **IOptionsAdapter** - Interface that allows **OptionsWarchest** to uniformly interact with various options protocols, effectively abstracting away all the differences between them. Every options protocol adapter implements this interface.

- **OptionsAdapter** - Helper library that makes delegate calls from **OptionsWarchest** to the options protocols adapters.

### Adapters

Separate contracts that implement the **IOptionsAdapter** interface.

#### Current adapters

- **ConvexityAdapter**
- **GammaAdapter**
- **HegicAdapter**
- **DeriswapAdapter**

#### Future adapters for options protocols that are not live yet

- **PrimitiveAdapter**
- **OptinoAdapter**

## IOptionsAdapter interface

### Common Functions

- Query and return available PUT options
- Query and return available CALL options
- Query and return PRICE for a given PUT/CALL
- A way to purchase a given PUT/CALL
- A way to sell a given PUT/CALL
- A way to exercise a given PUT/CALL
