pragma solidity =0.5.16;

contract MinePoolData {
    
    address public fnx ;
    address public lp;

    address  public rewardDistribution;
    
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public rewardRate;
    uint256 public rewardInterval;
    
    uint256 public reward; //reward token number per duration
    uint256 public duration;
    
    mapping(address => uint256) public rewards;   
        
    mapping(address => uint256) public userRewardPerTokenPaid;
    
    //record the time for user getreward
    mapping(address => uint256) public userBeginRewardTime;
    
    //begin time for this rate
   uint256[] rewardPerTokenPeriodEnd;
   uint256[] periodFinishTimeRecord;

    
    uint256 public periodFinish;

    uint256 internal totalsupply;
    mapping(address => uint256) internal balances;
    
}