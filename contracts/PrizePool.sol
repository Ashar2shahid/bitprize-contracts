// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AaveYieldSource.sol";
import "./RandomNumberGenerator.sol";
import "./Bit.sol";

interface IAaveYieldSource {
    function supplyTokenTo(uint256 depositAmount, address to) external;
    function redeemToken(uint256 redeemAmount) external returns (uint256);
    function sponsor(uint256 amount) external;
    function claimRewards(address to) external returns (bool);
    function redeemYieldAndTransferToOwner() external returns (uint256);
}

contract PrizePool is Ownable {
    IERC20 public usdcToken;
    Bit public bitToken;
    IAaveYieldSource public aTokenYieldSource;
    RandomNumberGenerator public rng;

    bool public isDrawActive;

    mapping(address => uint256) public balances;
    address[] public depositors;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event DrawStarted();
    event DrawStopped();
    event YieldDistributed(address indexed winner, uint256 amount);

    constructor(
        address _usdcToken,
        address _bitToken,
        address _aaveYieldSource,
        address _rng
    ) Ownable() {
        usdcToken = IERC20(_usdcToken);
        bitToken = Bit(_bitToken);
        aTokenYieldSource = IAaveYieldSource(_aaveYieldSource);
        rng = RandomNumberGenerator(_rng);
        isDrawActive = false;
    }

    modifier onlyWhenDrawActive() {
        require(isDrawActive, "Draw is not active");
        _;
    }

    modifier onlyWhenDrawInactive() {
        require(!isDrawActive, "Draw is already active");
        _;
    }

    function startDraw() external onlyOwner onlyWhenDrawInactive {
        isDrawActive = true;
        emit DrawStarted();
    }

    function stopDraw() external onlyOwner onlyWhenDrawActive {
        isDrawActive = false;
        _collectYieldAndDistribute();
        emit DrawStopped();
    }

    function deposit(uint256 amount) external onlyWhenDrawActive {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer deposit to the pool
        usdcToken.transferFrom(msg.sender, address(this), amount);

        usdcToken.approve(address(aTokenYieldSource), amount);

        // Supply the deposit to the Aave Yield Source
        aTokenYieldSource.supplyTokenTo(amount, address(this));

        // Track the depositor if they're depositing for the first time
        if (balances[msg.sender] == 0) {
            depositors.push(msg.sender);
        }

        // Update user's balance and total deposits
        balances[msg.sender] += amount;

        // Mint proportional Bits to the user
        bitToken.mint(msg.sender, amount);

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external onlyWhenDrawActive {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Redeem the deposit from the Aave Yield Source
        aTokenYieldSource.redeemToken(amount);

        // Update user's balance
        balances[msg.sender] -= amount;

        if(balances[msg.sender] == 0) {
            // Remove the user from the depositors list
            for (uint256 i = 0; i < depositors.length; i++) {
                if (depositors[i] == msg.sender) {
                    depositors[i] = depositors[depositors.length - 1];
                    depositors.pop();
                    break;
                }
            }
        }

        // Burn proportional Bits from the user
        bitToken.burn(msg.sender, amount);

        // Transfer deposit back to user
        usdcToken.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function _collectYieldAndDistribute() private {

        // Burn all Bits
        _returnAllDeposits();

        // Choose a random winner from Bit holders
        uint256 totalBits = bitToken.totalSupply();
        require(totalBits > 0, "No Bits available for drawing");

        address winner = rng.getRandomBitHolder(totalBits);

        aTokenYieldSource.redeemYieldAndTransferToOwner();

        // Transfer the collected yield to the winner
        usdcToken.transfer(winner, usdcToken.balanceOf(address(this)));

        emit YieldDistributed(winner, usdcToken.balanceOf(winner));

        _burnAllBitTokens();

    }

    function _burnAllBitTokens() private {
        uint256 totalHolders = bitToken.holdersCount();

        while(totalHolders > 0) {
            address holder = bitToken.holderAt(0);
            uint256 holderBitBalance = bitToken.balanceOf(holder);

            if (holderBitBalance > 0) {
                // Burn all Bits for the holder
                bitToken.burn(holder, holderBitBalance);
            }
            totalHolders--;
        }
    }

    function _returnAllDeposits() private {
        for (uint256 i = 0; i < depositors.length; i++) {
            address holder = depositors[i];
            uint256 holderDepositBalance = balances[holder];

            if (holderDepositBalance > 0) {
                // Return the deposit to the holder
                // Redeem the deposit from the Aave Yield Source
                aTokenYieldSource.redeemToken(holderDepositBalance);
                usdcToken.transfer(holder, holderDepositBalance);
                // Reset the user's deposit balance
                balances[holder] = 0;
            }
        }

        // Clear the depositors array for the next draw cycle
        delete depositors;
    }

    function getWinPercentage(address holder) external view returns (uint256) {
        uint256 totalBits = bitToken.totalSupply();
        uint256 holderBits = bitToken.balanceOf(holder);

        if (totalBits == 0 || holderBits == 0) {
            return 0;
        }

        return (holderBits * 10000) / totalBits;
    }

    function getUserDeposit(address holder) external view returns (uint256) {
        return balances[holder];
    }

    function getTotalDeposits() external view returns (uint256) {
        uint256 totalDeposits = 0;

        for (uint256 i = 0; i < depositors.length; i++) {
            totalDeposits += balances[depositors[i]];
        }

        return totalDeposits;
    }

    function getTotalParticipants() external view returns (uint256) {
        return depositors.length;
    }
}
