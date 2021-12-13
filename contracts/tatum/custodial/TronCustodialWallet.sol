// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/ERC20/IERC20.sol";
import "./CustodialOwnable.sol";

interface TRC721 {
    // Returns the number of NFTs owned by the given account
    function balanceOf(address _owner) external view returns (uint256);

    //Returns the owner of the given NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    //Transfer ownership of NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    //Transfer ownership of NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    //Transfer ownership of NFT
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    //Grants address ‘_approved’ the authorization of the NFT ‘_tokenId’
    function approve(address _approved, uint256 _tokenId) external payable;

    //Grant/recover all NFTs’ authorization of the ‘_operator’
    function setApprovalForAll(address _operator, bool _approved) external;

    //Query the authorized address of NFT
    function getApproved(uint256 _tokenId) external view returns (address);

    //Query whether the ‘_operator’ is the authorized address of the ‘_owner’
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    //The successful ‘transferFrom’ and ‘safeTransferFrom’ will trigger the ‘Transfer’ Event
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    //The successful ‘Approval’ will trigger the ‘Approval’ event
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    //The successful ‘setApprovalForAll’ will trigger the ‘ApprovalForAll’ event
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

}

contract TronCustodialWallet is CustodialOwnable {

    event TransferNativeAsset(address indexed recipient, uint256 indexed amount);
    
    function onTRC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onTRC721Received.selector;
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
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType, for ERC721 not important
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function transfer(address tokenAddress, uint256 contractType, address recipient, uint256 amount, uint256 tokenId) public payable onlyOwner {
        if (contractType == 0) {
            IERC20(tokenAddress).transfer(recipient, amount);
        } else if (contractType == 1) {
            TRC721(tokenAddress).safeTransferFrom(address(this), recipient, tokenId, "");
        } else if (contractType == 3) {
            emit TransferNativeAsset(recipient, amount);
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
        @param tokenId - tokenId to transfer, valid only for ERC721 and ERC1155
    **/
    function transferBatch(address[] memory tokenAddress, uint256[] memory contractType, address[] memory recipient, uint256[] memory amount, uint256[] memory tokenId) public payable onlyOwner {
        require(tokenAddress.length == contractType.length);
        require(recipient.length == contractType.length);
        require(recipient.length == amount.length);
        require(amount.length == tokenId.length);
        for (uint256 i = 0; i < tokenAddress.length; i++) {
            if (contractType[i] == 0) {
                IERC20(tokenAddress[i]).transfer(recipient[i], amount[i]);
            } else if (contractType[i] == 1) {
                TRC721(tokenAddress[i]).safeTransferFrom(address(this), recipient[i], tokenId[i], "");
            } else if (contractType[i] == 3) {
                payable(recipient[i]).transfer(amount[i]);
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
        @param spender - who will be able to spend the assets on behalf of the user
        @param amount - amount to be approved to spend in the asset based of the contractType
        @param tokenId - tokenId to transfer, valid only for ERC721 
    **/
    function approve(address tokenAddress, uint256 contractType, address spender, uint256 amount, uint256 tokenId) public virtual onlyOwner {
        if (contractType == 0) {
            IERC20(tokenAddress).approve(spender, amount);
        } else if (contractType == 1) {
            TRC721(tokenAddress).approve(spender, tokenId);
        } else {
            revert("Unsupported contract type");
        }
    }
}
