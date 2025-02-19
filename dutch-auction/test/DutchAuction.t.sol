// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DutchAuction, IERC721} from "../src/DutchAuction.sol";
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
        vm.deal(address(this), 100 ether);
        TestNFT testNft = new TestNFT();
        nft = IERC721(address(testNft));
        nft.mint(address(this), 1);
        dutchAuction = new DutchAuction(100 ether, 0.0001 ether, address(nft), 1);
        buyer = address(0x1);
        vm.deal(buyer, 100 ether);
    }

    function test_buy() public {
        assertEq(nft.ownerOf(1), address(this));
        nft.approve(address(dutchAuction), 1);
        vm.prank(buyer);
        dutchAuction.buy{value: 100 ether}();
        vm.stopPrank();
        assertEq(nft.ownerOf(1), buyer);
    }

    function test_auction_expired() public {
        vm.warp(block.timestamp + 8 days);
        vm.prank(buyer);
        vm.expectRevert("auction expired");
        dutchAuction.buy{value: 100 ether}();
        vm.stopPrank();
    }
}
