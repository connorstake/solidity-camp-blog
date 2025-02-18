// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
contract EtherWallet {
    address payable private _owner;

    constructor() {
        _owner = payable(msg.sender);
    }

    receive() external payable {}
    
    function withdraw(uint256 _amount) external {
        require(msg.sender == _owner, "caller is not owner");
        _owner.transfer(_amount);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function owner() external view returns (address) {
        return _owner;
    }
}
