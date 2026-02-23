// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
// import {PropertyMS} from "../src/PropertyMS.sol";
import {PropertyCoin} from "../src/PropertyCoin.sol";

contract DeployScript is Script {
    PropertyCoin public coin;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        coin = new PropertyCoin(msg.sender);

        vm.stopBroadcast();
    }
}
