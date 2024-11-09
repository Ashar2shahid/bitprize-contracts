// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bit is ERC20, Ownable {
    address[] private holders;
    mapping(address => bool) private isHolder;
    address public gameMinter;

    constructor() Ownable() ERC20("Pool Bit", "BIT") {}

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);

        // Track the holder if they're not already in the list
        if (!isHolder[to] && balanceOf(to) > 0) {
            holders.push(to);
            isHolder[to] = true;
        }
    }

    function gameMint(address to, uint256 amount) external {
        require(msg.sender == gameMinter, "Only the game minter can mint");
        _mint(to, amount);

        // Track the holder if they're not already in the list
        if (!isHolder[to] && balanceOf(to) > 0) {
            holders.push(to);
            isHolder[to] = true;
        }
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);

        // Remove the holder if their balance reaches zero
        if (balanceOf(from) == 0 && isHolder[from]) {
            _removeHolder(from);
        }
    }

    function _removeHolder(address holder) private {
        require(isHolder[holder], "Address is not a holder");

        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == holder) {
                holders[i] = holders[holders.length - 1];
                holders.pop();
                isHolder[holder] = false;
                break;
            }
        }
    }

    function holdersCount() external view returns (uint256) {
        return holders.length;
    }

    function holderAt(uint256 index) external view returns (address) {
        require(index < holders.length, "Index out of bounds");
        return holders[index];
    }

    // Overriding transfer to handle holder tracking
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);

        // If transferring from an existing holder, check if they should be removed
        if (from != address(0) && balanceOf(from) == amount) {
            _removeHolder(from);
        }

        // If transferring to a new holder, add them to the holders list
        if (to != address(0) && !isHolder[to] && balanceOf(to) == 0) {
            holders.push(to);
            isHolder[to] = true;
        }
    }
}
