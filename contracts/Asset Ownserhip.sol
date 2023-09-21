// Import necessary libraries and interfaces
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the Asset Ownership contract
contract AssetOwnership is ERC721, Ownable {
    // Mapping to store the token URI (metadata) for each NFT
    mapping(uint256 => string) private _tokenURIs;

    // Constructor to initialize the contract
    constructor() ERC721("GameAssets", "GA") {}

    // Mint a new NFT and assign it to an owner
    function mint(address owner, uint256 tokenId, string memory tokenURI) public onlyOwner {
        _mint(owner, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    // Get the token URI (metadata) for a specific token
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return _tokenURIs[tokenId];
    }

    // Transfer an NFT from the current owner to a new owner
    function transferNFT(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    // Internal function to set the token URI (metadata) for a token
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        _tokenURIs[tokenId] = tokenURI;
    }
}