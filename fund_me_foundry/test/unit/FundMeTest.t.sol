// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test ,console} from "forge-std/Test.sol";
import {FundMe} from  "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
  uint256 public constant SEND_VALUE = 0.1 ether; 
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    // modifier funded() {
    //     vm.prank(USER);
    //     fundMe.fund{value: SEND_VALUE}();
    //     assert(address(fundMe).balance > 0);
    //     _;
    // }

    function setUp() external{
        DeployFundMe deployFundMe= new DeployFundMe();
        fundMe=deployFundMe.run();
    }

    function testMinimumUsd() view public{
        assertEq(fundMe.minimumUsd(), 1e10);
    }

    function testOwnerIsMsgSender() view public{
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testVersion() view public{
        uint256 version=fundMe.getVersion();
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        fundMe.fund();
    }
    function testOnlyOwnerCanWithdraw() public {
        vm.expectRevert();
        vm.prank(address(2)); 
        fundMe.withdraw();
    }
    function testWithdrawFromASingleFunder() public {

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

      
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance 
        );
    }
    function testWithdrawFromMultipleFunders() public{
        uint160 numberOfFunders = 4;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            // vm.deal(address(i), STARTING_USER_BALANCE);
            // vm.startPrank(address(i));
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
            // vm.stopPrank();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        // assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }
}

