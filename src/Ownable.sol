// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

abstract contract Ownable {
    // owner 存储在storage中
    address public owner;

    // constructor 里 msg.sender 是部署测试合约的人
    constructor() {
        owner = msg.sender; // 部署者 = owner
    }

    // onlyOwner 修饰符：不是owner 就 revert
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
}
