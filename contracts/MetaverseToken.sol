// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaverseToken is ERC20, Ownable {
    uint256 public maxSupply = 100000000e18;

    uint256 public bootstrapSupply = 10000000e18;
    uint256 public bootstrapCounter;

    uint256 public teamSupply;
    uint256 public teamCounter;

    uint256 public treasurySupply;
    uint256 public treasuryCounter;

    uint256 public seedSupply;
    uint256 public seedCounter;

    uint256 public reservedSupply;
    uint256 public reservedCounter;

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
        for (uint256 i = 0; i < to.length; i++) {
            require(
                bootstrapCounter + amount[i] <= bootstrapSupply,
                "Bootstrap supply reached"
            );
            bootstrapCounter += amount[i];
            _mint(to[i], amount[i]);
        }
    }

    function devMint(
        address[] calldata to,
        uint256[] calldata amount,
        string[] calldata option
    ) public onlyOwner {
        require(distributionSet, "Distribution has not been set");
        require(to.length == amount.length, "Invalid input");
        require(to.length == option.length, "Invalid input");
        for (uint256 i = 0; i < to.length; i++) {
            if (
                keccak256(abi.encodePacked(option[i])) ==
                keccak256(abi.encodePacked("team"))
            ) {
                require(
                    teamCounter + amount[i] <= teamSupply,
                    "Cannot exceed team supply"
                );
                _mint(to[i], amount[i]);
                teamCounter += amount[i];
            } else if (
                keccak256(abi.encodePacked(option[i])) ==
                keccak256(abi.encodePacked("treasury"))
            ) {
                require(
                    treasuryCounter + amount[i] <= treasurySupply,
                    "Cannot exceed treasury supply"
                );
                _mint(to[i], amount[i]);
                treasuryCounter += amount[i];
            } else if (
                keccak256(abi.encodePacked(option[i])) ==
                keccak256(abi.encodePacked("seed"))
            ) {
                require(
                    seedCounter + amount[i] <= seedSupply,
                    "Cannot exceed seed supply"
                );
                _mint(to[i], amount[i]);
                seedCounter += amount[i];
            } else if (
                keccak256(abi.encodePacked(option[i])) ==
                keccak256(abi.encodePacked("reserved"))
            ) {
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
