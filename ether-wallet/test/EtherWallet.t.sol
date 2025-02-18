// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EtherWallet} from "../src/EtherWallet.sol";

contract EthereWalletTest is Test {
    EtherWallet private etherWallet;

    receive() external payable {}

    function setUp() public {
         etherWallet = new EtherWallet();
         vm.deal(address(this), 100 ether); 
    }

    function test_receive() public {
        payable(address(etherWallet)).transfer(10 ether);
        // also check balance method
        assertEq(etherWallet.balance(), 10 ether);
    }

    function test_withdraw() public {
        payable(address(etherWallet)).transfer(10 ether);
        
        uint256 contractBalance = etherWallet.balance();
        etherWallet.withdraw(contractBalance);
        
        assertEq(etherWallet.balance(), 0 ether, "Contract should have 0 balance");
        assertEq(address(this).balance, 100 ether, "Test contract should have its ETH back");
    }

    function test_owner() public view {
        assertEq(etherWallet.owner(), address(this), "Owner should be the test contract");
    }
}
