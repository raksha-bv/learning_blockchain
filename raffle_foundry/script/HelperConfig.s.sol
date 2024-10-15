// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script{
     struct NetworkConfig {
        uint64 subscriptionId;
        bytes32 gasLane;
        uint256 interval;
        uint256 entranceFee;
        uint32 callbackGasLimit;
        address vrfCoordinatorV2;
        address link;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetwork;
    uint256 public constant DEFAULT_ANVIL_KEY =0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    constructor(){
        if(block.chainid==43113){
            activeNetwork= getZKSyncNetworkConfig();
        }
        else if(block.chainid==11155111){
            activeNetwork= getSepoliaNetworkConfig();
        }
        else{
            activeNetwork=getAnvilNetworkConfig();
        }
    }

    function getZKSyncNetworkConfig() public view returns(NetworkConfig memory){
        return NetworkConfig({
            subscriptionId: 0,
            gasLane: 0xc799bd1e3bd4d1a41cd4968997a4e03dfd2a3c7c04b695881138580163f42887,
            interval: 30,
            entranceFee: 0.01 ether,
            callbackGasLimit: 50000,
            vrfCoordinatorV2: 0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE,
            link: 0x23A1aFD896c8c8876AF46aDc38521f4432658d1e,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getSepoliaNetworkConfig() public view returns(NetworkConfig memory){
        return NetworkConfig({
            subscriptionId: 0,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            interval: 30,
            entranceFee: 0.01 ether,
            callbackGasLimit: 50000,
            vrfCoordinatorV2: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getAnvilNetworkConfig() public returns(NetworkConfig memory){
        if(activeNetwork.vrfCoordinatorV2!=address(0)){
           return activeNetwork;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;
        LinkToken link = new LinkToken();

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2 = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        vm.stopBroadcast();

        return NetworkConfig({
            subscriptionId: 0,
            gasLane: 0xc799bd1e3bd4d1a41cd4968997a4e03dfd2a3c7c04b695881138580163f42887,
            interval: 30,
            entranceFee: 0.01 ether,
            callbackGasLimit: 50000,
            vrfCoordinatorV2: address(vrfCoordinatorV2),
            link: address(link),
            deployerKey:DEFAULT_ANVIL_KEY
        });
    }
}


