// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

contract Vault {

    mapping(address => uint256) public balances;

    // 为什么用 payable 修饰函数？ 因为这个函数需要接收以太币，如果没有 payable 修饰符，合约将无法接收以太币，调用该函数时会失败。
    function deposit() external payable {
        // msg.value == 0 就 require 掉
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "zero amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects - 先该状态，再外部调用
        balances[msg.sender] -= amount;

        // Interactions - 发送以太币给用户
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");
    }


}