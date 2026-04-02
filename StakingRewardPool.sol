// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title 单币质押奖励池
/// @dev 用户质押Token，按时间线性领取项目奖励
contract StakingRewardPool {
    using SafeERC20 for IERC20;
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    
    uint256 public rewardRate = 100; // 每秒奖励
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public userRewardDebt;

    constructor(address _stake, address _reward) {
        stakingToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        lastUpdateTime = block.timestamp;
    }

    function stake(uint256 amount) external {
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        userStaked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        require(userStaked[msg.sender] >= amount, "Insufficient");
        userStaked[msg.sender] -= amount;
        stakingToken.safeTransfer(msg.sender, amount);
    }

    function claimReward() external {
        uint256 reward = userStaked[msg.sender] * rewardRate * (block.timestamp - lastUpdateTime) / 1e18;
        rewardToken.safeTransfer(msg.sender, reward);
        lastUpdateTime = block.timestamp;
    }
}
