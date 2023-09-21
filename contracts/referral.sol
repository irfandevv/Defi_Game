// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Add this import for IERC20

contract AffiliateAndReferralProgramContract {
    address public owner;
    ERC20 public gameToken; // The game token contract address
    uint256 public referralBonusPercentage; // Referral bonus percentage (e.g., 5%)
    uint256 public referralBonusDuration; // Duration in seconds for which the referral bonus is active

    // Mapping to track referrals
    mapping(address => address) public referrers; // Referrer address mapping

    // Event to log a new referral
    event Referral(address indexed referrer, address indexed referredUser);

    constructor(
        address _gameTokenAddress,
        uint256 _referralBonusPercentage,
        uint256 _referralBonusDuration
    ) {
        owner = msg.sender;
        gameToken = ERC20(_gameTokenAddress);
        referralBonusPercentage = _referralBonusPercentage;
        referralBonusDuration = _referralBonusDuration;
    }

    // Function to set a user's referrer
    function setReferrer(address referrer) external {
        require(referrer != msg.sender, "You cannot refer yourself");
        require(referrers[msg.sender] == address(0), "Referrer already set");
        referrers[msg.sender] = referrer;

        // Emit the Referral event
        emit Referral(referrer, msg.sender);
    }

    // Function to calculate and distribute referral bonus
    function distributeReferralBonus(uint256 amount) external {
        require(referrers[msg.sender] != address(0), "You do not have a referrer");
        require(amount > 0, "Amount must be greater than zero");

        address referrer = referrers[msg.sender];
        uint256 bonusAmount = (amount * referralBonusPercentage) / 100;

        // Transfer the bonus tokens to the referrer
        require(
            gameToken.transfer(referrer, bonusAmount),
            "Token transfer failed"
        );
    }

    // Function to withdraw tokens from the contract (only owner)
    function withdrawTokens(address recipient, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can withdraw tokens");
        require(
            gameToken.transfer(recipient, amount),
            "Token transfer failed"
        );
    }
}