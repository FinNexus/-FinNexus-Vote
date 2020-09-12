pragma solidity =0.5.16;

import "./SafeMath.sol";
import "./MinePoolData.sol";
import "./IERC20.sol";
import "./LPTokenWrapper.sol";

/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract FNXMinePool is LPTokenWrapper {
    
    using SafeMath for uint256;

    //validate the address is correct
    modifier validateAddress(address addr) {
        require(addr != address(0),"lp is disabled");
        _;
    }

    event RedeemMineReward(address indexed from, address indexed mineCoin, uint256 value);
    event Staked(address lp, address indexed account,uint256 amount);
    event Unstaked(address lp, address indexed account,uint256 amount);  
//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////setting function/////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Set liquid pool mine info, only foundation owner can invoked.
     * @param liquidpool liquid pool address
     * @param mineTokenAddress mine token
     * @param mineAmount liquid pool distributed amount
     * @param mineInterval liquid pool distributied time interval
     */
    function setLpMineInfo(address liquidpool,address mineTokenAddress,uint256 mineAmount,uint256 mineInterval) 
                            validateAddress(liquidpool) 
                            validateAddress(mineTokenAddress) 
                            public onlyOwner {
                                
        require(mineAmount<1e30,"input mine amount is too large");
        require(mineInterval>0,"input mine Interval must larger than zero");
        
        lp = liquidpool;
        mineAmountPerInterval = mineAmount;
        mineTimeInterval = mineInterval;
        _mineSettlement();
    }
    

    /**
     * @dev changer mine coin distributed amount , only foundation owner can modify database.
     * @param mineAmount the distributed amount.
     */
    function setMineAmount(uint256 mineAmount)  public onlyOwner {
        require(mineAmount<1e30,"input mine amount is too large");
        
        _mineSettlement();
        mineAmountPerInterval = mineAmount;
    }
    
    
    /**
     * @dev changer liquid pool distributed time interval , only foundation owner can modify database.
     * @param mineInterval the distributed time interval.
     */
    function setMineInterval(uint256 mineInterval)  public onlyOwner {
        require(mineInterval>0,"input mine Interval must larger than zero");
        
        _mineSettlement();
        mineTimeInterval = mineInterval;
    }
    
    
    /**
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getBackLeftMiningToken(address reciever)  public onlyOwner {
        uint256 bal =  IERC20(mineToken).balanceOf(address(this));
        IERC20(mineToken).transfer(reciever,bal);
    }  
    
//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////public function//////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////    

     /**
     * @dev user stake in lp token
     * @param  amount stake in amout
     */
    function stake(uint256 amount) public {

        require(amount > 0, "Cannot stake 0");
        //need to offer mine token in advance
        //require(IERC20(mineToken).balanceOf(address(this)) > 0,"mine balance not set");

        //set user's intial networth for token
        _mineSettlement();
        _settleMinerBalance(msg.sender);
        super.stake(amount);

        emit Staked(lp,msg.sender, amount);
    }

    /**
     * @dev user  unstake to cancel mine
     * @param  amount stake in amout
     */
    function unstake(uint256 amount) public nonReentrant notHalted {
        require(amount > 0, "Cannot withdraw 0");
        
        _mineSettlement();
        _settleMinerBalance(msg.sender); 
        super.unstake(amount);
        
        emit Unstaked(lp,msg.sender, amount);
    }
    
    /**
     * @dev user redeem mine rewards.
     * @param amount redeem amount.
     */
    function redeemMineReward(uint256 amount) public  nonReentrant notHalted {
        require(amount > 0,"redeem amount should be bigger than 0");
        
        _mineSettlement();
        _settleMinerBalance(msg.sender);
        
        uint256 minerAmount = minerBalances[msg.sender];
        require(minerAmount>=amount,"miner balance is insufficient");

        minerBalances[msg.sender] = minerAmount.sub(amount);
               
        IERC20 minerToken = IERC20(mineToken);
        uint256 preBalance = minerToken.balanceOf(address(this));
        minerToken.transfer(msg.sender,amount);
        uint256 afterBalance = minerToken.balanceOf(address(this));
        require(preBalance.sub(afterBalance) == amount,"settlement token transfer error!");
        
        emit RedeemMineReward(msg.sender,lp,amount);
    }

//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////internal function////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev lp mine settlement.
     */    
    function _mineSettlement() internal {
        
        uint256 latestMined = getLatestMined();

        if (latestMined>0){
            totalMinedWorth = totalMinedWorth.add(latestMined.mul(calDecimals));
            totalMinedCoin = totalMinedCoin+latestMined;
        }
        
        latestSettleTime = now/mineTimeInterval*mineTimeInterval;

    }
    
  
    /**
     * @dev settle user's mint balance when user want to modify mine database.
     * @param account user's account
     */
    function _settleMinerBalance(address account) internal {
        uint256 tokenNetWorth = 0;
        uint256 total = super.totalSupply();
        
        if (total > 0){
            uint256 latestMined = getLatestMined();
            //the mined token per lp token
            tokenNetWorth = (totalMinedWorth.add(latestMined*calDecimals))/total;
            minerBalances[account] = minerBalances[account].add(_settlement(account,super.balanceOf(msg.sender),tokenNetWorth));
        }
        
        minerOriginWorthPerLpToken[account] = tokenNetWorth;
    }
  
    
    /**
     * @dev subfunction, settle user's latest mine amount.
     * @param account user's account
     * @param amount the input amount for operator
     * @param tokenNetWorth the latest token net worth
     */
    function _settlement(address account,uint256 amount,uint256 tokenNetWorth) internal view returns (uint256) {
        uint256 origin = minerOriginWorthPerLpToken[account];
        require(tokenNetWorth>=origin,"error: tokenNetWorth logic error!");
        return amount.mul(tokenNetWorth-origin)/calDecimals;
    }
         


//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////view function////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev retrieve total distributed mine coins.
     */
    function getTotalMined() public view returns(uint256){
        
        uint256 _totalSupply = super.totalSupply();
       
        if (_totalSupply > 0 && mineTimeInterval>0){
            uint256 latestMined = mineAmountPerInterval.mul(now-latestSettleTime)/mineAmountPerInterval;
            return totalMinedCoin.add(latestMined);
        }
        
        return totalMinedCoin;
    }
    
 
    
    /**
     * @dev retrieve liquid pool distributed informations.
     * @return distributed amount and distributed time interval.
     */
    function getMineInfo() public  view returns(uint256,uint256){
        return (mineAmountPerInterval,mineTimeInterval);
    }
    
    /**
     * @dev retrieve user's mine balance.
     * @param account user's account
     */
    function getMinerBalance(address account) public view returns(uint256){
        
        uint256 totalMineBalance = minerBalances[account];
        
        uint256 total = super.totalSupply();
        uint256 balance = super.balanceOf(account);
        
        if ( total > 0 && balance>0){
            
            uint256 latestMined = getLatestMined();
            //the mined token per lp token
            uint256 tokenNetWorth = (totalMinedWorth.add(latestMined*calDecimals))/total;
            totalMineBalance = totalMineBalance.add(_settlement(account,balance,tokenNetWorth));
        }
        
        return totalMineBalance;
    }
    
    /**
     * @dev retrieve liquid pool address
     * @return supported lp addresses
     */
    function getLpsAddress() public view returns(address){
        return lp;
    }    
    

    /**
     * @dev the auxiliary function for _mineSettlementAll. Calculate latest time phase distributied mine amount.
     */ 
    function getLatestMined()  internal view returns(uint256){
        
        uint256 total = super.totalSupply();
        
        if (total > 0 && mineTimeInterval>0){
            uint256 mintTime = (now - latestSettleTime)/mineTimeInterval;
            uint256 latestMined = mineAmountPerInterval*mintTime;
            return latestMined;
        }
        
        return 0;
    }
    
    /**
     * @dev subfunction, calculate token net worth when settlement is completed.
     */
    function getTokenNetWorth()internal view returns (uint256) {
        uint256 total = super.totalSupply();
        if (total > 0){
            return totalMinedWorth/total;
        }
        
        return 0;
    }   

}