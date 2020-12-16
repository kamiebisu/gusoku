// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./adapters/domain/OptionsModel.sol";
import "./OptionsProtocolAdapter.sol";

contract ProtocolAdapterProxy {
    using OptionsProtocolAdapter for Options;

    enum ProtocolNames {MockService}

    Options[1] public optionsProtocols;

    constructor(address _mockServiceAddress) {
        optionsProtocols[uint256(ProtocolNames.MockService)] = Options(
            _mockServiceAddress
        );
    }

    receive() external payable {}

    function getPutOptions(Options optionsProtocol, address baseAsset)
        public
        returns (OptionsModel.Option[] memory)
    {
        return optionsProtocol.getPutOptions(baseAsset);
    }

    function getCallOptions(Options optionsProtocol, address baseAsset)
        public
        returns (OptionsModel.Option[] memory)
    {
        return optionsProtocol.getCallOptions(baseAsset);
    }

    function buyOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        uint256 amountToBuy,
        address paymentTokenAddress
    ) public payable {
        optionsProtocol.buyOptions(option, amountToBuy, paymentTokenAddress);
    }

    function sellOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        uint256 amountToSell,
        address payoutTokenAddress
    ) public {
        optionsProtocol.sellOptions(option, amountToSell, payoutTokenAddress);
    }

    function exerciseOptions(
        Options optionsProtocol,
        OptionsModel.Option memory option,
        uint256 amountToExercise,
        address[] memory vaultOwners
    ) public payable {
        optionsProtocol.exerciseOptions(option, amountToExercise, vaultOwners);
    }
}
