// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract AuctionPlatform {
    struct Auction {
        uint256 id;
        uint256 start;
        uint256 duration;
        string itemName;
        string itemDescription;
        uint256 startingPrice;
        address creator;
        address highestBidder;
    }

    error InsufficientAmount();

    event NewAuction(uint256 indexed id);
    event NewHighestBid(uint256 indexed auctionId);

    modifier onlyActiveAuction(uint256 _auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(auction.start <= block.timestamp, "auction is not started yet");

        require(auction.duration >= block.timestamp, "auction already ended");

        _;
    }
    modifier auctionEnded(uint256 _auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(auction.duration < block.timestamp, "auction is not ended");

        _;
    }

    uint256 count = 1;

    uint256 public timeNow = block.timestamp;

    mapping(uint256 => uint256) public highestBids;
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => bool) public isFinalized;
    mapping(address => uint256) public availableToWithdrawal;

    function createAuction(
        uint256 _start,
        uint256 _duration,
        string memory _itemName,
        string memory _itemDescription,
        uint256 _startingPrice
    ) external {
        require(_start > block.timestamp, "Not correct start time");
        require(_duration > 0, "Duration cannot be zero or less");

        uint256 auctionId = count;

        count++;

        auctions[auctionId] = Auction(
            auctionId,
            _start,
            _start + _duration,
            _itemName,
            _itemDescription,
            _startingPrice,
            msg.sender,
            msg.sender
        );

        highestBids[auctionId] = _startingPrice;

        emit NewAuction(auctionId);
    }

    function placeBid(
        uint256 _auctionId
    ) external payable onlyActiveAuction(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(msg.sender != auction.creator, "Creator cannot place bid");

        if (msg.value > auction.startingPrice) {
            uint256 prevBid = auction.startingPrice;
            address prevBidder = auction.highestBidder;

            auction.startingPrice = msg.value;
            auction.highestBidder = msg.sender;
            highestBids[_auctionId] = msg.value;
            availableToWithdrawal[prevBidder] += prevBid;
        } else {
            revert InsufficientAmount();
        }

        emit NewHighestBid(_auctionId);
    }

    function finalizeAuction(
        uint256 _auctionId
    ) external auctionEnded(_auctionId) {
        Auction memory auction = auctions[_auctionId];
        require(
            isFinalized[_auctionId] == false,
            "Auction has already finalized"
        );
        require(auction.creator == msg.sender, "Only creator can finalize");

        isFinalized[_auctionId] = true;
    }

    function withdraw() external payable {
        uint256 amount = availableToWithdrawal[msg.sender];
        require(amount > 0, "Nothing to tranfer");
        availableToWithdrawal[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
