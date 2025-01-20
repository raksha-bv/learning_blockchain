// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Todo{
    struct List{
        uint256 id;
        string title;
    }

    mapping(uint256 => List) public items;
    uint256 private nextId; 

    function add(string memory item) public{
        require(bytes(item).length> 0, "Length of item cannot be 0");
        nextId++;
        items[nextId] = List(nextId, item);
    }
    function remove(uint256 _id) public {
        require(_id > 0, "ID must be greater than 0");
        require(bytes(items[_id].title).length > 0, "Item does not exist");
        delete items[_id];
    }

    function update(uint256 _id,string memory item ) public{
        require(_id > 0, "ID must be greater than 0");
        require(bytes(items[_id].title).length > 0, "Item does not exist");
        items[_id].title = item;
    }

    function get() public view returns(List[] memory){
        List[] memory allItems = new List[](nextId); // Create a temporary array to store items
        uint256 counter = 0;
        for (uint256 i = 1; i <= nextId; i++) {
            if (bytes(items[i].title).length > 0) { // Check if the item exists
            allItems[counter] = items[i];
            counter++;
            }
        }
        return allItems;
    }


}