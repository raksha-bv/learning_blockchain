// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";


contract DeployRaffle is Script{
    function run() external returns (Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        (uint64 subscriptionId,
        bytes32 gasLane, 
        uint256 interval,
        uint256 entranceFee,
        uint32 callbackGasLimit,
        address vrfCoordinatorV2,
        address link, 
        uint256 deployerKey)= helperConfig.activeNetwork();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            console.log("creating sub");
            (subscriptionId) =
                createSubscription.createSubscription(vrfCoordinatorV2, deployerKey);
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinatorV2, subscriptionId, link,deployerKey
            );
        }


        vm.startBroadcast();
        Raffle raffle=new Raffle(
        subscriptionId,
        gasLane, 
        interval,
        entranceFee,
        callbackGasLimit,
        vrfCoordinatorV2,
        link);
        vm.stopBroadcast();
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), vrfCoordinatorV2, subscriptionId, deployerKey);
        return (raffle,helperConfig);
    }
}