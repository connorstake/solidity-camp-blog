// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EnglishAuction} from "../src/EnglishAuction.sol";

contract EnglishAuctionScript is Script {
    EnglishAuction public englishAuction;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        englishAuction = new EnglishAuction();

        vm.stopBroadcast();
    }
}
