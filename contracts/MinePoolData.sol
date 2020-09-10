pragma solidity =0.5.16;

import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./Halt.sol";
import "./LPTokenWrapper.sol";

/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract MinePoolData is Ownable,Halt,ReentrancyGuard {
    
    //Special decimals for calculation
    uint256 constant calDecimals = 1e18;
    // miner's balance
    
    // map mineCoin => user => balance
    mapping(address=>mapping(address=>uint256)) internal minerBalances;
    // miner's origins, specially used for mine distribution
    // map mineCoin => user => balance
    mapping(address=>mapping(address=>uint256)) internal minerOriginWorthPerLpToken;
    
    // mine coins total worth, specially used for mine distribution
    mapping(address=>uint256) internal totalMinedWorth;
    // total distributed mine coin amount
    mapping(address=>uint256) internal totalMinedCoin;
    // latest time to settlement
    mapping(address=>uint256) internal latestSettleTime;
    
    //distributed mine amount per interval
    mapping(address=>uint256) internal mineAmountPerInterval;
    
    //distributed time interval
    mapping(address=>uint256) internal mineTimeInterval;
    

    //liquid pool address,uase array to support multi liquid pool
    mapping(address=>LPTokenWrapper) lpTokens;
    
    //the liquid pool status,enable or disable
    mapping(address=>bool) lpStatus;
    
    //the token address
    address[] lpAddress;
    
    //the mine token
    address mineToken;
    
    
    /**
     * @dev Emitted when `account` mint `amount` miner shares.
     */
    event MintMiner(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `account` burn `amount` miner shares.
     */
    event BurnMiner(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `from` redeem `value` mineCoins.
     */
    event RedeemMineCoin(address indexed from, address indexed mineCoin, uint256 value);
    /**
     * @dev Emitted when `from` transfer to `to` `amount` mineCoins.
     */
    event TranserMiner(address indexed from, address indexed to, uint256 amount);

    /**
     * @dev Emitted when user staking
     */
    event Staked(address lp, address indexed account,uint256 amount);

    /**
     * @dev Emitted when user stake out
     */    
   event Withdrawn(address lp, address indexed account,uint256 amount);    
    
    
}