const hre = require("hardhat");

async function main() {
    const CrowdfundingFactory = await hre.ethers.getContractFactory("CrowdfundingFactory");
    const crowdfundingFactory = await CrowdfundingFactory.deploy();

    await crowdfundingFactory.waitForDeployment();

    console.log("CrowdfundingFactory deployed to:", crowdfundingFactory.target);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });