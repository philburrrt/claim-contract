// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./VerifySig.sol";

contract MetaverseToken is
    ERC20,
    Pausable,
    Ownable,
    VerifySig,
    ReentrancyGuard
{
    mapping(address => uint256) public claimed;
    address public signer;

    constructor() ERC20("Metaverse", "META") {
        setSigner(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }

    // Claim function needs to know:
    // - the address of the account to claim
    // - the amount of tokens to claim
    // - the signature of the message hash
    // - the signer of the message hash

    function setSigner(address _signer) public {
        signer = _signer;
    }

    function claim(
        address to,
        uint256 amount,
        bytes memory signature
    ) public nonReentrant {
        bool verified = verify(signer, to, amount, signature);
        uint256 claimable = amount - claimed[to];
        require(verified, "Signature cannot be verified");
        require(claimable > 0, "Not enough tokens to claim");
        if (verified) {
            _mint(to, amount);
        }
    }
}
