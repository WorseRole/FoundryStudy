// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {CounterUpgradeableV1} from "../src/CounterUpgradeableV1.sol";
import {CounterUpgradeableV2} from "../src/CounterUpgradeableV2.sol";

contract CounterUpgradeableProxyTest2 is Test {
    
    CounterUpgradeableV1 public counterV1;
    address public owner = address(this);
    address public stranger = address(0x999);

    ERC1967Proxy public proxy;

    function setUp() public {
        // ---------- 和 Day 13 一样：开业 ----------
        CounterUpgradeableV1 implV1 = new CounterUpgradeableV1();
        bytes memory initData = abi.encodeCall(CounterUpgradeableV1.initialize, (owner));
        proxy = new ERC1967Proxy(address(implV1), initData);
        counterV1 = CounterUpgradeableV1(address(proxy));

        // ---------- 升级前在 Proxy 上攒一点状态 ----------
        counterV1.increment(); // number = 2
        counterV1.increment(); // number = 4
    }

    function test_UpgradeToV2_numberPreserved_resetAndVersion() public {
        // 1. 只部署 V2 实现 （新 impl 地址），不 new Proxy
        CounterUpgradeableV2 implV2 = new CounterUpgradeableV2();

        // 2. owner 对 Proxy 调升级（交易目标仍是 Proxy）
        //    V2 没有新的 state 要 init -> data 用空 bytes
        // counterV1.upgradeToAndCall(address(implV2), "");

        // 2.1 
        bytes memory data = abi.encodeCall(CounterUpgradeableV2.initializeV2, (100));
        // 2.2
        counterV1.upgradeToAndCall(address(implV2), data);


        // 3. 同一 Proxy 地址，换成 V2 接口
        CounterUpgradeableV2 counterV2 = CounterUpgradeableV2(address(proxy));

        // 4. 验收：旧状态还在
        assertEq(counterV2.number(), 4);

        // 5. 验收：V2新函数
        assertEq(counterV2.version(), "2");
        counterV2.reset();
        assertEq(counterV2.number(), 0);
        assertEq(counterV2.bump(), 100);

    }

    function test_RevertIf_NotOwnerUpgrade() public {
        CounterUpgradeableV2 implV2 = new CounterUpgradeableV2();

        vm.prank(stranger);
        vm.expectRevert(); // OZ v5 是自定义 error，先写 expectRevert() 无参数即可
        counterV1.upgradeToAndCall(address(implV2), "");
    }


}