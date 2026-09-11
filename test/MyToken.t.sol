// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    function setUp() public {
        vm.prank(owner);
        token = new MyToken(1000 ether);
        console.log(unicode"===测试开始===");
        console.log(unicode"初始供应量:", token.totalSupply());
        console.log(unicode"Owner余额:", token.balanceOf(owner));
        console.log("================\n");
    }

    function testInitialSupply() public {
        vm.prank(owner);
        assertEq(token.balanceOf(owner), 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);
    }

    function testTransfer() public {
        console.log(unicode"\n>>> 测试转账功能 <<<");
        console.log(unicode"转账前 - Owner余额:", token.balanceOf(owner));
        console.log(unicode"转账前 - User1余额:", token.balanceOf(user1));

        vm.prank(owner);
        bool success = token.transfer(user1, 100 ether);

        console.log(unicode"转账结果:", success);
        console.log(unicode"转账后 - Owner余额:", token.balanceOf(owner));
        console.log(unicode"转账后 - User1余额:", token.balanceOf(user1));

        assertTrue(success);
        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.balanceOf(owner), 900 ether);
    }

    function testApprove() public {
        console.log(unicode"\n>>> 测试授权功能 <<<");
        console.log(unicode"授权前 - Owner对User1的授权:", token.allowance(owner, user1));

        vm.prank(owner);
        bool success = token.approve(user1, 50 ether);

        console.log(unicode"授权结果:", success);
        console.log(unicode"授权后 - Owner对User1的授权:", token.allowance(owner, user1));

        assertTrue(success);
        assertEq(token.allowance(owner, user1), 50 ether);
    }

    function testTransferFrom() public {
        console.log(unicode"\n>>> 测试授权转账功能 <<<");

        // 先授权
        vm.prank(owner);
        token.approve(user1, 50 ether);
        console.log(unicode"授权: Owner授权User1 50 tokens");
        console.log(unicode"授权额度:", token.allowance(owner, user1));

        console.log(unicode"\n转账前 - Owner余额:", token.balanceOf(owner));
        console.log(unicode"转账前 - User2余额:", token.balanceOf(user2));
        console.log(unicode"剩余授权额度:", token.allowance(owner, user1));

        // 执行授权转账
        vm.prank(user1);
        bool success = token.transferFrom(owner, user2, 30 ether);

        console.log(unicode"\n转账结果:", success);
        console.log(unicode"转账后 - Owner余额:", token.balanceOf(owner));
        console.log(unicode"转账后 - User2余额:", token.balanceOf(user2));
        console.log(unicode"剩余授权额度:", token.allowance(owner, user1));

        assertTrue(success);
        assertEq(token.balanceOf(user2), 30 ether);
        assertEq(token.balanceOf(owner), 970 ether);
        assertEq(token.allowance(owner, user1), 20 ether);
    }

    // 修复：使用 test_RevertIf 模式而不是 testFail
    function test_RevertIf_InsufficientBalance() public {
        console.log(unicode"\n>>> 测试余额不足异常 <<<");
        console.log(unicode"User1余额:", token.balanceOf(user1));
        console.log(unicode"尝试转账: 1 ether");

        vm.prank(user1);
        vm.expectRevert("insufficient balance");
        token.transfer(user2, 1 ether);

        console.log(unicode"✓ 余额不足异常触发成功");
    }

    // 测试 Approve 后 transferFrom 余额不足的情况
    function test_RevertIf_InsufficientBalanceTransferFrom() public {
        // Owner approves user1 to spend 50 tokens
        vm.prank(owner);
        token.approve(user1, 50 ether);

        // user1 tries to transfer more than owner has
        vm.prank(user1);
        vm.expectRevert("insufficient balance");
        token.transferFrom(owner, user2, 2000 ether);
    }

    // 测试 Approve 额度不足的情况
    function test_RevertIf_InsufficientAllowance() public {
        // Owner approves user1 to spend only 10 tokens
        vm.prank(owner);
        token.approve(user1, 10 ether);

        // user1 tries to transfer more than approved
        vm.prank(user1);
        vm.expectRevert("insufficient allowance");
        token.transferFrom(owner, user2, 50 ether);
    }
}
