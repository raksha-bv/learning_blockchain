// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {StorageSimple} from "./storage.sol";

contract AddFive is StorageSimple {
    function store(uint256 _favNum) public override {
        myFavNum += _favNum + 5;
    }
}
