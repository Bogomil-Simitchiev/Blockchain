// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { CrowdfundingCampaign } from './CrowdfundingCampaign.sol';

contract CrowdfundingFactory {
    event CampaignCreated(address campaignAddress, string campaigName, uint256 campaignGoal);
    mapping(address => CrowdfundingCampaign) public campaigns;
    address[] public deployedCampaigns;
    uint256 campaignId = 0;
    function createCampaign(string memory _name, string memory _description, uint _goal, uint _duration) public {
        campaignId+=1;
        CrowdfundingCampaign newCampaign = new CrowdfundingCampaign(campaignId, _name, _description, _goal, _duration, msg.sender);
        campaigns[msg.sender] = newCampaign;
        deployedCampaigns.push(address(newCampaign));
        emit CampaignCreated(address(newCampaign), _name, _goal);
    }
     function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }

}