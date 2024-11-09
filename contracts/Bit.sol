// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bit is ERC20, Ownable {
    address[] private holders;
    mapping(address => bool) private isHolder;
    address public gameMinter;

    constructor() Ownable(msg.sender) ERC20("Pool Bit", "BIT") {}

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

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);

        // Check if 'from' balance is zero after transfer, to potentially remove from holders list
        if (from != address(0) && balanceOf(from) == 0 && isHolder[from]) {
            _removeHolder(from);
        }

        // Check if 'to' should be added to the holders list
        if (to != address(0) && !isHolder[to] && balanceOf(to) > 0) {
            holders.push(to);
            isHolder[to] = true;
        }
    }
}
