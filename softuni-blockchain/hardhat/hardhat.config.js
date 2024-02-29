require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
   defaultNetwork: "hardhat",
   networks: {
    hardhat: {},
    sepolia: {
      url: "https://sepolia.infura.io/v3/<key>",
    },
   },
  solidity: "0.8.24",
};
