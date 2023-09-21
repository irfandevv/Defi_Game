// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import necessary libraries for random number generation
import "@openzeppelin/contracts/utils/Random.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RandomNumberGenerator is Ownable {
    using Random for Random.Seed;
    using Random for Random.Request;

    event RandomNumberGenerated(uint256 indexed requestId, uint256 randomNumber);

    // Store the latest seed
    Random.Seed private seed;

    // Mapping requestId to a boolean to prevent duplicate requests
    mapping(uint256 => bool) private usedRequestIds;

    // Modifiers to restrict access to specific functions
    modifier onlyOwnerOrAuthorized() {
        require(msg.sender == owner() || msg.sender == address(this), "Not authorized");
        _;
    }

    // Function to request a random number
    function requestRandomNumber(uint256 requestId) external onlyOwnerOrAuthorized {
        require(!usedRequestIds[requestId], "Request ID already used");

        // Generate a random number using the current seed and requestId
        uint256 randomNumber = seed.random(requestId);

        // Mark the requestId as used
        usedRequestIds[requestId] = true;

        // Emit the random number generated
        emit RandomNumberGenerated(requestId, randomNumber);
    }

    // Function to update the seed (can only be called by the owner)
    function updateSeed(uint256 newSeed) external onlyOwner {
        seed.update(newSeed);
    }

    // Function to retrieve the current seed
    function getCurrentSeed() external view returns (uint256) {
        return seed.current();
    }
}