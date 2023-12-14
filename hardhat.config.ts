import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-deploy";

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
      url: "https://sepolia.era.zksync.dev",
      ethNetwork: "sepolia",
      zksync: true,
    },
  },
};

export default config;
