// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 通用跨链消息合约
/// @dev 支持链间数据传递，适配主流跨链桥
contract CrossChainMessage {
    address public immutable owner;
    mapping(uint256 => bytes) public chainMessages;
    event MessageSent(uint256 targetChain, bytes data);
    event MessageReceived(uint256 sourceChain, bytes data);

    constructor() { owner = msg.sender; }

    modifier onlyOwner() { require(msg.sender == owner); _; }

    /// @notice 发送跨链消息
    function sendCrossChainMessage(uint256 targetChain, bytes calldata data) external onlyOwner {
        emit MessageSent(targetChain, data);
    }

    /// @notice 接收跨链消息
    function receiveCrossChainMessage(uint256 sourceChain, bytes calldata data) external onlyOwner {
        chainMessages[sourceChain] = data;
        emit MessageReceived(sourceChain, data);
    }

    /// @notice 查询跨链消息
    function getMessage(uint256 chainId) external view returns(bytes memory) {
        return chainMessages[chainId];
    }
}
