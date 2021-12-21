const fs = require('fs');
const path = require('path');

require('@nomiclabs/hardhat-truffle5');
require('@nomiclabs/hardhat-solhint');
require('solidity-coverage');
require('hardhat-gas-reporter');

for (const f of fs.readdirSync(path.join(__dirname, 'hardhat'))) {
  require(path.join(__dirname, 'hardhat', f));
}

const enableGasReport = !!process.env.ENABLE_GAS_REPORT;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-ethers');

module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.6.12',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        }
      },
      {
        version: '0.5.5',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        }
      },
      {
        version: '0.8.7',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ]
  },
  networks: {
    hardhat: {
      blockGasLimit: 10000000,
    },
    ropsten: {
      url: "https://eth-ropsten.alchemyapi.io/v2/NIXVeA14pkc_XI97TmgAAO4BWOT80Mu8",
      accounts: ['0xd3d46d51fa3780cd952821498951e07307dfcfbbf2937d1c54123d6582032fa6'],
      gasPrice: 30 * 1e9
    },
    bsctest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: ['cd2fe348ecbde2a9b1caf0429dfaac4b656b9d969eca290cc106e6cbb38ef1e9'],
      gasPrice: 30 * 1e9
    },
  },
  gasReporter: {
    enable: enableGasReport,
    currency: 'USD',
    outputFile: process.env.CI ? 'gas-report.txt' : undefined,
  },
  mocha: {
    grep: 'Marketplace|NftAuction'
  }
};
