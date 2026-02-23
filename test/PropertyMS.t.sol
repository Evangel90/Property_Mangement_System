// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PropertyMS} from "../src/PropertyMS.sol";
import {PropertyCoin} from "../src/PropertyCoin.sol";

contract PropertyMSTest is Test {
    PropertyMS public propertyMS;
    PropertyCoin public token;

    address public owner = address(0x1);
    address public seller = address(0x2);
    address public buyer = address(0x3);

    function setUp() public {
        // Setup accounts
        vm.deal(buyer, 100 ether);

        // Deploy contracts as owner
        vm.startPrank(owner);
        token = new PropertyCoin(owner);
        propertyMS = new PropertyMS(owner, address(token));

        // Fund the PropertyMS contract with tokens.
        // The contract logic requires the contract itself to pay the seller in tokens
        // when a buyer sends ETH.
        token.transfer(address(propertyMS), 500000 * 10**18);
        vm.stopPrank();
    }

    function test_RegisterProperty() public {
        vm.startPrank(owner);
        propertyMS.registerProperty(seller, "Mansion", "New York", 10 ether);

        (uint id, address propOwner, string memory name, string memory location, uint256 value, bool forSale) = propertyMS.propertyList(0);

        assertEq(id, 1);
        assertEq(propOwner, seller);
        assertEq(name, "Mansion");
        assertEq(location, "New York");
        assertEq(value, 10 ether);
        assertEq(forSale, false);
        vm.stopPrank();
    }

    function test_ListPropertyForSale() public {
        vm.startPrank(owner);
        propertyMS.registerProperty(seller, "Villa", "Paris", 5 ether);
        propertyMS.listPropertyForSale(1);

        // Check it was added to propertiesForSale
        (uint id, address propOwner, , , , ) = propertyMS.propertiesForSale(0);
        assertEq(id, 1);
        assertEq(propOwner, seller);

        // Check the original list was updated
        (, , , , , bool forSale) = propertyMS.propertyList(0);
        assertTrue(forSale);
        vm.stopPrank();
    }

    function test_BuyProperty() public {
        uint256 price = 2 ether;

        // Register and List
        vm.startPrank(owner);
        propertyMS.registerProperty(seller, "Condo", "Tokyo", price);
        propertyMS.listPropertyForSale(1);
        vm.stopPrank();

        uint256 sellerTokenBalanceBefore = token.balanceOf(seller);
        uint256 contractEthBalanceBefore = address(propertyMS).balance;

        // Buy
        vm.startPrank(buyer);
        propertyMS.buyProperty{value: price}(1);
        vm.stopPrank();

        // Verify Seller received Tokens (as per contract logic)
        assertEq(token.balanceOf(seller), sellerTokenBalanceBefore + price);

        // Verify Contract received ETH
        assertEq(address(propertyMS).balance, contractEthBalanceBefore + price);

        // Verify property is removed from sale list
        // Accessing index 0 should revert as the array is empty after pop
        vm.expectRevert();
        propertyMS.propertiesForSale(0);
    }

    function test_UnlistProperty() public {
        vm.startPrank(owner);
        propertyMS.registerProperty(seller, "Flat", "London", 1 ether);
        propertyMS.listPropertyForSale(1);

        propertyMS.unlistProperty(1);
        vm.expectRevert(); // Should be empty
        propertyMS.propertiesForSale(0);
        vm.stopPrank();
    }
}
