// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: bids 0.11/0.12 ETH, reject 0.121, pull refund, expire, end once.

contract EnglishAuction {
    address payable public seller;
    uint256 public auctionEnd;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public constant MIN_INCREMENT = 5;
    mapping(address => uint256) public pendingReturns;
    bool public ended;
    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event PendingWithdrawn(address indexed bidder, uint256 amount);

    constructor(uint256 _biddingSeconds, uint256 _startPrice) {
        require(_biddingSeconds > 0 && _startPrice > 0, "Invalid auction");
        seller = payable(msg.sender);
        auctionEnd = block.timestamp + _biddingSeconds;
        highestBid = _startPrice;
    }

    function bid() external payable {
        require(!ended && block.timestamp < auctionEnd, "Auction ended");
        // Round UP: integer truncation must not allow an increment below 5%.
        uint256 increment = highestBid / 100 * MIN_INCREMENT
            + ((highestBid % 100) * MIN_INCREMENT + 99) / 100;
        require(msg.value >= highestBid + increment, "Bid increment below 5%");
        if (highestBidder != address(0)) pendingReturns[highestBidder] += highestBid;
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit NewBid(msg.sender, msg.value);
    }

    function withdrawPending() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No pending return");
        pendingReturns[msg.sender] = 0;
        emit PendingWithdrawn(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");
        return true;
    }

    function endAuction() external {
        require(block.timestamp >= auctionEnd, "Auction still active");
        require(!ended, "Already ended");
        ended = true;
        // The start price is not actual ETH. With no bids, pay nothing.
        uint256 amount = highestBidder == address(0) ? 0 : highestBid;
        emit AuctionEnded(highestBidder, amount);
        if (amount > 0) {
            (bool success, ) = seller.call{value: amount}("");
            require(success, "ETH transfer failed");
        }
    }
}
