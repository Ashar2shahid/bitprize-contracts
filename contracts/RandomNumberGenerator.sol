// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Bit.sol";


contract RandomNumberGenerator is Ownable {
    Bit public bitToken;
    address public prizePool; // Address of the PrizePool contract

    constructor(address _bitToken, address _prizePool) Ownable(msg.sender) {
        bitToken = Bit(_bitToken);
        prizePool = _prizePool; // Set the PrizePool address
    }

    function setPrizePool(address _prizePool) onlyOwner external {
        prizePool = _prizePool;
    }

    function getRandomBitHolder(uint256 totalBits) external view returns (address) {
        require(totalBits > 0, "Total Bits must be greater than zero");

        // Generate a random index between 0 and totalBits
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % totalBits;
        
        // Use the Bit's balanceOf to determine the winner
        address winner;
        uint256 cumulativeBits = 0;

        // Iterate over all holders (could use a more gas-efficient mapping or solution for production)
        for (uint i = 0; i < bitToken.holdersCount(); i++) {
            address holder = bitToken.holderAt(i);
            uint256 holderBits = bitToken.balanceOf(holder);
            cumulativeBits += holderBits;

            if (cumulativeBits > randomIndex) {
                winner = holder;
                break;
            }
        }

        return winner;
    }
}
