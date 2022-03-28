//SPDX-License-Identifier : MIT OR Apache-2.0

//Declare Pragma command line

pragma solidity ^0.8.4;

//Declare Counters lib from openzeppelin for math

import "@openzeppelin/contracts/utils/Counters.sol";

//Declare ReentrancyGuard lib from openzeppelin for avoiding redirect or same page on recurring payment

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//Declare ERC721 lib from openzeppelin for tokenize the nftContract

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Declare console.sol contract from hardhat to compile code in to ABI

import "hardhat/console.sol";


//Declare contract name as NFTMakret and assign with ReentrancyGuard to avoid recurring events
//Declare Counters.Counter from Counters
//Declare Counters.Counter for itemId
//Declatre Counters.Counter for itemsSold;

contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;


//Declare address type for owner
//Decalre uint256 variable for storing the price.

  address payable owner;
  uint256 listingPrice = 0.025 ether;


//Create a constructor to intialize this statement at the first stage of the whole process
//Declare owner address with payable type which indicates the current sender account "msg.sender"

  constructor(){
    owner = payable(msg.sender);
  }

//Create a structure for marketItem properties
//Items properties : itemId, nftContract, tokenId, seller, owner, price, sold
// Datatpes: uint, address, uint, address, address, uint256, bool

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

//set the marketItems to uint and map it to idToMarketItem

  mapping(uint256 => MarketItem) private idToMarketItem;


//Create an event for created market itemId
// event properties: itemId, nftContract, tokenId, seller, owner, price, sold
// Indexed properties: itemId, nftContract, tokenId

  event MarketItemCreated(
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );



  //Declare a function for getListingPrice and make it privateKey
  // Return the listingPrice

  function getListingPrice() public view returns(uint256){
    return listingPrice;
  }



//Declare a function for creating market item
//Pass the indexed properties from the created marketItem events
// Pass the indexed events only: itemId, nftContract, tokenId, price

// run test for initial price eligibility by setting condition to price variable
// make the price equal to the listed listingPrice


  function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant{
      require(price > 0, "price must be at least 1 wei");
      require(msg.value == listingPrice, "price must be equal to the listed price");

      _itemIds.increment();
      uint256 itemId = _itemIds.current();



//A: assign the created itemID to idToMarketItem in an array
//assign the MarketItem to the previously created array idToMarketItem[itemId]
//MarketItem inherits: itemId, nftContract, tokenId, seller, owner, price, solidity
//Assign payable terms here for seller and owner
//Seller inherits current account of the one who's selling the asset
//Owner inherits their logged account during the purchase.. owner always said to be address[0]

      idToMarketItem[itemId] = MarketItem(
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender),
        payable(address(0)),
        price,
        false
      );


//Declare the IERC721 type to tokenize our nftContract and transgfer it to seller to Owner
//transferFrom inherits: current seller (msg.sender), owner (address[this], tokenId)

      IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

//Emit the created marketItem
//Created marketItem includes: marketItem properties
//marketItem properties: itemsId, nftContract, tokenId, Seller, owner, price, sold
      emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
    }

// TILL THIS PROCESS THE SOLD PROPERTY SHOULD BE SET TO false
// BECAUSE WE HAVE ONLY CREATED ITEM IN MARKETPLACE AND LISTED SOME AMOUNT OF PRICE FOR SELLING






// ***********************************************************************************************************************************************//

// CREATES THE SALES FOR A MARKETPLACE ITEMS  AND   TRANSFER OWNSERSHIP OF THE ITEM, AS WELL AS FUNDS BETWEEN ACCOUNT HOLDERS

//********************************************************************************************************************************************//






//Declare a function for creating a market createMarketSale
//pass the marketItem properties: nftContract and itemId into the createMarketSale function
// make the function as payable nonReentrant: To avoid recurring events during payments

function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant{

  // get the price from idToMarketItem array
  // get the tokenId from idToMarketItem array

  uint price = idToMarketItem[itemId].price;
  uint tokenId = idToMarketItem[itemId].tokenId;



// Run test to check the amount to be spent is equal to the price or not
  require(msg.value == price, "Please submit the asking price to buy your requested asset");


//Get idToMarketItem property inherits the seller to pass the amout value
  idToMarketItem[itemId].seller.transfer(msg.value);


//Declare the tokenize nftcontract using iERC721 that inherits transferFrom property to send payment.
  IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);


//Assign the idToMarketItem array that inherits owner
//Assign the inherited owner property from idToMarketItem to payable property of current sender account
  idToMarketItem[itemId].owner = payable(msg.sender);


