pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;
}

// SPDX-License-Identifier: MIT
/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
contract Tatum {
    function tokenCashbackValues(uint256 tokenId, uint256 tokenPrice)
    public
    view
    virtual
    returns (uint256[] memory)
    {}

    function getCashbackAddress(uint256 tokenId)
    public
    view
    virtual
    returns (address)
    {}
}

contract NftAuction is Ownable, Pausable {
    using Address for address;

    struct Auction {
        // address of the seller
        address seller;
        // address of the token to sale
        address nftAddress;
        // ID of the NFT
        uint256 tokenId;
        // if the auction is for ERC721 - true - or ERC1155 - false
        bool isErc721;
        // Block height of end of auction
        uint256 endedAt;
        // Block height, in which the auction started.
        uint256 startedAt;
        // optional - if the auction is settled in the ERC20 token or in native currency
        address erc20Address;
        // for ERC-1155 - how many tokens are for sale
        uint256 amount;
        // Ending price of the asset at the end of the auction
        uint256 endingPrice;
        // Actual highest bidder
        address bidder;
        // Actual highest bid fee included
        uint256 highestBid;
    }

    // List of all auctions id => auction.
    mapping(string => Auction) private _auctions;

    uint256 private _auctionCount = 0;

    string[] private _openAuctions;

    // in percents, what's the fee for the auction house, 1% - 100, 100% - 10000, range 1-10000 means 0.01% - 100%
    uint256 private _auctionFee;
    // recipient of the auction fee
    address private _auctionFeeRecipient;

    /**
     * @dev Emitted when new auction is created by the owner of the contract. Amount is valid only for ERC-1155 tokens
     */
    event AuctionCreated(
        bool indexed isErc721,
        address indexed nftAddress,
        uint256 indexed tokenId,
        string id,
        uint256 amount,
        address erc20Address,
        uint256 endedAt
    );

    /**
     * @dev Emitted when auction assets were bid.
     */
    event AuctionBid(address indexed buyer, uint256 indexed amount, string id);

    /**
     * @dev Emitted when auction is settled.
     */
    event AuctionSettled(string id);

    /**
     * @dev Emitted when auction was cancelled and assets were returned to the seller.
     */
    event AuctionCancelled(string id);

    receive() external payable {}

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    constructor(uint256 fee, address feeRecipient) {
        _auctionFee = fee;
        _auctionFeeRecipient = feeRecipient;
    }

    function getAuctionFee() public view virtual returns (uint256) {
        return _auctionFee;
    }

    function getOpenAuctions()
    public
    view
    virtual
    returns (string[] memory)
    {
        return _openAuctions;
    }

    function getAuctionFeeRecipient() public view virtual returns (address) {
        return _auctionFeeRecipient;
    }

    function getAuction(string memory id)
    public
    view
    virtual
    returns (Auction memory)
    {
        return _auctions[id];
    }

    function setAuctionFee(uint256 fee) public virtual onlyOwner {
        require(
            _auctionCount == 0,
            "Fee can't be changed if there is ongoing auction."
        );
        _auctionFee = fee;
    }

    function setAuctionFeeRecipient(address recipient)
    public
    virtual
    onlyOwner
    {
        _auctionFeeRecipient = recipient;
    }

    /**
     * Check if the seller is the owner of the token.
     * We expect that the owner of the tokens approves the spending before he launch the auction
     * The function escrows the tokens to sell
     **/
    function _escrowTokensToSell(
        bool isErc721,
        address nftAddress,
        address seller,
        uint256 tokenId,
        uint256 amount
    ) internal {
        if (!isErc721) {
            require(amount > 0);
            require(
                IERC1155(nftAddress).balanceOf(seller, tokenId) >= amount,
                "ERC1155 token balance is not sufficient for the seller.."
            );
            //    IERC1155(nftAddress).safeTransferFrom(seller,address(this),tokenId,amount,"");
        } else {
            require(
                IERC721(nftAddress).ownerOf(tokenId) == seller,
                "ERC721 token does not belong to the author."
            );
            //    IERC721(nftAddress).safeTransferFrom(seller, address(this), tokenId);
        }
    }

    /**
     * Transfer NFT from the contract to the recipient
     */
    function _transferNFT(
        bool isErc721,
        address nftAddress,
        address sender,
        address recipient,
        uint256 tokenId,
        uint256 amount,
        address erc20Address
    ) internal {
        if (!isErc721) {
            IERC1155(nftAddress).safeTransferFrom(
                sender,
                recipient,
                tokenId,
                amount,
                ""
            );
        } else {
            uint256 cashbackSum = 0;
            if (_isTatumNFT(nftAddress, tokenId)) {
                if (Tatum(nftAddress).getCashbackAddress(tokenId) == address(0)) {
                    uint256[] memory cashback = Tatum(nftAddress)
                    .tokenCashbackValues(tokenId, amount);
                    for (uint256 j = 0; j < cashback.length; j++) {
                        cashbackSum += cashback[j];
                    }
                }
            }
            if (erc20Address == address(0)) {
                IERC721(nftAddress).safeTransferFrom{value : cashbackSum}(
                    sender,
                    recipient,
                    tokenId,
                    abi.encodePacked(
                        "SAFETRANSFERFROM",
                        "'''###'''",
                        _uint2str(amount)
                    )
                );
            } else {
                bytes memory bytesInput = abi.encodePacked(
                    "CUSTOMTOKEN0x",
                    _toAsciiString(erc20Address),
                    "'''###'''",
                    _uint2str(amount)
                );
                IERC721(nftAddress).safeTransferFrom{value : cashbackSum}(
                    sender,
                    recipient,
                    tokenId,
                    bytesInput
                );
            }
        }
    }

    function _toAsciiString(address x) internal pure returns (bytes memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = _char(hi);
            s[2 * i + 1] = _char(lo);
        }
        return s;
    }

    function _char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    /**
     * Transfer assets locked in the highest bid to the recipient
     * @param erc20Address - if we are working with ERC20 token or native asset
     * @param amount - bid value to be distributed
     * @param recipient - where we will send the bid
     * @param settleOrReturnFee - when true, fee is send to the auction recipient, otherwise returned to the owner
     */
    function _transferAssets(
        address erc20Address,
        uint256 amount,
        address recipient,
        bool settleOrReturnFee
    ) internal {
        uint256 fee = (amount * _auctionFee) / 10000;
        if (erc20Address != address(0)) {
            if (settleOrReturnFee) {
                IERC20(erc20Address).transfer(recipient, amount - fee);
                IERC20(erc20Address).transfer(_auctionFeeRecipient, fee);
            } else {
                IERC20(erc20Address).transfer(recipient, amount);
            }
        } else {
            if (settleOrReturnFee) {
                Address.sendValue(payable(recipient), amount - fee);
                Address.sendValue(payable(_auctionFeeRecipient), fee);
            } else {
                Address.sendValue(payable(recipient), amount);
            }
        }
    }

    /**
     * @dev Create new auction of the NFT token in the marketplace.
     * @param id - ID of the auction, must be unique
     * @param isErc721 - whether the auction is for ERC721 or ERC1155 token
     * @param nftAddress - address of the NFT token
     * @param tokenId - ID of the NFT token
     * @param amount - ERC1155 only, number of tokens to sold.
     * @param erc20Address - address of the ERC20 token, which will be used for the payment. If native asset is used, this should be 0x0 address
     */
    function createAuction(
        string memory id,
        bool isErc721,
        address nftAddress,
        uint256 tokenId,
        address seller,
        uint256 amount,
        uint256 endedAt,
        address erc20Address
    ) public whenNotPaused {
        require(
            _auctions[id].startedAt == 0,
            "Auction already existed for current auction Id"
        );
        require(
            endedAt > block.number + 5,
            "Auction must last at least 5 blocks from this block"
        );
        // check if the seller owns the tokens he wants to put on auction
        // transfer the tokens to the auction house
        _escrowTokensToSell(isErc721, nftAddress, seller, tokenId, amount);

        _auctionCount++;
        Auction memory auction = Auction(
            seller,
            nftAddress,
            tokenId,
            isErc721,
            endedAt,
            block.number,
            erc20Address,
            amount,
            0,
            address(0),
            0
        );
        _auctions[id] = auction;
        _openAuctions.push(id);
        emit AuctionCreated(
            isErc721,
            nftAddress,
            tokenId,
            id,
            amount,
            erc20Address,
            endedAt
        );
    }

    /**
     * @dev Buyer wants to buy NFT from auction. All the required checks must pass.
     * Buyer must approve spending of ERC20 tokens, which will be deducted from his account to the auction contract.
     * Contract must detect, if the bidder bid higher value thank the actual highest bid. If it's not enough, bid is not valid.
     * If bid is the highest one, previous bidders assets will be released back to him - we are aware of reentrancy attacks, but we will cover that.
     * Bid must be processed only during the validity of the auction, otherwise it's not accepted.
     * @param id - id of the auction to buy
     * @param bidValue - bid value + the auction fee
     * @param bidder - bidder of the auction, from which account the ERC20 assets will be debited
     */
    function bidForExternalBidder(
        string memory id,
        uint256 bidValue,
        address bidder
    ) public whenNotPaused {
        Auction memory auction = _auctions[id];
        require(
            auction.erc20Address != address(0),
            "Auction must be placed for ERC20 token."
        );
        require(
            auction.endedAt > block.number,
            "Auction has already ended. Unable to process bid. Aborting."
        );
        uint256 bidWithoutFee = (bidValue / (10000 + _auctionFee)) * 10000;
        require(
            auction.endingPrice < bidWithoutFee,
            "Bid fee of the auction fee is lower than actual highest bid price. Aborting."
        );
        require(
            IERC20(auction.erc20Address).allowance(bidder, address(this)) >=
            bidValue,
            "Insufficient approval for ERC20 token for the auction bid. Aborting."
        );

        Auction memory newAuction = Auction(
            auction.seller,
            auction.nftAddress,
            auction.tokenId,
            auction.isErc721,
            auction.endedAt,
            block.number,
            auction.erc20Address,
            auction.amount,
            auction.endingPrice,
            auction.bidder,
            auction.highestBid
        );
        // reentrancy attack - we delete the auction temporarily
        delete _auctions[id];

        IERC20 token = IERC20(newAuction.erc20Address);
        if (!token.transferFrom(bidder, address(this), bidValue)) {
            revert(
            "Unable to transfer ERC20 tokens from the bidder to the Auction. Aborting"
            );
        }

        // returns the previous bid to the bidder
        if (newAuction.bidder != address(0) && newAuction.highestBid != 0) {
            _transferAssets(
                newAuction.erc20Address,
                newAuction.highestBid,
                newAuction.bidder,
                false
            );
        }

        // paid amount is on the Auction SC, we just need to update the auction status
        newAuction.endingPrice = bidWithoutFee;
        newAuction.highestBid = bidValue;
        newAuction.bidder = bidder;

        _auctions[id] = newAuction;
        emit AuctionBid(bidder, bidValue, id);
    }

    /**
     * @dev Buyer wants to buy NFT from auction. All the required checks must pass.
     * Buyer must either send ETH with this endpoint, or ERC20 tokens will be deducted from his account to the auction contract.
     * Contract must detect, if the bidder bid higher value thank the actual highest bid. If it's not enough, bid is not valid.
     * If bid is the highest one, previous bidders assets will be released back to him - we are aware of reentrancy attacks, but we will cover that.
     * Bid must be processed only during the validity of the auction, otherwise it's not accepted.
     * @param id - id of the auction to buy
     * @param bidValue - bid value + the auction fee
     */
    function bid(string memory id, uint256 bidValue)
    public
    payable
    whenNotPaused
    {
        Auction memory auction = _auctions[id];
        uint256 bidWithoutFee = (bidValue / (10000 + _auctionFee)) * 10000;
        require(
            auction.endedAt > block.number,
            "Auction has already ended. Unable to process bid. Aborting."
        );
        require(
            auction.endingPrice < bidWithoutFee,
            "Bid fee of the auction fee is lower than actual highest bid price. Aborting."
        );
        if (auction.erc20Address == address(0)) {
            require(
                bidValue <= msg.value,
                "Wrong amount entered for the bid. Aborting."
            );
        }
        if (auction.erc20Address != address(0)) {
            require(
                IERC20(auction.erc20Address).allowance(
                    msg.sender,
                    address(this)
                ) >= bidValue,
                "Insufficient approval for ERC20 token for the auction bid. Aborting."
            );
        }

        Auction memory newAuction = Auction(
            auction.seller,
            auction.nftAddress,
            auction.tokenId,
            auction.isErc721,
            auction.endedAt,
            block.number,
            auction.erc20Address,
            auction.amount,
            auction.endingPrice,
            auction.bidder,
            auction.highestBid
        );
        // reentrancy attack - we delete the auction temporarily
        delete _auctions[id];

        uint256 cashbackSum = 0;
        if (newAuction.isErc721) {
            if (_isTatumNFT(newAuction.nftAddress, newAuction.tokenId)) {
                if (
                    Tatum(newAuction.nftAddress).getCashbackAddress(
                        newAuction.tokenId
                    ) == address(0)
                ) {
                    uint256[] memory cashback = Tatum(newAuction.nftAddress)
                    .tokenCashbackValues(newAuction.tokenId, bidValue);
                    for (uint256 j = 0; j < cashback.length; j++) {
                        cashbackSum += cashback[j];
                    }
                    if (newAuction.erc20Address == address(0)) {
                        require(msg.value >= cashbackSum + bidValue, "Balance Insufficient to pay royalties");
                    } else {
                        require(msg.value >= cashbackSum, "Balance Insufficient to pay royalties");
                    }
                    Address.sendValue(payable(address(this)), cashbackSum);
                }
            }
        }
        if (newAuction.erc20Address != address(0)) {
            IERC20 token = IERC20(newAuction.erc20Address);
            if (!token.transferFrom(msg.sender, address(this), bidValue)) {
                revert(
                "Unable to transfer ERC20 tokens to the Auction. Aborting"
                );
            }
        } else {
            Address.sendValue(payable(address(this)), bidValue);
        }
        // returns the previous bid to the bidder
        if (newAuction.bidder != address(0) && newAuction.highestBid != 0) {
            _transferAssets(
                newAuction.erc20Address,
                newAuction.highestBid,
                newAuction.bidder,
                false
            );
        }
        if (msg.value > bidValue + cashbackSum) {
            Address.sendValue(
                payable(msg.sender),
                msg.value - cashbackSum - bidValue
            );
        }
        // paid amount is on the Auction SC, we just need to update the auction status
        newAuction.endingPrice = bidWithoutFee;
        newAuction.highestBid = bidValue;
        newAuction.bidder = msg.sender;

        _auctions[id] = newAuction;
        emit AuctionBid(msg.sender, bidValue, id);
    }

    /**
     * Settle the already ended auction -
     */
    function settleAuction(string memory id) public payable virtual {
        // fee must be sent to the fee recipient
        // NFT token to the bidder
        // payout to the seller
        Auction memory auction = _auctions[id];
        require(
            auction.endedAt < block.number,
            "Auction can't be settled before it reaches the end."
        );

        bool isErc721 = auction.isErc721;
        address nftAddress = auction.nftAddress;
        uint256 amount = auction.amount;
        uint256 tokenId = auction.tokenId;
        address erc20Address = auction.erc20Address;
        uint256 highestBid = auction.highestBid;
        address bidder = auction.bidder;

        // avoid reentrancy attacks
        delete _auctions[id];

        _transferNFT(
            isErc721,
            nftAddress,
            auction.seller,
            bidder,
            tokenId,
            amount,
            auction.erc20Address
        );
        _transferAssets(erc20Address, highestBid, auction.seller, true);
        _toRemove(id);
        _auctionCount--;
        emit AuctionSettled(id);
    }

    function _toRemove(string memory id) internal {
        for (uint x = 0; x < _openAuctions.length; x++) {
            if (
                keccak256(abi.encodePacked(_openAuctions[x])) ==
                keccak256(abi.encodePacked(id))
            ) {
                for (uint i = x; i < _openAuctions.length - 1; i++) {
                    _openAuctions[i] = _openAuctions[i + 1];
                }
                _openAuctions.pop();
            }
        }
    }
    /**
     * @dev Cancel auction - returns the NFT asset to the seller.
     * @param id - id of the auction to cancel
     */
    function cancelAuction(string memory id) public payable virtual {
        Auction memory auction = _auctions[id];
        require(
            auction.seller != address(0),
            "Auction is already settled. Aborting."
        );
        require(
            auction.seller == msg.sender || msg.sender == owner(),
            "Auction can't be cancelled from other thank seller or owner. Aborting."
        );
        // bool isErc721 = auction.isErc721;
        // address nftAddress = auction.nftAddress;
        // uint256 amount = auction.amount;
        // uint256 tokenId = auction.tokenId;
        address erc20Address = auction.erc20Address;
        uint256 highestBid = auction.highestBid;
        address bidder = auction.bidder;

        // prevent reentrancy attack
        delete _auctions[id];

        // we have assured that the reentrancy attack wont happen because we have deleted the auction from the list of auctions before we are sending the assets back
        // returns the NFT to the seller

        // returns the highest bid to the bidder
        if (bidder != address(0) && highestBid != 0) {
            _transferAssets(erc20Address, highestBid, bidder, false);
        }
        uint256 cashbackSum = 0;
        if (_isTatumNFT(auction.nftAddress, auction.tokenId)) {
            if (
                Tatum(auction.nftAddress).getCashbackAddress(auction.tokenId) ==
                address(0)
            ) {
                uint256[] memory cashback = Tatum(auction.nftAddress)
                .tokenCashbackValues(auction.tokenId, highestBid);
                for (uint256 j = 0; j < cashback.length; j++) {
                    cashbackSum += cashback[j];
                }
            }
        }
        if (cashbackSum > 0 && bidder != address(0)) {
            Address.sendValue(payable(bidder), cashbackSum);
        }
        _auctionCount--;
        _toRemove(id);
        emit AuctionCancelled(id);
    }

    function _uint2str(uint256 _i)
    internal
    pure
    returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _isTatumNFT(address addr, uint256 p1) internal returns (bool){
        bool success;
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256("getCashbackAddress(uint256)")), p1);

        assembly {
            success := call(
            gas(), // gas remaining
            addr, // destination address
            0, // no ether
            add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
            mload(data), // input length (loaded from the first 32 bytes in the `data` array)
            0, // output buffer
            0               // output length
            )
        }

        return success;
    }
}
