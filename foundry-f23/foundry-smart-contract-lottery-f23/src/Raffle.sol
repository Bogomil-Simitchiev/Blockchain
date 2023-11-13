// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**@title A sample Raffle Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */
abstract contract Raffle is VRFConsumerBaseV2{
    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;


    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionid;
    uint32 private immutable i_callbackGasLimit;


    uint256 private s_lastTimeStamp;

    address payable[] private s_players;
    address private s_recentWinner;


    /* Events */
    event EnteredRaffle(address indexed player);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionid,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionid = subscriptionid;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_lastTimeStamp < i_interval)) {
            revert();
        }
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionid,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        
    }
     function fulfillRandomWords(
        uint256  requestId,
        uint256[] memory randomWords
    ) internal override {
       uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        (bool success, ) = winner.call{value: address(this).balance}("");
        // require(success, "Transfer failed");
        if (!success) {
            revert Raffle__TransferFailed();
        }

    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
