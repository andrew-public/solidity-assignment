// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GroceryShop {

    enum GroceryType{ None, Bread, Egg, Jam } 

    event Added(GroceryShop.GroceryType groceryType, uint256 units);
    event Bought(uint256 purchaseId, GroceryShop.GroceryType groceryType, uint256 units);

    struct CashRegister {
        address buyer;
        GroceryShop.GroceryType item;
        uint256 count;
    }

    uint256[4] stock;
    uint256 purchaseId;
    address owner;
    mapping(uint => CashRegister) purchased;

    constructor(uint256 _breadCount, uint256 _eggCount, uint256 _jamCount) {
        stock[uint(GroceryType.Bread)] = _breadCount;
        stock[uint(GroceryType.Jam)] = _jamCount;
        stock[uint(GroceryType.Egg)] = _eggCount;
        owner = msg.sender;
    }

    function add(GroceryType _type, uint _units) public {
        require(msg.sender == owner, "Only owner can call add");
        stock[uint(_type)] += _units;
        emit Added(_type, _units);
    }

    function buy(GroceryType _type, uint _units) payable public {
        uint expectedCost = _units * 0.01 ether;
        require(msg.value == expectedCost, "Incorrect payment amount");
        require(_units <= stock[uint(_type)], "Not enough stock");
        purchaseId++;
        purchased[purchaseId] = CashRegister(msg.sender, _type, _units);

        emit Bought(purchaseId, _type, _units);
    }

    function cashRegister(uint _purchaseId) public view returns (address, GroceryShop.GroceryType, uint256) {
        require(_purchaseId > 0 && _purchaseId <= purchaseId, "Unknown purchaseId");
        CashRegister memory order = purchased[_purchaseId];
        return (order.buyer, order.item, order.count);
    }

    function withdraw() public payable {
        require(msg.sender == owner, "Only owner can call withdraw");
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}