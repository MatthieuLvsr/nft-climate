// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/DailyWeatherNFT.sol";

// forge script script/Mint.s.sol:Mint --rpc-url $RPC_URL --broadcast -vvvv --legacy --private-key $PRIVATE_KEY

contract Mint is Script {
    function setUp() public {}

    function testA() public {}

    function run() public {        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        DailyWeatherNFT nft = DailyWeatherNFT(0xd97B68ae45C3d1B87FAd8958f6Dd7847917E049E);
        uint256 id = nft.mintDailyWeather(
            0xC99714dc1d77651985eb1354C6B1129967c5A095,
            "https://eastern-tan-smelt.myfilebase.com/ipfs/QmXBwTWiuBgVMcVXtTWqP4Pyb2nLt3jdjF6ThZ6dhN2d6T",
            "A sunny morning.",
            5,
            45,
            6);
        vm.stopBroadcast();
    }
}