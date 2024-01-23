// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private s_number;

    constructor() Ownable(msg.sender) {}

    event NumberChanged(uint256 number);

    function store(uint256 newNumber) public onlyOwner {
        s_number = newNumber;
        emit NumberChanged(newNumber);
    }

    function getNumner() external view returns (uint256) {
        return s_number;
    }
}
