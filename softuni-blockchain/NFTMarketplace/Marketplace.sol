// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./Event.sol";

contract Marketplace {
    address[] public events;

    event NewEvent(address creator, address eventAddr);

    function createEvent(
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _ticketsPrice,
        uint256 _maxTickets,
        string memory _metadata
    ) external {
        address newEvent = address(new Event(msg.sender, _saleStart, _saleEnd, _ticketsPrice, _maxTickets, _metadata));
        events.push(newEvent);
        emit NewEvent(msg.sender, newEvent);
    }
}