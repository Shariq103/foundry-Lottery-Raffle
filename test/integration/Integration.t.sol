// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract IntegrationTest is Test {
    Raffle public raffle;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, ) = deployer.run();
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testUserCanFundAndEnter() public {
        // --- ARRANGE ---
        uint256 entranceFee = raffle.getEntranceFee();

        vm.prank(PLAYER);

        // --- ACT ---
        // Wo galat line yahan se hata di gayi hai.
        // Seedha enter karo:
        raffle.enterRaffle{value: entranceFee}();

        // --- ASSERT ---
        // Yahan check kar sakte ho ki player record hua ya nahi
        assertEq(raffle.getNumberOfPlayers(), 1);
    }
}
