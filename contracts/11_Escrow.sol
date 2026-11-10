// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: four instances for delivery/refund/two dispute outcomes; reject wrong states.

contract Escrow {
    enum State { AwaitingPayment, AwaitingDelivery, Complete, Refunded, Disputed }
    address payable public buyer;
    address payable public seller;
    address payable public arbiter;
    State public state;
    event StateChanged(State newState);
    event PaymentReleased(address indexed to, uint256 amount);

    constructor(address payable _seller, address payable _arbiter) payable {
        require(msg.value > 0, "Payment required at deployment");
        require(_seller != address(0) && _arbiter != address(0), "Zero party");
        require(_seller != msg.sender && _arbiter != msg.sender && _seller != _arbiter,
            "Parties must be distinct");
        buyer = payable(msg.sender);
        seller = _seller;
        arbiter = _arbiter;
        state = State.AwaitingDelivery;
        emit StateChanged(state);
    }

    modifier onlyBuyer() { require(msg.sender == buyer, "Not buyer"); _; }
    modifier onlyArbiter() { require(msg.sender == arbiter, "Not arbiter"); _; }
    modifier onlyArbiterOrSeller() {
        require(msg.sender == arbiter || msg.sender == seller, "Not arbiter or seller"); _;
    }
    modifier onlyBuyerOrSeller() {
        require(msg.sender == buyer || msg.sender == seller, "Not buyer or seller"); _;
    }
    modifier stateCheck(State expected) { require(state == expected, "Wrong state"); _; }

    function confirmDelivery() external onlyBuyer stateCheck(State.AwaitingDelivery) {
        _release(seller, State.Complete);
    }

    function refundBuyer() external onlyArbiterOrSeller stateCheck(State.AwaitingDelivery) {
        _release(buyer, State.Refunded);
    }

    function raiseDispute() external onlyBuyerOrSeller stateCheck(State.AwaitingDelivery) {
        state = State.Disputed;
        emit StateChanged(state);
    }

    function resolveToSeller() external onlyArbiter stateCheck(State.Disputed) {
        _release(seller, State.Complete);
    }

    function resolveToBuyer() external onlyArbiter stateCheck(State.Disputed) {
        _release(buyer, State.Refunded);
    }

    function _release(address payable to, State finalState) private {
        uint256 amount = address(this).balance;
        state = finalState;
        emit StateChanged(state);
        emit PaymentReleased(to, amount);
        (bool success, ) = to.call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
