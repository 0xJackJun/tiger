require("@nomiclabs/hardhat-waffle");

const INFURA_API_KEY = "e2bd5b81da70452d8087087d86e54cc4";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
      accounts: []
    }
  }
};