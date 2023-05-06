// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract VulnerableValout is ERC20 {
    constructor(uint256 initialSupply) ERC20("Asset", "A") {
        _mint(msg.sender, initialSupply);
    }
}