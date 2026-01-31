// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {
    VRFConsumerBaseV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {
    VRFV2PlusClient
} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A Simple Raffle Contract
 * @author Mohd Shariq
 * @notice This contract is for creating a simple raffle
 * @dev Implementing chainlink VRF v2.5
 *
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* errors */
    error Raffle_NotEnoughETh();
    error Raffle_TransferFailed();
    error Raffle_RaffleNotOpen();
    error Raffle_UpkeepNotNeeded(
        uint256 balance,
        uint256 playersLength,
        uint256 raffleState
    );

    /* Type Declarations */
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1
    }

    /* State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entrance_fee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callBackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState; //start as open
    uint256 private counter; // For testing purpose

    /* Events */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner); // Added Event
    event RequestedRaffleWinner(uint256 indexed requestId);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gaslane,
        uint256 subscriptionId,
        uint32 callBackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entrance_fee = entranceFee;
        i_interval = interval;
        i_keyHash = gaslane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callBackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entrance_fee) {
            revert Raffle_NotEnoughETh();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // Chainlink Automation(UpKeeper) compatible functions
    /**
     * @dev This is the function that the Chainlink nodes will call to see
     * if the lottry is ready to have a winner picked.
     * the following should be true in order for upkeepNeeded to be true:
     * 1.the time interval has passed between raffle runs.
     * 2.the lottry is open
     * 3.the contract has ETH (has players)
     * 4. implicitly , your subscription is funded with LINK
     * @param - ignored
     * @return upkeepNeeded - true  if it's time to restart the lottry
     * @return - ignored
     */

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, (""));
    }

    function performUpkeep(bytes calldata /* performData */) external {
        // Check (if enough time has passed)
        (bool upkeepNeeded, ) = this.checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle_UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

        // if ((block.timestamp - s_lastTimeStamp) < i_interval) {
        //     revert Raffle_UpkeepNotNeeded();

        // Check if raffle is open
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }

        // State change
        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callBackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        // Request Random Number

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestedRaffleWinner(requestId);

        // Note: requestId is unused here, but that's okay correctly
    }

    // CEI: Check -> Effects -> Interactions Pattern
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal virtual override {
        //  Checks

        //  Effects  (internal contract state)
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0); // Reset players array
        s_lastTimeStamp = block.timestamp; // Reset timer
        emit WinnerPicked(s_recentWinner);

        //  Interactions (external contract intractions)
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle_TransferFailed();
        }
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entrance_fee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getNumberOfPlayers() external view returns (uint256) {
        return s_players.length;
    }
}
