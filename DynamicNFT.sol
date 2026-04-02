// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title 链上动态属性NFT
/// @dev NFT等级、属性随时间/交互自动变化，GameFi首选
contract DynamicNFT is ERC721 {
    uint256 public tokenCounter;
    mapping(uint256 => uint256) public nftLevel;
    mapping(uint256 => uint256) public lastUpgradeTime;

    constructor() ERC721("DynamicNFT", "DNFT") {}

    /// @notice 铸造动态NFT
    function mint() external {
        _safeMint(msg.sender, tokenCounter);
        nftLevel[tokenCounter] = 1;
        lastUpgradeTime[tokenCounter] = block.timestamp;
        tokenCounter++;
    }

    /// @notice NFT自动升级（链上逻辑）
    function autoUpgrade(uint256 tokenId) external {
        require(_exists(tokenId), "NFT not exist");
        require(block.timestamp >= lastUpgradeTime[tokenId] + 30 minutes, "Cooldown");
        nftLevel[tokenId]++;
        lastUpgradeTime[tokenId] = block.timestamp;
    }
}
