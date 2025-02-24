import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Timeframe} from "./TimeFrame.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CrowdFund {

    IERC20 private immutable _token;
    address private immutable _creator;
    uint256 private immutable _goal;
    uint256 private _pledged;
    Timeframe private _timeframe;
    bool private _claimed;
    bool private _cancelled;
    mapping(address => uint256) private _pledgedAmount;

    constructor(address c_token, uint256 c_goal, Timeframe memory c_timeframe) {
        if (c_timeframe.start > c_timeframe.end) {
            revert("start must be before end");
        }
        if (c_timeframe.start <= block.timestamp) {
            revert("start must be in the future");
        }
        if (c_timeframe.end > block.timestamp + 90 days) {
            revert("end must be within 90 days");
        }
        if (c_goal <= 0) {
            revert("goal must be greater than 0");
        }
        if (c_token == address(0)) {
            revert("token must be a valid address");
        }
        _token = IERC20(c_token);
        _goal = c_goal;
        _timeframe = c_timeframe;
        _creator = msg.sender;
    }

    function cancel() external _onlyCreator _notCancelled _notStarted {
        _cancelled = true;
    }

    function pledge(uint256 _amount) external _notCancelled _started _notEnded {
        _token.transferFrom(msg.sender, address(this), _amount);
        _pledgedAmount[msg.sender] += _amount;
        _pledged += _amount;
    }
    
    function removePledge(uint256 _amount) external _notCancelled _started _notEnded {
        _pledgedAmount[msg.sender] -= _amount;
        _pledged -= _amount;
        _token.transfer(msg.sender, _amount);
    }

    function claim() external 
    _onlyCreator 
    _notCancelled 
    _started  
    _goalReached 
    _notClaimed {
        _claimed = true;
        _token.transfer(_creator, _pledged); 
    }

    function refund() external _notCancelled _notClaimed _started _ended {
        uint256 pledged = _pledgedAmount[msg.sender];
        _token.transfer(msg.sender, pledged);
        _pledgedAmount[msg.sender] = 0;
    }

    function cancelled() public view returns (bool) {
        return _cancelled;
    }
    
    function pledged() public view returns (uint256) {
        return _pledged;
    }

    modifier _onlyCreator() {
        if (msg.sender != _creator) {
            revert("only the creator can call this function");
        }
        _;
    }

    modifier _notCancelled() {
        if (_cancelled) {
            revert("campaign has been cancelled");
        }
        _;
    }

    modifier _started() {
        if (block.timestamp < _timeframe.start) {
            revert("campaign has not started");
        }
        _;
    }

    modifier _notStarted() {
        if (block.timestamp >= _timeframe.start) {
            revert("campaign has started");
        }
        _;
    }

    modifier _notEnded() {
        if (block.timestamp >= _timeframe.end) {
            revert("campaign has ended");
        }
        _;
    }

    modifier _ended() {
        if (block.timestamp < _timeframe.end) {
            revert("campaign has not ended");
        }
        _;
    }

    modifier _goalReached() {
        if (_pledged < _goal) {
            revert("goal has not been reached");
        }
        _;
    }

    modifier _goalNotReached() {
        if (_pledged >= _goal) {
            revert("goal has been reached");
        }
        _;
    }

    modifier _notClaimed() {
        if (_claimed) {
            revert("campaign has been claimed");
        }
        _;
    }    
}