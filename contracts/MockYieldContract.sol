// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockYieldContract is Ownable {
    IERC20 public usdcToken;
    address public prizePool; // Address of the PrizePool contract

    event YieldDeposited(address indexed user, uint256 amount);
    event YieldCollected(uint256 amount);

    constructor(address _usdcToken, address _prizePool) Ownable() {
        usdcToken = IERC20(_usdcToken);
        prizePool = _prizePool; // Set the PrizePool address
    }

    // Modifier to restrict access to the PrizePool contract
    modifier onlyPrizePool() {
        require(msg.sender == prizePool, "Only PrizePool can collect yield");
        _;
    }

    // Function to allow users to deposit tokens as yield
    function depositYield(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer tokens from the user to this contract
        usdcToken.transferFrom(msg.sender, address(this), amount);

        emit YieldDeposited(msg.sender, amount);
    }

    // Function to collect all available yield (restricted to PrizePool)
    function collectYield() external onlyPrizePool returns (uint256) {
        uint256 collectedYield = IERC20(usdcToken).balanceOf(address(this));

        require(collectedYield > 0, "No yield to collect");

        // Transfer the collected yield to the PrizePool
        usdcToken.transfer(prizePool, collectedYield);

        emit YieldCollected(collectedYield);

        return collectedYield;
    }

    // Function to update the PrizePool address (only callable by the owner)
    function setPrizePool(address _prizePool) external onlyOwner {
        prizePool = _prizePool;
    }
}
