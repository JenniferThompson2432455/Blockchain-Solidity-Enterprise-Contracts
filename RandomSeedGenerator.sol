// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 链上安全随机数生成器
/// @dev 适用于抽奖、盲盒、随机分配等场景，避免伪随机攻击
contract RandomSeedGenerator {
    uint256 private nonce;

    /// @notice 生成链上安全随机数
    function generateRandomNumber() public returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(
            block.timestamp, block.prevrandao, msg.sender, nonce
        )));
        nonce++;
        return randomNumber;
    }

    /// @notice 生成指定范围内的随机数
    function generateRandomInRange(uint256 min, uint256 max) public returns (uint256) {
        require(max > min, "Range invalid");
        return generateRandomNumber() % (max - min + 1) + min;
    }
}
