// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CrowdFund {
    struct Timeframe {
        uint256 start;
        uint256 end;
    }

    IERC20 private immutable _token;
    address private immutable _creator;
    uint256 private immutable _goal;
    uint256 private _pledged;
    Timeframe private _timeframe;
    bool private _claimed;
    mapping(address => uint256) private _pledgedAmount;

    constructor(address c_token, uint256 c_goal, uint256 c_duration, Timeframe c_timeframe) {
        if (c_timeframe.start > c_timeframe.end) {
            revert("start must be before end");
        }
        if (c_timeframe.start <= block.timestamp) {
            revert("start must be in the future");
        }
        if (c_goal <= 0) {
            revert("goal must be greater than 0");
        }
        if (c_token == address(0)) {
            revert("token must be a valid address");
        }
        token = IERC20(c_token);
        goal = c_goal;
        timeframe = c_timeframe;
        creator = msg.sender;
    }
}