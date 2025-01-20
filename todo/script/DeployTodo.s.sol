// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Todo} from "../src/Todo.sol";

contract DeployTodo is Script {
    function run() external returns (Todo){
        vm.startBroadcast();
        Todo todo = new Todo();
        vm.stopBroadcast();
        return todo;
    }
}