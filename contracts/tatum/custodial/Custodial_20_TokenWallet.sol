// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../access/Ownable.sol";
import "../../token/ERC20/IERC20.sol";

contract Custodial_20_TokenWallet is Ownable {

    receive() external payable {
    }

    /**
        Function transfer assets owned by this wallet to the recipient. Transfer only 1 type of asset.
        @param tokenAddress - address of the asset to own, if transferring native asset, use 0x0000000 address
        @param contractType - type of asset
                                - 0 - ERC20
                                - 3 - native asset
        @param recipient - recipient of the transaction
        @param amount - amount to be transferred in the asset based of the contractType
    **/
    function transfer(address tokenAddress, uint256 contractType, address recipient, uint256 amount, uint256) public payable {
        if (contractType == 0) {
            IERC20(tokenAddress).transfer(recipient, amount);
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
                                - 0 - ERC20
        @param spender - who will be able to spend the assets on behalf of the user
        @param amount - amount to be approved to spend in the asset based of the contractType
    **/
    function approve(address tokenAddress, uint256 contractType, address spender, uint256 amount, uint256) public virtual {
        if (contractType == 0) {
            IERC20(tokenAddress).approve(spender, amount);
        } else {
            revert("Unsupported contract type");
        }
    }
}
