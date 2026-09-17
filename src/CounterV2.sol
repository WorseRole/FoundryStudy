// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import {Ownable} from "./Ownable.sol";

contract CounterV2 is Ownable {
    uint256 public number;

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

    function reset() public onlyOwner {
        number = 0;
    }

    function version() external pure returns (string memory) {
        return "2";
    } 

}