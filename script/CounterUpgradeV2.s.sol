// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;
import {Script, console} from "forge-std/Script.sol";
import {CounterUpgradeableV1} from "../src/CounterUpgradeableV1.sol";
import {CounterUpgradeableV2} from "../src/CounterUpgradeableV2.sol";


contract CounterUpgradeV2 is Script {

    address PROXY = 0x901D9F0d66db49226476372e1B63684bFEbE4F73;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        CounterUpgradeableV1 proxyAsV1 = CounterUpgradeableV1(PROXY);
        console.log("number before:", proxyAsV1.number());
        
        CounterUpgradeableV2 implV2 = new CounterUpgradeableV2();
        console.log("Implementation V2:", address(implV2));

        bytes memory data = abi.encodeCall(CounterUpgradeableV2.initializeV2, (100));
        proxyAsV1.upgradeToAndCall(address(implV2), data);

        CounterUpgradeableV2 proxyAsV2 = CounterUpgradeableV2(address(PROXY));

        console.log("number after:", proxyAsV2.number());
        console.log("bump:", proxyAsV2.bump());
        console.log("version:", proxyAsV2.version());

        vm.stopBroadcast();
    }


}