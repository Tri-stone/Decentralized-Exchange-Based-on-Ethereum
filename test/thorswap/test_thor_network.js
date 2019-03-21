let ThorNetwork = artifacts.require("ThorNetwork");
let ThorPrice = artifacts.require("ThorPrice");
let THORToken = artifacts.require("THORToken");
let ThorNetworkProxy = artifacts.require("ThorNetworkProxy");
let ThorUserInfo = artifacts.require("ThorUserInfo");
let ThorFee = artifacts.require("ThorFee");
let ThorReserve = artifacts.require("ThorReserve");
let Token = artifacts.require("Token")

//global variables
let ethAddr = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
let thorNet;
let thorReserve;
let thorReserve1;
let thorPrice;
let thorNetProxy;
let thorUserInfo;
let thorFee;
let token1;
let token2;
let token3;
let acc1;
let acc2;
let acc3;

/**
 * test the main procedure of thor swap without proxy
 */
contract("ThorNetwork", async function(accounts) {
    it("test setup contracts and dependencies", async function() {
        acc1 = accounts[0];
        acc2 = accounts[1];
        acc3 = accounts[2];
        
        thorNet = await ThorNetwork.new();
        contractAddress = await thorNet.address;
        
        thorPrice = await ThorPrice.new(contractAddress);
        thorNetProxy = await ThorNetworkProxy.new();
        thorUserInfo = await ThorUserInfo.new(contractAddress);
        thorFee = await ThorFee.new(contractAddress);
        
        token1 = await THORToken.new();
        token1Addr = await token1.address;

        thorReserve = await ThorReserve.new(contractAddress);
        thorReserve1 = await ThorReserve.new(contractAddress);
        reserveAddr = await thorReserve.address;
        reserveAddr1 = await thorReserve1.address;
    
        name = await thorNet.contractName.call();
        await thorNet.setContracts(acc1, thorPrice.address, thorUserInfo.address, thorFee.address);
        assert.equal(name, "ThorNetwork", "not the right name");
    });

    it("test set token pairs & add token pair and rate to reserve & transfer eth and token1 to reserves", async function() {
        await thorReserve.send(web3.toWei(10, 'ether'), {from: acc3});
        await thorReserve1.send(web3.toWei(10, 'ether'), {from: acc3});
        
        await thorNet.addTokensToExchange([ethAddr, token1Addr], 2);
        await thorReserve.addTokenPairAndRate(ethAddr, token1Addr, 9700);
        await thorReserve1.addTokenPairAndRate(ethAddr, token1Addr, 9699);
        res = await thorReserve.getTokenPairAndRate.call(ethAddr, token1Addr);
        assert.equal(res[0], 9700, "wrong rate");
        
        await token1.transfer(reserveAddr, web3.toWei(1000, 'ether'));
        await token1.transfer(reserveAddr1, web3.toWei(1000, 'ether'));
    });
    
    it("test set token pair's price", async function() {
        await thorPrice.addTokenPairAndPrice(ethAddr, token1Addr, 200000000);
        price = await thorPrice.getTokenPairAndPrice.call(ethAddr, token1Addr);
        priceList = await thorPrice.getTokenTransactionPrice.call(token1Addr);
        assert.equal(price.valueOf(), 200000000, "wrong price");
        assert.equal(priceList[0].valueOf(), 200000000, "wrong price");
        assert.equal(priceList[1].valueOf(), 200000000, "wrong transactionPrice");
    });
    
    it("test add reserves & set tokens included and enable & transfer eth to thornet", async function() {
        await thorNet.addReserve(reserveAddr);
        await thorNet.addReserve(reserveAddr1);
        await thorNet.setTokensIncludedEnable();
        res = await thorNet.getTokenPairAndPrice.call(ethAddr, token1Addr);
        await thorNet.addReserve(acc1);
        await thorNet.send(web3.toWei(10, 'ether'));
        await thorNet.removeReserve(acc1);

        balanceThornet = await web3.eth.getBalance(contractAddress);
        assert.equal(balanceThornet.valueOf(), web3.toWei(10, 'ether'), "thornetwork don't has right eth");
        assert.equal(res, 200000000, "wrong price value");
    });
    
    it("test exchange", async function() {
        balance_a_token1 = await token1.balanceOf.call(acc2);
        balance_a_eth_reserve = await web3.eth.getBalance(reserveAddr);
        balance_a_token1_reserve = await token1.balanceOf.call(reserveAddr);
        
        await thorNet.exchange(ethAddr, web3.toWei(1, 'ether'), token1Addr, acc2, 9500, acc3);
        
        balance_b_token1 = await token1.balanceOf.call(acc2);
        balance_b_eth_reserve = await web3.eth.getBalance(reserveAddr);
        balance_b_token1_reserve = await token1.balanceOf.call(reserveAddr);
        
        walletFee = await thorFee.getWalletFee.call(acc3);
        assert.equal(balance_b_token1.minus(balance_a_token1).valueOf(), 1938060000000000000, "wrong exchange");
        assert.equal(balance_b_eth_reserve.minus(balance_a_eth_reserve).valueOf(), 999000000000000000, "wrong exchange");
        assert.equal(walletFee.valueOf(), 400000000000000, "wrong exchange");
        assert.equal(balance_a_token1_reserve.minus(balance_b_token1_reserve).valueOf(), 1938060000000000000, "wrong exchange");
    });

    it("test calculateToTokenAmount", async function() {
        toAmount = await thorNet.calculateToTokenAmount.call(ethAddr, token1Addr, web3.toWei(1, 'ether'));
        assert.equal(toAmount.valueOf(), 2000000000000000000, "wrong amount");
    });
});