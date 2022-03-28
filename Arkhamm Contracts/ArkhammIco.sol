// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IArkhammIco.sol";

contract ArkhammIco is ERC20, Ownable {

    uint256 public constant tokenPrice = 0.01 ether;
    uint256 public constant tokensPerNFT = 10;
    uint256 public constant maxTotalSupply = 100000000;
    IArkhammIco ArkhammNFT;
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _arkhammContract) ERC20("Arkhamm ICO", "AKI") {
        ArkhammNFT = IArkhammIco(_arkhammContract);
    }


    function mint(uint256 amount) public payable {

        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        uint256 amountWithDecimals = amount * 10;
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply available.");

        _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
        address sender = msg.sender;

        uint256 balance = ArkhammNFT.balanceOf(sender);
        require(balance > 0, "You dont own any Arkhamm NFT's");
        uint256 amount = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = ArkhammNFT.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(amount > 0, "You have already claimed all the tokens");
        _mint(msg.sender, amount * tokensPerNFT);
    }

    receive() external payable {}


    fallback() external payable {}
}
