// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract AuctionPlatform {
    // model of what an auction will have
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

    // error for insufficient amount sent
    error InsufficientAmount();

    // events when new auction is created and new highest bid is sent
    event NewAuction(uint256 indexed id);
    event NewHighestBid(uint256 indexed auctionId);

    // modifiers for checking if auction is active and if auction ended
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

    // index of every new auction creation
    uint256 count = 1;

    uint256 public timeNow = block.timestamp;

    // mappings for highest bids, auctions, is current auction finalized and is user available to withdraw
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

        // checks _start is greater than the current time, because auction must starts in future
        require(_start > block.timestamp, "Not correct start time");

        // _duration cannot be zero or less
        require(_duration > 0, "Duration cannot be zero or less");

        // current auction id
        uint256 auctionId = count;

        // increase the state variable every time when new auction is created -> [1, 2, 3, ....]
        count++;

        // sets new auction with current id
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

        // first highest bid is what creator sent
        highestBids[auctionId] = _startingPrice;

        // emit event for new auction creation
        emit NewAuction(auctionId);
    }

    function placeBid(
        uint256 _auctionId
    ) external payable onlyActiveAuction(_auctionId) {

        // gets the current auction
        Auction storage auction = auctions[_auctionId];

        // every user can place a bid except the creator of the auction
        require(msg.sender != auction.creator, "Creator cannot place bid");

        // current value must be higher than the starting price
        if (msg.value > auction.startingPrice) {
            uint256 prevBid = auction.startingPrice;
            address prevBidder = auction.highestBidder;

            // sets the new starting price and the new highest bidder, also saved the highest bid of the current auction
            auction.startingPrice = msg.value;
            auction.highestBidder = msg.sender;
            highestBids[_auctionId] = msg.value;

            // saves amount of previous user bids, who is not the highest bidder already
            availableToWithdrawal[prevBidder] += prevBid;
        } else {
            revert InsufficientAmount();
        }

        // new highest bid is set
        emit NewHighestBid(_auctionId);
    }

    function finalizeAuction(
        uint256 _auctionId
    ) external auctionEnded(_auctionId) {

        // gets the current auction, checks if auction is finalized and checks if msg.sender is the creator 
        Auction memory auction = auctions[_auctionId];
        require(
            isFinalized[_auctionId] == false,
            "Auction has already finalized"
        );
        require(auction.creator == msg.sender, "Only creator can finalize");

        // sets auction as finalized
        isFinalized[_auctionId] = true;
    }

    function withdraw() external payable {

        // gets the amount of current msg.sender
        uint256 amount = availableToWithdrawal[msg.sender];

        // amount must be greater than zero so it means user can withdraw his ETHs from the bidding (if user is not the highest bidder)
        require(amount > 0, "Nothing to tranfer");

        // sets his amount to 0
        availableToWithdrawal[msg.sender] = 0;

        // withdraw his ETHs
        payable(msg.sender).transfer(amount);
    }
}
