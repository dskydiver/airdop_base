// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Verifier} from "../src/Verifier.sol";
import {Airdrop} from "../src/Airdrop.sol";
import {TestERC20} from "../src/mock/TestERC20.sol";
import {TestERC721} from "../src/mock/TestERC721.sol";
import "wormhole-solidity-sdk/testing/WormholeRelayerTest.sol";

contract AirdropTest is WormholeRelayerBasicTest {
    Verifier verifier;
    Airdrop airdrop;

    TestERC20 token;
    TestERC721 source_nft1;
    TestERC721 source_nft2;

    function setUpSource() public override {
        vm.deal(address(1), 10 ether);
        source_nft1 = new TestERC721("Test NFT1", "TST1");
        source_nft2 = new TestERC721("Test NFT2", "TST2");
        verifier = new Verifier(
            address(relayerSource),
            address(source_nft1),
            address(source_nft2)
        );
    }

    function setUpTarget() public override {
        token = new TestERC20("Test Token", "TST", 18);
        airdrop = new Airdrop(
            address(relayerTarget),
            address(token),
            address(source_nft1),
            address(source_nft2),
            1 ether,
            1 ether
        );
        token.approve(address(airdrop), 1000000 ether);
        airdrop.deposit(1000000 ether);
    }

    function testVerifyClaim() public {
        uint256 cost = verifier.quoteCrossChainCost(targetChain);

        vm.recordLogs();

        vm.startPrank(address(1));
        source_nft1.mint(1);
        verifier.verify{value: cost}(
            targetChain,
            address(airdrop),
            address(source_nft1),
            1
        );
        vm.stopPrank();

        performDelivery();

        vm.selectFork(targetFork);
        assertEq(TestERC20(token).balanceOf(address(1)), airdrop.amount1());
    }
}
