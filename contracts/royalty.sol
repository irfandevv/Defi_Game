// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoyaltyRevenueSharing {
    address public gameOwner;
    uint256 public totalRevenue;
    
    struct Creator {
        address payable creatorAddress;
        uint256 royaltyPercentage;
        uint256 totalRoyaltiesEarned;
    }
    
    mapping(address => Creator) public creators;
    
    event AssetSold(address indexed buyer, uint256 price, address indexed creator);
    event RoyaltyPaid(address indexed creator, uint256 amount);
    
    constructor() {
        gameOwner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == gameOwner, "Only the game owner can perform this operation");
        _;
    }
    
    function addCreator(address payable _creatorAddress, uint256 _royaltyPercentage) public onlyOwner {
        require(_creatorAddress != address(0), "Invalid creator address");
        require(_royaltyPercentage <= 100, "Royalty percentage cannot exceed 100%");
        
        creators[_creatorAddress] = Creator({
            creatorAddress: _creatorAddress,
            royaltyPercentage: _royaltyPercentage,
            totalRoyaltiesEarned: 0
        });
    }
    
    function sellAsset(address _buyer, uint256 _price) public {
        require(msg.sender != address(0), "Invalid sender address");
        require(_buyer != address(0), "Invalid buyer address");
        require(_price > 0, "Price must be greater than 0");
        
        Creator storage creator = creators[msg.sender];
        require(creator.creatorAddress != address(0), "Sender is not a registered creator");
        
        uint256 royaltyAmount = (_price * creator.royaltyPercentage) / 100;
        creator.totalRoyaltiesEarned += royaltyAmount;
        totalRevenue += _price;
        
        payable(creator.creatorAddress).transfer(royaltyAmount);
        
        emit AssetSold(_buyer, _price, msg.sender);
        emit RoyaltyPaid(msg.sender, royaltyAmount);
    }
    
    function getCreator(address _creatorAddress) public view returns (address, uint256, uint256) {
        Creator storage creator = creators[_creatorAddress];
        return (creator.creatorAddress, creator.royaltyPercentage, creator.totalRoyaltiesEarned);
    }
}