const hre = require("hardhat");

async function main() {
    // Get the accounts from Hardhat
    const [owner, contributor] = await hre.ethers.getSigners();

    // Replace with your deployed factory address
    const factoryAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Update with the actual address

    // Get the CrowdfundingFactory contract instance
    const CrowdfundingFactory = await hre.ethers.getContractFactory("CrowdfundingFactory");
    const crowdfundingFactory = await CrowdfundingFactory.attach(factoryAddress);

    // Create a new campaign
    console.log("Creating a new campaign...");
    const tx = await crowdfundingFactory.createCampaign(
        "Test Campaign",
        "A simple crowdfunding project",
        hre.ethers.parseEther("100"),
        30
    );
    await tx.wait();
    console.log("Campaign created!");

    // Get deployed campaigns
    const campaigns = await crowdfundingFactory.getDeployedCampaigns();
    console.log("Deployed Campaigns:", campaigns);

    // Interact with the first campaign
    const campaignAddress = campaigns[0];
    const CrowdfundingCampaign = await hre.ethers.getContractFactory("CrowdfundingCampaign");
    const crowdfundingCampaign = await CrowdfundingCampaign.attach(campaignAddress);

    // Contributor makes a contribution
    console.log("Contributing to the campaign...");
    const contributeTx = await crowdfundingCampaign.connect(contributor).contribute({ value: hre.ethers.parseEther("10") });
    await contributeTx.wait();
    console.log("Contribution made!");

    // Check the balance of the campaign
    const balance = await hre.ethers.provider.getBalance(campaignAddress);
    console.log("Campaign Balance:", hre.ethers.formatEther(balance), "ETH");

    // Try to withdraw funds (only the owner can do this)
    console.log("Withdrawing funds...");
    const withdrawTx = await crowdfundingCampaign.connect(owner).withdrawFunds();
    await withdrawTx.wait();
    console.log("Funds withdrawn successfully!");

    // Check the final balance
    const finalBalance = await hre.ethers.provider.getBalance(campaignAddress);
    console.log("Final Campaign Balance:", hre.ethers.formatEther(finalBalance), "ETH");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });