// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

contract Tatum1155 is ERC1155PresetMinterPauser {
    bool _publicMint;
    constructor(string memory uri, bool publicMint) ERC1155PresetMinterPauser(uri) {
        _publicMint=publicMint;
    }

    function safeTransfer(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    public
    virtual
    {
        return safeTransferFrom(_msgSender(), to, id, amount, data);
    }

    function safeBatchTransfer(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    public
    virtual
    {
        return safeBatchTransferFrom(_msgSender(), to, ids, amounts, data);
    }

    function mintBatch(address[] memory to, uint256[][] memory ids, uint256[][] memory amounts, bytes memory data) public virtual {
        if(!_publicMint){
            require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        }
        for (uint i = 0; i < to.length; i++) {
            _mintBatch(to[i], ids[i], amounts[i], data);
        }
    }
    function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual override{
        if(!_publicMint){
            require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        }
        _mint(to, id, amount, data);
    }
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual override {
        if(!_publicMint){
            require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");
        }
        _mintBatch(to, ids, amounts, data);
    }

}
