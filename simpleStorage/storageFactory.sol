// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {StorageSimple} from "./storage.sol";

contract storageFactory{
    StorageSimple[] public listOfSimpleStorage;

    function createSimpleStorage() public{
        StorageSimple storageSimple =new StorageSimple();
        listOfSimpleStorage.push(storageSimple);
    }
    
    function sfStore(uint256 _storageSimpleIndex, uint256 _favNum) public{
        listOfSimpleStorage[_storageSimpleIndex].store(_favNum);
    }

    function sfRetrieve(uint256 _storageSimpleIndex) public view returns(uint256){
        return listOfSimpleStorage[_storageSimpleIndex].retrieve();
    }

}