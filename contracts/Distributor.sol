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
    uint256 public balance;
    mapping(address => uint256) public claimed;
    IERC20 token;

    constructor(address _signer, address _token) {
        setSigner(_signer);
        token = IERC20(_token);
    }

    function setSigner(address _signer) public {
        signer = _signer;
    }

    function setToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function refill(uint256 _amount) public onlyOwner {
        token.transferFrom(msg.sender, address(this), _amount);
        balance += _amount;
    }

    function claim(
        address to,
        uint256 amount,
        bytes calldata signature
    ) public nonReentrant whenNotPaused {
        bool verified = verify(signer, to, amount, signature);
        uint256 claimable = amount - claimed[to];
        require(verified, "Signature cannot be verified");
        require(claimable > 0, "Not enough tokens to claim");
        if (verified) {
            token.transfer(to, claimable);
            claimed[to] = amount;
            balance -= claimable;
        }
    }
}
