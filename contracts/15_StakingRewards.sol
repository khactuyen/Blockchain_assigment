// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: 1/2 ETH stakes, wait, claim/top-up/rate change/exit; reject empty pool.

contract StakingRewards {
    address payable public owner;
    // Wei of rewards per 1 ETH staked per second; see README's PDF clarification.
    uint256 public rewardRatePerSecond;
    uint256 public constant RATE_SCALE = 1 ether;
    uint256 public totalStaked;
    uint256 public rewardPool;
    struct Stake { uint256 amount; uint256 startTime; uint256 rewardDebt; }
    mapping(address => Stake) public stakes;

    // Integral of rate over time. Checkpoints preserve the OLD rate for past time.
    uint256 public cumulativeRate;
    uint256 public lastRateUpdate;
    mapping(address => uint256) public paidRate;
    mapping(address => uint256) private rewardRemainder;
    bool private entered;
    event Staked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event Unstaked(address indexed user, uint256 principal, uint256 reward);
    event RewardsFunded(uint256 amount);
    event RewardRateChanged(uint256 oldRate, uint256 newRate);

    constructor(uint256 _rate) payable {
        owner = payable(msg.sender);
        rewardRatePerSecond = _rate;
        rewardPool = msg.value;
        lastRateUpdate = block.timestamp;
        emit RewardsFunded(msg.value);
    }

    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }
    modifier nonReentrant() {
        require(!entered, "Reentrant call");
        entered = true;
        _;
        entered = false;
    }

    function _currentRate() private view returns (uint256) {
        return cumulativeRate + rewardRatePerSecond * (block.timestamp - lastRateUpdate);
    }

    function _checkpoint(address user) private {
        uint256 current = _currentRate();
        Stake storage position = stakes[user];
        uint256 numerator = position.amount * (current - paidRate[user]) + rewardRemainder[user];
        position.rewardDebt += numerator / RATE_SCALE;
        rewardRemainder[user] = numerator % RATE_SCALE;
        position.startTime = block.timestamp;
        paidRate[user] = current;
    }

    function stake() external payable nonReentrant {
        require(msg.value > 0, "Zero stake");
        _checkpoint(msg.sender); // Snapshot OLD amount before increasing principal.
        stakes[msg.sender].amount += msg.value;
        totalStaked += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function pendingReward(address user) public view returns (uint256) {
        Stake storage position = stakes[user];
        uint256 numerator = position.amount * (_currentRate() - paidRate[user]) + rewardRemainder[user];
        return position.rewardDebt + numerator / RATE_SCALE;
    }

    function claimReward() external nonReentrant {
        _checkpoint(msg.sender);
        Stake storage position = stakes[msg.sender];
        uint256 reward = position.rewardDebt;
        require(reward > 0, "No reward");
        require(reward <= rewardPool, "Insufficient reward pool");
        position.rewardDebt = 0;
        rewardPool -= reward;
        emit RewardClaimed(msg.sender, reward);
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "ETH transfer failed");
    }

    function unstake() external nonReentrant {
        require(stakes[msg.sender].amount > 0, "No stake");
        _checkpoint(msg.sender);
        uint256 principal = stakes[msg.sender].amount;
        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward <= rewardPool, "Insufficient reward pool");
        totalStaked -= principal;
        rewardPool -= reward;
        delete stakes[msg.sender];
        delete rewardRemainder[msg.sender]; // Sub-wei dust is discarded on full exit.
        delete paidRate[msg.sender];
        emit Unstaked(msg.sender, principal, reward);
        (bool success, ) = payable(msg.sender).call{value: principal + reward}("");
        require(success, "ETH transfer failed");
    }

    function fundRewards() external payable onlyOwner nonReentrant {
        require(msg.value > 0, "Zero funding");
        rewardPool += msg.value;
        emit RewardsFunded(msg.value);
    }

    function setRewardRate(uint256 _newRate) external onlyOwner nonReentrant {
        cumulativeRate = _currentRate();
        lastRateUpdate = block.timestamp;
        emit RewardRateChanged(rewardRatePerSecond, _newRate);
        rewardRatePerSecond = _newRate;
    }
}
