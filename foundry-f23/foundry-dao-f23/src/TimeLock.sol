// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {TimelockController} from "../lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";

contract TimeLock is TimelockController {
      constructor(uint256 minDelay, address[] memory proposers, address[] memory executors)
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}
