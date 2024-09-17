require("@nomicfoundation/hardhat-toolbox");

require('./tasks');

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
