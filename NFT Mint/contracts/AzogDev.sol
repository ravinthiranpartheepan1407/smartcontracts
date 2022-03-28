// SPDX-License-Identifier: MIT
pragma solidity^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract AzogDev is ERC721Enumerable, Ownable {
  string _baseTokenURI;
  uint256 public _price = 0.05 ether;
  bool public _paused;
  uint256 public maxTokenIds = 50;
  uint256 public tokenIds;
  IWhitelist whitelist;

  bool public presaleStarted;
  uint public presaleEnded;

  modifier onlyWhenNotPaused {
    require(!_paused, "Contract Currently Paused");
    _;
  }

  constructor(string memory baseURI, address whitelistContract) ERC721("Azog Dev", "AZD"){
    _baseTokenURI = baseURI;
    whitelist = IWhitelist(whitelistContract);
  }

  function startPresale() public onlyOwner {
    presaleStarted = true;
    presaleEnded = block.timestamp + 5 minutes;
  }

  function presaleMint() public payable onlyWhenNotPaused {
    require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
    require(whitelist.whiteListedAddresses(msg.sender),"You are whitelisted");
    require(tokenIds < maxTokenIds, "Exceeded maxmimum suuply of AxogDev Tokens");
    require(msg.value >= _price, "Higher Ether Alloc is not allowed");

    _safeMint(msg.sender, tokenIds);
  }

  function mint() public payable onlyWhenNotPaused{
    require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
    require(tokenIds < maxTokenIds, "Exceeded max supply of AzogDev");
    require(msg.value >= _price, "Higher ether alloc is not allowed");
    tokenIds += 1;
    _safeMint(msg.sender, tokenIds);
  }

  function _baseURI() internal view virtual override returns(string memory) {
    return _baseTokenURI;
  }

  function setPaused(bool val)public onlyOwner {
    _paused = val;
  }

  function withdraw() public onlyOwner {
    address _owner = owner();
    uint256 amount = address(this).balance;
    (bool sent,) = _owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
  }

  receive() external payable{}

  fallback() external payable{}
}
