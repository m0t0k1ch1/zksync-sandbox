import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

import { Wallet } from "zksync-ethers";

export default async function (hre: HardhatRuntimeEnvironment) {
  let deployer: Deployer;
  {
    const privkey = process.env.PRIVATE_KEY;
    if (privkey === undefined) {
      throw new Error("PRIVATE_KEY required");
    }

    deployer = new Deployer(hre, new Wallet(privkey));
  }

  const contract = await deployer.deploy(
    await deployer.loadArtifact("MinimalAccount"),
    [],
    undefined
  );
  await contract.waitForDeployment();

  console.log(await contract.getAddress());
}
