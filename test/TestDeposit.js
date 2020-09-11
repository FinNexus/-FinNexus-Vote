const PoolProxy = artifacts.require('MinePoolProxy');
const MinePool = artifacts.require('FNXMinePool');
const MockTokenFactory = artifacts.require('TokenFactory');
const Token = artifacts.require("TokenMock");

const assert = require('assert');
const BN = require("bn.js")

contract('MinePoolProxy', function (accounts){
    let minepool;
    let proxy;
    let tokenFactory;
    let lpToken1;
    let lpToken2;
    let fnxToken;

    let userLpAmount = web3.utils.toWei('1000', 'ether');
    let staker1 = accounts[1];
    let staker2 = accounts[2];

    let fnxMineAmount = web3.utils.toWei('1000000', 'ether');
    let disSpeed = web3.utils.toWei('1', 'ether');
    let interval = 1;

    before("init", async()=>{
        minepool = await MinePool.new();
        console.log("pool address:", minepool.address);

        proxy = await PoolProxy.new(minepool.address);
        console.log("proxy address:",proxy.address);

        tokenFactory = await MockTokenFactory.new();
        console.log("tokenfactory address:",tokenFactory.address);

        await tokenFactory.createToken(18);
        lpToken1 = await Token.at(await tokenFactory.createdToken());
        console.log("lptoken1 address:",lpToken1.address);

        await tokenFactory.createToken(18);
        lpToken2 = await Token.at(await tokenFactory.createdToken());
        console.log("lptoken2 address:",lpToken2.address);

        await tokenFactory.createToken(18);
        fnxToken = await Token.at(await tokenFactory.createdToken());
        console.log("lptoken3 address:",fnxToken.address);

        //mock token set balance
        await lpToken1.adminSetBalance(staker1, userLpAmount);
        await lpToken1.adminSetBalance(staker2, userLpAmount);

        await fnxToken.adminSetBalance(minepool.address,fnxMineAmount);

        //set mine coin info
        let res = await proxy.setLpMineInfo(fnxToken.address,disSpeed,interval);

        assert.equal(res.receipt.status,true);

    })


    it("", async()=>{


		})


})
