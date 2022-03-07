// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "../token/ERC721/ERC721.sol";
import "../token/ERC721/extensions/ERC721Enumerable.sol";
import "../token/ERC721/extensions/ERC721URIStorage.sol";
import "../security/Pausable.sol";
import "../utils/Ownable.sol";
import "../access/AccessControl.sol";
import "../token/ERC721/extensions/ERC721Burnable.sol";

contract Tatum721General is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, AccessControl, ERC721Burnable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bool _publicMint;
    constructor(string memory name_, string memory symbol_, bool publicMint)
    ERC721(name_, symbol_)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _publicMint = publicMint;
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "TatumGeneral721: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "TatumGeneral721: must have pauser role to pause"
        );
        _unpause();
    }

    /**
      * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param uri The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintWithTokenURI(
        address to,
        uint256 tokenId,
        string memory uri
    ) public returns (bool) {
        if (!_publicMint) {
            require(
                hasRole(MINTER_ROLE, _msgSender()),
                "TatumGeneral721: must have minter role to mint"
            );
        }
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return true;
    }

    /**
     * @dev Function to mint tokens. This helper function allows to mint multiple NFTs in 1 transaction.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param uri The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
    */
    function mintMultiple(
        address[] memory to,
        uint256[] memory tokenId,
        string[] memory uri
    ) public returns (bool) {
        if (!_publicMint) {
            require(
                hasRole(MINTER_ROLE, _msgSender()),
                "TatumGeneral721: must have minter role to mint"
            );
        }
        for (uint256 i = 0; i < to.length; i++) {
            _safeMint(to[i], tokenId[i]);
            _setTokenURI(tokenId[i], uri[i]);
        }
        return true;
    }

    function safeTransfer(address to, uint256 tokenId, bytes calldata data) public virtual {
        super._safeTransfer(_msgSender(), to, tokenId, data);
    }

    function safeTransfer(address to, uint256 tokenId) public virtual {
        super._safeTransfer(_msgSender(), to, tokenId, "");
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
