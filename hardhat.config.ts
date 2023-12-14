import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-verify";

const config: HardhatUserConfig = {
  zksolc: {
    version: "1.3.18",
    settings: {
      isSystem: true,
    },
  },
  solidity: {
    version: "0.8.23",
  },
  networks: {
    sepolia: {
      url: "https://rpc.sepolia.org",
    },
    "zksync-sepolia": {
      url: "https://sepolia.era.zksync.dev",
      ethNetwork: "sepolia",
      zksync: true,
      verifyURL:
        "https://explorer.sepolia.era.zksync.dev/contract_verification",
    },
  },
};

export default config;
