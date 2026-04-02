// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 2/3 多签钱包
/// @dev 3位管理员，任意2人同意即可执行转账
contract MultiSignatureWallet {
    address[3] public owners;
    uint256 public constant requiredSign = 2;
    mapping(bytes32 => mapping(address => bool)) public signatures;

    constructor(address[3] memory _owners) { owners = _owners; }

    modifier onlyOwner() { require(isOwner(msg.sender), "Not owner"); _; }

    function isOwner(address account) public view returns(bool) {
        for(uint i=0;i<3;i++){if(owners[i]==account)return true;}
        return false;
    }

    function submitTransaction(address to, uint256 value) external onlyOwner returns(bytes32) {
        bytes32 txId = keccak256(abi.encodePacked(to, value, block.timestamp));
        signTransaction(txId);
        return txId;
    }

    function signTransaction(bytes32 txId) public onlyOwner {
        require(!signatures[txId][msg.sender], "Signed");
        signatures[txId][msg.sender] = true;
    }

    function executeTransaction(address to, uint256 value, bytes32 txId) external {
        uint256 count = 0;
        for(uint i=0;i<3;i++){if(signatures[txId][owners[i]])count++;}
        require(count >= requiredSign, "Not enough signs");
        (bool success,) = payable(to).call{value:value}("");
        require(success, "Transfer failed");
    }
}
