// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/DailyWeatherNFT.sol";

contract DailyWeatherNFTTest is Test {
    DailyWeatherNFT private dailyWeatherNFT;
    address private owner;
    address private user;

    function setUp() public {
        owner = address(this); // Test contract as owner
        user = address(0x123); // Sample user address
        dailyWeatherNFT = new DailyWeatherNFT(); // Deploy the contract
    }

    function testMintDailyWeather() public {
        string memory imageURI = "https://example.com/morning.png";
        string memory description = "Sunny";
        uint8 temperature = 25;
        uint8 humidity = 60;
        uint8 windSpeed = 15;

        // Mint the NFT
        dailyWeatherNFT.mintDailyWeather(
            user,
            imageURI,
            description,
            temperature,
            humidity,
            windSpeed
        );

        // Validate the token exists
        assertEq(dailyWeatherNFT.balanceOf(user), 1, "User should own 1 NFT");
        assertEq(dailyWeatherNFT.ownerOf(1), user, "User should own token 1");

        // Validate the weather data
        DailyWeatherNFT.WeatherData memory data = dailyWeatherNFT.getWeatherData(1);
        assertEq(data.weatherImageURI, imageURI, "Image URI is incorrect");
        assertEq(data.description, description, "Description is incorrect");
        assertEq(data.temperature, temperature, "Temperature is incorrect");
        assertEq(data.humidity, humidity, "Humidity is incorrect");
        assertEq(data.windSpeed, windSpeed, "Wind speed is incorrect");
    }

    function testCannotMintTwiceInSameDay() public {
        string memory imageURI = "https://example.com/morning.png";
        string memory description = "Sunny";
        uint8 temperature = 25;
        uint8 humidity = 60;
        uint8 windSpeed = 15;

        // Mint the first NFT
        dailyWeatherNFT.mintDailyWeather(
            user,
            imageURI,
            description,
            temperature,
            humidity,
            windSpeed
        );

        // Attempt to mint again on the same day
        vm.expectRevert("Token already minted for today");
        dailyWeatherNFT.mintDailyWeather(
            user,
            imageURI,
            description,
            temperature,
            humidity,
            windSpeed
        );
    }

    function testUpdateWeatherData() public {
        // Mint the NFT
        dailyWeatherNFT.mintDailyWeather(
            user,
            "https://example.com/morning.png",
            "Sunny",
            25,
            60,
            15
        );

        DailyWeatherNFT.WeatherData memory data1 = dailyWeatherNFT.getWeatherData(1);

        console.log(data1.weatherImageURI);

        // Update weather data
        string memory newImageURI = "https://example.com/evening.png";
        string memory newDescription = "Cloudy";
        uint8 newTemperature = 20;
        uint8 newHumidity = 70;
        uint8 newWindSpeed = 10;

        dailyWeatherNFT.updateWeatherData(
            newImageURI,
            newDescription,
            newTemperature,
            newHumidity,
            newWindSpeed
        );

        // Validate the updated weather data
        DailyWeatherNFT.WeatherData memory data = dailyWeatherNFT.getWeatherData(1);
        console.log(data.weatherImageURI);
        assertEq(data.weatherImageURI, newImageURI, "Updated Image URI is incorrect");
        assertEq(data.description, newDescription, "Updated Description is incorrect");
        assertEq(data.temperature, newTemperature, "Updated Temperature is incorrect");
        assertEq(data.humidity, newHumidity, "Updated Humidity is incorrect");
        assertEq(data.windSpeed, newWindSpeed, "Updated Wind Speed is incorrect");
    }

    function testTokenURI() public {
        // Mint the NFT
        dailyWeatherNFT.mintDailyWeather(
            user,
            "https://example.com/morning.png",
            "Sunny",
            25,
            60,
            15
        );

        // Validate the tokenURI
        string memory tokenURI = dailyWeatherNFT.tokenURI(1);
        assertTrue(bytes(tokenURI).length > 0, "Token URI should not be empty");
        assertTrue(
            keccak256(abi.encodePacked(tokenURI)).length > 0,
            "Token URI should contain valid metadata"
        );
    }

    function testNewDayAllowsMint() public {
        string memory imageURI = "https://example.com/morning.png";
        string memory description = "Sunny";
        uint8 temperature = 25;
        uint8 humidity = 60;
        uint8 windSpeed = 15;

        // Mint for today
        dailyWeatherNFT.mintDailyWeather(
            user,
            imageURI,
            description,
            temperature,
            humidity,
            windSpeed
        );

        // Fast-forward one day
        vm.warp(block.timestamp + 1 days);

        // Mint for the new day
        dailyWeatherNFT.mintDailyWeather(
            user,
            imageURI,
            description,
            temperature,
            humidity,
            windSpeed
        );

        // Validate balances
        assertEq(dailyWeatherNFT.balanceOf(user), 2, "User should own 2 NFTs");
    }
}
