// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/GasMining.sol";
import "../src/mock/SOLOToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Reference existing token
        IERC20 token = IERC20(0xCEc192BACA961730c07Ad4CC59BbC6292f0DE8eb);

        // Deploy implementation contract
        GasMining implementation = new GasMining();
        
        // Set up initialization parameters
        uint256 blockReward = 5549213597000000000;    // ~5.55 tokens per block
        uint256 epochDuration = 900;                   // ~1 day in blocks
        
        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            GasMining.initialize.selector,
            address(token),
            blockReward,
            epochDuration,
            block.number
        );

        // Deploy proxy with initialization
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        // Get interface for logging
        GasMining gasMining = GasMining(address(proxy));

        // Calculate and transfer monthly tokens
        uint256 monthlyTokens = 14383561643424000000000000; 
        token.transfer(address(proxy), monthlyTokens);
        
        console.log("---------------------------------------");
        console.log("Deployment Details:");
        console.log("---------------------------------------");
        console.log("Implementation contract deployed at:", address(implementation));
        console.log("Proxy contract deployed at:", address(proxy));
        console.log("---------------------------------------");
        console.log("Configuration:");
        console.log("Block reward:", blockReward / 10**18, "tSOLO");
        console.log("Epoch duration:", epochDuration, "blocks");
        console.log("Initial funding:", monthlyTokens / 10**18, "tSOLO");
        console.log("Estimated runtime: ~30 days");
        console.log("---------------------------------------");

        vm.stopBroadcast();
    }
}
