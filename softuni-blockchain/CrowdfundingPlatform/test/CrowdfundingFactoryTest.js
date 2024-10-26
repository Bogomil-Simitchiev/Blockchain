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
    it("Should create more than 1 campaigns", async function () {
      const CrowdfundingFactory = await ethers.getContractFactory("CrowdfundingFactory");
      const crowdfundingFactory = await CrowdfundingFactory.deploy();
      await crowdfundingFactory.waitForDeployment();

      await crowdfundingFactory.createCampaign("Test Campaign", "A simple crowdfunding project", 100, 30);
      await crowdfundingFactory.createCampaign("Test Campaign2", "A simple crowdfunding project2", 100, 30);

      const campaigns = await crowdfundingFactory.getDeployedCampaigns();

      expect(campaigns.length).to.equal(2);
    });
  });
  describe('Withdrawals', () => {
    let crowdfundingFactory;
    let crowdfundingCampaign;
    let owner;
    let contributor;

    beforeEach(async function () {
      [owner, contributor] = await ethers.getSigners();

      const CrowdfundingFactory = await ethers.getContractFactory("CrowdfundingFactory");
      crowdfundingFactory = await CrowdfundingFactory.deploy();
      await crowdfundingFactory.waitForDeployment();

      await crowdfundingFactory.createCampaign(
        "Test Campaign",
        "A simple crowdfunding project",
        ethers.parseEther("100"), // Set goal to 100 ETH
        10
      );

      const campaigns = await crowdfundingFactory.getDeployedCampaigns();
      crowdfundingCampaign = await ethers.getContractAt("CrowdfundingCampaign", campaigns[0]);
    });

    it("Should allow owner to withdraw funds once the goal is reached", async function () {
      // Contribute the full amount to meet the goal
      await crowdfundingCampaign.connect(contributor).contribute({ value: ethers.parseEther("100") });

      // Move forward in time to simulate campaign end
      await ethers.provider.send("evm_increaseTime", [11 * 24 * 60 * 60]); // Move forward 11 days
      await ethers.provider.send("evm_mine");

      // Withdraw funds
      await crowdfundingCampaign.connect(owner).withdrawFunds();

      // Check if campaign balance is 0

      expect(await ethers.provider.getBalance(crowdfundingCampaign.target)).to.equal(0);
    });
    it("Should not allow non-owner to withdraw funds", async function () {

      await crowdfundingCampaign.connect(contributor).contribute({ value: ethers.parseEther("100") });

      await ethers.provider.send("evm_increaseTime", [11 * 24 * 60 * 60]); // Move forward 11 days
      await ethers.provider.send("evm_mine");

      await expect(crowdfundingCampaign.connect(contributor).withdrawFunds()).to.be.revertedWith("Sender is not the owner");

    });
  });
})