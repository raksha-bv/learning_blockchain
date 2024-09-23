// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract StorageSimple{
    uint256 public myFavNum;
    mapping(string=>uint256) public nameToNumber;

    function store(uint256 _myFavNum) public virtual  {
        myFavNum=_myFavNum;
    }

    struct Person{
        uint256 favNum;
        string name;
    }

    function retrieve() public view returns(uint256){
        return myFavNum;
    }

    Person[] public listOfPpl;

    function addPpl(uint256 _favNum, string memory _name) public{
        listOfPpl.push(Person({favNum:_favNum, name:_name }));
        nameToNumber[_name]=_favNum;
    }


}