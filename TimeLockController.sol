// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 时间锁权限管理合约
/// @dev 所有敏感操作延迟执行，防止恶意攻击
contract TimeLockController {
    address public immutable owner;
    uint256 public constant MIN_DELAY = 1 hours;
    uint256 public constant MAX_DELAY = 30 days;
    mapping(bytes32 => uint256) public queueTime;

    constructor() { owner = msg.sender; }

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function queueTransaction(bytes32 txId) external onlyOwner {
        queueTime[txId] = block.timestamp;
    }

    function executeTransaction(bytes32 txId) external onlyOwner {
        require(block.timestamp >= queueTime[txId] + MIN_DELAY, "Delay not passed");
        require(block.timestamp <= queueTime[txId] + MAX_DELAY, "Expired");
        queueTime[txId] = 0;
    }

    function cancelTransaction(bytes32 txId) external onlyOwner {
        queueTime[txId] = 0;
    }
}
