//SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
 * @title DSCEngine
 * @author Mahima Thacker
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract DSCEngine is ReentrancyGuard {
    ////////////////////////////////
    //Errors//
    ////////////////////////////////

    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesLengthsMustBeTheSame();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__HealthFactorIsBroken();
    error DSCEngine__MintFailed();

    ////////////////////////////////
    //State Variables//
    ////////////////////////////////
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    mapping(address token => address priceFeed) public s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;
    DecentralizedStableCoin private immutable i_dsc;
    address[] private s_collateralTokens;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    ////////////////////////////////
    //Events//
    ////////////////////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);


    ////////////////////////////////
    //Modifiers//
    ////////////////////////////////

    modifier morethanZero(uint256 amount) {
        //USD Price Feeds

        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }

        _; //Insert the function code here. It's used inside modifiers to control when and where the function logic should execute.
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__NotAllowedToken();
        }
        _;
    }

    ////////////////////////////////
    // Functions //
    ////////////////////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesLengthsMustBeTheSame();
        }
        //For example ETH/USD, BTC/USD, etc.
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ////////////////////////////////
    // External Functions //
    ////////////////////////////////

    function depositCollateralAndMintDSC() external {}
    /*
    * @notice following CEI ( Checks, Effects, Interactions )
    * @param tokenCollateralAddress The address of the token to deposit as collateral
    * @param amountCollateral The amount of collateral to deposit
    */

    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        morethanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if(!success){
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

/* 
* @notice You can only mint DSC if you have  enough collateral
* @param amountDscToMint The amount of DSC to mint
*/

    function mintDsc(uint256 amountDscToMint) external  morethanZero(amountDscToMint) nonReentrant{
       s_DSCMinted[msg.sender] += amountDscToMint;
      bool minted = i_dsc.mint(msg.sender, amountDscToMint);
      if(!minted){
        revert DSCEngine__MintFailed();
      }
       //if mintes $150 and they have balance of $100, it will revert
        _revertIfHealthFactorIsBroken(msg.sender);
        
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    ////////////////////////////////
    //Private, Internal, View & Pure Functions //
    ////////////////////////////////

function _getAccountInformation(address user) private view returns (uint256 totalDscMinted, uint256 totalCollateralValue){
    totalDscMinted = s_DSCMinted[user];
    totalCollateralValue = getCollateralValue(user);
}
    /* 
    Returns how close to liquidation a user is
    and user can get liquidated if the health factor is below 1
    */ 

    function _healthFactor(address user) private  view returns (uint256) {
        //total DC Minted
        //total collateral value
        (uint256 totalDscMinted, uint256 totalCollateralValue) = _getAccountInformation(user);
        uint256 collateralAdjustedForThreshold = (totalCollateralValue * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }
            //Check if the user has enough collateral and revert otherwise

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 healthFactor = _healthFactor(user);
        if(healthFactor < MIN_HEALTH_FACTOR){
            revert DSCEngine__HealthFactorIsBroken();
        }

}

///////////////////////////////
// Public and   External View Function //
///////////////////////////////

function getCollateralValue(address user) public view returns (uint256 totalCollateralValue){
    //loop through collateral tokens, get amount, and map to price to get USD value

    for(uint256 i = 0; i < s_collateralTokens.length; i++){
        address token = s_collateralTokens[i];
        uint256 amount = s_collateralDeposited[user][token];
        totalCollateralValue += getUsdValue(token, amount);
    }
    return totalCollateralValue;


}
function getUsdValue(address token, uint256 amount) public view returns (uint256){
    AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return (uint256(price) * amount * ADDITIONAL_FEED_PRECISION) / PRECISION;
}

}