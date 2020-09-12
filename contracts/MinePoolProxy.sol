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
     * @dev Set liquid pool mine info, only foundation owner can invoked.
     * @ liquidpool liquid pool address
     * @ mineTokenAddress mine token
     * @ mineAmount liquid pool distributed amount
     * @ mineInterval liquid pool distributied time interval
     */
    function setLpMineInfo(address /*liquidpool*/,address /*mineTokenAddress*/,uint256 /*mineAmount*/,uint256 /*mineInterval*/) public {
        delegateAndReturn();
    }

    /**
     * @dev changer mine coin distributed amount , only foundation owner can modify database.
     * @ mineAmount the distributed amount.
     */
    function setMineAmountPerInterval(uint256 /*mineAmount*/)  public {
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
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getBackLeftMiningToken(address reciever)  public {
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
     * @return distributed amount and distributed time interval.
     */
    function getMineInfo() public view returns(uint256,uint256){
        delegateToViewAndReturn();
    }
    
    /**
     * @dev retrieve user's mine balance.
     *  account user's account
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

    /**
     * @dev retrieve user's stake balance.
     *  account user's account
     */
    function getStakeBalance(address /*account*/) public view returns(uint256) {
        delegateToViewAndReturn();
    }
    
}