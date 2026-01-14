// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract EHKDEscrow {
    using SafeERC20 for ERC20;

    ERC20 public immutable eHKD;
    address public seller;
    address public buyer;
    uint256 public amount;
    bool public isFulfilled;
    bool public isRefunded;

    // Events
    event DepositMade(address indexed buyer, uint256 amount);
    event FulfillmentConfirmed(address indexed seller);
    event FundsReleased(address indexed seller, uint256 amount);
    event RefundIssued(address indexed buyer, uint256 amount);

    constructor(address _eHKDAddress, address _seller) {
        eHKD = ERC20(_eHKDAddress);
        seller = _seller;
    }

    // Buyer locks eHKD in the contract
    function deposit(uint256 _amount) external {
        require(!isFulfilled && !isRefunded, "Transaction already completed");
        require(_amount > 0, "Amount must be > 0");
        require(buyer == address(0), "Buyer already set");

        buyer = msg.sender;
        amount = _amount;
        eHKD.safeTransferFrom(msg.sender, address(this), _amount);

        emit DepositMade(msg.sender, _amount);
    }

    // Seller confirms fulfillment (e.g., delivery)
    function confirmFulfillment() external {
        require(msg.sender == seller, "Only seller can confirm");
        require(!isFulfilled && !isRefunded, "Transaction already completed");

        isFulfilled = true;
        emit FulfillmentConfirmed(seller);
    }

    // Seller withdraws funds after fulfillment
    function releaseFunds() external {
        require(isFulfilled, "Fulfillment not confirmed");
        require(!isRefunded, "Funds already refunded");

        uint256 balance = eHKD.balanceOf(address(this));
        require(balance >= amount, "Insufficient balance");

        eHKD.safeTransfer(seller, amount);
        emit FundsReleased(seller, amount);
    }

    // Buyer can refund if seller doesn't fulfill (timeout can be added)
    function refund() external {
        require(msg.sender == buyer, "Only buyer can refund");
        require(!isFulfilled && !isRefunded, "Transaction already completed");

        uint256 balance = eHKD.balanceOf(address(this));
        require(balance >= amount, "Insufficient balance");

        isRefunded = true;
        eHKD.safeTransfer(buyer, amount);
        emit RefundIssued(buyer, amount);
    }

    // Verify balances (for testing/verification)
    function verifyBalances() external view returns (uint256 contractBalance, uint256 buyerBalance, uint256 sellerBalance) {
        return (
            eHKD.balanceOf(address(this)),
            eHKD.balanceOf(buyer),
            eHKD.balanceOf(seller)
        );
    }
}