var SafeMath = artifacts.require("SafeMath");
var Ownable = artifacts.require("Ownable");
var StandardToken = artifacts.require("StandardToken");

var Utils = artifacts.require("Utils");
var Withdrawable = artifacts.require("Withdrawable");
var THORToken = artifacts.require("THORToken");
var ThorNetworkProxy = artifacts.require("ThorNetworkProxy");
var ThorNetwork = artifacts.require("ThorNetwork");
var ThorReserve = artifacts.require("ThorReserve");
var ThorFee = artifacts.require("ThorFee");
var ThorUserInfo = artifacts.require("ThorUserInfo");
var ThorPrice = artifacts.require("ThorPrice");


module.exports = function(deployer) {
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, [
        Ownable, 
        StandardToken, 
        THORToken,
        ThorNetworkProxy,
        ThorNetwork,
        ThorFee,
        ThorPrice
    ]);
    
    deployer.deploy(Ownable);
    deployer.deploy(StandardToken);
    deployer.deploy(Utils);
    deployer.deploy(Withdrawable);
    deployer.deploy(THORToken);
    deployer.deploy(ThorNetworkProxy);

    deployer.deploy(ThorNetwork).then(function() {
        return deployer.deploy(ThorPrice, ThorNetwork.address);
    }).then(function() {
        return deployer.deploy(ThorReserve, ThorNetwork.address);
    }).then(function() {
        return deployer.deploy(ThorFee, ThorNetwork.address);
    }).then(function() {
        return deployer.deploy(ThorUserInfo, ThorNetwork.address);
    });

    deployer.then(function() {
        return ThorNetwork.deployed();
    }).then(function(instance) {
        thorNet = instance;
        return ThorNetworkProxy.deployed();
    }).then(function(instance) {
        proxy = instance;
        proxy.setThorNetworkContract(thorNet.address);
        return ThorPrice.deployed();
    }).then(function(instance) {
        price = instance;
        return ThorUserInfo.deployed();
    }).then(function(instance) {
        info = instance;
        return ThorFee.deployed();
    }).then(function(instance) {
        fee = instance;
        return thorNet.setContracts(proxy.address, price.address, info.address, fee.address);
    })
};
