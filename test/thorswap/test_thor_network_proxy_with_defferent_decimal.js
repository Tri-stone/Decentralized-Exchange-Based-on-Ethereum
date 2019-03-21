let ThorNetwork = artifacts.require("ThorNetwork");
let ThorPrice = artifacts.require("ThorPrice");
let THORToken = artifacts.require("THORToken1");
let ThorNetworkProxy = artifacts.require("ThorNetworkProxy");
let ThorUserInfo = artifacts.require("ThorUserInfo");
let ThorFee = artifacts.require("ThorFee");
let ThorReserve = artifacts.require("ThorReserve");
let Token = artifacts.require("Token")

let ethAddr = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
let thorNet;
let thorReserve;
let thorReserve1;
let thorPrice;
let thorNetProxy;
let thorUserInfo;
let thorFee;
let token1;
let acc1;
let acc2;
let acc3;

/**
 * Same call of test thor network proxy, but with defferent ERC20-token decimal
 */
contract("ThorNetworkProxy", async function(accounts) {
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
        await thorNet.setContracts(thorNetProxy.address, thorPrice.address, thorUserInfo.address, thorFee.address);
        await thorNetProxy.setThorNetworkContract(contractAddress);
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
        
        await token1.transfer(reserveAddr, web3.toWei(1000, 'ether') / 10 ** 6);
        await token1.transfer(reserveAddr1, web3.toWei(1000, 'ether') / 10 ** 6);
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
        // balanceThornet = await web3.eth.getBalance(contractAddress);
        // assert.equal(balance_thornet.valueOf(), web3.toWei(10, 'ether'), "thornetwork don't has right eth");
        assert.equal(res, 200000000, "wrong price value");
    });

    it("test exchange", async function() {
        balance_a_token1 = await token1.balanceOf.call(acc2);
        balance_a_eth_reserve = await web3.eth.getBalance(reserveAddr);
        balance_a_token1_reserve = await token1.balanceOf.call(reserveAddr);
        
        await thorNetProxy.exchange(ethAddr, web3.toWei(1, 'ether'), token1Addr, 9500, acc3, {from: acc2, value: web3.toWei(1, 'ether')});
        
        balance_b_token1 = await token1.balanceOf.call(acc2);
        balance_b_eth_reserve = await web3.eth.getBalance(reserveAddr);
        balance_b_token1_reserve = await token1.balanceOf.call(reserveAddr);
        
        walletFee = await thorFee.getWalletFee.call(acc3);
        assert.equal(balance_b_token1.minus(balance_a_token1).valueOf(), 1938060000000, "wrong exchange");
        assert.equal(balance_b_eth_reserve.minus(balance_a_eth_reserve).valueOf(), 999000000000000000, "wrong exchange");
        assert.equal(walletFee.valueOf(), 400000000000000, "wrong exchange");
        assert.equal(balance_a_token1_reserve.minus(balance_b_token1_reserve).valueOf(), 1938060000000, "wrong exchange");
    });

    it("wallet withdraw fee", async function() {
        balanceAcc3a = await web3.eth.getBalance(acc2);
        await thorFee.withdrawFee(acc2, walletFee.valueOf(), {from: acc3});
        balanceAcc3b = await web3.eth.getBalance(acc2);
        assert.equal(balanceAcc3b.minus(balanceAcc3a).valueOf(), walletFee.valueOf(), "wallet withdraw failed");
    });

    it("reserve withdraw tokens and ether", async function() {
        token1Balance = await token1.balanceOf.call(acc3);
        ethBalance = await web3.eth.getBalance(acc3);
        await thorReserve.withdrawToken(token1Addr, web3.toWei(1, 'ether') / 10 ** 6, acc3);
        await thorReserve.withdrawEther(web3.toWei(1, 'ether'), acc3);
        token1Balanceb = await token1.balanceOf.call(acc3);
        ethBalanceb = await web3.eth.getBalance(acc3);
        assert.equal(token1Balanceb.minus(token1Balance).valueOf(), web3.toWei(1, 'ether') / 10 ** 6, "token withdraw failed");
        assert.equal(ethBalanceb.minus(ethBalance).valueOf(), web3.toWei(1, 'ether'), "eth withdraw failed");
    });
});