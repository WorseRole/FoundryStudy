// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

contract VaultVunlnerable {

    mapping(address => uint256) public balances;

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    /**
     * @dev 这个函数存在重入漏洞，攻击者可以在收到以太币后再次调用 withdraw 函数，从而重复提取资金。
     * @notice 这个函数的漏洞在于它在发送以太币给用户之前没有更新用户的余额。如果攻击者在收到以太币后再次调用 withdraw 函数，他们可以在余额被更新之前重复提取资金。
     * @param amount 要提取的以太币数量
     * 
     * 转 ETH 时，链上余额还没减，恶意合约还能再 withdraw，导致重入攻击
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "zero amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 错误顺序：先 Interactions - 发送以太币给用户 （外部call）
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        if (balances[msg.sender] < amount) {
            return;
        }
        
        // 错误顺序： 再 Effects 改状态 ———— 重入时 balances 还没减
        balances[msg.sender] -= amount;
    }
}