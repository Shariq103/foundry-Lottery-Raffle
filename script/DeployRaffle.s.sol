// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {
    CreateSubscription,
    FundSubscription,
    AddConsumer
} from "script/Interaction.s.sol";

contract DeployRaffle is Script {
    // Update: 'external' aur 'returns' add kiya
    function run() external returns (Raffle, HelperConfig) {
        return deployContract(); // <--- 'return' keyword add kiya
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        //  local -> deploy mock, get local config
        // sepolia -> get sepolia config
        HelperConfig.NetworkConfig memory Config = helperConfig.getConfig();

        if (Config.subscriptionId == 0) {
            //create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (Config.subscriptionId, Config.vrfCoordinator) = createSubscription
                .createSubscription(Config.vrfCoordinator, Config.account);

            // Fund it!
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                Config.vrfCoordinator,
                Config.subscriptionId,
                Config.link,
                Config.account
            );
        }

        vm.startBroadcast(Config.account);
        Raffle raffle = new Raffle(
            Config.entranceFee,
            Config.interval,
            Config.vrfCoordinator,
            Config.gaslane,
            Config.subscriptionId,
            Config.callBackGasLimit
        );

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            Config.vrfCoordinator,
            Config.subscriptionId,
            Config.account
        );

        return (raffle, helperConfig);
    }
}
