// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.20;
import { Test } from "forge-std/Test.sol";
import { DSCEngine} from "../../src/DSCEngine.sol";
import { DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import { HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDsc} from '../../script/DeployDsc.s.sol';
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDsc deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig public helperConfig;
    address public weth;
    address public ethUsdPriceFeeds;
    address public USER = makeAddr("user");
uint256 public constant AMOUNT_COLLATERAL = 10 ether;
uint256 public constant STARTING_ERC20_BALANCE = 10 ether;
    function setUp() public {
        deployer = new DeployDsc();
        (dsc, dsce, helperConfig) = deployer.run();
        (ethUsdPriceFeeds, , weth, ,) = helperConfig.activeNetworkConfig();
            ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);


 }

 ////////////////////////////////
 // Price Tests //
 ////////////////////////////////

function testGetUsdValue() public {
    // 15e18 * 2,000/ETH = 30,000e18
    uint256 ethAmount = 15e18;
    uint256 expectedUsd = 30000e18;
    uint256 actualUsd = dsce.getUsdValue(weth, ethAmount);
    assertEq(expectedUsd, actualUsd);
}

///////////////////////////////
// Depositcollatoral Tests //
///////////////////////////////

function testRevertsIfCollateralZero() public {
    vm.startPrank(USER);
    ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
    vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
    dsce.depositCollateral(weth, 0);
    vm.stopPrank();
}
}