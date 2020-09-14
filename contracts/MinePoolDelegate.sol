pragma solidity ^0.5.16;

import "./Math.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./LPTokenWrapper.sol";
import "./Halt.sol";


contract MinePoolDelegate is LPTokenWrapper {

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;     
            userBeginRewardTime[account] = now;
        }
        _;
    }

    function setPoolMineAddress(address _liquidpool,address _fnxaddress) public onlyOwner{
        require(_liquidpool != address(0));
        require(_fnxaddress != address(0));
        
        lp  = _liquidpool;
        fnx = _fnxaddress;
    }
    
    function setMineRate(uint256 _reward,uint256 _duration) public onlyOwner updateReward(address(0)) {
        require(_reward>0);
        require(_duration>0);
        //only passed finsh time,the rate can be changed
        require(now > periodFinish);
        
        //token number per seconds
        rewardRate = _reward.div(_duration);
        require(rewardRate > 0);
        
        lastUpdateTime = now;        
        reward = _reward;
        duration = _duration;
    }   
    
    function setPeriodFinish(uint256 _periodfinish) public onlyOwner {
        //the setting time must pass timebeing
        require(_periodfinish > now);
        
        //record last period data
        if (periodFinish > 0) {
            uint256 idx = periodFinishTimeRecord.length;
            if( idx > 0 &&
                periodFinishTimeRecord[idx-1] > _periodfinish) 
            {
                rewardPerTokenPeriodEnd[idx] = rewardPerToken();
                periodFinishTimeRecord[idx] = _periodfinish;
            } else {
                rewardPerTokenPeriodEnd.push(rewardPerToken());
                periodFinishTimeRecord.push(periodFinish);
            }
        }
        
        //set new finish time
        periodFinish = _periodfinish;

    }  
    
    /**
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getbackLeftMiningToken(address reciever)  public onlyOwner {
        uint256 bal =  IERC20(fnx).balanceOf(address(this));
        IERC20(fnx).transfer(reciever,bal);
    }  
        
//////////////////////////public function/////////////////////////////////    

    function lastTimeRewardApplicable() public view returns(uint256) {
         return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns(uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        
        return rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(totalSupply())
        );
    }

    function earned(address account) public view returns(uint256) {
        return balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) notHalted nonReentrant {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public updateReward(msg.sender) notHalted nonReentrant {
        require(amount > 0, "Cannot withdraw 0");
        super.unstake(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() public notHalted nonReentrant {
        super.unstake(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) notHalted nonReentrant {
        uint256 reward = 0;
        if (userBeginRewardTime[msg.sender] < lastUpdateTime) {
            reward = getHistoryReward();
        } 
        reward = reward.add(earned(msg.sender));
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IERC20(fnx).transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

 
    function getHistoryReward() internal view returns(uint256) {
         uint256 i;
         uint256 reward = 0;
            
         for (i=0; i<periodFinishTimeRecord.length-1; i++) {
             if (userBeginRewardTime[msg.sender] > periodFinishTimeRecord[i]) {
                 break;
             }
         }
         
         //use next finsh data
         i++;
         reward = reward.add(balanceOf(msg.sender).mul(rewardPerTokenPeriodEnd[i].sub(userRewardPerTokenPaid[msg.sender])).div(1e18)); 
         i++; 
         //caculate rest
         for (;i<periodFinishTimeRecord.length; i++) {
             reward = reward.add(balanceOf(msg.sender).mul(rewardPerTokenPeriodEnd[i]).div(1e18)); 
         }
          
          return reward;
         
      }       
   
}
