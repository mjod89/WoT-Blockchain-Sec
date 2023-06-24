// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SensorDataAccess is Ownable {
    using Counters for Counters.Counter;

    mapping(address => bool) private authority;
    mapping(uint256 => string) private sensorData;
    Counters.Counter private _dataIds;

    event DataAdded(uint256 indexed dataId, address indexed sender);
    event DataRetrieved(uint256 indexed dataId, address indexed requester);
    event AuthorityAdded(address indexed newAuthority);
    event AuthorityRemoved(address indexed removedAuthority);

    constructor() {
        _addAuthority(0xC1aBbC1aBC2aBc3aBc4aBc5aBc6aBc7aBc8aBc9a); // Gateway1
        _addAuthority(0xD1eBbD1aBD2aBd3aBd4aBd5aBd6aBd7aBd8aBd9a); // Gateway2
        _addAuthority(0xE1fBbE1aBE2aBe3aBe4aBe5aBe6aBe7aBe8aBe9a); // Application1
    }

    modifier onlyAuthority() {
        require(authority[msg.sender], "Caller is not authorized");
        _;
    }

    function addData(string memory data) public onlyAuthority returns (uint256) {
        _dataIds.increment();
        uint256 newDataId = _dataIds.current();
        sensorData[newDataId] = data;

        emit DataAdded(newDataId, msg.sender);

        return newDataId;
    }

    function getData(uint256 dataId) public view onlyAuthority returns (string memory) {
        require(_dataExists(dataId), "Data does not exist");

        emit DataRetrieved(dataId, msg.sender);

        return sensorData[dataId];
    }

    function addAuthority(address newAuthority) public onlyOwner {
        _addAuthority(newAuthority);
    }

    function removeAuthority(address removedAuthority) public onlyOwner {
        _removeAuthority(removedAuthority);
    }

    function _addAuthority(address newAuthority) private {
        require(newAuthority != address(0), "Invalid address");
        require(!authority[newAuthority], "Address is already authorized");

        authority[newAuthority] = true;

        emit AuthorityAdded(newAuthority);
    }

    function _removeAuthority(address removedAuthority) private {
        require(removedAuthority != address(0), "Invalid address");
        require(authority[removedAuthority], "Address is not authorized");

        authority[removedAuthority] = false;

        emit AuthorityRemoved(removedAuthority);
    }

    function _dataExists(uint256 dataId) private view returns (bool) {
        return dataId > 0 && dataId <= _dataIds.current();
    }
}
