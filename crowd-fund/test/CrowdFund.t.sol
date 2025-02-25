// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFund} from "../src/CrowdFund.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Timeframe} from "../src/TimeFrame.sol";

contract TestToken is ERC20 {
    constructor() ERC20("Test", "TEST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}


contract CrowdFundTest is Test {
    CrowdFund public crowdFund;
    IERC20 public token;
    address public pledger;
    function setUp() public {
        token = new TestToken();

        crowdFund = new CrowdFund(address(this), address(token), 100 ether, Timeframe(block.timestamp + 100, block.timestamp + 500));
        pledger = makeAddr("Pledger");
        TestToken(address(token)).mint(pledger, 100 ether);
        TestToken(address(token)).mint(address(this), 100 ether);
    }

    function test_cancel() public {
        crowdFund.cancel();    
        assertEq(crowdFund.cancelled(), true);
    }

    function test_cancel_after_start() public {
        vm.warp(block.timestamp + 100);
        vm.expectRevert("campaign has started");
        crowdFund.cancel();
    }

    function test_pledge() public {
        vm.warp(block.timestamp + 100);
        vm.prank(pledger);
        token.approve(address(crowdFund), 100 ether);
        vm.prank(pledger);
        crowdFund.pledge(10 ether);
        assertEq(crowdFund.pledged(), 10 ether);
    }

    function test_pledge_before_start() public {
        vm.prank(pledger);
        token.approve(address(crowdFund), 100 ether);
        vm.prank(pledger);
        vm.expectRevert("campaign has not started");
        crowdFund.pledge(10 ether);
    }

    function test_pledge_after_end() public {
        vm.warp(block.timestamp + 900);
        vm.prank(pledger);
        token.approve(address(crowdFund), 100 ether);
        vm.prank(pledger);
        vm.expectRevert("campaign has ended");
        crowdFund.pledge(10 ether);
    }

    function test_removePledge() public {
        vm.warp(block.timestamp + 100);
        vm.prank(pledger);
        token.approve(address(crowdFund), 100 ether);
        vm.prank(pledger);
        crowdFund.pledge(10 ether);
        assertEq(crowdFund.pledged(), 10 ether);
        vm.prank(pledger);
        crowdFund.removePledge(10 ether);
        assertEq(crowdFund.pledged(), 0);
    }

    function test_removePledge_after_successful_end() public {
        vm.warp(block.timestamp + 100);
        vm.prank(pledger);
        token.approve(address(crowdFund), 100 ether);
        vm.prank(pledger);
        crowdFund.pledge(100 ether);
        vm.warp(block.timestamp + 900);
        vm.prank(pledger);
        vm.expectRevert("campaign has ended");
        crowdFund.removePledge(10 ether);
    }

    function test_removePledge_when_no_pledged() public {
        vm.warp(block.timestamp + 100);
        token.approve(address(crowdFund), 10 ether);
        crowdFund.pledge(10 ether);
        vm.prank(pledger);
        vm.expectRevert(); // arithmetic underflow
        crowdFund.removePledge(10 ether);
        vm.stopPrank();
    }

    function test_claim() public {
        vm.warp(block.timestamp + 100);
        vm.prank(pledger);
        token.approve(address(crowdFund), 100 ether);
        vm.prank(pledger);
        crowdFund.pledge(100 ether);
        vm.warp(block.timestamp + 900);
        vm.stopPrank();
        crowdFund.claim();
        assertEq(token.balanceOf(address(crowdFund)), 0);
        assertEq(token.balanceOf(address(this)), 200 ether); // 100 ether from pledge and 100 ether from mint
    }

    function test_refund() public {
        vm.warp(block.timestamp + 100);
        vm.prank(pledger);
        token.approve(address(crowdFund), 99 ether);
        vm.prank(pledger);
        crowdFund.pledge(99 ether);
        assertEq(token.balanceOf(address(pledger)), 1 ether);
        vm.warp(block.timestamp + 900);
        vm.prank(pledger);
        crowdFund.refund();
        assertEq(token.balanceOf(address(pledger)), 100 ether);
    }
}

