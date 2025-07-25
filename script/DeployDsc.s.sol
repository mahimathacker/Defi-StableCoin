// SPDK-License-Identifier: MIT

import { Script } from "forge-std/Script.sol";
import { DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import { DSCEngine} from "../src/DSCEngine.sol";
import { HelperConfig} from "./HelperConfig.s.sol";
contract DeployDsc is Script {

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns(DecentralizedStableCoin, DSCEngine, HelperConfig) {

        HelperConfig helperConfig = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];
        vm.startBroadcast(deployerKey);
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine engine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();
        return (dsc, engine, helperConfig);

    }

}