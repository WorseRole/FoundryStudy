// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title CounterUpgradeableV1
 * @notice Day 13：给 Proxy 用的「逻辑合约 V1」，不是给用户直接点的地址。
 *
 * 和 Day 12 的 CounterV1 业务一样，但部署方式不同：
 * - 用户只和 Proxy 地址交互；Proxy 用 delegatecall 执行本合约的代码。
 * - number、owner 等状态写在 Proxy 的 storage 里，不写在 impl 地址上。
 * - 不能用 constructor 给 Proxy 设 owner，所以用 initialize()，且只能调一次。
 */
contract CounterUpgradeableV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @dev 存在 Proxy 的 slot 里；V2 升级时不能改这个变量在布局里的位置
    uint256 public number;

    /**
     * @dev 部署「实现合约」时执行：锁死 impl，防止别人对 impl 地址调 initialize 抢 owner。
     * Proxy 部署时不会跑这段 constructor，只会 delegatecall initialize。
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice 在 Proxy 创建时通过 initData 调用，给 Proxy 上的 owner 赋值。
     * @param initialOwner 谁当管理员（链上脚本一般是 deployer，测试里是 address(this)）
     */
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
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

    /**
     * @dev UUPS 规定：谁有权把 Proxy 里的 implementation 指针换成新地址。
     * Day 14 升级 V2 时会走这里；只有 owner 能升级。
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
