// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: deploy(42), get(), B set(100), get(), inspect ValueSet in Ganache.

contract Storage {
    uint256 private storedData;
    event ValueSet(address indexed who, uint256 newValue);

    constructor(uint256 _init) { storedData = _init; }

    function set(uint256 _value) public {
        storedData = _value;
        emit ValueSet(msg.sender, _value);
    }

    function get() public view returns (uint256) { return storedData; }
}
