// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./OptionsModel.sol";
import "./OptionsStore.sol";

/**
 * This represents a store of options the chest owns i.e. has bought. This can be used to understand
 * current position, what can be exercised etc...
 */
contract OwnedOptionsStore is OptionsStore {
    using SafeMath for uint256;

    //TODO: Parent method createOption is public so need to make sure no-one can alter the state...
    //TODO: Need a mapping of optionID => amountOwned
    //TODO: Need to be able to remove from the store once exercised (or expired)
}
