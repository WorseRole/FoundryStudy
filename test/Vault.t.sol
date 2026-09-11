// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;

    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    function setUp() public {
        vault = new Vault();
        // 给测试账户发 ETH （默认地址余额是 0）
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_Deposit() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balances(alice), 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }

    function test_Withdraw() public {
        vm.prank(alice);
        vault.deposit{value: 2 ether}();

        uint256 beforeBal = alice.balance;

        vm.prank(alice);
        vault.withdraw(1 ether);

        assertEq(vault.balances(alice), 1 ether);
        assertEq(alice.balance, beforeBal + 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }

    function test_RevertIf_ZeroDeposit() public {
        vm.prank(alice);
        vm.expectRevert("Deposit amount must be greater than zero");
        vault.deposit{value: 0}();
    }

    function test_RevertIf_InsifficientBalance() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert("Insufficient balance");
        vault.withdraw(2 ether);
    }

    function test_IndependentBalances() public {
        vm.prank(alice);
        vault.deposit{value: 3 ether}();

        vm.prank(bob);
        vault.deposit{value: 1 ether}();

        vm.prank(alice);
        vault.withdraw(3 ether);

        // Alice 取完不影响 Bob 的余额
        assertEq(vault.balances(alice), 0);
        assertEq(vault.balances(bob), 1 ether);
        assertEq(address(vault).balance, 1 ether);
    }
}
