pragma solidity =0.5.16;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./MinePoolData.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./Halt.sol";
import "./IERC20.sol";

contract LPTokenWrapper is MinePoolData,Ownable,Halt,ReentrancyGuard {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    function totalSupply() public view returns(uint256) {
        return totalsupply;
    }

    function balanceOf(address account) public view returns(uint256) {
        return balances[account];
    }

    function stake(uint256 amount) public {
        totalsupply = totalsupply.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        IERC20(lp).safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake (uint256 amount) public {
        totalsupply = totalsupply.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        IERC20(lp).safeTransfer(msg.sender, amount);
    }
    
}