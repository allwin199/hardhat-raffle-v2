// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHEntered();
    error Raffle__TransferFailed();

    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    //VRFCoordinator variables
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1; // only one random no is required

    // Lottery variables;
    address private s_recentWinner;

    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 _entranceFee,
        address _vrfCoordinatorV2,
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinatorV2) {
        i_entranceFee = _entranceFee;
        // vrf
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughETHEntered();
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    // this fn will be called be called automatically by chainlink keepers
    function requestRandomWinner() external {
        // to pick a random winner
        // 1. We need to get random number from chainlink VRF
        // - chainlink VRF is a 2 transaction process
        // - If it is done through 1 transaction it can be manipulated
        // - The current function we are in, will request for RandomNumber
        // - Then chainlink keepers will call `fullfillRandomnumbers` fn
        // 2. Then based on the random number, pick the winner.

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, // gasLane
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        // requestRandomWords will return a uint256 requestId based on who is requesting
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /* _requestId */,
        uint256[] memory _randomWords
    ) internal override {
        // for eg let's assume `_randomWords` has returned no 202
        // s_players array has 10 players.
        // To pick a random winner, we can use modulo
        // 202 % 10 = 2
        // since we are using s_players length, result will be always one of the index
        uint256 indexOfWinner = _randomWords[0] % s_players.length;
        // since we are getting only one random no, it will be at index 0.
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) revert Raffle__TransferFailed();
        emit WinnerPicked(recentWinner);
    }

    /* View / Pure functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 _playerIndex) public view returns (address) {
        return s_players[_playerIndex];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
