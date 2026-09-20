// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Day 14：在此实现 CounterUpgradeableV2（layout 兼容 V1 + reset / version）
contract CounterUpgradeableV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    
    /// @dev 存在 Proxy 的 slot 里；V2 升级时不能改这个变量在布局里的位置
    uint256 public number;

    uint256 public bump;

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    // 升级 V1 -> V2 后执行一次，给新变量 bump 赋初值
    //  reinitializer(2) = 第二次初始化步骤（V1 的 initialize 算第 1 次）
    function initializeV2(uint256 initBump) public reinitializer(2) {
        bump = initBump;
    }

    function setNumber(uint256 newNumber) public onlyOwner {
        number = newNumber;
    }

    function increment() public {
        number += 2;
    }

    function decrement() public {
        require(number >= 2, "number too small");
        number -= 2;
    }

    function reset() public onlyOwner {
        number = 0;
    }

    function version() external pure returns (string memory) {
        return "2";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

}