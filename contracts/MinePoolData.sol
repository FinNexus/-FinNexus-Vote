pragma solidity =0.5.16;



/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract MinePoolData {
    
    //Special decimals for calculation
    uint256 constant calDecimals = 1e18;
    // miner's balance
    
    // map mineCoin => user => balance
    mapping(address=>uint256) internal minerBalances;
    // miner's origins, specially used for mine distribution
    // map mineCoin => user => balance
    mapping(address=>uint256) internal minerOriginWorthPerLpToken;
    
    // mine coins total worth, specially used for mine distribution
    uint256 internal totalMinedWorth;
    // total distributed mine coin amount
    uint256 internal totalMinedCoin;
    // latest time to settlement
    uint256 internal latestSettleTime;
    
    //distributed mine amount per interval
    uint256 internal mineAmountPerInterval;
    
    //distributed time interval
    uint256 internal mineTimeInterval;

    //the mine token
    address mineToken;
    
    uint256 internal totalsupply;
    
    mapping(address => uint256) internal balances;
    
    address internal lp;    
}