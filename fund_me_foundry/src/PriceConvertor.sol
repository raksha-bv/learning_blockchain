// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConvertor{
    function getPrice(AggregatorV3Interface priceFeed) public view returns(uint256){
        (,int256 price,,,)= priceFeed.latestRoundData();
        return uint256(price * 1e18);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) public view returns(uint256){
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd=(ethPrice*ethAmount)/1e18;
        return ethAmountInUsd;
    }
    // function getVersion() public view returns (uint256) {
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);
    //     return priceFeed.version();
    // }
}