import hre from "hardhat";
import { HttpNetworkConfig } from "hardhat/types";

import { Provider, utils } from "zksync-ethers";
import { TransactionLike } from "zksync-ethers/build/src/types";

const TO_ADDRESS = "0xFE863b5dd6eDD37E9878008119460036949bd242";
const FROM_ADDRESS = "0x2C4ec149c4F2EeC1380B89bfee9708AeF3b6d1B9";
const VALUE = hre.ethers.parseEther("0.01");

(async () => {
  const provider = new Provider((hre.network.config as HttpNetworkConfig).url);

  let tx: TransactionLike;
  {
    tx = {
      to: TO_ADDRESS,
      from: FROM_ADDRESS,
      value: VALUE,
    };

    const gasLimit = await provider.estimateGas(tx);

    tx = {
      ...tx,
      nonce: await provider.getTransactionCount(FROM_ADDRESS),
      gasLimit: gasLimit,
      gasPrice: await provider.getGasPrice(),
      chainId: (await provider.getNetwork()).chainId,
      customData: {
        customSignature: hre.ethers.ZeroHash,
      },
    };
  }

  {
    const txResp = await provider.broadcastTransaction(
      utils.serializeEip712(tx)
    );
    console.log(txResp.hash);
    await txResp.wait();
  }
})().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
