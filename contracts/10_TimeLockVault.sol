// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: deposit, reject early/wrong-user withdrawal, extend, wait, withdraw.

contract TimeLockVault {
    address payable public beneficiary;
    uint256 public unlockTime;
    event Deposited(address indexed from, uint256 amount, uint256 newUnlockTime);
    event Withdrawn(address indexed to, uint256 amount);
    event LockExtended(uint256 newUnlockTime);

    constructor(address payable _beneficiary, uint256 _lockSeconds) {
        require(_beneficiary != address(0), "Zero beneficiary");
        require(_lockSeconds > 0, "Zero lock duration");
        beneficiary = _beneficiary;
        unlockTime = block.timestamp + _lockSeconds;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not beneficiary");
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");
        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    function extendLock(uint256 _extraSeconds) external onlyBeneficiary {
        require(_extraSeconds > 0, "Zero extension");
        // Explicit extension adds to the existing deadline; deposits never extend it.
        unlockTime += _extraSeconds;
        emit LockExtended(unlockTime);
    }

    function withdraw() external onlyBeneficiary {
        require(block.timestamp >= unlockTime, "Vault is still locked");
        uint256 amount = address(this).balance;
        require(amount > 0, "Empty vault");
        emit Withdrawn(msg.sender, amount);
        (bool success, ) = beneficiary.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function timeRemaining() external view returns (uint256) {
        return block.timestamp < unlockTime ? unlockTime - block.timestamp : 0;
    }
}
