pragma solidity ^0.8.7;

import "../token/ERC20/extensions/ERC20Capped.sol";
import "../token/ERC20/extensions/ERC20Burnable.sol";

pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
   */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
   */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
   * @return bool
   */
    function has(Role storage role, address account)
    internal
    view
    returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

abstract contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract TatumErc20CappedToken is ERC20Capped, ERC20Burnable, MinterRole {

    string public builtOn = "https://tatum.io";

    uint8 private _decimals;
    constructor(
        string memory _name,
        string memory _symbol,
        address receiver,
        uint8 __decimals,
        uint256 _cap,
        uint256 initialBalance
    )
    MinterRole()
    ERC20(_name, _symbol)
    ERC20Capped(_cap)
    {
        _decimals = __decimals;
        if (initialBalance > 0) {
            _mint(receiver, initialBalance);
        }
    }

    function mint(
        address to,
        uint256 value
    )
    public
    onlyMinter
    returns (bool)
    {
        _mint(to, value);
        return true;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        ERC20Capped._mint(account, amount);
    }
}
