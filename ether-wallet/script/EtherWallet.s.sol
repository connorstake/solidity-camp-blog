// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EtherWallet} from "../src/EtherWallet.sol";

contract EtherWalletScript is Script {
    EtherWallet public etherWallet;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        etherWallet = new EtherWallet();

        vm.stopBroadcast();
    }
}
