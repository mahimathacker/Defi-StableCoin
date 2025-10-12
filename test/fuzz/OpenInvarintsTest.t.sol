// // SPDX-License-Identifier: MIT
// //It will have invarints ( Properties that should always hold )

// // What are the invariants of my protocol?

// // We need to ascertain which properties of our system must always hold. What are some for DecentralizedStableCoin?

// // The total supply of DSC should be less than the total value of collateral

// // Getter view functions should never revert

// pragma solidity ^0.8.20;
// import {Test, console} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {DSCEngine} from "../../src/DSCEngine.sol";
// import {DeployDsc} from "../../script/DeployDsc.s.sol";
// import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract OpenInvarintsTest is StdInvariant, Test {
//  DeployDsc deployer;
//  DSCEngine dsce;
//  DecentralizedStableCoin dsc;
//  HelperConfig helperConfig;

//  address weth;
//  address wbtc;
//     function setUp() external {
//         deployer = new DeployDsc();
// ( dsc, dsce, helperConfig) = deployer.run();
// (,,weth, wbtc,) = helperConfig.activeNetworkConfig();

// targetContract(address(dsce));

//     }
// function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
//     //get the value of all collateral in the engine and compare it to all the  debt(DSC)
//  uint256 totalSupply = dsc.totalSupply();
//  uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
//  uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

//  uint256 totalWethValue = dsce.getUsdValue(weth, totalWethDeposited);
//  uint256 totalWbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);
//  uint256 totalCollateralValue = totalWethValue + totalWbtcValue;

// console.log("weth value", totalWethValue);
// console.log("wbtc value", totalWbtcValue);
// console.log("total collateral value", totalCollateralValue);
// console.log("total supply", totalSupply);

//  assert(totalCollateralValue >= totalSupply);
// }

// }
