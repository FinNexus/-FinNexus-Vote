pragma solidity ^0.5.16;
import "./openzeppelin/contracts/math/Math.sol";
import "./openzeppelin/contracts/math/SafeMath.sol";
import "./openzeppelin/contracts/ownership/Ownable.sol";
import "./openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./MinePoolData.sol";

contract LPTokenWrapper is MinePoolData {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lp.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lp.safeTransfer(msg.sender, amount);
    }
}
