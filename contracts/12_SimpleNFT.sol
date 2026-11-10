// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Manual test: mint twice, transfer, approve/spend, check cleared approval, withdraw revenue.

// Educational ERC-721-style subset, not a complete ERC-721 implementation.
contract SimpleNFT {
    string public name;
    string public symbol;
    address public owner;
    uint256 public nextTokenId;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public mintPrice = 0.01 ether;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approvals;
    event Minted(address indexed to, uint256 indexed tokenId);
    event TransferNFT(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    event PaymentsWithdrawn(uint256 amount);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }

    function mint() external payable returns (uint256) {
        require(msg.value == mintPrice, "Incorrect mint price");
        require(nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = nextTokenId++;
        ownerOf[tokenId] = msg.sender;
        balances[msg.sender] += 1;
        emit Minted(msg.sender, tokenId);
        emit TransferNFT(address(0), msg.sender, tokenId);
        return tokenId;
    }

    function transferNFT(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not token owner");
        _transfer(msg.sender, to, tokenId);
    }

    function approve(address spender, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not token owner");
        approvals[tokenId] = spender; // address(0) revokes an approval.
        emit Approval(msg.sender, spender, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(ownerOf[tokenId] != address(0), "Token does not exist");
        require(ownerOf[tokenId] == from, "Incorrect token owner");
        require(approvals[tokenId] == msg.sender, "Not approved spender");
        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        require(to != address(0), "Zero recipient");
        delete approvals[tokenId]; // Old permissions must not survive a transfer.
        balances[from] -= 1;
        balances[to] += 1;
        ownerOf[tokenId] = to;
        emit TransferNFT(from, to, tokenId);
    }

    function withdrawPayments() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No payments");
        emit PaymentsWithdrawn(amount);
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "ETH transfer failed");
    }
}
