// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


interface IDaoNFTMarketplace {

    function getPrice() external view returns (uint256);
    function available(uint256 _tokenId) external view returns (bool);

    function purchase(uint256 _tokenId) external payable;
}


interface IArkhammNFT {

    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}

contract ArkhammDAO is Ownable {
    IDaoNFTMarketplace nftMarketplace;
    IArkhammNFT arkhammDaoNFT;

    struct Proposal {
        uint256 nftTokenId;
        uint256 deadline;
        uint256 approveAKM;
        uint256 denyAKM;
        bool executed;
        mapping(uint256 => bool) voters;
    }

    enum Vote {
        AKMY,
        AKMN
    }


    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    modifier nftHolderOnly() {
        require(arkhammDaoNFT.balanceOf(msg.sender) > 0, "NOT_A_ARKHAMM_DAO_MEMBER");
        _;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "DEADLINE_EXCEEDED"
        );
        _;
    }


    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "DEADLINE_NOT_EXCEEDED"
        );
        require(
            proposals[proposalIndex].executed == false,
            "PROPOSAL_ALREADY_APPROVED"
        );
        _;
    }

    constructor(address _nftMarketplace, address _arkhammDaoNFT) payable {
        nftMarketplace = IDaoNFTMarketplace(_nftMarketplace);
        arkhammDaoNFT = IArkhammNFT(_arkhammDaoNFT);
    }


    function createProposal(uint256 _nftTokenId)
        external
        nftHolderOnly
        returns (uint256)
    {
        require(nftMarketplace.available(_nftTokenId), "ARKHAMM_NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + 120 minutes;

        numProposals++;

        return numProposals - 1;
    }


    function voteOnProposal(uint256 proposalIndex, Vote vote)
        external
        nftHolderOnly
        activeProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = arkhammDaoNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;


        for (uint256 i = 0; i < voterNFTBalance; i++) {
            console.log(arkhammDaoNFT.tokenOfOwnerByIndex(msg.sender, i));
            uint256 tokenId = arkhammDaoNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false) {
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }
        require(numVotes > 0, "ALREADY_VOTED");

        if (vote == Vote.AKMY) {
            proposal.approveAKM += numVotes;
        } else {
            proposal.denyAKM += numVotes;
        }
    }


    function executeProposal(uint256 proposalIndex)
        external
        nftHolderOnly
        inactiveProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];


        if (proposal.approveAKM > proposal.denyAKM) {
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}
