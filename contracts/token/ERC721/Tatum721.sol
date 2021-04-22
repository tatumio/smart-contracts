pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./extensions/ERC721Enumerable.sol";
import "./extensions/ERC721URIStorage.sol";
import "../../access/AccessControlEnumerable.sol";

contract Tatum721 is ERC721Enumerable, ERC721URIStorage, AccessControlEnumerable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // mapping cashback to addresses and their values
    mapping (uint256 => address[]) private _cashbacks;
    mapping (uint256 => uint256[]) private _cashbacksValue;
    
    constructor (string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted tokens.
     * @param tokenId The token id to mint.
     * @param tokenURI The token URI of the minted token.
     * @return A boolean that indicates if the operation was successful.
     */
    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public returns (bool) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        return ERC721URIStorage._burn(tokenId);
    }

    function mintMultiple(address[] memory to, uint256[] memory tokenId, string[] memory tokenURI) public returns (bool) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        for (uint i = 0; i < to.length; i++) {
            _mint(to[i], tokenId[i]);
            _setTokenURI(tokenId[i], tokenURI[i]);
        }
        return true;
    }

    function mintWithCashback(address to, uint256 tokenId, string memory tokenURI, address[] memory authorAddresses, uint256[] memory cashbackValues) public returns (bool) {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        // saving cashback addresses and values
        _cashbacks[tokenId] = authorAddresses;
        _cashbacksValue[tokenId]=cashbackValues; 
        return true; 
    }

    function _cashbackBalance(uint256 tokenId) private view returns(uint256){
        // returns the sum of cashbackValues
        uint256 sum=0;
        for (uint i=0;i<_cashbacksValue[tokenId].length;i++){
            sum+=_cashbacksValue[tokenId][i];
        }
        return sum;
    }
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    function safeTransfer(address to, uint256 tokenId) public payable{
        if(_cashbacks[tokenId].length!=0){
            // checking cashback addresses exists and sum of cashbacks
            require(_cashbacks[tokenId].length!=0, "CashbackToken should be of cashback type");
            uint256 sum=_cashbackBalance(tokenId);
            require(sum < msg.value, "Value should be greater than or equal to cashback value");
            for (uint i=0;i<_cashbacks[tokenId].length;i++){
                // transferring cashback to authors
                payable(_cashbacks[tokenId][i]).transfer(_cashbacksValue[tokenId][i]);
            }
            if(msg.value>sum){
                payable(msg.sender).transfer(msg.value-sum);
            }
            _safeTransfer(_msgSender(), to, tokenId, "");
        }else{
            if(msg.value>0){
                payable(msg.sender).transfer(msg.value);
            }
            _safeTransfer(_msgSender(), to, tokenId, "");
        }
        
    }
}
