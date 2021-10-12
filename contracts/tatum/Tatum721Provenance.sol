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
    mapping(uint256 => string[]) private _tokenData;
    mapping(uint256 => address[]) private _cashbackRecipients;
    mapping(uint256 => uint256[]) private _cashbackValues;
    mapping(uint256 => uint256[]) private _fixedValues;

    event TransferWithProvenance(
        uint256 indexed id,
        address owner,
        string data
    );

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function _appendTokenData(
        uint256 tokenId,
        string memory tokenData
    ) internal virtual {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenData[tokenId].push(tokenData);
    }

    function mintWithCashback(
        address to,
        uint256 tokenId,
        string memory uri,
        address[] memory recipientAddresses,
        uint256[] memory cashbackValues,
        uint256[] memory fValues
    ) public returns (bool) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have minter role to mint"
        );
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        // saving cashback addresses and values
        _cashbackRecipients[tokenId] = recipientAddresses;
        _cashbackValues[tokenId] = cashbackValues;
        _fixedValues[tokenId]=fValues;
        return true;
    }

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
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function getTokenData(uint256 tokenId)
        public
        view
        virtual
        returns (string[] memory)
    {
        return _tokenData[tokenId];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721, ERC721URIStorage)
    {
        return ERC721URIStorage._burn(tokenId);
    }

    function tokenCashbackValues(uint256 tokenId)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        return _cashbackValues[tokenId];
    }

    function tokenCashbackRecipients(uint256 tokenId)
        public
        view
        virtual
        returns (address[] memory)
    {
        return _cashbackRecipients[tokenId];
    }

    function updateCashbackForAuthor(uint256 tokenId, uint256 cashbackValue)
        public
        returns (bool)
    {
        for (uint256 i; i < _cashbackValues[tokenId].length; i++) {
            if (_cashbackRecipients[tokenId][i] == _msgSender()) {
                _cashbackValues[tokenId][i] = cashbackValue;
            }
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

    function _stringToUint(string memory s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        // result = 0;
        for (uint i; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    function safeTransfer(
        address to,
        uint256 tokenId,
        string calldata data
    ) public payable{
        uint index;
        uint value;
        bytes calldata dataBytes= bytes(data);
        for(uint i;i<dataBytes.length;i++){
            if(dataBytes[i]==0x27 && dataBytes[i+1]==0x27 && dataBytes[i+2]==0x27 && dataBytes[i+3]==0x23 && dataBytes[i+4]==0x23 && dataBytes[i+5]==0x23 && dataBytes[i+6]==0x27 && dataBytes[i+7]==0x27 && dataBytes[i+8]==0x27){
                index=i;
                bytes calldata valueBytes=dataBytes[index+9:];
                value=_stringToUint(string(valueBytes));
            }
        }
        
        if (_cashbackRecipients[tokenId].length != 0) {
            uint256 percentSum;
            for (uint256 i; i < _cashbackValues[tokenId].length; i++) {
                percentSum += _cashbackValues[tokenId][i];
            }
            uint256 sum = (percentSum * value) / 100;
            if (sum > msg.value) {
                payable(msg.sender).transfer(msg.value);
                revert(
                    "Value should be greater than or equal to cashback value"
                );
            }
            for (uint256 i; i < _cashbackRecipients[tokenId].length; i++) {
                // transferring cashback to authors
                // require(_cashbackValues[tokenId][i] > 0);
                uint cbvalue=(_cashbackValues[tokenId][i]* value) / 100;
                if ( cbvalue>=_fixedValues[tokenId][i]) {
                    payable(_cashbackRecipients[tokenId][i]).transfer(cbvalue);
                }else if(cbvalue<_fixedValues[tokenId][i]){
                    payable(_cashbackRecipients[tokenId][i]).transfer(
                        (_fixedValues[tokenId][i])
                    );
                }
            }
            if (msg.value > sum) {
                payable(msg.sender).transfer(msg.value - sum);
            }
          
        } 
        _safeTransfer(_msgSender(), to, tokenId, dataBytes);
        _appendTokenData(tokenId,data);
        emit TransferWithProvenance(tokenId, to, data);
    }
}
