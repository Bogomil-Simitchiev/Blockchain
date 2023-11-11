// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**@title A sample Raffle Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */
contract Raffle {
    error Raffle_NotEnoughEthSent();
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    /* Events */
    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function entreRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle_NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
