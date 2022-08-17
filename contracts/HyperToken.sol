// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HyperToken is ERC20, Pausable, Ownable {

    uint256 public constant maxSupply = 1000000e18;
    uint256 public constant teamSupply = 200000e18;
    uint256 public constant incentiveSupply = 400000e18;
    uint256 public constant reserveSupply = 400000e18;
    uint256 public reserveUsed = 0;

    bool public devMintPaused = false;


    constructor() ERC20("Hyperfy", "HYPER") {
    }

    function pauseDevMint() public onlyOwner{
        devMintPaused = true;
    }

    function resumeDevMint() public onlyOwner{
        devMintPaused = false;
    }

    function devMint(address to, uint256 quantity) public onlyOwner{
        require(!devMintPaused, "Dev minting is paused");
        require((totalSupply() + quantity) <= reserveSupply, "Not enough tokens available");
        require((reserveUsed + quantity) <= reserveSupply, "Not enough tokens available");
        _mint(to, quantity);
        reserveUsed += quantity;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}