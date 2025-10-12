// SPDX-License-Identifier: MIT
//It will narrow down the way we call the functions

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { MockV3Aggregator } from "../mocks/MocksV3Aggregator.sol";

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;
    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;
    uint256  public timesMintIsCalled;
    address[] public usersWithCollateral;
    MockV3Aggregator public ethUsdPriceFeed;

    constructor(DSCEngine _dsce, DecentralizedStableCoin _dsc) {
        dsce = _dsce;
        dsc = _dsc;
        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
    }

    function mintDsc(uint256 amount, uint256 addressSeed) public {
        if(usersWithCollateral.length == 0){
            return;
        }
    address sender = usersWithCollateral[addressSeed % usersWithCollateral.length];

    (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);
    int256 maxDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);
                timesMintIsCalled++;

    if(maxDscToMint <= 0){
        return;
    }

    amount = bound(amount, 1, uint256(maxDscToMint));
    vm.startPrank(sender);
    dsce.mintDsc(amount);
    vm.stopPrank();
}

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeeds(collateralSeed);
        
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        usersWithCollateral.push(msg.sender);
    }

    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeeds(collateralSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(msg.sender, address(collateral));
        
        // Don't redeem if user has no collateral
        if(maxCollateralToRedeem == 0){
            return;
        }
        
        // Check if user has DSC minted - if so, don't redeem collateral (would break health factor)
        (uint256 totalDscMinted,) = dsce.getAccountInformation(msg.sender);
        if(totalDscMinted > 0){
            return;
        }
        
        amountCollateral = bound(amountCollateral, 1, maxCollateralToRedeem);
        
        vm.prank(msg.sender);
        dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    // function updateCollateralPrice(uint96 newPrice) public {
    // int256 newPriceInt = int256(uint256(newPrice));
    // ethUsdPriceFeed.updateAnswer(newPriceInt);

    // }
    //Helper Functions 
 
    function _getCollateralFromSeeds(uint256 collateralSeed) public view returns (ERC20Mock) {
        if(collateralSeed % 2 == 0){
            return weth;
        }
        return wbtc;

    }
}
