// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    IERC20 public ttccToken;
    IERC721 public nftContract;
    
    // Mapping to track each player's staked amount
    mapping(address => uint256) public stakedAmount;
    
    // Reward rate per staked token or NFT
    uint256 public rewardRate;
    
    // Event to log staking activity
    event Staked(address indexed player, uint256 amount);
    event Unstaked(address indexed player, uint256 amount);
    
    constructor(address _ttccTokenAddress, address _nftContractAddress, uint256 _initialRewardRate) {
        ttccToken = IERC20(_ttccTokenAddress);
        nftContract = IERC721(_nftContractAddress);
        rewardRate = _initialRewardRate;
    }

    // Function to stake TTCC tokens
    function stakeTTCC(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(ttccToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        stakedAmount[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    // Function to stake an NFT by its token ID
    function stakeNFT(uint256 tokenId) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You don't own this NFT");
        
        stakedAmount[msg.sender] += 1;
        emit Staked(msg.sender, 1);
    }

    // Function to unstake TTCC tokens
    function unstakeTTCC(uint256 amount) external {
        require(stakedAmount[msg.sender] >= amount, "Insufficient staked amount");
        
        stakedAmount[msg.sender] -= amount;
        require(ttccToken.transfer(msg.sender, amount), "Transfer failed");
        emit Unstaked(msg.sender, amount);
    }

    // Function to unstake an NFT by its token ID
    function unstakeNFT(uint256 tokenId) external {
        require(stakedAmount[msg.sender] > 0, "No NFTs staked");
        
        stakedAmount[msg.sender] -= 1;
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Unstaked(msg.sender, 1);
    }

    // Function to update the reward rate (only owner)
    function updateRewardRate(uint256 newRate) external onlyOwner {
        rewardRate = newRate;
    }

    // Function to calculate and distribute rewards based on gameplay performance
    function distributeRewards(address[] memory players, uint256[] memory performanceScores) external onlyOwner {
        require(players.length == performanceScores.length, "Invalid input data");
        
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 performanceScore = performanceScores[i];
            uint256 rewardAmount = performanceScore * rewardRate;
            
            require(ttccToken.transfer(player, rewardAmount), "Transfer failed");
        }
    }
}