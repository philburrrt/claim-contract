// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./VerifySig.sol";

contract MetaverseToken is
    ERC20,
    Ownable,
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

    uint256 reservedSupply;
    uint256 reservedCounter;

    bool distributionSet;

    constructor() ERC20("HyperfyToken", "HYPER") {}

    function setDistribution(
        uint256 _teamSupply,
        uint256 _treasurySupply,
        uint256 _seedSupply,
        uint256 _reservedSupply
    ) public onlyOwner {
        teamSupply = _teamSupply;
        treasurySupply = _treasurySupply;
        seedSupply = _seedSupply;
        reservedSupply = _reservedSupply;
        distributionSet = true;
    }

    function bootstrapMint(address[] calldata to, uint256[] calldata amount)
        public
        onlyOwner
    {
        require(to.length == amount.length, "Invalid input");
        for (uint256 i = 0; i < to.length; i++) {
            require(
                bootstrapCounter + amount[i] <= bootstrapSupply,
                "Cannot exceed bootstrap supply"
            );
            _mint(to[i], amount[i]);
            bootstrapCounter += amount[i];
        }
    }

    function devMint(
        address[] calldata to,
        uint256[] calldata amount,
        string calldata option
    ) public onlyOwner {
        require(distributionSet, "Distribution has not been set");
        require(to.length == amount.length, "Invalid input");
        if (
            keccak256(abi.encodePacked(option)) ==
            keccak256(abi.encodePacked("team"))
        ) {
            for (uint256 i = 0; i < to.length; i++) {
                require(
                    teamCounter + amount[i] <= teamSupply,
                    "Cannot exceed team supply"
                );
                _mint(to[i], amount[i]);
                teamCounter += amount[i];
            }
        } else if (
            keccak256(abi.encodePacked(option)) ==
            keccak256(abi.encodePacked("treasury"))
        ) {
            for (uint256 i = 0; i < to.length; i++) {
                require(
                    treasuryCounter + amount[i] <= treasurySupply,
                    "Cannot exceed treasury supply"
                );
                _mint(to[i], amount[i]);
                treasuryCounter += amount[i];
            }
        } else if (
            keccak256(abi.encodePacked(option)) ==
            keccak256(abi.encodePacked("seed"))
        ) {
            for (uint256 i = 0; i < to.length; i++) {
                require(
                    seedCounter + amount[i] <= seedSupply,
                    "Cannot exceed seed supply"
                );
                _mint(to[i], amount[i]);
                seedCounter += amount[i];
            }
        } else if (
            keccak256(abi.encodePacked(option)) ==
            keccak256(abi.encodePacked("reserved"))
        ) {
            for (uint256 i = 0; i < to.length; i++) {
                require(
                    reservedCounter + amount[i] <= reservedSupply,
                    "Cannot exceed reserved supply"
                );
                _mint(to[i], amount[i]);
                reservedCounter += amount[i];
            }
        }
    }
}
