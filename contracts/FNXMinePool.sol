pragma solidity =0.5.16;

import "./SafeMath.sol";
import "./MinePoolData.sol";
import "./IERC20.sol";

/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract FNXMinePool is MinePoolData {
    
    using SafeMath for uint256;
    
    //verify the lp is enabled or disabled
    modifier isEnabled(address lp) {
        require(lpStatus[lp],"lp is disabled");
        _;
    }
    
    //validate the address is correct
    modifier validateAddress(address addr) {
        require(addr != address(0),"lp is disabled");
        _;
    }
        

//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////setting function/////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Set liquid pool mine info, only foundation owner can invoked.
     * @param lp liquid pool address
     * @param mineAmount liquid pool distributed amount
     * @param mineInterval liquid pool distributied time interval
     */
    function setLpMineInfo(address lp,uint256 mineAmount,uint256 mineInterval) public onlyOwner {
        require(mineAmount<1e30,"input mine amount is too large");
        require(mineInterval>0,"input mine Interval must larger than zero");
        require(!lpStatus[lp],"lp token is already set");
        
        _mineSettlement(lp);
        
        mineAmountPerInterval[lp] = mineAmount;
        mineTimeInterval[lp] = mineInterval;
        
        lpTokens[lp] = LPTokenWrapper(lp);
        lpStatus[lp] = true;
        lpAddress.push(lp);
    }
    

    /**
     * @dev disable liquid pool mine info, only foundation owner can invoked.
     * @param lp liquid pool address
     */    
    function disableLp(address lp) public onlyOwner {
         lpStatus[lp] = false;
    }
 
    /**
     * @dev changer mine coin distributed amount , only foundation owner can modify database.
     * @param lp liquid pool mine coin address
     * @param mineAmount the distributed amount.
     */
    function setMineAmount(address lp,uint256 mineAmount)  public isEnabled(lp) onlyOwner {
        require(mineAmount<1e30,"input mine amount is too large");
        
        _mineSettlement(lp);
        mineAmountPerInterval[lp] = mineAmount;
    }
    
    
    /**
     * @dev changer liquid pool distributed time interval , only foundation owner can modify database.
     * @param  lp uniswap liquid pool address
     * @param mineInterval the distributed time interval.
     */
    function setMineInterval(address lp,uint256 mineInterval)  public isEnabled(lp) onlyOwner {
        require(mineInterval>0,"input mine Interval must larger than zero");
        _mineSettlement(lp);
        mineTimeInterval[lp] = mineInterval;
    }
    
    /**
     * @dev set mine token address
     * @param mineTokenAddress the mined token address
     */
    function setMineTokenAddress(address mineTokenAddress)  public  validateAddress(mineTokenAddress) onlyOwner {
        mineToken = mineTokenAddress;
    }    
    
//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////public function////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////    

     /**
     * @dev user stake in lp token
     * @param  lp uniswap liquid pool address
     * @param  amount stake in amout
     */
    function stake(address lp,uint256 amount) public isEnabled(lp) validateAddress(lp) {
        require(amount > 0, "Cannot stake 0");

        //set user's intial networth for token    
        _mineSettlement(lp);
        _settleMinerBalance(lp,msg.sender);
        
        lpTokens[lp].stake(amount);
        
        emit Staked(lp,msg.sender, amount);
    }

    /**
     * @dev user  unstake to cancel mine
     * @param  lp uniswap liquid pool address
     * @param  amount stake in amout
     */
    function unstake(address lp,uint256 amount) public validateAddress(lp)  nonReentrant notHalted {
        require(amount > 0, "Cannot withdraw 0");
        
        _mineSettlement(lp);
        _settleMinerBalance(lp,msg.sender);        
        
        lpTokens[lp].unstake(amount);
        emit Withdrawn(lp,msg.sender, amount);
    }
    
    /**
     * @dev user redeem mine rewards.
     * @param  lp uniswap liquid pool address
     * @param amount redeem amount.
     */
    function redeemMineReward(address lp,uint256 amount) public  nonReentrant notHalted {
        
        require(lp != address(0),"lp address is not correct");
        require(amount > 0,"redeem amount should be bigger than 0");
        require(lpTokens[lp].balanceOf(msg.sender) > 0);
        
        _mineSettlement(lp);
        _settleMinerBalance(lp,msg.sender);
        
        uint256 minerAmount = minerBalances[lp][msg.sender];
        require(minerAmount>=amount,"miner balance is insufficient");

        minerBalances[lp][msg.sender] = minerAmount.sub(amount);
               
        IERC20 minerToken = IERC20(mineToken);
        uint256 preBalance = minerToken.balanceOf(address(this));
        minerToken.transfer(msg.sender,amount);
        uint256 afterBalance = minerToken.balanceOf(address(this));
        require(preBalance.sub(afterBalance) == amount,"settlement token transfer error!");
        
        emit RedeemMineCoin(msg.sender,lp,amount);
    }

//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////internal function////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev lp mine settlement.
     */    
    function _mineSettlement(address lp) internal {
        
        uint256 latestMined = getLatestMined(lp);
        uint256 _mineInterval = mineTimeInterval[lp];
        
        if (latestMined>0){
            totalMinedWorth[lp] = totalMinedWorth[lp].add(latestMined.mul(calDecimals));
            totalMinedCoin[lp] = totalMinedCoin[lp]+latestMined;
        }
        
        if (_mineInterval>0){
            latestSettleTime[lp] = now/_mineInterval*_mineInterval;
        }else{
            latestSettleTime[lp] = now;
        }
        
    }
    
  
    /**
     * @dev settle user's mint balance when user want to modify mine database.
     * @param lp uniswap liquid pool address
     * @param account user's account
     */
    function _settleMinerBalance(address lp,address account) internal {
        
        uint256 _totalSupply = totalSupply(lp);
        uint256 tokenNetWorth = 0;
        
        if (_totalSupply > 0){
            
            tokenNetWorth = totalMinedWorth[lp]/_totalSupply;
            
            minerBalances[lp][account] = minerBalances[lp][account].add(_settlement(lp,account,balanceOf(mineToken,account),tokenNetWorth));
        }

        minerOriginWorthPerLpToken[lp][account] = tokenNetWorth;
    }
  
    
    /**
     * @dev subfunction, settle user's latest mine amount.
     * @param lp uniswap liquid pool address
     * @param account user's account
     * @param amount the input amount for operator
     * @param tokenNetWorth the latest token net worth
     */
    function _settlement(address lp,address account,uint256 amount,uint256 tokenNetWorth) internal view returns (uint256) {
        uint256 origin = minerOriginWorthPerLpToken[lp][account];
        require(tokenNetWorth>=origin,"error: tokenNetWorth logic error!");
        return amount.mul(tokenNetWorth-origin)/calDecimals;
    }
         


//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////view function////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev retrieve total distributed mine coins.
     * @param  lp uniswap liquid pool address
     */
    function getTotalMined(address lp) public view returns(uint256){
        
        uint256 _totalSupply = totalSupply(lp);
        uint256 _mineInterval = mineTimeInterval[lp];
        
        if (_totalSupply > 0 && _mineInterval>0){
            uint256 _mineAmount = mineAmountPerInterval[lp];
            uint256 latestMined = _mineAmount.mul(now-latestSettleTime[lp])/_mineInterval;
            return totalMinedCoin[lp].add(latestMined);
        }
        
        return totalMinedCoin[lp];
    }
    
    /**
     * @dev retrieve liquid pool distributed informations.
     * @param  lp uniswap liquid pool address
     * @return distributed amount and distributed time interval.
     */
    function getMineInfo(address lp) public  isEnabled(lp) view returns(uint256,uint256){
        return (mineAmountPerInterval[lp],mineTimeInterval[lp]);
    }
    
    /**
     * @dev retrieve user's mine balance.
     * @param account user's account
     * @param  lp uniswap liquid pool address
     */
    function getMinerBalance(address account,address lp) public view returns(uint256){
        
        uint256 totalBalance = minerBalances[lp][account];
        
        uint256 _totalSupply = totalSupply(lp);
        //the balance in lp
        uint256 balance = balanceOf(lp,account);
        
        if (_totalSupply > 0 && balance>0){
            
            uint256 latestMined = getLatestMined(lp);
            
            //the mined token per lp token
            uint256 tokenNetWorth = (totalMinedWorth[lp].add(latestMined*calDecimals))/_totalSupply;
            
            totalBalance= totalBalance.add(_settlement(lp,account,balance,tokenNetWorth));
        }
        
        return totalBalance;
    }
    
    /**
     * @dev retrieve liquid pool address
     * @return supported lp addresses
     */
    function getLpsAddress() public view returns( address[] memory){
        return lpAddress;
    }    
    

    /**
     * @dev the auxiliary function for _mineSettlementAll. Calculate latest time phase distributied mine amount.
     */ 
    function getLatestMined(address lp)  internal view returns(uint256){
        
        uint256 _mineInterval = mineTimeInterval[lp];
        uint256 _totalSupply = totalSupply(lp);
        
        if (_totalSupply > 0 && _mineInterval>0){
            uint256 _mineAmount = mineAmountPerInterval[lp];
            
            uint256 mintTime = (now - latestSettleTime[lp])/_mineInterval;
            uint256 latestMined = _mineAmount*mintTime;
            
            return latestMined;
        }
        
        return 0;
    }
    

    /**
     * @dev get lptokens total supply.
     */
    function totalSupply(address lptoken) internal view returns(uint256){
        IERC20 token = IERC20(lptoken);
        return token.totalSupply();
    }
    
    /**
     * @dev get FPTCoin's user balance.
     */
    function balanceOf(address lptoken, address account) internal view returns(uint256){
        IERC20 token = IERC20(lptoken);
        return token.balanceOf(account);
    }
    
    
    
    
}