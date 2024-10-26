// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract CrowdfundingCampaign is ERC20, Ownable {
    event ContributionReceived(address contributor, uint amount);
    event FundsWithdrawn(uint amount);
    event RefundIssued(address contributor, uint amount);
    
    uint256 campaignId;
    address public campaignCreator;
    string public campaignDescription;
    uint256 public campaignGoal;
    uint256 public campaignEnd;
    bool public goalReached = false;
    uint256 public totalContributed = 0;

    mapping(address => uint) public contributions;

     constructor(uint256 _id, string memory _name, string memory _description, uint256 _goal, uint256 _duration, address _creator) 
        ERC20(_name, "CFT") Ownable(_creator) {
        campaignId = _id;
        campaignCreator = _creator;
        campaignDescription = _description;
        campaignGoal = _goal;
        campaignEnd = block.timestamp + _duration;
    }

    function contribute() public payable {
        require(block.timestamp < campaignEnd, "Campaign has ended");
        require(totalContributed + msg.value <= campaignGoal, "Contribution exceeds goal");

        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;

        _mint(msg.sender, msg.value);

        emit ContributionReceived(msg.sender, msg.value);
    }
    function claimRefund() public {
        require(block.timestamp >= campaignEnd, "Campaign is still active");
        require(totalContributed < campaignGoal, "Goal was reached, no refunds");

        uint contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "No contribution to refund");

        contributions[msg.sender] = 0;

        payable(msg.sender).transfer(contributedAmount);

        emit RefundIssued(msg.sender, contributedAmount);
    }
    function withdrawFunds() public {
        require(block.timestamp >= campaignEnd, "Campaign is still active");
        require(totalContributed >= campaignGoal, "Goal not reached");
        require(msg.sender == campaignCreator, "Sender is not the owner");


        goalReached = true;

        payable(owner()).transfer(address(this).balance);

        emit FundsWithdrawn(totalContributed);
    }
    function distributeReward(uint rewardAmount) public onlyOwner {
        require(goalReached, "Goal must be reached to distribute rewards");

        uint totalSupply = totalSupply();
        for (uint i = 0; i < totalSupply; i++) {
            address contributor = address(uint160(i)); // Get address of contributor
            uint reward = (balanceOf(contributor) * rewardAmount) / totalSupply;
            payable(contributor).transfer(reward);
        }
    }

}