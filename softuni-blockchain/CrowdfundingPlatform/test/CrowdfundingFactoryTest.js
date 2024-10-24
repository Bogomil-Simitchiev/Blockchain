const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("CrowdfundingPlatform", function () {
  describe('Creation', () => {
    it("Should allow users to create a campaign", async function () {
      const CrowdfundingFactory = await ethers.getContractFactory("CrowdfundingFactory");
      const crowdfundingFactory = await CrowdfundingFactory.deploy();
      await crowdfundingFactory.waitForDeployment();

      await crowdfundingFactory.createCampaign("Test Campaign", "A simple crowdfunding project", 100, 30);
      const campaigns = await crowdfundingFactory.getDeployedCampaigns();

      expect(campaigns.length).to.equal(1);
    });
  });
})