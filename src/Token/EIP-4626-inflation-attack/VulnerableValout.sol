// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC4626-release-v4-8.sol";

contract VulnerableValout is ERC4626Vul {
    constructor(IERC20 asset) ERC20("Share", "S") ERC4626Vul(asset) {}
}
