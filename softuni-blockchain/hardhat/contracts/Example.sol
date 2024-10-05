// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

contract Example {
    struct Person {
        string name;
        uint256 age;
    }

    Person public person = Person("Tester", 16);
    function setDifferentName() public {
        person.name = "John";
    }

}