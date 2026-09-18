// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {CounterUpgradeableV1} from "../src/CounterUpgradeableV1.sol";

/**
 * @title CounterUpgradeableProxyTest
 * @notice Day 13：不上链，在本地模拟「Proxy + 实现合约」整套流程。
 */
contract CounterUpgradeableProxyTest is Test {
    /// @dev 注意：这里绑的是 Proxy 地址，不是 impl 地址
    CounterUpgradeableV1 public counter;
    address public owner = address(this);

    function setUp() public {
        // 1. 部署逻辑合约（实现）。用户以后不要直接调这个地址做业务。
        CounterUpgradeableV1 impl = new CounterUpgradeableV1();

        // 2. 把 initialize(owner) 编码成 calldata，Proxy 创建时会 delegatecall 执行它
        bytes memory initData = abi.encodeCall(CounterUpgradeableV1.initialize, (owner));

        // 3. 部署 Proxy：内部记下 impl 地址，并用 initData 完成 Proxy 上的初始化
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);

        // 4. 类型转换：把 Proxy 地址当成 Counter 来调，和链上用法一致
        counter = CounterUpgradeableV1(address(proxy));
    }

    /// @dev 验收标准：通过 Proxy 调 increment，改的是 Proxy 里的 number
    function test_Increment_viaProxy() public {
        counter.increment();
        assertEq(counter.number(), 2);
    }

    /// @dev owner 也应写在 Proxy 的 storage 里，不是 impl 上
    function test_OwnerIsProxyContext() public view {
        assertEq(counter.owner(), owner);
    }
}
