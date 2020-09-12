const PoolProxy = artifacts.require('MinePoolProxy');
const MinePool = artifacts.require('FNXMinePool');
const MockTokenFactory = artifacts.require('TokenFactory');
const Token = artifacts.require("TokenMock");

const assert = require('chai').assert;
const Web3 = require('web3');
const config = require("../truffle.js");
const BN = require("bn.js");
var utils = require('./utils.js');

web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));

// async function setupNetwork() {
//   let network = args.network;
//   web3url = "http://" + config.networks[network].host + ":" + config.networks[network].port;
//   console.log("setup network %s", network);
//   if (network == 'development' || network == 'soliditycoverage') {
//     web3 = new Web3(new Web3.providers.HttpProvider(web3url));
//   }
// }

contract('MinePoolProxy', function (accounts){
    let minepool;
    let proxy;
    let tokenFactory;
    let lpToken1;
    let lpToken2;
    let fnxToken;
    let time1;

    let stakeAmount = web3.utils.toWei('1', 'ether');
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
        fnxToken = await Token.at(await tokenFactory.createdToken());
        console.log("lptoken3 address:",fnxToken.address);

        //mock token set balance
        await lpToken1.adminSetBalance(staker1, userLpAmount);
        let staker1Balance =await lpToken1.balanceOf(staker1);
        //console.log(staker1Balance);
        assert.equal(staker1Balance,userLpAmount);

        await lpToken1.adminSetBalance(staker2, userLpAmount);

        await fnxToken.adminSetBalance(proxy.address,fnxMineAmount);

        //set mine coin info
        let res = await proxy.setLpMineInfo(lpToken1.address,fnxToken.address,disSpeed,interval);

        assert.equal(res.receipt.status,true);

    })


    it("[0010] stake test and check mined balance,should pass", async()=>{

      let preMinerBalance = await proxy.getMinerBalance(staker1);
      console.log("before mine balance = " + preMinerBalance);

      let res = await lpToken1.approve(proxy.address,stakeAmount,{from:staker1});
      res = await proxy.stake(stakeAmount,{from:staker1});
      time1 = await tokenFactory.getBlockTime();
      console.log(time1.toString(10));

      let bigin = await web3.eth.getBlockNumber();
      console.log("start block="+ bigin )
      await utils.pause(web3,bigin + 1);

      let time2 = await tokenFactory.getBlockTime();
      //console.log(time2.toString(10));

      let afterMinerBalance = await proxy.getMinerBalance(staker1);
      console.log("after mine balance = " + afterMinerBalance);

      let diff = web3.utils.fromWei(afterMinerBalance) - web3.utils.fromWei(preMinerBalance);
      //console.log("time diff=" + (time2 - time1));
      let timeDiff = time2 - time1;

      console.log("mine balance = " + diff);
      assert.equal(diff>=timeDiff&&diff<=diff*(timeDiff+1),true);
		})

  it("[0020]get out mine reward,should pass", async()=>{
    console.log("\n\n");
    let preMinedAccountBalance = await fnxToken.balanceOf(staker1);
    console.log("before mined token balance="+preMinedAccountBalance);

    let mineReward = await proxy.getMinerBalance(staker1);
    console.log("mined reward = " + mineReward);

    let time2 = await tokenFactory.getBlockTime();
    console.log(time2.toString(10));

    let timeDiff = time2 - time1;
    console.log("timeDiff=" + timeDiff);

    let res = await proxy.redeemMineReward(mineReward,{from:staker1});
    assert.equal(res.receipt.status,true);

    let afterMineAccountBalance = await fnxToken.balanceOf(staker1);
    console.log("after mined account balance = " + afterMineAccountBalance);

    let diff = web3.utils.fromWei(afterMineAccountBalance) - web3.utils.fromWei(preMinedAccountBalance);

    console.log("mine reward = " + diff);

    assert.equal(diff>=timeDiff&&diff<=diff*(timeDiff+1),true);
  })


  it("[0030] stake out,should pass", async()=>{
    console.log("\n\n");
    let preLpBlance = await lpToken1.balanceOf(staker1);
    console.log("preLpBlance=" + preLpBlance);

    let preStakeBalance = await proxy.getStakeBalance(staker1);
    console.log("before mine balance = " + preStakeBalance);

    let res = await proxy.unstake(preStakeBalance,{from:staker1});
    assert.equal(res.receipt.status,true);

    let afterStakeBalance = await proxy.getStakeBalance(staker1);
    console.log("after mine balance = " + afterStakeBalance);

    let diff = web3.utils.fromWei(preStakeBalance) - web3.utils.fromWei(afterStakeBalance);
    console.log("stake out balance = " + diff);

    let afterLpBlance = await lpToken1.balanceOf(staker1);
    console.log("afterLpBlance=" + afterLpBlance);
    let lpdiff = web3.utils.fromWei(afterLpBlance) - web3.utils.fromWei(preLpBlance);

    assert.equal(diff,lpdiff);
  })


})
