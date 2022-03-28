//SPDX-License-Identifier: MIT

pragma solidity^0.8.4;

contract Whitelist {
  uint8 public maxWhiteListedAddresses;
  mapping (address => bool) public whiteListedAddresses;
  uint8 public numAddressWhiteListed;

  constructor(uint8 _maxWhiteListedAddresses){
    maxWhiteListedAddresses = _maxWhiteListedAddresses;
  }

  function addAddressToWhiteList() public {
    require(!whiteListedAddresses[msg.sender], "User Already Whitelisted");
    require(numAddressWhiteListed < maxWhiteListedAddresses, "User Can Be Added");
    whiteListedAddresses[msg.sender] = true;
    numAddressWhiteListed += 1;
  }
}
