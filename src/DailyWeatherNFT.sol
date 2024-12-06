// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract DailyWeatherNFT is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Strings for uint8;

    /**
     * @dev Represents weather data for the NFT.
     */
    struct WeatherData {
        string weatherImageURI; // URI of the weather image
        string description;     // Description of the weather conditions
        uint8 temperature;      // Temperature in Celsius
        uint8 humidity;         // Humidity percentage
        uint8 windSpeed;        // Wind speed in km/h
        uint256 timestamp;      // Last update timestamp
    }

    uint256 private currentTokenId; // Tracks the latest token ID
    mapping(uint256 => WeatherData) public weatherData; // Stores weather data for each token

    /// Emitted when weather data is updated for a token.
    event WeatherUpdated(
        uint256 indexed tokenId,
        string weatherImageURI,
        string description,
        uint8 temperature,
        uint8 humidity,
        uint8 windSpeed
    );

    /**
     * @dev Initializes the contract with the name and symbol of the NFT collection.
     */
    constructor() ERC721("DailyWeatherNFT", "DWNFT") Ownable(msg.sender) {}

    /**
     * @notice Mints a daily weather NFT. Can only be called once per day.
     * @dev This function mints a new NFT with initial weather data.
     * @param recipient The address receiving the NFT.
     * @param initialWeatherImageURI The URI of the initial weather image.
     * @param initialDescription The initial description of the weather conditions.
     * @param initialTemperature The initial temperature in Celsius.
     * @param initialHumidity The initial humidity percentage.
     * @param initialWindSpeed The initial wind speed in km/h.
     */
    function mintDailyWeather(
        address recipient,
        string memory initialWeatherImageURI,
        string memory initialDescription,
        uint8 initialTemperature,
        uint8 initialHumidity,
        uint8 initialWindSpeed
    ) external onlyOwner returns(uint256){
        require(currentTokenId == 0 || _isNewDay(), "Token already minted for today");

        currentTokenId++;
        _mint(recipient, currentTokenId);

        weatherData[currentTokenId] = WeatherData({
            weatherImageURI: initialWeatherImageURI,
            description: initialDescription,
            temperature: initialTemperature,
            humidity: initialHumidity,
            windSpeed: initialWindSpeed,
            timestamp: block.timestamp
        });

        // Generate and set the initial token URI
        string memory tokenURIData = _generateTokenURI(currentTokenId);
        _setTokenURI(currentTokenId, tokenURIData);

        emit WeatherUpdated(
            currentTokenId,
            initialWeatherImageURI,
            initialDescription,
            initialTemperature,
            initialHumidity,
            initialWindSpeed
        );
        return currentTokenId;
    }

    /**
     * @notice Updates the weather data for the current day's NFT.
     * @dev This function updates the weather data and regenerates the token URI.
     * @param weatherImageURI The new URI of the weather image.
     * @param description The new description of the weather conditions.
     * @param temperature The new temperature in Celsius.
     * @param humidity The new humidity percentage.
     * @param windSpeed The new wind speed in km/h.
     */
    function updateWeatherData(
        string memory weatherImageURI,
        string memory description,
        uint8 temperature,
        uint8 humidity,
        uint8 windSpeed
    ) external onlyOwner {
        require(currentTokenId > 0, "No token minted yet");

        WeatherData storage currentWeather = weatherData[currentTokenId];
        currentWeather.weatherImageURI = weatherImageURI;
        currentWeather.description = description;
        currentWeather.temperature = temperature;
        currentWeather.humidity = humidity;
        currentWeather.windSpeed = windSpeed;
        currentWeather.timestamp = block.timestamp;

        // Regenerate and update the token URI
        string memory tokenURIData = _generateTokenURI(currentTokenId);
        _setTokenURI(currentTokenId, tokenURIData);

        emit WeatherUpdated(
            currentTokenId,
            weatherImageURI,
            description,
            temperature,
            humidity,
            windSpeed
        );
    }

    /**
     * @notice Generates the token URI dynamically based on weather data.
     * @dev Encodes the weather data into a JSON metadata format and returns it as a Base64 string.
     * @param tokenId The ID of the token for which to generate the metadata.
     * @return string The dynamically generated token URI in JSON format.
     */
    function _generateTokenURI(uint256 tokenId) internal view returns (string memory) {
        WeatherData memory data = weatherData[tokenId];

        // Construct metadata in JSON format
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name":"Daily Weather #', tokenId.toString(), '",',
            '"description":"An NFT representing daily weather data.",',
            '"image":"', data.weatherImageURI, '",',
            '"attributes":[',
            '{"trait_type":"Description","value":"', data.description, '"},',
            '{"trait_type":"Temperature","value":', data.temperature.toString(), '},',
            '{"trait_type":"Humidity","value":', data.humidity.toString(), '},',
            '{"trait_type":"Wind Speed","value":', data.windSpeed.toString(), '}]}'
        ))));

        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    /**
     * @notice Checks if a new day has started (UTC).
     * @dev Compares the current timestamp with the timestamp of the last update, rounded to days.
     * @return bool True if a new day has started, false otherwise.
     */
    function _isNewDay() internal view returns (bool) {
        uint256 lastTimestamp = weatherData[currentTokenId].timestamp;
        return block.timestamp / 1 days > lastTimestamp / 1 days;
    }

    function getWeatherData(uint256 _id) external view returns(WeatherData memory){
        return weatherData[_id];
    }
}
