// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Token/EIP-4626-inflation-attack/Asset.sol";
import "src/Token/EIP-4626-inflation-attack/Vault.sol";
import "src/Token/EIP-4626-inflation-attack/VulnerableVault.sol";

contract Attack is Test {
    // Mittigation with higher precision in shares decimals

    address alice = 0x83563f56957D039abB72C679aD277F0CB1f720Ef;
    address bob = 0xaFfa4F2906fb9315331943837773d19bC0804601;

    ERC20 asset;
    ERC4626 vault;

    function setUp() public {
        asset = new Asset(3 ether);
        vault = new Vault(asset);
        asset.transfer(bob, 2 ether);
        asset.transfer(alice, 1 ether);
    }

    function test_TheAttackCanBeMitigatedWithAHigherPrecisionInSharesDecimals() public {
        console.log("asset decimals", asset.decimals());
        console.log("asset decimals", vault.decimals());
        console.log("Initial Bob asset balance", asset.balanceOf(bob));
        console.log("Initial Alice asset balance", asset.balanceOf(alice));

        // Alice check the price
        console.log("Price that Alice sees:", vault.convertToShares(1 ether));

        /* Front Running tx */
        vm.startPrank(bob);

        // Bob deposits 1 wei of asset
        asset.approve(address(vault), 1);
        vault.deposit(1, bob);
        // Bob donates 1 token asset (1e18 wei) to manipulate the price of the share
        asset.transfer(address(vault), 1 ether);
        console.log("Price after bob manipulation", vault.convertToShares(1 ether));

        vm.stopPrank();

        /* Front Runned tx */
        vm.startPrank(alice);

        // Alice deposit
        asset.approve(address(vault), 1 ether);
        vault.deposit(1 ether, alice);

        vm.stopPrank();

        /* Bob drains all assets from the contract */
        vm.startPrank(bob);

        vault.redeem(vault.balanceOf(bob), bob, bob);

        vm.stopPrank();

        /* Alice redeem*/
        vm.startPrank(alice);

        vault.redeem(vault.balanceOf(alice), alice, alice);

        vm.stopPrank();

        console.log("Final Bob asset balance", asset.balanceOf(bob));
        console.log("Final Alice asset balance", asset.balanceOf(alice));
    }
}
