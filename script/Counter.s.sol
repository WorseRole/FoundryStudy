// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

// 继承forge-std 的 Script，才能用 vm.startBrodcast、vm.envuint 等方法
contract CounterScript is Script {
    Counter public counter;

    // setUp() 空着没问题；复杂脚本里会在 setUp 里读配置、算地址，再在 run 里广播。
    function setUp() public {}

    // forge script script/Counter.s.sol 的入口（默认跑 run; 也可 :CounterScript 指定合约）
    function run() public {
        // 从 .env 里读取私钥，用来签名
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // 中间每一句会发脸上操作的（例如 new Counter()）， 在
        //    不加 --broadcast：只在RPC上模拟，不花gas，不上链
        //    加 --broadcast：会在RPC上模拟，并且花gas，上链
        // 从这里开始：后面的 new Counter()、contract.foo() 等，在 --broadcast 时会用这把私钥签名并发送。
        vm.startBroadcast(deployerPrivateKey);

        // 等价于发一笔 创建合约的交易； 地址就是日志里的 Counter deployed at: 0x...
        counter = new Counter();
        // 和测试里一样，终端里看输出（部署地址就靠这个）
        console.log("Counter deployed at:", address(counter));

        // 从这里开始：不再把后续操作当成要广播的交易。
        vm.stopBroadcast();
    }
}
