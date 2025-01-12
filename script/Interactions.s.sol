// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";
import { Script, console } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundFundMe is Script {
  uint256 AMOUNT_TO_SEND = 0.1 ether;

  function fundFundMe(address mostRecentlyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentlyDeployed)).fund{ value: AMOUNT_TO_SEND }();
    vm.stopBroadcast();
    console.log("Funded FundMe with %s", AMOUNT_TO_SEND);
  }

  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
      "FundMe",
      block.chainid
    );
    fundFundMe(mostRecentlyDeployed);
  }
}

contract WithdrawFundMe is Script {
  function withdrawFundMe(address mostRecentlyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentlyDeployed)).withdraw();
    vm.stopBroadcast();
    console.log("Withdraw FundMe balance!");
  }

  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
      "FundMe",
      block.chainid
    );
    withdrawFundMe(mostRecentlyDeployed);
  }
}
