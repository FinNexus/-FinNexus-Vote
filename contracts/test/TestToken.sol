// SPDX-License-Identifier: MIT
pragma solidity 0.5.10;

import "./ERC20.sol";

contract TestToken is ERC20 {
    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
