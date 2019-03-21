const ThorFee = artifacts.require("./ThorFee.sol");

/**
 * test contract ThorFee
 */
contract("ThorFee", function(accounts) {
    it("init thor fee and test handleFee & withdrawFee", function() {
        acc1 = accounts[0];
        acc2 = accounts[1];
        acc3 = accounts[2];

        return ThorFee.new(acc1).then(function(instance) {
            thorFee = instance;
            asset1 = web3.eth.getBalance(acc3);
            return thorFee.handleFee(1000, acc2, {from: acc1, value: 2000});
        }).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "HandleFee", "not right event");
            return thorFee.withdrawFee(acc3, 100, {from: acc2});
        }).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "EtherFeeWithdraw", "not right event");
            return web3.eth.getBalance(acc3); 
        }).then(function(asset2) {
            assert.equal(asset1.minus(100).toNumber(), asset2.toNumber(), "Not equal");
        });
    });

    it("get fees", function() {
        return thorFee.getWalletFee.call(acc2).then(function(walletsFee) {
            assert.equal(walletsFee.toNumber(), 300, "not the right wallet fee");
            return thorFee.getSelfWalletFee.call({from: acc2});
        }).then(function(thorWalletFee) {
            assert.equal(thorWalletFee.toNumber(), 300, "not the right fee of thor wallet");
        });
    });

    it("set and get ratio", function() {
        return thorFee.setFeeDistributionRatio(5, 5).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "SetFeeDistributionRatio", "not right event");
        });
    });
});
