// Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/GasMining.sol";
import "../src/mock/SOLOToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IERC20 token = IERC20(0xCEc192BACA961730c07Ad4CC59BbC6292f0DE8eb);
        // Deploy DummyToken first
        //SOLOToken token = new SOLOToken();
        //console.log("---------------------------------------");
        //console.log("Deployment Details:");
        //console.log("---------------------------------------");
        //console.log("SOLOToken (tSOLO) deployed at:", address(token));
        //console.log("Total supply: 25,000,000 tSOLO");

        // Deploy GasMining with these parameters
        uint256 blockReward = 5549213597000000000;    // 100 tokens per block
        uint256 epochDuration = 900;          // ~1 day in blocks

        GasMining gasMining = new GasMining(
            address(token),
            blockReward,
            epochDuration,
            block.number
        );
        console.log("GasMining contract deployed at:", address(gasMining));

        // Calculate one month worth of tokens (assuming 12s block time)
        // incorrect calculations below
        // ~216,000 blocks per month (30 days) * 100 tokens per block
        uint256 monthlyTokens = 14383561643424000000000000; 
        token.transfer(address(gasMining), monthlyTokens);
        
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
