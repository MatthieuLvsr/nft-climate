// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/DailyWeatherNFT.sol";

// forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast -vvvv --legacy --private-key $PRIVATE_KEY --verify

contract Deploy is Script {
    function setUp() public {}

    function testA() public {}

    function run() public {        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        DailyWeatherNFT nft = new DailyWeatherNFT();
        console.log("NFT address:",address(nft));
        vm.stopBroadcast();
    }
}
