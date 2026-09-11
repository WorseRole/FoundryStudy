// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/VaultVunlnerable.sol";
import "../src/Vault.sol";
import "../src/Attacker.sol";

contract ReentrancyTest is Test {
    // ------------ 测试1：针对不安全 Vault 的重入攻击 ------------
    function test_Reentrancy_DrainsVulnerableVault() public {
        VaultVunlnerable vault = new VaultVunlnerable();
        AttackerVulnerable attacker = new AttackerVulnerable(vault);

        // 先给测试合约发 10 ether
        vm.deal(address(this), 10 ether);
        // 给 Vault 里先放【别的用户】 的钱，模拟池子里不止攻击者一份
        vault.deposit{value: 5 ether}();

        // 攻击者带 1 ether 来打
        vm.deal(address(attacker), 1 ether);
        attacker.attack{value: 1 ether}();

        // 不安全：攻击者把池子里 ETH 基本卷走 （5 + 1 都被提走）
        assertEq(address(vault).balance, 0);
        // 断言攻击者的余额大于 1 ether，说明攻击者成功地从不安全的 Vault 中提取了超过他存入的金额。
        assertGt(address(attacker).balance, 1 ether);
    }

    // ------------ 测试2：针对安全 Vault 的重入攻击 ------------
    function test_Reentrancy_FailOnSafeVault() public {
        Vault vault = new Vault();
        AttackerSafe attacker = new AttackerSafe(vault);

        vm.deal(address(this), 10 ether);
        vault.deposit{value: 5 ether}();

        vm.deal(address(attacker), 1 ether);
        attacker.attack{value: 1 ether}();

        // 安全 Vault：只能拿走攻击者自己存的 1 ether， 剩下 5 ether 还在。
        assertEq(address(vault).balance, 5 ether);
        assertEq(vault.balances(address(this)), 5 ether);
    }
}
