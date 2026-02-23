// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PropertyMS is Ownable {
    uint propertyId;
    IERC20 token;

    struct Property {
        uint id;
        address owner;
        string name;
        string location;
        uint256 value;
        bool forSale;
    }

    mapping(address => uint) public propertiesId;

    Property[] public propertyList;
    Property[] public propertiesForSale;
    
    constructor(address initialOwner, address _token) Ownable(initialOwner) {
        token = IERC20(_token);
    }

    function registerProperty(address owner, string memory propertyName, string memory propertyLocation, uint propertyPrice) public onlyOwner{
        propertyId = propertyId + 1;
        Property memory newProperty = Property(propertyId, owner, propertyName, propertyLocation, propertyPrice, false);
        propertiesId[owner] = propertyId;
        propertyList.push(newProperty);
    }

    function listPropertyForSale(uint id) public onlyOwner {
        for(uint i = 0; i < propertyList.length; i++){
            if(propertyList[i].id == id){
                propertiesForSale.push(propertyList[i]);
                propertyList[i].forSale = true;
                break;
            }
        }
    }

    function buyProperty(uint id) public payable {
        for(uint i = 0; i < propertiesForSale.length; i++){
            if(propertiesForSale[i].id == id){
                require(msg.value == propertiesForSale[i].value, "Incorrect value sent");
                address previousOwner = propertiesForSale[i].owner;
                propertiesForSale[i].owner = msg.sender;
                propertiesForSale[i].forSale = false;
                require(token.transfer(previousOwner, propertiesForSale[i].value), "Transfer failed");
                propertiesForSale[i] = propertiesForSale[propertiesForSale.length - 1];
                propertiesForSale.pop();
                break;
            }
        }
    }

    function unlistProperty(uint id) public onlyOwner {
        for(uint i = 0; i < propertiesForSale.length; i++){
            if(propertiesForSale[i].id == id){
                propertiesForSale[i] = propertiesForSale[propertiesForSale.length - 1];
                propertiesForSale.pop();
                break;
            }
        }
    }
}
