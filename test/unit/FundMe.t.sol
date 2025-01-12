// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe fundMe;

  address public DIAMOND = makeAddr("DIAMOND");
  uint256 public AMOUNT_TO_SEND = 10 ether;

  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(DIAMOND, 10 ether);
  }

  modifier funded() {
    vm.prank(DIAMOND);
    fundMe.fund{ value: AMOUNT_TO_SEND }();
    _;
  }

  modifier withdrew() {
    _;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingContractBalance = address(fundMe).balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingContractBalance = address(fundMe).balance;

    assertEq(endingContractBalance, 0);
    assertEq(
      endingOwnerBalance,
      startingContractBalance + startingOwnerBalance
    );
  }

  function testMinUSD() public view {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testValidateOwner() public view {
    assertEq(fundMe.getOwner(), msg.sender);
  }

  function testPriceConversionIsAccurate() public view {
    uint256 version = fundMe.getVersion();
    assertEq(version, 4);
  }

  function testFundNotEnoughETH() public {
    vm.expectRevert();
    fundMe.fund();
  }

  function testFundUpdatesData() public funded {
    uint256 amountFunded = fundMe.getAddressToAmountFunded(DIAMOND);
    assertEq(AMOUNT_TO_SEND, amountFunded);
  }

  function testAddsFunderToStorage() public funded {
    address funder = fundMe.getFunder(0);
    assertEq(DIAMOND, funder);
  }

  function testOnlyOwnerCanWithdraw() public funded {
    vm.expectRevert();
    fundMe.withdraw();
  }

  function testWithdrawWithSingleFunder() public funded withdrew {}

  function testWithdrawWithMultipleFunders() public withdrew {
    uint160 startingFunderIndex = 1;
    uint160 quantityOfFunders = 10;

    for (
      uint160 i = startingFunderIndex;
      startingFunderIndex < quantityOfFunders;
      startingFunderIndex++
    ) {
      hoax(address(i), AMOUNT_TO_SEND);
      fundMe.fund{ value: AMOUNT_TO_SEND }();
    }
  }
}
