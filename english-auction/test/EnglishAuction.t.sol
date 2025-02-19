// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EnglishAuction, IERC721} from "../src/EnglishAuction.sol";

contract EnglishAuctionTest is Test {
    EnglishAuction public englishAuction;
    IERC721 public nft;

    function setUp() public {
        nft = new ERC721("Test", "TEST");
        englishAuction = new EnglishAuction();
    }

}
