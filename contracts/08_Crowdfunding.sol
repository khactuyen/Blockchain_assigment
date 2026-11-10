// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: separate success/failed campaigns; claim/refund after expiry; reject repeats.

contract Crowdfunding {
    address payable public owner;
    uint256 public goal;
    uint256 public deadline;
    uint256 public raised;
    bool public claimed;
    mapping(address => uint256) public contributions;
    event Contributed(address indexed contributor, uint256 amount);
    event FundsClaimed(uint256 amount);
    event Refunded(address indexed contributor, uint256 amount);

    constructor(uint256 _goal, uint256 _durationSeconds) {
        require(_goal > 0 && _durationSeconds > 0, "Invalid campaign");
        owner = payable(msg.sender);
        goal = _goal;
        deadline = block.timestamp + _durationSeconds;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Zero contribution");
        contributions[msg.sender] += msg.value;
        raised += msg.value;
        emit Contributed(msg.sender, msg.value);
    }

    function getRemainingTime() public view returns (uint256) {
        return block.timestamp < deadline ? deadline - block.timestamp : 0;
    }

    function claimFunds() external onlyOwner {
        require(block.timestamp >= deadline, "Campaign still active");
        require(raised >= goal, "Goal not reached");
        require(!claimed, "Already claimed");
        claimed = true;
        emit FundsClaimed(raised);
        (bool success, ) = owner.call{value: raised}("");
        require(success, "ETH transfer failed");
    }

    function refund() external {
        require(block.timestamp >= deadline, "Campaign still active");
        require(raised < goal, "Goal reached");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "Nothing to refund");
        contributions[msg.sender] = 0;
        // raised remains the historical total, so the result cannot change after refunds.
        emit Refunded(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
