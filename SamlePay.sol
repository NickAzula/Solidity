// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract SampleContract {
    // address -> 20 byte -> 160 bit
    // state
    address public owner;
    mapping (address => uint256) public payments;

    constructor() {
        // code
        owner = msg.sender;
    }

    function payForItem() public payable {
        payments[msg.sender] = msg.value;
    }

    function withdrawAll() public {
        //temp
        address payable _to = payable(owner);
        address _thisContract = address(this);

        _to.transfer(_thisContract.balance);
    }
}