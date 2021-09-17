//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../token/ERC721/extensions/ERC721Enumerable.sol";
import "../token/ERC721/extensions/ERC721URIStorage.sol";
import "../access/AccessControlEnumerable.sol";

contract Tatum721Provenance is
ERC721Enumerable,
ERC721URIStorage,
AccessControlEnumerable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping (uint256 => TokenData[]) private _tokenData;
    struct TokenData {
        string data;
        uint256 value;
    }
    event TransferWithProvenance(uint256 indexed id, address owner,string data, uint256 value);
    constructor (string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function _setTokenData(uint256 tokenId, string memory tokenData,uint256 value) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        TokenData memory tokendata=TokenData(tokenData,value);
        _tokenData[tokenId].push(tokendata);
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
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have minter role to mint"
        );
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return true;
    }

    function supportsInterface(bytes4 interfaceId)
    public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
    public view virtual override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }
    function gettokenData(uint256 tokenId)
    public view virtual returns (TokenData[] memory)
    {
        return _tokenData[tokenId];
    }
    function caller()public view virtual returns (address){
        return _msgSender();
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
    internal virtual override(ERC721, ERC721URIStorage)
    {
        return ERC721URIStorage._burn(tokenId);
    }

    function mintMultiple(
        address[] memory to,
        uint256[] memory tokenId,
        string[] memory uri
    ) public returns (bool) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have minter role to mint"
        );
        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], tokenId[i]);
            _setTokenURI(tokenId[i], uri[i]);
        }
        return true;
    }
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );
        _burn(tokenId);
    }

    function safeTransfer(address to, uint256 tokenId,string memory data, uint256 value) public { 
            bytes memory bytesData =bytes(data);
            _safeTransfer(_msgSender(), to, tokenId, bytesData);
            _setTokenData(tokenId, data,value);     
            emit TransferWithProvenance(tokenId, _msgSender(), data, value);   
    }

}
