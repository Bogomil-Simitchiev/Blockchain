import "./App.css";

import { init, useConnectWallet } from "@web3-onboard/react";
import injectedModule from "@web3-onboard/injected-wallets";
import walletConnectModule from "@web3-onboard/walletconnect";

import ChainModal from "./components/ChainModal/ChainModal";
import Navbar from "./components/NavBar/NavBar";
import Button from "./components/Button/Button";
import SendForm from "./components/SendForm.jsx/SendForm";
import EventModal from "./components/EventModal/EventModal";
import TransfersSection from "./components/TransferSection/TransferSection";

const API_KEY = "Pv-hZUItmViRh3LlPTzymYC4LdC0QO0X";
const rpcUrl = `https://eth-sepolia.g.alchemy.com/v2/${API_KEY}`;
const wcInitOptions = {
  /**
   * Project ID associated with [WalletConnect account](https://cloud.walletconnect.com)
   */
  projectId: 'f5c395c74df38d50fc59b79def7fe445',
  /**
   * Chains required to be supported by all wallets connecting to your DApp
   */
  requiredChains: [11155111],
  /**
   * Chains required to be supported by all wallets connecting to your DApp
   */
  optionalChains: [],
  /**
   * Defaults to `appMetadata.explore` that is supplied to the web3-onboard init
   * Strongly recommended to provide atleast one URL as it is required by some wallets (i.e. MetaMask)
   * To connect with WalletConnect
   */
  dappUrl: 'http://localhost:3000/'
}
const injected = injectedModule();
const walletConnect = walletConnectModule(wcInitOptions);
// initialize Onboard
init({
  connect: {
    autoConnectLastWallet: true,
  },
  wallets: [injected, walletConnect],
  chains: [
    {
      id: "0xaa36a7",
      token: "ETH",
      label: "Ethereum Sepolia",
      rpcUrl,
    },
  ],
  accountCenter: {
    desktop: {
      enabled: false,
    },
    mobile: {
      enabled: false,
    },
  },
});

function App() {
  const [{ wallet, connecting }, connect, disconnect] = useConnectWallet();

  function handleConnect() {
    connect();
  }

  function handleDisconnect() {
    if (!wallet) {
      return;
    }

    disconnect(wallet).catch((error) => {
      console.error(error);
    });
  }

  if (wallet) {
    return (
      <div className='App'>
        <Navbar onDisconnect={handleDisconnect} />
        <div className='main'>
          <ChainModal onDisconnect={handleDisconnect} />
          <EventModal />
          <SendForm />
          <TransfersSection />
        </div>
      </div>
    );
  }

  return (
    <div className='App'>
      <Navbar onDisconnect={handleDisconnect} />
      <div className='main'>
        <Button
          disabled={connecting}
          handleClick={handleConnect}
          text={"Connect"}
        />
      </div>
    </div>
  );
}

export default App;
