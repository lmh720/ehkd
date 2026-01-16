// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Demo is ReentrancyGuard {
    IERC20 public immutable ehkd;

    event TransferThroughContract(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _ehkd) {
        require(_ehkd != address(0), "Invalid token");
        ehkd = IERC20(_ehkd);
    }

    /* -------------------------------------------------------------
       READ FUNCTIONS
    ------------------------------------------------------------- */

    function getBalance(address user) external view returns (uint256) {
        return ehkd.balanceOf(user);
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return ehkd.allowance(owner, spender);
    }

    /* -------------------------------------------------------------
       TRANSFER EH KD FROM CALLER → SOMEONE ELSE
       (requires approve first)
    ------------------------------------------------------------- */

    function sendEHkd(address to, uint256 amount) external nonReentrant {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");

        bool success = ehkd.transferFrom(msg.sender, to, amount);
        require(success, "Transfer failed");

        emit TransferThroughContract(msg.sender, to, amount);
    }

    /* -------------------------------------------------------------
       OPTIONAL: HOLD EH KD IN THIS CONTRACT
    ------------------------------------------------------------- */

    // User deposits EH KD into this contract
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");

        bool success = ehkd.transferFrom(msg.sender, address(this), amount);
        require(success, "Deposit failed");

        emit Deposit(msg.sender, amount);
    }

    // User withdraws their EH KD from this contract
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        require(ehkd.balanceOf(address(this)) >= amount, "Not enough in contract");

        bool success = ehkd.transfer(msg.sender, amount);
        require(success, "Withdraw failed");

        emit Withdraw(msg.sender, amount);
    }
}
