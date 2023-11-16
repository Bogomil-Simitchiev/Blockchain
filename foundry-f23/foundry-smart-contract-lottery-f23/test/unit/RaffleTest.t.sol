// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";

contract RaffleTest is Test {
    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        Raffle raffle = deployer.run();
    }
}
