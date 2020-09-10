pragma solidity =0.5.16;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";

contract LPTokenWrapper {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    IERC20 public _lp;
    
    constructor (address lp) public{
        _lp = IERC20(lp);
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) external {
        _totalSupply = _totalSupply.add(amount);
        _balances[tx.origin] = _balances[tx.origin].add(amount);
        _lp.safeTransferFrom(tx.origin, address(this), amount);
    }

    function unstake (uint256 amount) external {
        _totalSupply = _totalSupply.sub(amount);
        _balances[tx.origin] = _balances[tx.origin].sub(amount);
        _lp.safeTransfer(tx.origin, amount);
    }
    
}