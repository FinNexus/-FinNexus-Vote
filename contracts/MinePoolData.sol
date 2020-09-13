pragma solidity =0.5.16;
import "./openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract MinePoolData {
    
    IERC20  public fnx ;
    IERC20  public lp;
    address public rewardDistribution;
    
    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;  

    uint256 public DURATION = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public rewardRate;
    uint256 public rewardInterval;
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;    
    
    uint256 public periodFinish = uint256(-1);
    
}