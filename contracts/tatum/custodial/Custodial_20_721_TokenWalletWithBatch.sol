// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../access/Ownable.sol";
import "../../token/ERC20/IERC20.sol";
import "../../token/ERC721/IERC721.sol";

contract Custodial_20_721_TokenWalletWithBatch is Ownable {

    receive() external payable {
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
    /**
        Function transfer assets owned by this wallet to the recipient. Transfer only 1 type of asset.
        @param tokenAddress - address of the asset to own, if transferring native asset, use 0x0000000 address
        @param contractType - type of asset
                                - 0 - ERC20
                                - 1 - ERC721
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType, for ERC721 not important
        @param tokenId - tokenId to transfer, valid only for ERC721
    **/
    function transfer(address tokenAddress, uint256 contractType, address recipient, uint256 amount, uint256 tokenId) public payable {
        if (contractType == 0) {
            IERC20(tokenAddress).transfer(recipient, amount);
        } else if (contractType == 1) {
            IERC721(tokenAddress).safeTransferFrom(address(this), recipient, tokenId, "");
        } else if (contractType == 3) {
            payable(recipient).transfer(amount);
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
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType, for ERC721 not important
        @param tokenId - tokenId to transfer, valid only for ERC721
    **/
    function transferBatch(address[] memory tokenAddress, uint256[] memory contractType, address[] memory recipient, uint256[] memory amount, uint256[] memory tokenId) public payable {
        require(tokenAddress.length == contractType.length);
        require(recipient.length == contractType.length);
        require(recipient.length == amount.length);
        require(recipient.length == tokenId.length);
        for (uint256 i = 0; i < tokenAddress.length; i++) {
            if (contractType[i] == 0) {
                IERC20(tokenAddress[i]).transfer(recipient[i], amount[i]);
            } else if (contractType[i] == 1) {
                IERC721(tokenAddress[i]).safeTransferFrom(address(this), recipient[i], tokenId[i], "");
            } else if (contractType[i] == 3) {
                payable(recipient[i]).transfer(amount[i]);
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
        @param spender - who will be able to spend the assets on behalf of the user
        @param amount - amount to be approved to spend in the asset based of the contractType
        @param tokenId - tokenId to transfer, valid only for ERC721
    **/
    function approve(address tokenAddress, uint256 contractType, address spender, uint256 amount, uint256 tokenId) public virtual {
        if (contractType == 0) {
            IERC20(tokenAddress).approve(spender, amount);
        } else if (contractType == 1) {
            IERC721(tokenAddress).approve(spender, tokenId);
        } else {
            revert("Unsupported contract type");
        }
    }
}
