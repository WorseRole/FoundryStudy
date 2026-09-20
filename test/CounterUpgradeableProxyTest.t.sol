// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {CounterUpgradeableV1} from "../src/CounterUpgradeableV1.sol";

contract CounterUpgradeableProxyTest is Test {
    CounterUpgradeableV1 public counter;
    address public owner = address(this);

    function setUp() public {
        CounterUpgradeableV1 impl = new CounterUpgradeableV1();

        bytes memory initData = abi.encodeCall(CounterUpgradeableV1.initialize, (owner));

        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);

        counter = CounterUpgradeableV1(address(proxy));
    }

    function test_Increment_viaProxy() public {
        counter.increment();
        assertEq(counter.number(), 2);
    }

    function test_OwnerIsProxyContext() public view {
        assertEq(counter.owner(), owner);
    }


}