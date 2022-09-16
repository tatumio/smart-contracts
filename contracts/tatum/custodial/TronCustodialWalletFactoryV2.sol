// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../../access/Ownable.sol";
import "./TronCustodialWallet.sol";
import "../../proxy/Clones.sol";

contract TronCustodialWalletFactoryV2 {

    using Clones for TronCustodialWalletFactoryV2;

    uint256 private constant _MAX_ARRAY_BOUNDS = 2000;
    uint256 private constant _MAX_ARRAY_CALCULATE_BOUNDS = 10_000;

    TronCustodialWallet private _rawWallet;

    mapping(bytes32 => address) public wallets;

    event WalletDetails(address addr, address owner, uint256 index);
    event Created(address addr);
    event CreateFailed(address addr, address owner, string reason);

    constructor () {
        _rawWallet = new TronCustodialWallet();
    }

    function getWallet(address owner, uint256 index) public view returns (address addr, bool exists, bytes32 salt) {
        salt = keccak256(abi.encodePacked(owner, index));
        addr = Clones.predictDeterministicTronAddress(address(_rawWallet), salt);
        exists = wallets[salt] != address(0);
    }

    function getWallets(address owner, uint256[] memory index) external view returns (address[] memory, bool[] memory, bytes32[] memory) {
        require(index.length <= _MAX_ARRAY_CALCULATE_BOUNDS, "Maximum allowable size of array has been exceeded");
        address[] memory addr = new address[](index.length); 
        bool[] memory exists = new bool[](index.length); 
        bytes32[] memory salt = new bytes32[](index.length);
        
        for (uint256 i = 0; i < index.length; i++) {
            salt[i] = keccak256(abi.encodePacked(owner, index[i]));
            addr[i] = Clones.predictDeterministicTronAddress(address(_rawWallet), salt[i]);
            exists[i] = wallets[salt[i]] != address(0);
        }
        return (addr, exists, salt);
    }

    function createBatch(address owner, uint256[] memory index) external {
        require(index.length <= _MAX_ARRAY_BOUNDS, "Maximum allowable size of array has been exceeded");
        for (uint256 i = 0; i < index.length; i++) {
            (address calculatedAddress, bool exists, bytes32 salt) = getWallet(owner, index[i]);
            if(exists) {
                emit CreateFailed(calculatedAddress, owner, "Wallet already exists");
                continue;
            }
            address addr = Clones.cloneDeterministic(address(_rawWallet), salt);
            if(addr != calculatedAddress) {
                emit CreateFailed(calculatedAddress, owner, "Address doesnt match with predicted address.");
                continue;
            }

            wallets[salt] = addr;
            TronCustodialWallet(payable(addr)).init(owner);
            emit Created(addr);
            emit WalletDetails(addr, owner, index[i]);
        }
    }

    function create(address owner, uint256 index) external {
        (address calculatedAddress, bool exists, bytes32 salt) = getWallet(owner, index);
        require(!exists, "Wallet already exists");
        address addr = Clones.cloneDeterministic(address(_rawWallet), salt);
        require(addr == calculatedAddress, "Address doesnt match with predicted address.");

        wallets[salt] = addr;
        TronCustodialWallet(payable(addr)).init(owner);
        emit Created(addr);
        emit WalletDetails(addr, owner, index);
    }
}
