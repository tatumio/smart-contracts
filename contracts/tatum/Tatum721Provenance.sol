//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

//import "../utils/Stringutils.sol";
import "../token/ERC721/extensions/ERC721Enumerable.sol";
import "../token/ERC721/extensions/ERC721URIStorage.sol";
import "../access/AccessControlEnumerable.sol";

abstract contract Stringsutils {
        struct Slice {
            uint _len;
            uint _ptr;
        }
        function toSlice(string memory self) external virtual pure returns (Slice memory);
        function toString(Slice memory self) external virtual pure returns (string memory);
        function count(Slice memory self, Slice memory needle) external virtual pure returns (uint cnt);
        function split(Slice memory self, Slice memory needle) external virtual pure returns (Slice memory token);
        function rsplit(Slice memory self, Slice memory needle) external virtual pure returns (Slice memory token);
}
contract Tatum721Provenance is
    ERC721Enumerable,
    ERC721URIStorage,
    AccessControlEnumerable
{
    Stringsutils str= Stringsutils(0xb9a3a1183b8e62139C14a06E8474c26C5c4eEcD8);
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    struct Slice {
            uint _len;
            uint _ptr;
        }
    mapping(uint256 => string[]) private _tokenData;
    mapping(uint256 => address[]) private _cashbackRecipients;
    mapping(uint256 => uint256[]) private _cashbackValues;

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

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param uri The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */

    function mintWithCashback(
        address to,
        uint256 tokenId,
        string memory uri,
        address[] memory recipientAddresses,
        uint256[] memory cashbackValues
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

    function caller() public view virtual returns (address) {
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
                return true;
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
    
    function checkData(string memory data)public view returns (string[] memory){
        Stringsutils.Slice memory s = str.toSlice(data);    
        Stringsutils.Slice memory delim = str.toSlice("'''###'''");     
        // // Stringsutils.Slice memory token;
        // string[] memory parts = new string[](s.count(delim)+1);      
        string[] memory parts = new string[](str.count(s,delim)+1);      
        // parts[0]=str.toString(str.split(s,delim));
        // parts[1]=str.toString(str.rsplit(s,delim));
        //return _stringToUint(parts[1]);
        return parts;
    }
    function _stringToUint(string memory s) internal pure returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    // function safeTransfer(
    //     address to,
    //     uint256 tokenId,
    //     string memory data
    // ) public payable {
    //     Stringsutils.Slice memory s = str.toSlice(data);    
    //     Stringsutils.Slice memory delim = str.toSlice("'''###'''");     
    //     Stringsutils.Slice memory token;
    //     // string[] memory parts = new string[](s.count(delim)+1);      
    //     string[] memory parts = new string[](str.count(s,delim)+1);      
    //     parts[0]=str.toString(str.split(s,delim,token));
    //     parts[1]=str.toString(str.rsplit(s,delim,token));
    //     uint value =_stringToUint(parts[1]);
    //     bytes memory bytesData=abi.encodePacked(data);
        
    //     if (_cashbackRecipients[tokenId].length != 0) {
    //         // checking cashback addresses exists and sum of cashbacks
    //         require(
    //             _cashbackRecipients[tokenId].length != 0,
    //             "CashbackToken should be of cashback type"
    //         );
    //         uint256 percentSum = 0;
    //         for (uint256 i = 0; i < _cashbackValues[tokenId].length; i++) {
    //             percentSum += _cashbackValues[tokenId][i];
    //         }
    //         uint256 sum = (percentSum * value) / 100;
    //         if (sum > msg.value) {
    //             payable(msg.sender).transfer(msg.value);
    //             revert(
    //                 "Value should be greater than or equal to cashback value"
    //             );
    //         }
    //         for (uint256 i = 0; i < _cashbackRecipients[tokenId].length; i++) {
    //             // transferring cashback to authors
    //             if (_cashbackValues[tokenId][i] > 0) {
    //                 payable(_cashbackRecipients[tokenId][i]).transfer(
    //                     (_cashbackValues[tokenId][i] * value) / 100
    //                 );
    //             }
    //         }
    //         if (msg.value > sum) {
    //             payable(msg.sender).transfer(msg.value - sum);
    //         }
    //         _safeTransfer(_msgSender(), to, tokenId, bytesData);
    //     } else {
    //         _safeTransfer(_msgSender(), to, tokenId, bytesData);
    //     }
    //     _appendTokenData(tokenId,string(bytesData));
    //     emit TransferWithProvenance(tokenId, to, string(bytesData));
    // }
}
