// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    address public owner = address(this);
    address public stranger = address(0x999);

    function test_SetNumber_byOwner() public {
        counter.setNumber(42); // 默认 msg.sender = owner
        assertEq(counter.number(), 42);
    }

    function test_RevertIf_NotOwnerSetNumber() public {
        vm.prank(stranger);
        vm.expectRevert("not owner");
        counter.setNumber(42);
    }

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 2);
    }

    function test_Decrement() public {
        counter.setNumber(10);
        counter.decrement();
        assertEq(counter.number(), 8);
    }

    function test_RevertIf_DecrementTooSmall() public {
        counter.setNumber(1);
        vm.expectRevert("number too small");
        counter.decrement();
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
