// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

/// @title 带版税的NFT交易市场
/// @dev 自动执行创作者版税，符合ERC2981标准
contract RoyaltyNFTMarket is ERC2981 {
    struct Listing {
        address seller;
        uint256 price;
        address nftContract;
        uint256 tokenId;
    }

    mapping(bytes32 => Listing) public listings;

    function listNFT(address nft, uint256 tokenId, uint256 price) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        bytes32 id = keccak256(abi.encodePacked(nft, tokenId));
        listings[id] = Listing(msg.sender, price, nft, tokenId);
    }

    function buyNFT(bytes32 listingId) external payable {
        Listing memory item = listings[listingId];
        require(msg.value >= item.price, "Insufficient funds");
        
        (address creator, uint256 royalty) = royaltyInfo(item.tokenId, item.price);
        payable(creator).transfer(royalty);
        payable(item.seller).transfer(msg.value - royalty);
        
        IERC721(item.nftContract).transferFrom(address(this), msg.sender, item.tokenId);
        delete listings[listingId];
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
