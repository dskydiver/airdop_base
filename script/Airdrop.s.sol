// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/Airdrop.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Airdrop airdrop = new Airdrop(
            vm.envAddress("WORMHOLE_RELAYER"),
            vm.envAddress("TOKEN"),
            vm.envAddress("NFT1"),
            vm.envAddress("NFT2"),
            vm.envUint("AMOUNT1"),
            vm.envUint("AMOUNT2")
        );

        console.log(address(airdrop));

        vm.stopBroadcast();
    }
}
