// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Add this import for IERC20

contract NFTMarketplace is Ownable {
    using SafeMath for uint256;

    // Struct to represent an NFT listing
    struct NFTListing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    // Storage for all NFT listings
    NFTListing[] public listings;

    // Mapping to track the NFT listings of each user
    mapping(address => uint256[]) public userToListings;

    // Mapping to check if a listing exists
    mapping(address => mapping(uint256 => bool)) public listingExists;

    // ERC-20 token used for payments
    IERC20 public paymentToken; // This declaration should work now

    // Event to log a new NFT listing
    event NFTListed(uint256 indexed listingId, address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price);

    // Event to log an NFT sale
    event NFTSold(uint256 indexed listingId, address indexed buyer, uint256 price);

    constructor(address _paymentToken) {
        paymentToken = IERC20(_paymentToken);
    }
    // Function to list an NFT for sale
    function listNFT(address _nftContract, uint256 _tokenId, uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");
        require(IERC721(_nftContract).ownerOf(_tokenId) == msg.sender, "You do not own this NFT");
        require(!listingExists[_nftContract][_tokenId], "NFT is already listed");

        IERC721Metadata nftContract = IERC721Metadata(_nftContract);
        string memory nftName = nftContract.name();
        string memory nftSymbol = nftContract.symbol();

        NFTListing memory listing = NFTListing({
            seller: msg.sender,
            nftContract: _nftContract,
            tokenId: _tokenId,
            price: _price,
            active: true
        });

        listings.push(listing);
        uint256 listingId = listings.length - 1;

        userToListings[msg.sender].push(listingId);
        listingExists[_nftContract][_tokenId] = true;

        emit NFTListed(listingId, msg.sender, _nftContract, _tokenId, _price);
    }

    // Function to buy an NFT
    function buyNFT(uint256 _listingId) external {
        require(_listingId < listings.length, "Invalid listing ID");
        NFTListing storage listing = listings[_listingId];
        require(listing.active, "Listing is not active");
        require(paymentToken.allowance(msg.sender, address(this)) >= listing.price, "Insufficient allowance for payment");
        require(paymentToken.balanceOf(msg.sender) >= listing.price, "Insufficient balance for payment");

        listing.active = false;

        paymentToken.transferFrom(msg.sender, listing.seller, listing.price);

        IERC721(listing.nftContract).safeTransferFrom(listing.seller, msg.sender, listing.tokenId);

        emit NFTSold(_listingId, msg.sender, listing.price);
    }

    // Function to cancel an NFT listing
    function cancelNFTListing(uint256 _listingId) external {
        require(_listingId < listings.length, "Invalid listing ID");
        NFTListing storage listing = listings[_listingId];
        require(msg.sender == listing.seller, "Only the seller can cancel the listing");
        require(listing.active, "Listing is not active");

        listing.active = false;
        listingExists[listing.nftContract][listing.tokenId] = false;

        emit NFTListed(_listingId, address(0), address(0), 0, 0); // Clear the listing
    }

    // Function to get the number of NFT listings
    function getListingCount() external view returns (uint256) {
        return listings.length;
    }

    // Function to get the NFT listing details
    function getListing(uint256 _listingId) external view returns (NFTListing memory) {
        require(_listingId < listings.length, "Invalid listing ID");
        return listings[_listingId];
    }

    // Function to get the listings of a specific user
    function getUserListings(address _user) external view returns (uint256[] memory) {
        return userToListings[_user];
    }

    // Function to withdraw funds from the contract (only owner)
    function withdrawFunds(address _recipient, uint256 _amount) external onlyOwner {
        require(_recipient != address(0), "Invalid recipient address");
        require(_amount > 0, "Withdrawal amount must be greater than zero");
        require(_amount <= address(this).balance, "Insufficient contract balance");

        payable(_recipient).transfer(_amount);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}