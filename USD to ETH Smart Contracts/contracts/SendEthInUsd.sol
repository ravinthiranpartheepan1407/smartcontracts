//SPDX-License-Identifier: MIT

pragma solidity^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SendEthInUsd {
  AggregatorV3Interface internal priceFeed;

  constructor(address aggregatorAddress){
    priceFeed = AggregatorV3Interface(aggregatorAddress);
  }

  function getEthUsd()public view returns (int) {
    (
    ,
    int price,
    ,
    ,

  ) = priceFeed.latestRoundData();
  return price;
  }

  function sendEther(address payable _to) public payable {
    (bool sent, ) = _to.call{value: msg.value}("");
    require(sent, "Failed To Send Ether");
  }
}
