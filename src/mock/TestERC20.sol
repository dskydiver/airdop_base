// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/mocks/MockERC20.sol";

contract TestERC20 is MockERC20 {
    constructor(string memory name, string memory symbol, uint8 decimals) {
        initialize(name, symbol, decimals);
        _mint(msg.sender, 1000000 * 10 ** decimals);
    }
}
