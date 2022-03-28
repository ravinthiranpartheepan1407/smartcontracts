// SPDX-License-Identifier: MIT
pragma solidity^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IAzogDevs.sol";

contract AzogDevToken is ERC20, Ownable{
  uint256 public constant tokenPrice = 0.001 ether;
  uint256 public constant tokensPerNFT = 10 * 10**18;
  uint256 public constant maxTotalSupply = 1000000 * 10**18;

  IAzogDevs AzogDevsNFT;

  mapping (uint256 => bool) public tokenIdsClaimed;

  constructor(address _azogDevsContract) ERC20("Azog Dev Token", "AZD"){
    AzogDevsNFT = IAzogDevs(_azogDevsContract);
  }

  function mint(uint256 amount) public payable {
    uint256 _requiredAmount = tokenPrice * amount;
    require(msg.value >= _requiredAmount, "Ether sent is incorrect");
    uint256 amountWithDecimals = amount * 10**18;

    require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds max total supply available");
    _mint(msg.sender, amountWithDecimals);
  }

  function claim() public {
    address sender = msg.sender;
    uint256 balance = AzogDevsNFT.balanceOf(sender);
    require(balance > 0, "You Don't own any Crypto Dev NFTs");
    uint256 amount = 0;
    for(uint256 i=0; i<balance; i++){
      uint256 tokenId = AzogDevsNFT.tokenOfOwnerByIndex(sender, i);
      if(!tokenIdsClaimed[tokenId]){
        amount += 1;
        tokenIdsClaimed[tokenId] = true;
      }
    }
    require(amount > 0, "You have already claimed all the tokens");
    _mint(msg.sender, amount * tokensPerNFT);
  }

  receive() external payable{}
  fallback() external payable{}
}
