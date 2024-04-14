// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/Verifier.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Verifier verifier = new Verifier(
            vm.envAddress("WORMHOLE_RELAYER"),
            vm.envAddress("NFT1"),
            vm.envAddress("NFT2")
        );

        console.log(address(verifier));

        vm.stopBroadcast();
    }
}
