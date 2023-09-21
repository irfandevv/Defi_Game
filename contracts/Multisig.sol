// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSignatureWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public quorum;  // Minimum number of signatures required for a transaction
    uint256 public transactionCount;
    
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }
    
    mapping(uint256 => Transaction) public transactions;
    
    event Deposit(address indexed sender, uint256 value);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }
    
    constructor(address[] memory _owners, uint256 _quorum) {
        require(_owners.length > 0, "Owners required");
        require(_quorum > 0 && _quorum <= _owners.length, "Invalid quorum");
        
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner");
            owners.push(owner);
            isOwner[owner] = true;
        }
        
        quorum = _quorum;
    }
    
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    
    function submitTransaction(address to, uint256 value, bytes memory data) public onlyOwner returns (uint256) {
        uint256 transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            to: to,
            value: value,
            data: data,
            executed: false
        });
        transactionCount++;
        emit Submission(transactionId);
        return transactionId;
    }
    
    function executeTransaction(uint256 transactionId) public onlyOwner {
        Transaction storage txn = transactions[transactionId];
        require(!txn.executed, "Transaction already executed");
        
        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value, data: txn.data}("");
        if (success) {
            emit Execution(transactionId);
        } else {
            emit ExecutionFailure(transactionId);
            txn.executed = false;
        }
    }
    
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
}