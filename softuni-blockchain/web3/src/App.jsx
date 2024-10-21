import { useState } from 'react';
import './App.css'
import { ethers } from 'ethers';
import imageURL from './assets/web3.jfif';

function App() {
   const [account, setCurrentAccount] = useState(null);
   const [provider, setProvider] = useState(null);
   const [accountBalance, setCurrentAccountBalance] = useState(null);
   const [blockNumber, setCurrentBlockNumber] = useState(null);

   function handleWalletConnection() {
      if (!window.ethereum) {
         alert('Install Metamask!')
         return;
      }

      const provider = new ethers.BrowserProvider(window.ethereum);
      setProvider(provider);

      provider.send('eth_requestAccounts', []).then((accounts) => {
         if (accounts.length > 0) {
            setCurrentAccount(accounts[0]);
         }
      }).catch((error) => console.log(error));

   }

   async function sendTransactionGO() {
      const signer = await provider.getSigner();
      const tx = {
         to: "0x258BD1E3b6e9932a9221ccda650c4d8B3c2ebd4e", // Replace with the recipient's address
         value: ethers.parseEther("0.1"), // Sending 0.1 ETH, use ethers to convert to Wei
      };
      signer.sendTransaction(tx).then((txInfo) => {
         console.log(txInfo);
      })

   }

   function getBalanceOfAccount() {
      provider.getBalance(account).then((balance) => {
         setCurrentAccountBalance(balance);
      }).catch((err) => console.log(err));
   }

   async function getBlockNumber() {
      const blockNumber = await provider.getBlockNumber();
      setCurrentBlockNumber(blockNumber);
   }

   return (
      <>
         <img src={imageURL} />
         <br />
         <button onClick={handleWalletConnection}>Connect to wallet</button>
         <h2>Wallet account:</h2>
         {account && <h2>{account}</h2>}
         <button onClick={getBalanceOfAccount}>Get Balance</button>
         <h2>Account{"'"}s balance:</h2>
         {accountBalance ? <h2 className='heading'>{ethers.formatEther(accountBalance.toString())}</h2> : <h2>Zero balance</h2>}
         <button onClick={getBlockNumber}>Get BlockNumber</button>
         <h2>Current block number:</h2>
         <h2>{blockNumber}</h2>
         <button onClick={sendTransactionGO}>Send GO</button>


      </>
   )
}

export default App;