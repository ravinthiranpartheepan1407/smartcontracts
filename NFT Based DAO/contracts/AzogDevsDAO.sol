// SPDX-License-Identifier: MIT

pragma solidity^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

interface INFTMarketplace{
  function getPrice() external view returns(uint256);
  function available(uint256 _tokenId) external view returns(bool);
  function purchase(uint256 _tokenId) external payable;
}

interface IAzogDev{
  function balanceOf(address owner) external view returns (uint256);
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract AzogDevsDAO is Ownable {
  struct Proposal {
    uint256 nftTokenId;
    uint256 deadline;
    uint256 yesVotes;
    uint256 noVotes;
    bool executed;
    mapping (uint256 => bool) voters;
  }

  mapping (uint256 => Proposal) public proposals;
  uint256 public numProposals;

  INFTMarketplace nftMarketplace;
  IAzogDev azogDevNFT;

  constructor(address _nftMarketPlace, address _AzogDevsNFT) payable{
    nftMarketplace = INFTMarketplace(_nftMarketPlace);
    azogDevNFT = IAzogDev(_AzogDevsNFT);
  }

  modifier nftHolderOnly() {
    require(azogDevNFT.balanceOf(msg.sender) > 0, "Not An Azog DAO Member");
    _;
  }

  function createProposal(uint256 _nftTokenId) external nftHolderOnly returns (uint256) {
    require(nftMarketplace.available(_nftTokenId), "NFT Not For Sale");
    Proposal storage proposal = proposals[numProposals];
    proposal.nftTokenId = _nftTokenId;
    proposal.deadline = block.timestamp + 5 minutes;
    numProposals++;
    return numProposals - 1;
  }

  modifier activeProposalOnly(uint256 proposalIndex) {
    require(proposals[proposalIndex].deadline > block.timestamp, "Deadline Exceeded");
    _;
  }

  enum Vote {
    YES,
    NO
  }

  function voteOnProposal(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex) {
    Proposal storage proposal = proposals[proposalIndex];
    uint256 voterNFTBalance = azogDevNFT.balanceOf(msg.sender);
    uint256 numVotes = 0;
    for(uint256 i = 0; i < voterNFTBalance; i++){
      uint256 tokenId = azogDevNFT.tokenOfOwnerByIndex(msg.sender, i);
      if(proposal.voters[tokenId] == false){
        numVotes++;
        proposal.voters[tokenId] = true;
      }
    }
    require(numVotes > 0, "Already Voted");

    if(vote == Vote.YES){
      proposal.yesVotes += numVotes;
    } else{
      proposal.noVotes += numVotes;
    }
  }

  modifier inactiveProposalOnly(uint256 proposalIndex) {
    require(proposals[proposalIndex].deadline <= block.timestamp, "Deadline Not Exceeded");
    require(proposals[proposalIndex].executed == false, "Proposal Already Executed");
    _;
  }

  function executeProposal(uint256 proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex) {
    Proposal storage proposal = proposals[proposalIndex];
    if(proposal.yesVotes > proposal.noVotes){
      uint256 nftPrice = nftMarketplace.getPrice();
      require(address(this).balance >= nftPrice, "Not Enough Funds");
      nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);

    }
    proposal.executed = true;
  }

  function withdrawEther() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  receive() external payable{}
  fallback() external payable{}
}
