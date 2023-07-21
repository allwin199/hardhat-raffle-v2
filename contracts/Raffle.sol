// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Raffle {
    error Raffle__NotEnoughETHEntered();

    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    event RaffleEnter(address indexed player);

    constructor(uint256 _entranceFee) {
        i_entranceFee = _entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughETHEntered();
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    // function pickRandomWinner()

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 _playerIndex) public view returns (address) {
        return s_players[_playerIndex];
    }
}
