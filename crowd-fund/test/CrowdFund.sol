// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFund} from "../src/CrowdFund.sol";

contract CrowdFundTest is Test {
    CrowdFund public crowdFund;

    function setUp() public {
        crowdFund = new CrowdFund();
    }
}
