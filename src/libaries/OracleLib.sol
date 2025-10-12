// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
/* 
@title OracleLib
@author Mahima Thacker
@notice Library for oracle functions
@dev This library contains functions for the oracle
if a price is stale, function will revert - by design from chainlink docs
we want to freeze the price when it is stale
so if chainlink network is exploded, this is bad and our money is locked
*/
error OracleLib__StalePrice();

library OracleLib {
    uint256 public constant TIMEOUT = 3 hours;

     function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)public view returns(uint80, int256,  uint256, uint256, uint80) {
       (  uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound) =  priceFeed.latestRoundData();
           uint256 secondsSince = block.timestamp - updatedAt;
if (secondsSince > TIMEOUT) revert OracleLib__StalePrice();
return (roundId, answer, startedAt, updatedAt, answeredInRound);
     }

}