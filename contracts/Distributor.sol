// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./VerifySig.sol";

contract Distributor is Pausable, Ownable, VerifySig, ReentrancyGuard {
    mapping(address => uint256) public claimed;
    address public signer;
    address public tokenAddr;
    IERC20 public token;

    constructor(address _signer, address _tokenAddr) {
        setSigner(_signer);
        setToken(_tokenAddr);
    }

    function setToken(address _tokenAddr) public onlyOwner {
        tokenAddr = _tokenAddr;
        token = IERC20(_tokenAddr);
    }

    function setSigner(address _signer) public {
        signer = _signer;
    }

    function bootstrapClaim(
        address to,
        uint256 amount,
        bytes calldata signature
    ) public nonReentrant whenNotPaused {
        bool verified = verify(signer, to, amount, signature);
        uint256 claimable = amount - claimed[to];
        require(verified, "Signature cannot be verified");
        require(claimable > 0, "Not enough tokens to claim");
        require(
            claimable <= token.balanceOf(address(this)),
            "Claim exceeds contract balance"
        );
        if (verified) {
            token.transferFrom(address(this), to, claimable);
            claimed[to] = amount;
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
