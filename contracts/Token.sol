// Import necessary libraries and interfaces
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the TTCC token contract
contract TTCC is ERC20, Ownable {
    // Constructor to initialize the contract with an initial supply
    constructor(uint256 initialSupply) ERC20("TTCC Token", "TTCC") {
        _mint(msg.sender, initialSupply);
    }

    // Mint new TTCC tokens and assign them to an account
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    // Burn a specific amount of TTCC tokens from the caller's balance
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Transfer tokens from the sender to a recipient
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "Invalid address");
        return super.transfer(recipient, amount);
    }

    // Transfer tokens from one account to another
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0) && recipient != address(0), "Invalid address");
        return super.transferFrom(sender, recipient, amount);
    }
}