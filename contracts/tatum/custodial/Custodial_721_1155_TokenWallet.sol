// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../access/Ownable.sol";
import "../../token/ERC1155/IERC1155.sol";
import "../../token/ERC721/IERC721.sol";

contract Custodial_721_1155_TokenWallet is Ownable {

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

    /**
        Function transfer assets owned by this wallet to the recipient. Transfer only 1 type of asset.
        @param tokenAddress - address of the asset to own, if transferring native asset, use 0x0000000 address
        @param contractType - type of asset
                                - 1 - ERC721
                                - 2 - ERC1155
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType, for ERC721 not important
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function transfer(address tokenAddress, uint256 contractType, address recipient, uint256 amount, uint256 tokenId) public payable {
        if (contractType == 1) {
            IERC721(tokenAddress).safeTransferFrom(address(this), recipient, tokenId, "");
        } else if (contractType == 2) {
            IERC1155(tokenAddress).safeTransferFrom(address(this), recipient, tokenId, amount, "");
        } else if (contractType == 3) {
            payable(recipient).transfer(amount);
        } else {
            revert("Unsupported contract type");
        }
    }

    /**
        Function approves the transfer of assets owned by this wallet to the spender. Approve only 1 type of asset.
        @param tokenAddress - address of the asset to approve
        @param contractType - type of asset
                                - 1 - ERC721
                                - 2 - ERC1155
        @param spender - who will be able to spend the assets on behalf of the user
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function approve(address tokenAddress, uint256 contractType, address spender, uint256, uint256 tokenId) public virtual {
        if (contractType == 1) {
            IERC721(tokenAddress).approve(spender, tokenId);
        } else if (contractType == 2) {
            IERC1155(tokenAddress).setApprovalForAll(spender, true);
        } else {
            revert("Unsupported contract type");
        }
    }
}
