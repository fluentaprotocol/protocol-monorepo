import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.27",
        settings: {
          evmVersion: 'shanghai',
          viaIR: true,
        },
      },
      {
        version: "0.8.4",
        settings: {
          evmVersion: 'shanghai',
        },
      },
    ],
  },
  gasReporter: {
    L1: "ethereum",
    gasPrice: 20,
    currency: "USD",
    token: "ETH",
    tokenPrice: "3800.00" as any,
    includeIntrinsicGas: true,
    excludeContracts: ["MockERC20"],
  },
};

export default config;
