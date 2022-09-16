// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/ERC20/IERC20.sol";
import "../../token/ERC1155/IERC1155.sol";
import "../../token/ERC721/IERC721.sol";
import "./CustodialOwnable.sol";
import "../../token/ERC20/utils/SafeERC20.sol";
import "../../utils/Address.sol";

contract CustodialWallet is CustodialOwnable {

    using SafeERC20 for IERC20;

    bool private _locked = false;
    modifier entrancyGuard() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    event TransferNativeAsset(address indexed recipient, uint256 indexed amount);

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    receive() external payable {
    }

    function init(address owner) public override {
        CustodialOwnable.init(owner);
    }

    /**
        Function transfer assets owned by this wallet to the recipient. Transfer only 1 type of asset.
        @param tokenAddress - address of the asset to own, if transferring native asset, use 0x0000000 address
        @param contractType - type of asset
                                - 0 - ERC20
                                - 1 - ERC721
                                - 2 - ERC1155
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType, for ERC721 not important
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function transfer(address tokenAddress, uint256 contractType, address recipient, uint256 amount, uint256 tokenId) public payable onlyOwner entrancyGuard {
        require(recipient != address(0), "Invalid recipient address");
        if (contractType == 0) {
            IERC20(tokenAddress).safeTransfer(recipient, amount);
        } else if (contractType == 1) {
            IERC721(tokenAddress).safeTransferFrom(address(this), recipient, tokenId, "");
        } else if (contractType == 2) {
            IERC1155(tokenAddress).safeTransferFrom(address(this), recipient, tokenId, amount, "");
        } else if (contractType == 3) {
            Address.sendValue(payable(recipient), amount);
            emit TransferNativeAsset(recipient, amount);
        } else {
            revert("Unsupported contract type");
        }
    }

    /**
        Function transfer assets owned by this wallet to the recipient. Transfer any number of assets.
        @param tokenAddress - address of the asset to own, if transferring native asset, use 0x0000000 address
        @param contractType - type of asset
                                - 0 - ERC20
                                - 1 - ERC721
                                - 2 - ERC1155
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType, for ERC721 not important
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function transferBatch(address[] memory tokenAddress, uint256[] memory contractType, address[] memory recipient, uint256[] memory amount, uint256[] memory tokenId) external payable onlyOwner entrancyGuard{
        require(tokenAddress.length == contractType.length, "Length mismatch between tokenAddress array and contractType array");
        require(recipient.length == contractType.length, "Length mismatch between recipient array and contractType array");
        require(recipient.length == amount.length, "Length mismatch between recipient array and amount array");
        require(amount.length == tokenId.length, "Length mismatch between toeknId array and amount array");
        for (uint256 i = 0; i < tokenAddress.length; i++) {
            require(recipient[i] != address(0), "Check addresses for validity");
            if (contractType[i] == 0) {
                IERC20(tokenAddress[i]).safeTransfer(recipient[i], amount[i]);
            } else if (contractType[i] == 1) {
                IERC721(tokenAddress[i]).safeTransferFrom(address(this), recipient[i], tokenId[i], "");
            } else if (contractType[i] == 2) {
                IERC1155(tokenAddress[i]).safeTransferFrom(address(this), recipient[i], tokenId[i], amount[i], "");
            } else if (contractType[i] == 3) {
                Address.sendValue(payable(recipient[i]), amount[i]);
                emit TransferNativeAsset(recipient[i], amount[i]);
            } else {
                revert("Unsupported contract type");
            }
        }
    }

    /**
        Function approves the transfer of assets owned by this wallet to the spender. Approve only 1 type of asset.
        @param tokenAddress - address of the asset to approve
        @param contractType - type of asset
                                - 0 - ERC20
                                - 1 - ERC721
                                - 2 - ERC1155
        @param spender - who will be able to spend the assets on behalf of the user
        @param amount - amount to be approved to spend in the asset based of the contractType
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function approve(address tokenAddress, uint256 contractType, address spender, uint256 amount, uint256 tokenId) public virtual onlyOwner {
        if (contractType == 0) {
            bool approval = IERC20(tokenAddress).approve(spender, amount);
            require(approval, "Approval was unsuccessful");
        } else if (contractType == 1) {
            IERC721(tokenAddress).approve(spender, tokenId);
        } else if (contractType == 2) {
            IERC1155(tokenAddress).setApprovalForAll(spender, true);
        } else {
            revert("Unsupported contract type");
        }
    }
}
