// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/mocks/MockERC721.sol";

contract TestERC721 is MockERC721 {
    constructor(string memory name, string memory symbol) {
        initialize(name, symbol);
    }

    function mint(uint256 tokenId) public {
        _mint(msg.sender, tokenId);
    }
}
