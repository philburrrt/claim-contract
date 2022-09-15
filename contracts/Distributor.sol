// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./VerifySig.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Distributor is Pausable, VerifySig, ReentrancyGuard, Ownable {
    address public signer;
    uint256 public used;
    uint256 public rewardForPd;
    mapping(address => uint256) public claimed;
    IERC20 token;

    constructor(address _signer, address _token) {
        setSigner(_signer);
        token = IERC20(_token);
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function setToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function refill(uint256 _amount) public onlyOwner {
        token.transferFrom(msg.sender, address(this), _amount);
        rewardForPd += _amount;
        delete used;
    }

    function claim(
        address _to,
        uint256 _amount,
        bytes calldata _signature
    ) public nonReentrant whenNotPaused {
        require(_amount + used <= rewardForPd, "Not enough reward");
        bool verified = verify(signer, _to, _amount, _signature);
        uint256 claimable = _amount - claimed[_to];
        require(verified, "Signature cannot be verified");
        require(claimable > 0, "You have claimed all owed tokens");
        if (verified) {
            token.transfer(_to, claimable);
            claimed[_to] = _amount;
            used += claimable;
        }
    }
}
