// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameRewards is Ownable {
    IERC20 public ttccToken;
    
    mapping(address => uint256) public playerRewards;
    
    event RewardsDistributed(address indexed player, uint256 amount);
    
    constructor(address _ttccTokenAddress) {
        ttccToken = IERC20(_ttccTokenAddress);
    }
    
    function distributeRewards(address player, uint256 amount) public onlyOwner {
        require(player != address(0), "Invalid player address");
        require(amount > 0, "Amount must be greater than 0");
        
        playerRewards[player] += amount;
        require(ttccToken.transfer(player, amount), "Transfer failed");
        
        emit RewardsDistributed(player, amount);
    }
    
    function getPlayerRewards(address player) public view returns (uint256) {
        return playerRewards[player];
    }
}