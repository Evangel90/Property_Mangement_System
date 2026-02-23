// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PropertyMS is Ownable {
    struct Property {
        string name;
        string location;
        uint256 value;
    }

    mapping(address => Property) properties;
    
    constructor(address initialOwner) Ownable(initialOwner) {}
}
