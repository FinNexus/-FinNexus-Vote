pragma solidity ^0.5.16;

import "./openzeppelin/contracts/math/Math.sol";
import "./openzeppelin/contracts/math/SafeMath.sol";

import "./openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./LPTokenWrapper.sol";
import "./Halt.sol";


contract MinePoolDelegate is LPTokenWrapper,Halt {


    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }


    function setMineInfo(address liquidpool,
                         address fnxaddress, 
                         uint256 reward,
                         uint256 rewardinterval
                         ) 
             public             
             onlyOwner
    {
        require(liquidpool != address(0));
        require(fnxaddress != address(0));
        
        lp  = IERC20(liquidpool);
        fnx = IERC20(fnxaddress);
        
        //token number per seconds
        rewardRate = reward.div(rewardInterval);
        rewardInterval = rewardinterval;
        
        lastUpdateTime = block.timestamp;
    }
    
    function setMineRate(uint256 reward,uint256 rewardinterval) external onlyOwner {
        require(reward>0);
        require(rewardinterval>0);
        
        //token number per seconds
        rewardRate = reward.div(rewardInterval);
        require(rewardRate > 0);
        
        rewardInterval = rewardinterval;
    }   
    
    function setPeriodFinish(uint256 periodfinish) external onlyOwner {
        require(periodfinish > now);
        periodFinish = periodfinish;
    }  
    
    /**
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getbackLeftMiningToken(address reciever)  public onlyOwner {
        uint256 bal =  fnx.balanceOf(address(this));
        fnx.transfer(reciever,bal);
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
        return balanceOf(account).mul(
            rewardPerToken().sub(userRewardPerTokenPaid[account])
        ).div(1e18).add(rewards[account]);
    }

    function stake(uint256 amount) public updateReward(msg.sender) notHalted {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public updateReward(msg.sender) notHalted {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() public notHalted {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) notHalted {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            fnx.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

}
