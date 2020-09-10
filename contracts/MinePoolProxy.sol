pragma solidity =0.5.16;
import "./MinePoolData.sol";
import "./baseProxy.sol";
/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract MinePoolProxy is MinePoolData,baseProxy {
    constructor (address implementation_) baseProxy(implementation_) public{
    }
    /**
     * @dev default function for foundation input miner coins.
     */
    function()external payable{
    }
    
    
    /**
     * @dev Set mineCoin mine info, only foundation owner can invoked.
     *  mineCoin mineCoin address
     *  _mineAmount mineCoin distributed amount
     *  _mineInterval mineCoin distributied time interval
     */
    function setMineCoinInfo(address /*mineCoin*/,uint256 /*_mineAmount*/,uint256 /*_mineInterval*/)public {
        delegateAndReturn();
    }

    /**
     * @dev disable liquid pool mine info, only foundation owner can invoked.
     * @ lp liquid pool address
     */    
    function disableLp(address /*lp*/) public {
         delegateAndReturn();
    }    
    
    /**
     * @dev changer mine coin distributed amount , only foundation owner can modify database.
     * @ lp liquid pool mine coin address
     * @ mineAmount the distributed amount.
     */
    function setMineAmount(address /*lp*/,uint256 /*mineAmount*/)  public {
        delegateAndReturn();
    }    
    
    
    /**
     * @dev changer liquid pool distributed time interval , only foundation owner can modify database.
     * @  lp uniswap liquid pool address
     * @  mineInterval the distributed time interval.
     */
    function setMineInterval(address /*lp*/,uint256 /*mineInterval*/) public {
        delegateAndReturn();
    }    
    
    /**
     * @dev set mine token address
     * @ mineTokenAddress the mined token address
     */
    function setMineTokenAddress(address /*mineTokenAddress*/)  public {
         delegateAndReturn();
    }  
    
     /**
     * @dev user stake in lp token
     * @  lp uniswap liquid pool address
     * @  amount stake in amout
     */
    function stake(address /*lp*/,uint256 /*amount*/) public {
         delegateAndReturn();
    }  
    
    
   /**
     * @dev user  unstake to cancel mine
     * @  lp uniswap liquid pool address
     * @  amount stake in amout
     */
    function unstake(address/* lp*/,uint256 /*amount*/) public {
         delegateAndReturn();
    }    

    /**
     * @dev user redeem mine rewards.
     * @  lp uniswap liquid pool address
     * @ amount redeem amount.
     */
    function redeemMineReward(address /*lp*/,uint256 /*amount*/) public {
        delegateAndReturn();
    }    
    

///////////////////////////////////////////////////////////////////////////////////
    function getTotalMined(address /*mineCoin*/) public view returns(uint256){
        delegateToViewAndReturn();
    }
    
    /**
     * @dev retrieve minecoin distributed informations.
     *  mineCoin mineCoin address
     * @return distributed amount and distributed time interval.
     */
    function getMineInfo(address /*mineCoin*/) public view returns(uint256,uint256){
        delegateToViewAndReturn();
    }
    
    /**
     * @dev retrieve user's mine balance.
     *  account user's account
     *  mineCoin mineCoin address
     */
    function getMinerBalance(address /*account*/,address /*mineCoin*/) public view returns(uint256){
        delegateToViewAndReturn();
    }
    
    /**
     * @dev retrieve liquid pool address
     * @return supported lp addresses
     */
    function getLpsAddress() public view returns( address[] memory) {
        delegateToViewAndReturn();
    }    
    
}