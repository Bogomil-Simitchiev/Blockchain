const { task } = require('hardhat/config');

task('accounts', 'Print the list of accounts')
    .addParam('acc', 'account number')
    .setAction(async (taskArgs, hre) => {
        const accounts = await hre.ethers.getSigners();
        for (let index = 0; index < Number(taskArgs.acc); index++) {
            console.log(accounts[index].address);
        }
    })