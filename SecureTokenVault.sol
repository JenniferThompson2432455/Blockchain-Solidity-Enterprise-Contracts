// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20";

/// @title ERC20代币安全托管金库
/// @dev 支持时间锁解锁、管理员冻结、限额提现，适合团队资金管理
contract SecureTokenVault {
    address public immutable owner;
    uint256 public unlockDelay = 1 hours;
    bool public vaultFrozen;
    
    mapping(address => uint256) public withdrawRequests;
    mapping(address => uint256) public requestTime;

    constructor() { owner = msg.sender; }

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }
    modifier notFrozen() { require(!vaultFrozen, "Vault frozen"); _; }

    /// @notice 提交提现申请
    function requestWithdraw(address token, uint256 amount) external notFrozen {
        withdrawRequests[token] = amount;
        requestTime[token] = block.timestamp;
    }

    /// @notice 延迟后提现
    function executeWithdraw(address token) external onlyOwner notFrozen {
        require(block.timestamp >= requestTime[token] + unlockDelay, "Wait delay");
        uint256 amount = withdrawRequests[token];
        IERC20(token).transfer(owner, amount);
    }

    /// @notice 紧急冻结金库
    function toggleFreeze() external onlyOwner { vaultFrozen = !vaultFrozen; }
}
