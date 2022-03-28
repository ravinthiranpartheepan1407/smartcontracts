//SPDX-License-Identifier: MIT OR Apache-2.0

// Declare Pragma Command
pragma solidity ^0.8.4;

// Declare openzeppelin libraries - ERC721URIStorage (For Storing Token), Counters (Math), ERC721 (NFT Support)
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



//Decalre console.sol from hardhat for compilation into ABI

import "hardhat/console.sol";



//Declare contract Name and call it as ERC721URIStorage
//Declare Counters from Counters lib inheriting Counters
//Assign Counters.Counter(Inheritance) to tokenIds in private view
//Declatre contractAddress

contract NFT is ERC721URIStorage{
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address contractAddress;



//Declare a constructor (Which has the priority) to call the marketplaceAddress first.
//Assign the ERC721 lib with "token name" , "token symbol"
//Assign contractAddress = marketplaceAddress

  constructor(address marketplaceAddress) ERC721("Azog Tokens", "AZT"){
    contractAddress = marketplaceAddress;
  }

//Create a function for tokens and pass parameters that can holds the memory for tokenURI toString
//Along with function set the visbile property to: public view returns (uint)


  function createToken(string memory tokenURI) public returns (uint){

    // Increment the tokenId at the inital stage
    // create a newtoken variable to store the value for current tokenId
    // Mint current sender address and pass it to the newtoken created in the previous step
    // update / set the tokenURI for the minted sender address and tokenID
    // Approve the assigned tokenURI to "true"
    // Return the newtokenID


    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI);
    setApprovalForAll(contractAddress, true);
    return newItemId;
  }
}
