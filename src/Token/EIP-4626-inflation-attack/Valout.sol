// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract Valout is ERC4626 {
    constructor(IERC20 asset) ERC20("Share", "S") ERC4626(asset) {}

    function _decimalsOffset() internal pure override returns (uint8) {
        return 18;
    }
}
