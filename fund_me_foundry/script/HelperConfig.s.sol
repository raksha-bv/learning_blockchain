// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed;
    }

    NetworkConfig public activeConfig;
    constructor(){
        if (block.chainid== 84532){
        activeConfig = getBaseConfig();
        }
        else if(block.chainid==300){
            activeConfig = getZKsyncConfig();
        }
        else{
            activeConfig = getAnvilConfig();
        }
    }

    function getBaseConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory BaseConfig= NetworkConfig({priceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1});
        return BaseConfig;
    }
    function getZKsyncConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ZKsyncConfig= NetworkConfig({priceFeed: 0x61Ec26aA57019C486B10502285c5A3D4A4750AD7});
        return ZKsyncConfig;
    }

function getAnvilConfig() public returns (NetworkConfig memory) {
        if(activeConfig.priceFeed!=address(0)){
            return  activeConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed= new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory AnvilConfig= NetworkConfig({priceFeed: address(mockPriceFeed)});
        return AnvilConfig;
    }

}