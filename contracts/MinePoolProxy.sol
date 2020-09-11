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
     *  _mineAmount mineCoin distributed amount
     *  _mineInterval mineCoin distributied time interval
     */
    function setLpMineInfo(uint256 /*_mineAmount*/,uint256 /*_mineInterval*/)public {
        delegateAndReturn();
    }


    /**
     * @dev changer mine coin distributed amount , only foundation owner can modify database.
     * @ mineAmount the distributed amount.
     */
    function setMineAmount(uint256 /*mineAmount*/)  public {
        delegateAndReturn();
    }    
    
    
    /**
     * @dev changer liquid pool distributed time interval , only foundation owner can modify database.
     * @  mineInterval the distributed time interval.
     */
    function setMineInterval(uint256 /*mineInterval*/) public {
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
    function stake(uint256 /*amount*/) public {
         delegateAndReturn();
    }  
    
    
   /**
     * @dev user  unstake to cancel mine
     * @  lp uniswap liquid pool address
     * @  amount stake in amout
     */
    function unstake(uint256 /*amount*/) public {
         delegateAndReturn();
    }    

    /**
     * @dev user redeem mine rewards.
     * @  lp uniswap liquid pool address
     * @ amount redeem amount.
     */
    function redeemMineReward(uint256 /*amount*/) public {
        delegateAndReturn();
    }    
    

///////////////////////////////////////////////////////////////////////////////////
    function getTotalMined() public view returns(uint256){
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
    function getMinerBalance(address /*account*/) public view returns(uint256){
        delegateToViewAndReturn();
    }
    
    /**
     * @dev retrieve liquid pool address
     * @return supported lp addresses
     */
    function getLpsAddress() public view returns( address) {
        delegateToViewAndReturn();
    }    
    
}