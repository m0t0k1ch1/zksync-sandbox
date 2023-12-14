import { HardhatRuntimeEnvironment } from "hardhat/types";

import { Wallet } from "zksync-ethers";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

export default async function (hre: HardhatRuntimeEnvironment) {
  let deployer: Deployer;
  {
    const privkey = process.env.PRIVATE_KEY;
    if (privkey === undefined) {
      throw new Error("PRIVATE_KEY required");
    }

    deployer = new Deployer(hre, new Wallet(privkey), "create2Account");
  }

  const contract = await deployer.deploy(
    await deployer.loadArtifact("MinimalAccount"),
    [],
    undefined
  );
  await contract.waitForDeployment();

  console.log(await contract.getAddress());
}
