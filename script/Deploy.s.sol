// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PropertyMS} from "../src/PropertyMS.sol";
// import {PropertyCoin} from "../src/PropertyCoin.sol";

contract DeployScript is Script {
    PropertyMS public ms;

    function run() public {
        vm.startBroadcast();

        ms = new PropertyMS(msg.sender, 0xc6dedb50397A47ee9FA4c79A5FbD65f91e397534);

        vm.stopBroadcast();
    }
}
