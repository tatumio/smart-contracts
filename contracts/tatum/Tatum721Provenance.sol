//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "../token/ERC721/extensions/ERC721Enumerable.sol";
import "../token/ERC721/extensions/ERC721URIStorage.sol";
import "../access/AccessControlEnumerable.sol";
import "../token/ERC20/IERC20.sol";

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
        string data,
        uint256 value
    );

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function _appendTokenData(uint256 tokenId, string calldata tokenData)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenData[tokenId].push(tokenData);
    }

    function mintWithTokenURI(
        address to,
        uint256 tokenId,
        string memory uri,
        address[] memory recipientAddresses,
        uint256[] memory cashbackValues,
        uint256[] memory fValues
    ) public {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have minter role to mint"
        );
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        // saving cashback addresses and values
        if (recipientAddresses.length > 0) {
            _cashbackRecipients[tokenId] = recipientAddresses;
            _cashbackValues[tokenId] = cashbackValues;
            _fixedValues[tokenId] = fValues;
        }
    }

    function mintMultiple(
        address[] memory to,
        uint256[] memory tokenId,
        string[] memory uri,
        address[][] memory recipientAddresses,
        uint256[][] memory cashbackValues,
        uint256[][] memory fValues
    ) public {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have minter role to mint"
        );
        for (uint256 i; i < to.length; i++) {
            _mint(to[i], tokenId[i]);
            _setTokenURI(tokenId[i], uri[i]);
            if (
                recipientAddresses.length > 0 &&
                recipientAddresses[i].length > 0
            ) {
                _cashbackRecipients[tokenId[i]] = recipientAddresses[i];
                _cashbackValues[tokenId[i]] = cashbackValues[i];
                _fixedValues[tokenId[i]] = fValues[i];
            }
        }
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
    {
        for (uint256 i; i < _cashbackValues[tokenId].length; i++) {
            if (_cashbackRecipients[tokenId][i] == _msgSender()) {
                _cashbackValues[tokenId][i] = cashbackValue;
            }
        }
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );
        _burn(tokenId);
    }

    function _stringToUint(string memory s)
        internal
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        // result = 0;
        for (uint256 i; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    function allowance(address a, uint256 t) public view returns (bool) {
        return _isApprovedOrOwner(a, t);
    }

    function safeTransfer(
        address to,
        uint256 tokenId,
        bytes calldata dataBytes
    ) public payable {
        uint256 index;
        uint256 value;
        uint256 sum;
        address erc;
        IERC20 token;
        (index, value, erc) = _bytesCheck(dataBytes);
        if (erc != address(0)) {
            token = IERC20(erc);
        }
        if (_cashbackRecipients[tokenId].length > 0) {
            uint256 percentSum;
            for (uint256 i = 0; i < _cashbackValues[tokenId].length; i++) {
                percentSum += _cashbackValues[tokenId][i];
            }
            sum = (percentSum * value) / 10000;
            if (erc == address(0)) {
                if (sum > msg.value) {
                    payable(msg.sender).transfer(msg.value);
                    revert(
                        "Value should be greater than or equal to cashback value"
                    );
                }
            } else {
                if (sum > token.allowance(msg.sender, address(this))) {
                    revert(
                        "Insufficient ERC20 allowance balance for paying for the asset."
                    );
                }
            }
            for (uint256 i = 0; i < _cashbackRecipients[tokenId].length; i++) {
                // transferring cashback to authors
                uint256 cbvalue = (_cashbackValues[tokenId][i] * value) / 10000;
                if (erc == address(0)) {
                    if (cbvalue >= _fixedValues[tokenId][i]) {
                        payable(_cashbackRecipients[tokenId][i]).transfer(
                            cbvalue
                        );
                    } else if (cbvalue < _fixedValues[tokenId][i]) {
                        payable(_cashbackRecipients[tokenId][i]).transfer(
                            (_fixedValues[tokenId][i])
                        );
                    }
                    if (msg.value > sum) {
                        payable(msg.sender).transfer(msg.value - sum);
                    }
                } else {
                    cbvalue = _cashbackCalculator(
                        cbvalue,
                        _fixedValues[tokenId][i]
                    );
                    token.transferFrom(
                        msg.sender,
                        _cashbackRecipients[tokenId][i],
                        cbvalue
                    );
                    if (msg.value > 0) {
                        payable(msg.sender).transfer(msg.value);
                    }
                }
            }
        }
        _safeTransfer(msg.sender, to, tokenId, dataBytes);
        string calldata dataString = string(dataBytes);
        _appendTokenData(tokenId, dataString);
        emit TransferWithProvenance(tokenId, to, dataString[:index], value);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata dataBytes
    ) public payable virtual override {
        uint256 index;
        uint256 value;
        uint256 sum;
        address erc;
        IERC20 token;
        (index, value, erc) = _bytesCheck(dataBytes);
        if (erc != address(0)) {
            token = IERC20(erc);
        }
        if (_cashbackRecipients[tokenId].length > 0) {
            uint256 percentSum;
            for (uint256 i = 0; i < _cashbackValues[tokenId].length; i++) {
                percentSum += _cashbackValues[tokenId][i];
            }
            sum = (percentSum * value) / 10000;
            if (erc == address(0)) {
                if (sum > msg.value) {
                    payable(from).transfer(msg.value);
                    revert(
                        "Value should be greater than or equal to cashback value"
                    );
                }
            } else {
                if (sum > token.allowance(to, address(this))) {
                    revert(
                        "Insufficient ERC20 allowance balance for paying for the asset."
                    );
                }
            }
            for (uint256 i = 0; i < _cashbackRecipients[tokenId].length; i++) {
                // transferring cashback to authors
                uint256 cbvalue = (_cashbackValues[tokenId][i] * value) / 10000;
                if (erc == address(0)) {
                    if (cbvalue >= _fixedValues[tokenId][i]) {
                        payable(_cashbackRecipients[tokenId][i]).transfer(
                            cbvalue
                        );
                    } else if (cbvalue < _fixedValues[tokenId][i]) {
                        payable(_cashbackRecipients[tokenId][i]).transfer(
                            (_fixedValues[tokenId][i])
                        );
                    }
                    if (msg.value > sum) {
                        payable(from).transfer(msg.value - sum);
                    }
                } else {
                    cbvalue = _cashbackCalculator(
                        cbvalue,
                        _fixedValues[tokenId][i]
                    );
                    token.transferFrom(
                        to,
                        _cashbackRecipients[tokenId][i],
                        cbvalue
                    );
                    if (msg.value > 0) {
                        payable(from).transfer(msg.value);
                    }
                }
            }
        }
        _safeTransfer(from, to, tokenId, dataBytes);
        string calldata dataString = string(dataBytes);
        _appendTokenData(tokenId, dataString);
        emit TransferWithProvenance(tokenId, to, dataString[:index], value);
    }

    function _cashbackCalculator(uint256 x, uint256 y)
        private
        pure
        returns (uint256)
    {
        if (x >= y) {
            return x;
        }
        return y;
    }

    function _bytesToAddress(bytes calldata tmp)
        internal
        pure
        returns (address _parsedAddress)
    {
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function _bytesCheck(bytes calldata dataBytes)
        private
        pure
        returns (
            uint256 index,
            uint256 value,
            address erc
        )
    {
        for (uint256 i = 0; i < dataBytes.length; i++) {
            if (
                dataBytes[i] == 0x27 &&
                dataBytes.length > i + 8 &&
                dataBytes[i + 1] == 0x27 &&
                dataBytes[i + 2] == 0x27 &&
                dataBytes[i + 3] == 0x23 &&
                dataBytes[i + 4] == 0x23 &&
                dataBytes[i + 5] == 0x23 &&
                dataBytes[i + 6] == 0x27 &&
                dataBytes[i + 7] == 0x27 &&
                dataBytes[i + 8] == 0x27
            ) {
                index = i;
                bytes calldata valueBytes = dataBytes[index + 9:];
                value = _stringToUint(string(valueBytes));
                if (
                    dataBytes.length > 11 &&
                    keccak256(abi.encodePacked(dataBytes[:11])) ==
                    keccak256(abi.encodePacked(string("CUSTOMTOKEN")))
                ) {
                    erc = _bytesToAddress(dataBytes[11:]);
                }
            }
        }
    }
}
