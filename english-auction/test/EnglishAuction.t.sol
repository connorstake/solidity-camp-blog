// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EnglishAuction, IERC721} from "../src/EnglishAuction.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Add this contract before EnglishAuctionTest
contract TestNFT is ERC721 {
    constructor() ERC721("Test", "TEST") {}

    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
    }
}

contract EnglishAuctionTest is Test {
    EnglishAuction public englishAuction;
    IERC721 public nft;
    address public bidder;


    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setUp() public {   
        vm.deal(address(this), 100 ether);
        TestNFT testNft = new TestNFT();
        nft = IERC721(address(testNft));
        nft.mint(address(this), 1);
        englishAuction = new EnglishAuction(address(nft), 1, 1 ether);
        nft.approve(address(englishAuction), 1);
        bidder = address(0x1);
        vm.deal(bidder, 100 ether);
    }

    function test_start() public {
        englishAuction.start();
        assertEq(englishAuction.started(), true);
    }   

    function test_bid() public {
        englishAuction.start();
        englishAuction.submitBid{value: 10 ether}();
        assertEq(englishAuction.highestBid(), 10 ether);
        assertEq(englishAuction.highestBidder(), address(this));
        // new bidder
        vm.startPrank(bidder);
        englishAuction.submitBid{value: 11 ether}();
        assertEq(englishAuction.highestBid(), 11 ether);
        assertEq(englishAuction.highestBidder(), bidder);
        vm.stopPrank();
    }

    function test_withdraw() public {
        englishAuction.start();
        englishAuction.submitBid{value: 10 ether}();
        assertEq(englishAuction.highestBid(), 10 ether);
        assertEq(englishAuction.highestBidder(), address(this));
        vm.startPrank(bidder);
        englishAuction.submitBid{value: 11 ether}();
        vm.stopPrank();
        assertEq(englishAuction.highestBid(), 11 ether);
        assertEq(englishAuction.highestBidder(), bidder);
        englishAuction.withdrawBid();
        assertEq(englishAuction.bidsByBidder(address(this)), 0);
    }

    function test_close() public {
        englishAuction.start();
        englishAuction.submitBid{value: 10 ether}();
        // set time to 7 days in the future
        vm.warp(block.timestamp + 8 days);
        englishAuction.closeAndDistributeTokens();
        assertEq(englishAuction.closed(), true);
        assertEq(nft.ownerOf(1), address(this));
    }

}
