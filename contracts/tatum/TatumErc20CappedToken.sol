pragma solidity ^0.8.7;

import "../token/ERC20/extensions/ERC20Capped.sol";
import "../token/ERC20/extensions/ERC20Burnable.sol";

pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

contract TatumErc20CappedToken is ERC20Capped, ERC20Burnable {

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
    ERC20(_name, _symbol)
    ERC20Capped(_cap)
    {
        _decimals = __decimals;
        if (initialBalance > 0) {
            _mint(receiver, initialBalance);
        }
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        ERC20Capped._mint(account, amount);
    }
}
