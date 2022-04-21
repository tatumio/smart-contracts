// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../../access/Ownable.sol";
import "./CustodialWallet.sol";
import "../../proxy/Clones.sol";

contract CustodialWalletFactoryV2 {

    using Clones for CustodialWalletFactoryV2;

    CustodialWallet private rawWallet;

    mapping(bytes32 => address) public wallets;

    event WalletDetails(address addr, address owner, uint256 index);
    event Created(address addr);

    constructor () {
        rawWallet = new CustodialWallet();
    }

    function getWallet(address owner, uint256 index) public view returns (address addr, bool exists, bytes32 salt) {
        salt = keccak256(abi.encodePacked(owner, index));
        addr = Clones.predictDeterministicAddress(address(rawWallet), salt);
        exists = wallets[salt] != address(0);
    }

    function getWallets(address owner, uint256[] memory index) public view returns (address[] memory addr, bool[] memory exists, bytes32[] memory salt) {
        for (uint256 i = 0; i < index.length; i++) {
            salt[i] = keccak256(abi.encodePacked(owner, index[i]));
            addr[i] = Clones.predictDeterministicAddress(address(rawWallet), salt[i]);
            exists[i] = wallets[salt[i]] != address(0);
        }
        return (addr, exists, salt);
    }

    function create(address owner, uint256[] memory index) public {
        for (uint256 i = 0; i < index.length; i++) {
            (address calculatedAddress, bool exists, bytes32 salt) = getWallet(owner, index[i]);
            require(!exists, "Wallet already exists");
            address addr = Clones.cloneDeterministic(address(rawWallet), salt);
            require(addr == calculatedAddress, "Address doesnt match with predicted address.");

            wallets[salt] = addr;
            CustodialWallet(payable(addr)).init(owner);
            emit Created(addr);
            emit WalletDetails(addr, owner, index[i]);
        }
    }

    function create(address owner, uint256 index) public {
        (address calculatedAddress, bool exists, bytes32 salt) = getWallet(owner, index);
        require(!exists, "Wallet already exists");
        address addr = Clones.cloneDeterministic(address(rawWallet), salt);
        require(addr == calculatedAddress, "Address doesnt match with predicted address.");

        wallets[salt] = addr;
        CustodialWallet(payable(addr)).init(owner);
        emit Created(addr);
        emit WalletDetails(addr, owner, index);
    }
}
