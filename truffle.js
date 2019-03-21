var HDWalletProvider = require("/usr/study_stack/node-v8.11.4-linux-x64/lib/node_modules/truffle-hdwallet-provider");
var mnemonic = "goddess bargain skirt moral tiny lock menu month float wrap end leader";

module.exports = {
    solc: {
  	optimizer: {
    	enabled: true,
    	runs: 200
  	}
    },

    networks: {
       // development: {
         //   host: "10.32.16.26",
           // port: 8545,
           // network_id: "5777",
            // gas: 20000000,
            // gasPrice: 2000,
        //},
	
	development: {
            host: "192.168.203.1",
            port: 7545,
            network_id: "5777",
            gas: 20000000,
            gasPrice: 5000,
        },

        "rinkeby": {
            provider: () => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/62bd3a8d8ccf4176b960b8d4ad8be0c6"),
            network_id: 4,
	    gas: 4612388,
            gasPrice: 4000000000
        },

        "ropsten": {
            provider: () => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/62bd3a8d8ccf4176b960b8d4ad8be0c6"),
            network_id: 3,
	    gas: 4612388,
	    gasPrice: 3000000000
        },

	"main": {
	    provider: () => new HDWalletProvider(mnemonic, "https://mainnet.infura.io/v3/62bd3a8d8ccf4176b960b8d4ad8be0c6"),
	    network_id: 3,
            gas: 3012388,
            gasPrice: 1000000000
	}
    }
};
