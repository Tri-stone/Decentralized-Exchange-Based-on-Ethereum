let ThorReserve = artifacts.require("ThorReserve");
let THORToken = artifacts.require("THORToken");
let ThorNetwork = artifacts.require("ThorNetwork");

let ethAddr = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
let amountEth = 10 ** 17;
let amountToken = 10 ** 20;
let acc1;
let acc2;
let acc3;
let thorNet;
let thorReserve;
let token;

contract("ThorReserveTest", async function(accounts) {
    it("init tokens", async function() {
        token = await THORToken.new();
    });
    
    it("init thornetwork", async function() {
        thorNet = await ThorNetwork.new();
        thorNetAddr = await thorNet.address;
        await thorNet.addTokensToExchange([ethAddr, token.address], 2);
        res = await thorNet.getTokenToExchangeIsEnable.call(ethAddr);
        assert.equal(res, true, "wrong res");
    });
    
    it("init thorReserve", async function() {
        acc1 = accounts[0];
        acc2 = accounts[1];
        acc3 = accounts[2];
        
        thorReserve = await ThorReserve.new(thorNetAddr);
        name = await thorReserve.contractName.call();
        assert.equal(name, "ThorReserve", "not the right name");
        await web3.eth.sendTransaction({from: acc3, to: thorReserve.address, value: amountEth});
        await token.transfer(thorReserve.address, amountToken);
    });

    it("add and get token pair & rate", async function() {
        await thorReserve.addTokenPairAndRate(ethAddr, token.address, 9900);
        res = await thorReserve.getTokenPairAndRate.call(ethAddr, token.address);
        assert.equal(res[0], 9900, "not the right rate");
        assert(typeof(res[1].toNumber()) == 'number', "wrong block number");
        assert(typeof(res[2].toNumber()) == 'number', "wrong block number");
    });
    
    it("test exchange", async function() {
        await thorReserve.setThorNetworkContract(acc1);
        name = await thorReserve.getThorNetworkContract.call();
        assert.equal(name, acc1, "wrong contract name");
        balance1 = await web3.eth.getBalance(acc2);
        await thorReserve.exchange(token.address, ethAddr, acc2, 10 ** 16, 9900);
        balance2 = await web3.eth.getBalance(acc2);
        assert.equal(balance2.toNumber(), balance1.plus(10 ** 16).toNumber(), "balance not right");
    });

    it("test set info of reserve, check if reserve has enough eth and set & get token pair enable", async function() {
        await thorReserve.modifyTokenPairRate(ethAddr, token.address, 9800);
        res = await thorReserve.getExchangeRate.call(token.address, ethAddr, 10 ** 16);
        assert.equal(res, 9800, "wrong rate");
        await thorReserve.setTokenReserveInfo(ethAddr, amountEth, 10, 9);
        await thorReserve.setTokenReserveInfo(token.address, amountToken, 10, 9);
        res = await thorReserve.isEnoughToken.call(ethAddr, 10 ** 16);
        assert.equal(res, true, "not enough for exchange");
        await thorReserve.setTokenPairIsEnable(ethAddr, token.address, true);
        res = await thorReserve.getTokenPairIsEnable.call(ethAddr, token.address);
        assert.equal(res, true, "not enable");
    });
});