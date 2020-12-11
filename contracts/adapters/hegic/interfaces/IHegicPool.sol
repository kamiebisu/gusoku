pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

interface IHegicPool {
    function availableBalance() external view returns (uint256 balance);

    function totalBalance() external view returns (uint256 balance);
}
