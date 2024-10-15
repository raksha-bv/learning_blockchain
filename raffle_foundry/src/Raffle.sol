// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 currentBalance, RaffleState raffleState, uint256 numPlayers);

    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);
    enum RaffleState {
        OPEN, 
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS=3;
    uint32 private constant NUM_WORDS=1;

    uint256 private immutable i_entranceFee;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 private immutable i_interval;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;


    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    uint256 private s_subscriptionId;
    address private s_recentWinner;
    bool private s_enableNativePayment;
    RaffleState private s_raffleState;
    


   constructor(
        uint64 subscriptionId,
        bytes32 gasLane, // keyHash
        uint256 interval,
        uint256 entranceFee,
        uint32 callbackGasLimit,
        address vrfCoordinatorV2,
        address link
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_interval = interval;
        s_subscriptionId = subscriptionId;
        i_entranceFee = entranceFee;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_callbackGasLimit = callbackGasLimit;
    }


    function enterRaffle() external payable{
        if(msg.value<i_entranceFee){
            revert Raffle__NotEnoughEthSent();
        }
        if(s_raffleState!= RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0"); // can we comment this out?
    }



    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_raffleState,
                s_players.length  
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            uint64(s_subscriptionId),
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }
    function fulfillRandomWords(uint256 /*requestId*/, uint256[] memory randomWords) internal override{
        uint256 indexOfWinner=randomWords[0] % s_players.length;
        address payable winner=s_players[indexOfWinner];
        s_recentWinner=winner;
        s_raffleState=RaffleState.OPEN;

        s_players=new address payable[](0);
        s_lastTimeStamp=block.timestamp;
        emit WinnerPicked(winner);

        (bool success, )= winner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
    }

    function getEntranceFee() public view returns(uint256){
        return i_entranceFee;
    }
    function getRaffleState() public view returns(RaffleState){
        return s_raffleState;
    }
    function getPlayer(uint256 indexPlayer) public view returns(address){
        return s_players[indexPlayer];
    }
    function getRecentWinner() public view returns(address){
        return s_recentWinner;
    }
    function getLastTimeStamp() public view returns(uint256){
        return s_lastTimeStamp;
    }
    function getInterval() public view returns (uint256) {
        return i_interval;
    }
    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }
}