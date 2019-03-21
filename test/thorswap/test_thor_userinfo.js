const ThorUserInfo = artifacts.require("./ThorUserInfo.sol");
const ThorNetwork = artifacts.require("ThorNetwork");

contract("ThorUserInfo", function(accounts) {
    it("init thoruserinfo and set and get user's quota", function() {
        return ThorUserInfo.new(accounts[0]).then(function(instance) {
            thorUserInfo = instance;
            return thorUserInfo.setUserQuota(accounts[0], 1);
        }).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "SetUserQuota", "not the right event");
            return thorUserInfo.getUserQuota.call(accounts[0]);
        }).then(function(quota) {
            assert.equal(quota.toNumber(), 2 * 10 ** 19, "wrong number") ;
        });
    });

    it("set and get thornetwork", function() {
        return ThorNetwork.new().then(function(instance) {
            thorNetAddr = instance.address;
            return thorUserInfo.setThorNetworkContract(thorNetAddr);  
        }).then(function(eventObj) {
            assert.equal(eventObj.logs[0].event, "SetThorNetworkContract", "not the right event");
            return thorUserInfo.getThorNetworkContract.call();
        }).then(function(x) {
            assert.equal(x, thorNetAddr, "not the right address")
        });
    });
});