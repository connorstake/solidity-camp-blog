// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DutchAuction} from "../src/DutchAuction.sol";
import {EnglishAuction, IERC721} from "../src/EnglishAuction.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestNFT is ERC721 {
    constructor() ERC721("Test", "TEST") {}
    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
    }
}

contract DutchAuctionTest is Test {
    DutchAuction public dutchAuction;
    IERC721 public nft;
    address public buyer;


    receive() external payable {}

    function setUp() public {
        dutchAuction = new DutchAuction();
        vm.deal(address(this), 100 ether);
        TestNFT testNft = new TestNFT();
        nft = IERC721(address(testNft));
        nft.mint(address(this), 1);
        dutchAuction = new DutchAuction(address(nft), 1, 1 ether);
        buyer = address(0x1);
        vm.deal(buyer, 100 ether);
    }

    function test_buy() public {
        vm.prank(buyer);
        dutchAuction.buy{value: 1 ether}();
        assertEq(nft.ownerOf(1), buyer);
        vm.stopPrank();
    }
}
