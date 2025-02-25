// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFundFactory} from "../src/CrowdFundFactory.sol";
import {CrowdFund} from "../src/CrowdFund.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Timeframe} from "../src/CrowdFund.sol";
import {Vm} from "forge-std/Vm.sol";
contract TestToken is ERC20 {
    constructor() ERC20("Test", "TEST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}   

contract CrowdFundFactoryTest is Test {
    CrowdFundFactory public crowdFundFactory;
    TestToken public token;
    address public creator;
    address public pledger;

    function setUp() public {
        token = new TestToken();
        crowdFundFactory = new CrowdFundFactory();
        pledger = makeAddr("Pledger");
        creator = makeAddr("Creator");
        token.mint(pledger, 1000 ether);
        token.mint(creator, 1000 ether);
    }

    function test_newCrowdFund() public {
        // Arrange
        uint256 goal = 100 ether;
        uint256 start = block.timestamp + 100;
        uint256 end = block.timestamp + 500;
        Timeframe memory timeframe = Timeframe(start, end);

        vm.recordLogs();
        address crowdFundAddress = crowdFundFactory.newCrowdFund(
            creator,
            address(token),
            goal,
            timeframe
        );

        Vm.Log[] memory logs = vm.getRecordedLogs();
        require(logs.length > 0, "No logs recorded");

        bytes32 expectedEventSignature = keccak256("CrowdFundCreated(address,address)");
        assertEq(logs[0].topics[0], expectedEventSignature, "Event signature mismatch");

        address eventCreator = address(uint160(uint256(logs[0].topics[1])));
        address eventCrowdFund = address(uint160(uint256(logs[0].topics[2])));
        
        assertEq(eventCreator, creator, "Creator address mismatch");
        assertEq(eventCrowdFund, crowdFundAddress, "CrowdFund address mismatch");
    }

    function test_newCrowdFund_invalid_creator() public {
        vm.expectRevert("creator must be a valid address");
        crowdFundFactory.newCrowdFund(address(0), address(token), 100 ether, Timeframe(block.timestamp + 100, block.timestamp + 500));
    }

    function test_newCrowdFund_invalid_timeframe() public {
        vm.expectRevert("start must be before end");
        crowdFundFactory.newCrowdFund(creator, address(token), 100 ether, Timeframe(block.timestamp + 500, block.timestamp + 100));
    }
    
}       