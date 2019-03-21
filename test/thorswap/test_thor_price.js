const ThorPrice = artifacts.require("./ThorPrice.sol");
const THORToken = artifacts.require("./THORToken.sol");
const ThorNetwork = artifacts.require("ThorNetwork");

const ethAddr = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
const moleculePrice = 91;
const denominatorPrice = 100;

/**
 * test thor price contract
 */
contract("ThorPrice", function(accounts) {
    it("init a thorprice instance, test the contract name, and get tokens' address", function() {
        return THORToken.new().then(function(instance) {
            return instance.address;
        }).then(function(addr) {
            tokenAddr = addr;
            return THORToken.new();
        }).then(function(instance) {
            return instance.address;
        }).then(function(addr) {
            tokenAddr1 = addr;
            return THORToken.new();
        }).then(function(instance) {
            return instance.address;
        }).then(function(addr) {
            tokenAddr2 = addr;
            return ThorNetwork.new();
        }).then(function(instance) {
            thorNetAddr = instance.address;
            return ThorPrice.new(thorNetAddr);          
        }).then(function(instance) {
            thorPrice = instance;
            return thorPrice.contractName.call();
        }).then(function(res) {
            assert.equal(res.valueOf(), "ThorPrice");
        });
    });

    it("set and get price rate", function() {
        return thorPrice.setPriceRate(moleculePrice, denominatorPrice, {from: accounts[0]}).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "SetPriceRate", "Not right event");
            return thorPrice.getPriceRate.call();
        }).then(function(res) {
            assert.equal(res[0].toNumber(), moleculePrice, "wrong moleculePrice");
            assert.equal(res[1].toNumber(), denominatorPrice, "wrong denominatorPrice");
        });
    });

    it("add and get token pair and the price", function() {
        return thorPrice.addTokenPairAndPrice(ethAddr, tokenAddr, 10 ** 20).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "AddTokenPairAndPrice", "Not right event");
            return thorPrice.getTokenPairAndPrice.call(ethAddr, tokenAddr);
        }).then(function(price) {
            assert.equal(price, 91 * 10 ** 18, "incorrected price");
        });
    });

    it("add token pairs and prices, then get them", function() {
        return thorPrice.addTokenPairsAndPrice([tokenAddr1, tokenAddr2], [10 ** 20, 10 ** 20]).then(function(eventObj) {
            len = eventObj.logs.length;
            assert.equal(eventObj.logs[len - 1].event, "AddTokenPairsAndPrice", "Not right event");
            return thorPrice.getTokenPairAndPrice.call(ethAddr, tokenAddr1);
        }).then(function(price1) {
            assert.equal(price1, 91 * 10 ** 18, "incorrected price1");
            return thorPrice.getTokenPairAndPrice.call(ethAddr, tokenAddr2);
        }).then(function(price2) {
            assert.equal(price2, 91 * 10 ** 18, "incorrected price2");
        });
    });

    it("modify token pair and price", function() {
        return thorPrice.modifyTokenPairPrice(ethAddr, tokenAddr1, 10 ** 19).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "ModifyTokenPairPrice");
            return thorPrice.getTokenPairAndPrice.call(ethAddr, tokenAddr1);
        }).then(function(price) {
            assert.equal(price.toNumber(), 91 * 10 ** 17, "incorrected price");
        });
    });

    it("set and get if token pair is enabled", function() {
        return thorPrice.setTokenPairIsEnable(ethAddr, tokenAddr1, true).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "SetTokenPairIsEnable", "Not right event");
            return thorPrice.getTokenPairIsEnable.call(ethAddr, tokenAddr1);
        }).then(function(res) {
            assert.equal(res, true, "wrong result");
        });
    });

    it("set and get ThorNetworkContract", function() {
        return thorPrice.setThorNetworkContract(thorNetAddr).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "SetThorNetworkContract", "Not right event");
            return thorPrice.getThorNetworkContract.call();
        }).then(function(res) {
            assert.equal(res.valueOf(), thorNetAddr, "wrong ThorNetwork contract address");
        })
    });

    it("get tokens which are included in contracts", function() {
        return thorPrice.getTokensIncluded.call().then(function(tokensIncluded) {
            arr = [ethAddr, tokenAddr, tokenAddr1, tokenAddr2];
            for (var i = 0; i < arr.length; i++) {
                assert.equal(tokensIncluded[i].valueOf(), arr[i].valueOf(), "not same tokens");
            }
        });
    });
});