//Assign the idToMarketItem array that inherits SOLD
//Now set the sold bool property to TRUE
  idToMarketItem[itemId].sold = true;


//Do increment for itemsSold
  _itemsSold.increment();


//transfer the price from the owner
  payable(owner).transfer(listingPrice);
}





//********************************************************************************************************************************************//

// RETURN ALL UNSOLD ITEMS TO THE MARKETPLACE

//********************************************************************************************************************************************//






//Declare function for fetching market items
//Set the function to public visibility but only display the marketItem not editable
// Set memory for marketItem array
function fetchMarketItems() public view returns (MarketItem[] memory){


//Declare itemCount variable to store the current _itemId from Counters.Counter for checking the remaining amount of items in the marketplace
  uint itemCount = _itemIds.current();


//Declare aa variable for unSoldItemCount to store the remaining items Counter
//Formula: current itemId from Counter - current ItemSold from Counter
  uint unsoldItemCount = _itemIds.current() - _itemsSold.current();



//Set Current Index to Zero
  uint currentIndex = 0;



//Declare MarketItem array along with assigned memory type to "items" variable
//Assign a new object for MarketItem array and pass the unSoldItemCount into it.
  MarketItem[] memory items = new MarketItem[](unsoldItemCount);



//initialize a for loop function to run through whole marketItem to check the item count
  for(uint i=0; i<itemCount; i++){


//Check the idToMarketItem owner's address equals to current logged address
    if(idToMarketItem[i+1].owner == address(0)){


//if equal then set currentId to increment by 1
      uint currentId = i + 1;


//Set MarketItem storage property to currentItem variable for storing the currentId value
      MarketItem storage currentItem = idToMarketItem[currentId];


//set a currentIndex array for currentItem
//Value of currentIndex: 0 (refer line 230)
      items[currentIndex] = currentItem;

//Increment the currentIndex by +1
      currentIndex += 1;
    }
  }
  return items;
}







//********************************************************************************************************************************************//

// RETURN ONLY THE ITEMS USER HAS MADE THE PURCHASE

//********************************************************************************************************************************************//



//GET the nft that you would like to purchase: For that assign a function to fetch the NFTMakret
// Function should be visbile only in public but not editable
// Pass the MarketItem array with memory type


function fetchNFTs() public view returns (MarketItem[] memory){

//Declare totalItemCount variable to store current itemId from counters lib
//Set ItemCount to Zero
//Set Current Index to Zero
  uint totalItemCount = _itemIds.current();
  uint itemCount = 0;
  uint currentIndex = 0;

//Initialize a for loop to run through the whole items in marketplace to check for purchase availability
  for(uint i=0; i<totalItemCount; i++){

//if idToMarketItem array that inherits woner eauls to current seller account then
// Increment itemCount by +1
    if(idToMarketItem[i+1].owner == msg.sender){
      itemCount += 1;
    }
  }

//Declare MarketItem array with memory for the variable "items"
//Set the "items" variable along with MarketItem memory type to a new object
//Create a object for MarketItem array that pass the itemCount
  MarketItem[] memory items = new MarketItem[](itemCount);

//initialize a for loop function to run through whole marketItem to check the item count
  for(uint i=0; i<totalItemCount; i++){

//Check the idToMarketItem owner's address equals to current logged address

    if(idToMarketItem[i+1].owner == msg.sender){

//if equal then set currentId to increment by 1
      uint currentId = i+1;

//Set MarketItem storage property to currentItem variable for storing the currentId value
      MarketItem storage currentItem = idToMarketItem[currentId];


//set a currentIndex array for currentItem
//Value of currentIndex: 0 (refer line 230)
      items[currentIndex] = currentItem;

//Increment the currentIndex by +1
      currentIndex += 1;
    }
  }
  return items;
}


//********************************************************************************************************************************************//

// RETURN ONLY THE ITEMS USER HAS MADE CREATED

//********************************************************************************************************************************************//




function fetchItemsCreated() public view returns(MarketItem[] memory){
  uint totalItemCount = _itemIds.current();
  uint itemCount = 0;
  uint currentIndex = 0;

  for(uint i=0; i<totalItemCount; i++){
    if(idToMarketItem[i+1].seller == msg.sender){
      itemCount += 1;
    }
  }
    MarketItem[] memory items = new MarketItem[](itemCount);
    for(uint i=0; i<totalItemCount; i++){
      if(idToMarketItem[i+1].owner == msg.sender){
        uint currentId = i+1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }







//******************************************************************************************************************************************//

  }
