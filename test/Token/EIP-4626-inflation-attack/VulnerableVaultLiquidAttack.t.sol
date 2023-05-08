// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Token/EIP-4626-inflation-attack/Asset.sol";
import "src/Token/EIP-4626-inflation-attack/Vault.sol";
import "src/Token/EIP-4626-inflation-attack/VulnerableVault.sol";

contract Attack is Test {
    // Mittigationwith liquidity
    address liquidityProvider = 0x1c738175d6391321D2eE5746f22A1Eb01117bd3E;
    address alice = 0x83563f56957D039abB72C679aD277F0CB1f720Ef;
    address bob = 0xaFfa4F2906fb9315331943837773d19bC0804601;

    IERC20 asset;
    IERC4626 vault;

    function setUp() public {
        asset = new Asset(100003 ether);
        vault = new VulnerableVault(asset);
        asset.transfer(bob, 2 ether);
        asset.transfer(alice, 1 ether);

        // Mint inital liquidity
        asset.approve(address(vault), 100000 ether);
        vault.deposit(100000 ether, liquidityProvider);
    }

    function test_TheAttackCanBeMitigatedWithEnoughtLiquidityInTheVault() public {
        console.log("Initial Bob asset balance", asset.balanceOf(bob));
        console.log("Initial Alice asset balance", asset.balanceOf(alice));

        // Alice check the price
        console.log("Price that Alice sees:", vault.convertToShares(1 ether));

        /* Front Running tx */
        vm.startPrank(bob);

        // Bob deposits 1 wei of asset
        asset.approve(address(vault), 1 ether);
        vault.deposit(1 wei, bob);
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
