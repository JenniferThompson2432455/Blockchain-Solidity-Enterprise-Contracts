// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title 灵魂绑定身份SBT
/// @dev 不可转让，用于KYC、社区身份、资质认证
contract SoulBoundIdentity is ERC721 {
    uint256 public tokenId;
    mapping(address => bool) public hasIdentity;
    mapping(uint256 => string) public userIdentityURI;

    constructor() ERC721("SoulBoundID", "SBTID") {}

    /// @notice 铸造SBT身份（不可转让）
    function mintIdentity(string calldata uri) external {
        require(!hasIdentity[msg.sender], "Already own SBT");
        _safeMint(msg.sender, tokenId);
        userIdentityURI[tokenId] = uri;
        hasIdentity[msg.sender] = true;
        tokenId++;
    }

    /// @notice 重写转让函数 → 强制禁止转账
    function _transfer(address, address, uint256) internal pure override {
        revert("SBT cannot be transferred");
    }
}
