// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: deploy ProtectedVault, deposit, reject non-owner, transfer owner, withdraw.

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Zero owner");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}

contract ProtectedVault is Ownable {
    event Deposited(address indexed from, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "Zero deposit");
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(address to, uint256 amt) public onlyOwner {
        require(to != address(0), "Zero recipient");
        require(amt > 0 && amt <= address(this).balance, "Invalid amount");
        emit Withdrawn(to, amt);
        (bool success, ) = payable(to).call{value: amt}("");
        require(success, "ETH transfer failed");
    }

    function contractBalance() public view returns (uint256) { return address(this).balance; }
}
