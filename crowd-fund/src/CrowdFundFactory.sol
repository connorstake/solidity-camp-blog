import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CrowdFund} from "./CrowdFund.sol";
import {Timeframe} from "./CrowdFund.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CrowdFundFactory {
    event CrowdFundCreated(address indexed creator, address indexed crowdFund);

    function newCrowdFund(address _creator, address _token, uint256 _goal, Timeframe memory _timeframe) public returns (address) {
        CrowdFund crowdFund = new CrowdFund(_creator, _token, _goal, _timeframe);
        emit CrowdFundCreated(_creator, address(crowdFund));
        return address(crowdFund);
    }
}