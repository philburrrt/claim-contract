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
    uint256 public maxSupply = 100000000 * 10e18;

    uint256 bootstrapSupply = 10000000 * 10e18;
    uint256 bootstrapCounter;

    uint256 teamSupply;
    uint256 teamCounter;

    uint256 treasurySupply;
    uint256 treasuryCounter;

    uint256 seedSupply;
    uint256 seedCounter;

    uint256 incentiveSupply;
    uint256 incentiveCounter;

    uint256 reservedSupply;
    uint256 reservedCounter;

    mapping(address => uint256) public claimed;
    address public signer;

    constructor(address _signer) ERC20("Metaverse", "META") {
        setSigner(_signer);
    }

    function setDistribution(
        uint256 _teamSupply,
        uint256 _treasurySupply,
        uint256 _seedSupply,
        uint256 _incentiveSupply,
        uint256 _reservedSupply
    ) public onlyOwner {
        teamSupply = _teamSupply;
        treasurySupply = _treasurySupply;
        seedSupply = _seedSupply;
        incentiveSupply = _incentiveSupply;
        reservedSupply = _reservedSupply;
    }

    function setSigner(address _signer) public {
        signer = _signer;
    }

    function bootstrapClaim(
        address to,
        uint256 amount,
        bytes memory signature
    ) public nonReentrant {
        bool verified = verify(signer, to, amount, signature);
        uint256 claimable = amount - claimed[to];
        require(verified, "Signature cannot be verified");
        require(claimable > 0, "Not enough tokens to claim");
        require(
            totalSupply() + claimable <= maxSupply,
            "Cannot exceed max supply"
        );
        require(
            bootstrapCounter + claimable <= bootstrapSupply,
            "Cannot exceed bootstrap supply"
        );
        if (incentiveSupply == 0) {}
        if (verified) {
            _mint(to, amount);
            claimed[to] = amount;
            bootstrapCounter += claimable;
        }
    }

    function incentiveClaim(
        address to,
        uint256 amount,
        bytes memory signature
    ) public nonReentrant {
        bool verified = verify(signer, to, amount, signature);
        uint256 claimable = amount - claimed[to];
        require(verified, "Signature cannot be verified");
        require(claimable > 0, "Not enough tokens to claim");
        require(
            totalSupply() + claimable <= maxSupply,
            "Cannot exceed max supply"
        );
        require(
            incentiveCounter + claimable <= incentiveSupply,
            "Cannot exceed incentive supply"
        );
        if (incentiveSupply == 0) {}
        if (verified) {
            _mint(to, amount);
            claimed[to] = amount;
            incentiveCounter += claimable;
        }
    }

    function teamMint(address[] memory _to, uint256[] memory _amount)
        public
        onlyOwner
    {
        require(_to.length == _amount.length, "Invalid input");
        for (uint256 i = 0; i < _to.length; i++) {
            _mint(_to[i], _amount[i]);
        }
    }

    function seedMint(address[] memory _to, uint256[] memory _amount)
        public
        onlyOwner
    {
        require(_to.length == _amount.length, "Invalid input");
        for (uint256 i = 0; i < _to.length; i++) {
            _mint(_to[i], _amount[i]);
        }
    }

    function treasuryMint(address[] memory _to, uint256[] memory _amount)
        public
        onlyOwner
    {
        require(_to.length == _amount.length, "Invalid input");
        for (uint256 i = 0; i < _to.length; i++) {
            _mint(_to[i], _amount[i]);
        }
    }

    function reservedMint(address[] memory _to, uint256[] memory _amount)
        public
        onlyOwner
    {
        require(_to.length == _amount.length, "Invalid input");
        for (uint256 i = 0; i < _to.length; i++) {
            _mint(_to[i], _amount[i]);
        }
    }

    function pause() public onlyOwner {
        _pause();
    }
}
