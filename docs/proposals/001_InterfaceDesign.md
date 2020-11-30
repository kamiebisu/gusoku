## Proposal: New interface design

### Changes:

**1. Calling methods with an Option instead of an optionID.**

The reason for this change is to get rid of the optionID which makes things a bit more complex, we can just use the option itself which is now self descriptive (since there's now only a generic option rather than address/attribute options now).

The alternative is to build an array of options and then add AMM options we are interested in. Then we pass both the array and the index and the implemented method will fetch it from the array. This means passing 2 params per method rather than one and there will be duplication of the fetch from array in each implementation. I dont see any reason to have the whole array  of options (or OptionsStore) in the method as its not needed unless there are objections to this approach?

**2. New methods and interfaces.**

I have introduced a new interface for selling options, as not all protocols support selling of options. For both buying and selling there are new methods to get liquidity and get liquidity until certain prices.

This will allow us to do smart routing as the price is not constant and we may need to distribute an order across many protocols. For example, the smart router may eventually do something like this (this is not as smart as it could be... but at least smarter than a naive single protocol pricing). Pseudocode and simplified to 2 protocols but i think this illustrates the point of these methods...

```
function getSmartPrice(IOptionsProtocol[] protocols, uint256 desiredOptions) returns (uint256) {
    //these can be fetched from the array without needing to know what protocol, but to be explicit...
    IOptionsProtocol opyn = protocols[0];
    IOptionsProtocol hegic = protocols[1];

    opynPriceInETH = opyn.getBuyPrice(someAsset, 1, address(0)); //returns 0.1ETH, so we know price at opyn starts here...
    hegicPriceInETH = hegic.getBuyPrice(someAsset, 1, address(0)); //returns 0.15ETH

    if(opynPriceInETH < hegicPriceInETH) {
        uint256 opynAvailabilityCheaper = getAvailableBuyLiquidityAtPrice(option, 0.15ETH, address(0));

        //if we can buy all at opyn, return that price, else distribute the price.
        if(opynAvailabilityCheaper >= desiredOptions) {
            return opyn.getBuyPrice(someAsset, desiredOptions, address(0));
        } else {
            //this assumes we know hegic is constant price. we should add a method to check if protocols are constant price (see remaining work #1)...
            //also we would check liquidity of hegic so we know the pool has enough free capital. there are methods for this in the interfaces but omitted here
            return opyn.getBuyPrice(someAsset, opynAvailabilityCheaper, address(0)) + hegic.getBuyPrice(someAsset, desiredOptions - opynAvailabilityCheaper, address(0));
        }
    } else {
        //hegic is cheaper, buy all options there
        return hegic.getBuyPrice(someAsset, desiredOptions - opynAvailabilityCheaper, address(0));
    }
}
```

If we want to get even more granular with the interfaces, we can move ```getAvailableBuyLiquidityAtPrice``` and ```getAvailableSellLiquidityAtPrice``` to IVariablePriceOptionsProtocol and IVariablePriceResellableOptionsProtocol respectively. This is because for constant price AMMs like Hegic, these methods will do the same thing.

**3. Introduction of OwnedOptionsStore**

This will represent options owned by the warchest, just a shell right now. It's not too relevant to the interface changes but I added it anyway as I think this is what we were initially trying to achieve with the "optionsID" for easy access when removing an option (on exercise or expiry). We can either use inheritance or composition for this.

### Remaining work:

**1. Interface detection**

If we're happy to go ahead with this approach, we will need some utility methods to tell us which interfaces are implemented on each protocol. This allows us to check methods exist before calling them.

```
canResellOptions(); //e.g. opyn
isConstantPricing(); //e.g. hegic
isDiscreteProtocol(); //e.g. opyn
```

We can implement [ERC165](https://github.com/ethereum/EIPs/pull/881) so that we know which protocols support which functionality. This will allow us to add methods to a helper library which can check what features a protocol has like so:

```
library OptionsProtocolFeatures {
    function canResellOptions(IOptionsProtocol protocol) returns(boolean) {
        return supportsInterface(bytes4(keccak256('sellOptions(OptionsModel.Option, uint256, address)')));
    }
}
```

**2. OptionsProtocolAdapterV2 to support new methods**

They haven't been added yet, this is just a copy for now.

**3. Tests**

I've introduced a proxy class so we can use this to test rather than calling from the warchest directly. The proxy will eventually become a router, I imagine, which the warchest will use instead of the library directly.

**4. Change OptionMarket from enum to address**

This is not urgent and just some forward-thinking. enums, once deployed, can't be altered. the general premise of smart contracts is their functionality shouldn't change but its likely we want to support new options protocols in the future as they inevitably come out. by using an address we will be able to still return options from an OptionsMarket that was not supported at time of deployment. Obviously, this will have to be opt-in, and the protocol will somehow have to support a change of config. Governance can then trigger adding (or deleting) a protocol to the config.
