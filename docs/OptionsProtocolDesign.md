# Options Protocol Design

Options are a relatively new primitive to cryptocurrency with only a few centralised exchanges supporting them and more recently, a few decentralised protocols have surfaced. The decentralised protocols vary in design, feature set and liquidity. To make Gukosu as efficient as possible with LP returns in mind, it must support many options protocols. To do this, a composable interface architecture has been designed to support the varying features of each protocol. The design and explanations of these interfaces is outlined below:

## Options Model

The options model attempts to model the attributes of an option in a standardised way so that consumers need not be aware of protocol-specific design.

First, we define an OptionType:

    enum OptionType {CALL, PUT}
    
Next, we define OptionMarket which refers to the 
    
    enum OptionMarket {CONVEXITY, HEGIC, MOCKSERVICE}

PROPOSAL: Actually, in the interest of upgradeability, I'm thinking we can model the above as an address instead. This way, if any new protocols are added once the contracts are deployed, it will be a matter of changing a config somewhere to support new protocols... I'll create a separate ticket for this though...

Finally, using the above and solidity data types, we define an Option:

    struct Option {
        OptionMarket optionMarket;
        OptionType optionType;
        uint256 strikePrice;
        uint256 expiryDate;
        address tokenAddress;
        address settlementAsset;
        address paymentAsset;
    }

Consumers of this Option type can treat each Option as a generic object without needing to be aware of the underlying implementation of the protocol which issued it.

## Interfaces:

#### IOptionsProtocol

This is the base interface that all options should inherit regardless of their functionality. It provides the minimum feature set that any options protocol should have:
- getBuyPrice
- buyOptions
- exerciseOptions
- getAvailableBuyLiquidity
- getAvailableBuyLiquidityAtPrice

For protocols that are pool based and provide a no-slippage market maker e.g. HEGIC, getAvailableLiquidityAtPrice and getAvailableLiquidity will do the same thing. This is because price is constant and won't alter the behaviour between these 2 methods.

#### IDiscreteOptionsProtocol

There are two types of options markets:
- Continuous market: An AMM which quotes a price based on features of the option (Option type, Strike price, Expiry). Since these parameters can be supplied at will, there is a near infinite amount of permutations.
- Discrete market: A rigid set of {Option type + Strike price + Expiry} combinations which can be selected from. This set can change but it is not malleable in the way it is with an AMM.

The DiscreteOptionsProtocol interface is to be implemented by protocols which have a set amount of options to buy from. It provides two methods to be implemented:
- getPutOptions(baseAsset)
- getCallOptions(baseAsset)

These should return an exhaustive set of **non-expired** options.

#### ResellableOptionsProtocol

Some protocols allow options to be resold to a pool rather than exercised. The ResellableOptionsProtocol interface is to be implemented by these protocols. It provides the following methods:
- getSellPrice
- sellOptions
- getAvailableSellLiquidity
- getAvailableSellLiquidityAtPrice

These methods are synonymous to the buy related methods in IOptionsProtocol, but for selling.


