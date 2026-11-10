// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: 5 entries at 0.01 ETH, reject wrong fee/role, draw, check payout/reset.

contract Lottery {
    address payable[] private players;
    address public manager;
    uint256 public entryFee;
    uint256 public minPlayers;
    bool private drawing;
    event Entered(address indexed player, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 amount);

    constructor(uint256 _entryFee, uint256 _minPlayers) {
        require(_entryFee > 0 && _minPlayers > 0, "Invalid lottery");
        manager = msg.sender;
        entryFee = _entryFee;
        minPlayers = _minPlayers;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Not manager");
        _;
    }

    function enter() public payable {
        require(!drawing, "Drawing in progress");
        require(msg.sender != manager, "Manager cannot enter");
        require(msg.value == entryFee, "Incorrect entry fee");
        players.push(payable(msg.sender));
        emit Entered(msg.sender, msg.value);
    }

    function playersCount() public view returns (uint256) { return players.length; }

    function pickWinner() public onlyManager {
        require(!drawing, "Drawing in progress");
        require(players.length >= minPlayers, "Not enough players");
        // Assignment demonstration only: blockhash is predictable/manipulable.
        uint256 index = uint256(blockhash(block.number - 1)) % players.length;
        address payable winner = players[index];
        uint256 amount = address(this).balance;
        drawing = true;
        delete players;
        emit WinnerSelected(winner, amount);
        (bool success, ) = winner.call{value: amount}("");
        require(success, "ETH transfer failed");
        drawing = false;
    }
}
