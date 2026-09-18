// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {CounterUpgradeableV1} from "../src/CounterUpgradeableV1.sol";

/**
 * @title CounterUpgradeableScript
 * @notice Day 13：Sepolia 部署 Proxy + V1 实现（可选 --broadcast --verify）。
 *
 * 用法示例：
 *   forge script script/CounterUpgradeable.s.sol --rpc-url sepolia -vvvv
 *   forge script script/CounterUpgradeable.s.sol --rpc-url sepolia --broadcast --verify -vvvv
 *
 * 记地址：README 里填 Counter Proxy 那一行；Implementation 单独记作 V1 impl。
 */
contract CounterUpgradeableScript is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        address deployer = vm.addr(pk);

        // 实现合约：只提供代码；业务状态在 Proxy 上
        CounterUpgradeableV1 impl = new CounterUpgradeableV1();
        console.log("Implementation V1:", address(impl));

        // Proxy  constructor 里会 delegatecall initialize，把 deployer 设为 owner
        bytes memory initData = abi.encodeCall(CounterUpgradeableV1.initialize, (deployer));

        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        console.log("Counter Proxy:", address(proxy));

        // 以后用户、cast、前端都只用 proxy 地址
        CounterUpgradeableV1 counter = CounterUpgradeableV1(address(proxy));
        counter.increment();
        console.log("number after increment:", counter.number());

        vm.stopBroadcast();
    }
}
