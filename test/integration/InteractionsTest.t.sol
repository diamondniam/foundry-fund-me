// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
  FundMe fundMe;

  address public DIAMOND = makeAddr("DIAMOND");
  uint256 public AMOUNT_TO_SEND = 10 ether;
  uint256 public STARTING_BALANCE = 20 ether;

  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(DIAMOND, STARTING_BALANCE);
  }

  function testUserCanFundAndOwnerCanWithdraw() public {
    vm.prank(DIAMOND);
    fundMe.fund{value: AMOUNT_TO_SEND}();

    WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    withdrawFundMe.withdrawFundMe(address(fundMe));

    assertEq(address(fundMe).balance, 0);
  }
}
