// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script,console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNft is Script{
    function svgToImage(string memory svg) public pure returns(string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory encodedUrl= Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseUrl,encodedUrl));
    }

    function run() external returns(MoodNft){
        string memory sadSvg = vm.readFile("./Images/sad.svg");
        string memory happySvg = vm.readFile("./Images/happy.svg");
        vm.startBroadcast();
        MoodNft moodNft = new MoodNft(svgToImage(sadSvg),svgToImage(happySvg));
        vm.stopBroadcast();
        return moodNft;
    }

    
}
