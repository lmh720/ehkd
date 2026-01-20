// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EHkdPermitTransfer is ReentrancyGuard {
    IERC20 public immutable ehkd;
    IERC20Permit public immutable ehkdPermit;
    
    event TransferWithPermit(address indexed from, address indexed to, uint256 amount);

    constructor(address _ehkd) {
        require(_ehkd != address(0), "Invalid token");
        ehkd = IERC20(_ehkd);
        ehkdPermit = IERC20Permit(_ehkd);
    }

    /// @notice Transfer EHkd from `from` to `to` using an ERC-2612 permit (single-call)
    /// @param from The token owner who signed the permit
    /// @param to Recipient address
    /// @param amount Amount to transfer
    /// @param deadline Permit expiration timestamp
    /// @param v,r,s Permit signature components
    function transferWithPermit(
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(from != address(0), "Invalid from");
        require(to != address(0), "Invalid to");
        require(amount > 0, "Amount must be > 0");

        // Use permit to set allowance of this contract for `from`
        ehkdPermit.permit(from, address(this), amount, deadline, v, r, s);

        // Pull tokens from `from` and send to `to`
        bool ok = ehkd.transferFrom(from, to, amount);
        require(ok, "Transfer failed");

        emit TransferWithPermit(from, to, amount);
    }
}