//var HDWalletProvider = require("truffle-hdwallet-provider");

// 12-word mnemonic
//var mnemonic = "onyx aloof polio bronco spearfish clustered refined earflap darkroom slashing casualty curled";

module.exports = {
    networks: {
        ropsten: {
            network_id: 3,      // Official ropsten network id
            //provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"),   // Use our custom provider
            host: 'localhost',
            port: 8546
        },
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*"
        }
    },
    mocha: {
       reporter: 'mocha-junit-reporter'
    }
};
