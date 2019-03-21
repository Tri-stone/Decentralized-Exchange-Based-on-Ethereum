var HDWalletProvider = require("/usr/study_stack/node-v8.11.4-linux-x64/lib/node_modules/truffle-hdwallet-provider");
var mnemonic = "goddess bargain skirt moral tiny lock menu month float wrap end leader";

module.exports = {
    networks: {
        development: {
            host: "10.32.16.26",
            port: 8545,
            network_id: "*",
            gas: 672197500000,
            gasPrice: 0,
        },

        "rinkeby-infura": {
            provider: () => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/62bd3a8d8ccf4176b960b8d4ad8be0c6"),
            network_id: 3,
            gas: 4700000
        },

        "ropsten-infura": {
            provider: () => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/62bd3a8d8ccf4176b960b8d4ad8be0c6"),
            network_id: 4,
        }
    }
};
