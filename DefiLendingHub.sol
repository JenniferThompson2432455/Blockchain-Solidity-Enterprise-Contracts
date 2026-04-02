// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title DeFi去中心化借贷中心
/// @dev 抵押资产 → 借贷资产 → 计息 → 清算
contract DefiLendingHub {
    IERC20 public collateralToken;
    IERC20 public lendToken;
    uint256 public collateralRate = 150; // 150%抵押率
    uint256 public dailyInterest = 1; // 1%日息

    mapping(address => uint256) public collateralBalance;
    mapping(address => uint256) public lendBalance;
    mapping(address => uint256) public lendStartTime;

    constructor(address _collateral, address _lend) {
        collateralToken = IERC20(_collateral);
        lendToken = IERC20(_lend);
    }

    function depositCollateral(uint256 amount) external {
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateralBalance[msg.sender] += amount;
    }

    function borrow(uint256 amount) external {
        uint256 required = (amount * collateralRate) / 100;
        require(collateralBalance[msg.sender] >= required, "Insufficient collateral");
        lendBalance[msg.sender] += amount;
        lendStartTime[msg.sender] = block.timestamp;
        lendToken.transfer(msg.sender, amount);
    }

    function repay() external {
        uint256 daysPassed = (block.timestamp - lendStartTime[msg.sender]) / 1 days;
        uint256 interest = (lendBalance[msg.sender] * dailyInterest * daysPassed) / 100;
        lendToken.transferFrom(msg.sender, address(this), lendBalance[msg.sender] + interest);
        lendBalance[msg.sender] = 0;
    }
}
