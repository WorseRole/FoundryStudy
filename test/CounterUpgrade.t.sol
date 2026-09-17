// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {CounterV1} from "../src/CounterV1.sol";
import {CounterV2} from "../src/CounterV2.sol";


contract CounterUpgrade is Test {
    CounterV1 counterV1;
    CounterV2 counterV2;

    address public stranger = address(0x999);

    function setUp() public {
        counterV1 = new CounterV1();
        counterV2 = new CounterV2();
    }

    function test_SetNumber_byOwner() public {
        counterV1.setNumber(10);
        assertEq(counterV1.number(), 10);
    }

    function test_Increment() public {
        counterV1.increment();
        assertEq(counterV1.number(), 2);
    }

    function test_Decrement() public {
        counterV1.setNumber(20);
        counterV1.decrement();
        assertEq(counterV1.number(), 18);
    }

    function test_RevertIf_DecrementTooSmall() public {
        counterV1.setNumber(1);
        vm.expectRevert("number too small");
        counterV1.decrement();
    }

    function test_RevertIf_NotOwnerSetNumber() public {
        vm.prank(stranger);
        vm.expectRevert("not owner");
        counterV1.setNumber(42);
    }

    function test_Increment_v2() public {
        counterV2.increment();
        assertEq(counterV2.number(), 2);
    }

    function test_Decrement_v2() public {
        counterV2.setNumber(20);
        counterV2.decrement();
        assertEq(counterV2.number(), 18);
    }

    function test_reset_v2() public {
        counterV2.increment();
        assertEq(counterV2.number(), 2);
        counterV2.reset();
        assertEq(counterV2.number(), 0);
    }

    function test_RevertIf_NotOwnerReset() public {
        counterV2.increment();
        vm.prank(stranger);
        vm.expectRevert("not owner");
        counterV2.reset();
    }

    function test_version_v2() public view {
        assertEq(counterV2.version(), "2");
    }
}