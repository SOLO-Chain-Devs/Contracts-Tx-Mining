// Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/GasMining.sol";
import "../src/mock/DummyToken.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy DummyToken first
        DummyToken token = new DummyToken();
        console.log("---------------------------------------");
        console.log("Deployment Details:");
        console.log("---------------------------------------");
        console.log("DummyToken (DUMMY) deployed at:", address(token));
        console.log("Total supply: 25,000,000 DUMMY");

        // Deploy GasMining with these parameters
        uint256 blockReward = 100 * 10**18;    // 100 tokens per block
        uint256 epochDuration = 7200;          // ~1 day in blocks

        GasMining gasMining = new GasMining(
            address(token),
            blockReward,
            epochDuration
        );
        console.log("GasMining contract deployed at:", address(gasMining));

        // Calculate one month worth of tokens (assuming 12s block time)
        // ~216,000 blocks per month (30 days) * 100 tokens per block
        uint256 monthlyTokens = 22_000_000 * 10**18; // Adding buffer for safety
        token.transfer(address(gasMining), monthlyTokens);
        
        console.log("---------------------------------------");
        console.log("Configuration:");
        console.log("Block reward:", blockReward / 10**18, "DUMMY");
        console.log("Epoch duration:", epochDuration, "blocks");
        console.log("Initial funding:", monthlyTokens / 10**18, "DUMMY");
        console.log("Estimated runtime: ~30 days");
        console.log("---------------------------------------");

        vm.stopBroadcast();
    }
}
