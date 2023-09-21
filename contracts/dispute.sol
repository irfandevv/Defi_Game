// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowAndDisputeResolutionContract {
    address public owner;

    enum EscrowState { Created, Funded, Completed, Refunded, Disputed }

    struct Escrow {
        address buyer;
        address seller;
        uint256 amount;
        EscrowState state;
        bool buyerApproved;
        bool sellerApproved;
    }

    uint256 public escrowCount;
    mapping(uint256 => Escrow) public escrows;

    // Event to log a new escrow creation
    event EscrowCreated(uint256 indexed escrowId, address indexed buyer, address indexed seller, uint256 amount);

    // Event to log an escrow state change
    event EscrowStateChanged(uint256 indexed escrowId, EscrowState newState);

    constructor() {
        owner = msg.sender;
    }

    // Function to create a new escrow
    function createEscrow(address _seller) external payable {
        require(msg.sender != _seller, "Buyer and seller cannot be the same address");
        require(msg.value > 0, "Escrow amount must be greater than zero");

        uint256 escrowId = escrowCount++;
        escrows[escrowId] = Escrow({
            buyer: msg.sender,
            seller: _seller,
            amount: msg.value,
            state: EscrowState.Created,
            buyerApproved: false,
            sellerApproved: false
        });

        // Emit the EscrowCreated event
        emit EscrowCreated(escrowId, msg.sender, _seller, msg.value);
    }

    // Function for the seller to approve the escrow
    function approveEscrow(uint256 escrowId) external {
        Escrow storage escrow = escrows[escrowId];
        require(msg.sender == escrow.seller, "Only the seller can approve the escrow");
        require(escrow.state == EscrowState.Created, "Escrow is not in the Created state");

        escrow.sellerApproved = true;
        escrow.state = EscrowState.Funded;

        // Emit the EscrowStateChanged event
        emit EscrowStateChanged(escrowId, EscrowState.Funded);
    }

    // Function for the buyer to approve the escrow
    function confirmReceived(uint256 escrowId) external {
        Escrow storage escrow = escrows[escrowId];
        require(msg.sender == escrow.buyer, "Only the buyer can confirm receipt");
        require(escrow.state == EscrowState.Funded, "Escrow is not in the Funded state");

        escrow.buyerApproved = true;
        escrow.state = EscrowState.Completed;

        // Transfer the funds to the seller
        payable(escrow.seller).transfer(escrow.amount);

        // Emit the EscrowStateChanged event
        emit EscrowStateChanged(escrowId, EscrowState.Completed);
    }

    // Function for either party to initiate a dispute
    function initiateDispute(uint256 escrowId) external {
        Escrow storage escrow = escrows[escrowId];
        require(msg.sender == escrow.buyer || msg.sender == escrow.seller, "Only the buyer or seller can initiate a dispute");
        require(escrow.state == EscrowState.Funded || escrow.state == EscrowState.Completed, "Invalid escrow state for dispute");

        escrow.state = EscrowState.Disputed;

        // Emit the EscrowStateChanged event
        emit EscrowStateChanged(escrowId, EscrowState.Disputed);
    }

    // Function for the contract owner to resolve a dispute
    function resolveDispute(uint256 escrowId, address payable recipient) external {
        Escrow storage escrow = escrows[escrowId];
        require(msg.sender == owner, "Only the contract owner can resolve disputes");
        require(escrow.state == EscrowState.Disputed, "Escrow is not in the Disputed state");

        // Transfer the escrowed funds to the specified recipient
        recipient.transfer(escrow.amount);

        // Emit the EscrowStateChanged event
        emit EscrowStateChanged(escrowId, EscrowState.Refunded);
    }
}