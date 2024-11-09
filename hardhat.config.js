require('@nomiclabs/hardhat-waffle');
require('hardhat-deploy');
require("@nomicfoundation/hardhat-verify");

const fs = require('fs');
let credentials = require('./credentials.example.json');
if (fs.existsSync('./credentials.json')) {
  credentials = require('./credentials.json');
}

module.exports = {
  networks: { ...credentials.networks.mainnets, ...credentials.networks.testnets },
  etherscan: {
    apiKey: "SMCGJRBG4ZE1JC5G5FWFVE3Y7UWKK8UQ68",
    customChains: [
      {
        name: 'base',
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org/",
        }
      },
      {
        network: 'base-sepolia',
        chainId: 84532,
        urls: {
          apiURL: 'https://api-sepolia.basescan.org/api',
          browserURL: 'https://sepolia.basescan.org/',
        }
      }
    ]
  },
  solidity: {
    version: '0.8.10',
    settings: {
      optimizer: {
        enabled: false
      },
    },
  },
};