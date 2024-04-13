// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "wormhole-solidity-sdk/interfaces/IWormholeRelayer.sol";
import "wormhole-solidity-sdk/interfaces/IWormholeReceiver.sol";

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Airdrop is IWormholeReceiver {
    event Claimed(
        address claimer,
        uint16 sourceChain,
        address nft,
        uint256 tokenId
    );

    IWormholeRelayer public immutable wormholeRelayer;

    address public source_nft1;
    address public source_nft2;

    mapping(uint256 => address) public nft1_claimed;
    mapping(uint256 => address) public nft2_claimed;

    address public token;
    uint256 public amount1;
    uint256 public amount2;

    constructor(
        address _wormholeRelayer,
        address _token,
        address _source_nft1,
        address _source_nft2,
        uint256 _amount1,
        uint256 _amount2
    ) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        source_nft1 = _source_nft1;
        source_nft2 = _source_nft2;
        token = _token;
        amount1 = _amount1;
        amount2 = _amount2;
    }

    function deposit(uint256 amount) external {
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory, // additionalVaas
        bytes32, // address that called 'sendPayloadToEvm' (HelloWormhole contract address)
        uint16 sourceChain,
        bytes32 // unique identifier of delivery
    ) public payable override {
        require(msg.sender == address(wormholeRelayer), "Only relayer allowed");

        // Parse the payload and do the corresponding actions!
        (address sender, address source_nft, uint256 tokenId) = abi.decode(
            payload,
            (address, address, uint256)
        );

        require(sender != address(0), "Sender is zero");
        require(source_nft != address(0), "Source nft is zero");

        require(
            source_nft == source_nft1 || source_nft == source_nft2,
            "Wrong source nft"
        );

        if (source_nft == source_nft1) {
            require(nft1_claimed[tokenId] == address(0), "Already claimed");
        } else {
            require(nft2_claimed[tokenId] == address(0), "Already claimed");
        }

        if (source_nft == source_nft1) {
            nft1_claimed[tokenId] = sender;
            require(IERC20(token).transfer(sender, amount1), "Transfer failed");
        } else {
            nft2_claimed[tokenId] = sender;
            require(IERC20(token).transfer(sender, amount2), "Transfer failed");
        }

        emit Claimed(sender, sourceChain, source_nft, tokenId);
    }
}
