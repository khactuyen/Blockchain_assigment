// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: A/B deposit 2/3 ETH, reject overdraw, withdraw 1 ETH, verify balances/logs.

contract SimpleBank {
    mapping(address => uint256) private balances;
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Zero withdrawal");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        // Effects before interaction: a callback cannot spend this amount again.
        balances[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function myBalance() public view returns (uint256) { return balances[msg.sender]; }
    function bankTotal() public view returns (uint256) { return address(this).balance; }
}
