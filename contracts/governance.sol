// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GovernanceAndVotingContract {
    address public owner;
    uint256 public totalTokens; // Total tokens available for voting
    uint256 public votingDuration; // Duration of each voting round in seconds
    uint256 public votingEndTime; // End time of the current voting round
    bool public votingInProgress; // Flag to indicate if a voting round is in progress

    struct Proposal {
        string description; // Description of the proposal
        uint256 votesFor; // Total votes in favor
        uint256 votesAgainst; // Total votes against
        mapping(address => bool) hasVoted; // Mapping to track if an address has voted
    }

    Proposal[] public proposals; // Array to store all proposals

    // Event to log a new proposal
    event NewProposal(uint256 proposalId, string description);

    // Event to log a vote
    event Voted(uint256 proposalId, address indexed voter, bool inFavor);

    constructor(uint256 _totalTokens, uint256 _votingDuration) {
        owner = msg.sender;
        totalTokens = _totalTokens;
        votingDuration = _votingDuration;
    }

    // Only the contract owner can create new proposals
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can create proposals");
        _;
    }

    // Function to create a new proposal
    function createProposal(string memory description) external onlyOwner {
        require(!votingInProgress, "Cannot create a new proposal during a voting round");

        uint256 proposalId = proposals.length;
        proposals.push(Proposal(description, 0, 0));

        // Emit the NewProposal event
        emit NewProposal(proposalId, description);
    }

    // Function to vote in favor of or against a proposal
    function vote(uint256 proposalId, bool inFavor) external {
        require(votingInProgress, "Voting is not currently in progress");
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(!proposals[proposalId].hasVoted[msg.sender], "You have already voted");

        if (inFavor) {
            proposals[proposalId].votesFor++;
        } else {
            proposals[proposalId].votesAgainst++;
        }

        proposals[proposalId].hasVoted[msg.sender] = true;

        // Emit the Voted event
        emit Voted(proposalId, msg.sender, inFavor);
    }

    // Function to start a new voting round
    function startVotingRound() external onlyOwner {
        require(!votingInProgress, "Voting round is already in progress");

        votingEndTime = block.timestamp + votingDuration;
        votingInProgress = true;
    }

    // Function to end the current voting round and determine the result
    function endVotingRound(uint256 proposalId) external onlyOwner {
        require(votingInProgress, "No voting round in progress");
        require(block.timestamp >= votingEndTime, "Voting round has not ended yet");
        require(proposalId < proposals.length, "Invalid proposal ID");

        Proposal storage proposal = proposals[proposalId];
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;

        // Determine the result of the vote
        bool passed = proposal.votesFor > proposal.votesAgainst;

        // Reset voting state
        delete proposal.hasVoted;
        votingInProgress = false;

        // Execute the proposal if it passed
        if (passed) {
            // Implement the action related to the passed proposal here
            // For example, you can execute code to update the game or ecosystem
            // This is a placeholder and should be replaced with the actual implementation
        }
    }
}