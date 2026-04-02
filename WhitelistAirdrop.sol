// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title 白名单专属空投
/// @dev 仅白名单用户可领取，支持单次/批量空投
contract WhitelistAirdrop {
    using SafeERC20 for IERC20;
    address public owner;
    IERC20 public token;
    mapping(address => bool) public whitelist;
    mapping(address => bool) public claimed;
    uint256 public airdropAmount = 1000 * 1e18;

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function addToWhitelist(address[] calldata users) external onlyOwner {
        for(uint i=0;i<users.length;i++){whitelist[users[i]]=true;}
    }

    function claimAirdrop() external {
        require(whitelist[msg.sender], "Not in whitelist");
        require(!claimed[msg.sender], "Already claimed");
        claimed[msg.sender] = true;
        token.safeTransfer(msg.sender, airdropAmount);
    }
}
