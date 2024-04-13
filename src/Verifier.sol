// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Verifier {
    event Verified(address owner, address nft, uint256 id, uint16 targetChain);

    uint256 constant GAS_LIMIT = 200_000;

    IWormholeRelayer public immutable wormholeRelayer;

    address public nft1;
    address public nft2;

    constructor(address _wormholeRelayer, address _nft1, address _nft2) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        nft1 = _nft1;
        nft2 = _nft2;
    }

    function quoteCrossChainCost(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );
    }

    function verify(
        uint16 targetChain,
        address targetAddress,
        address nft,
        uint256 tokenId
    ) public payable {
        require(nft == nft1 || nft == nft2, "Not a valid NFT");
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Not the owner");

        uint256 cost = quoteCrossChainCost(targetChain);
        require(
            msg.value == cost,
            "msg.value must be quoteCrossChainCost(targetChain)"
        );

        wormholeRelayer.sendPayloadToEvm{value: cost}(
            targetChain,
            targetAddress,
            abi.encode(msg.sender, nft, tokenId),
            0,
            GAS_LIMIT
        );
        emit Verified(msg.sender, nft, tokenId, targetChain);
    }
}
