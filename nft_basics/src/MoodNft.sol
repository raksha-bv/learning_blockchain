// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantflipMood();
    enum NFTState {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    mapping(uint256 => NFTState) private s_tokenIdToState;
    // mapping (uint256 => string) private s_tokenIdToUri;
    constructor(string memory sadSvgImageUri, string memory happySvgImageUri) ERC721("Mood", "MN"){
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri;
    }

    function mintNft() public{
        // s_tokenIdToUri[s_tokenCounter]=tokenURI;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        s_tokenIdToState[s_tokenCounter]=NFTState.HAPPY;
    }

    function flipMood(uint256 tokenId) public {
        if(getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender){
            revert MoodNft__CantflipMood();
        }
        if(s_tokenIdToState[tokenId]== NFTState.HAPPY){
            s_tokenIdToState[tokenId]=NFTState.SAD;
        }
        else{
            s_tokenIdToState[tokenId]=NFTState.HAPPY;
        }

    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory){
        string memory imageUri;
        if(s_tokenIdToState[tokenId]==NFTState.HAPPY){
            imageUri=s_happySvgImageUri;
        }
        else{
            imageUri=s_sadSvgImageUri;
        }
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageUri,
                            '"}'
                        )
                    )
                )
            )
        );

    }

    
}