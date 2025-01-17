// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/GasMining.sol";
import "../src/mock/SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployGasMiningScript is Script {
    function run() external {
        // Load the deployer's private key from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the SOLO token implementation and proxy
        SOLOToken tokenImplementation = new SOLOToken();
        bytes memory tokenInitData = abi.encodeWithSelector(
            SOLOToken.initialize.selector
        );
        ERC1967Proxy tokenProxy = new ERC1967Proxy(
            address(tokenImplementation),
            tokenInitData
        );
        SOLOToken token = SOLOToken(address(tokenProxy));

        // Deploy the GasMining implementation contract
        GasMining gasMiningImplementation = new GasMining();

        // Set initialization parameters for GasMining
        uint256 blockReward = 100 * 10**18;  // 5 tokens per block
        uint256 epochDuration = 7200;      // ~1 day in blocks
        uint256 latestClaimableBlock = block.number;

        // Encode initialization data for GasMining
        bytes memory gasMiningInitData = abi.encodeWithSelector(
            GasMining.initialize.selector,
            address(token),
            blockReward,
            epochDuration,
            latestClaimableBlock
        );

        // Deploy the GasMining proxy contract
        ERC1967Proxy gasMiningProxy = new ERC1967Proxy(
            address(gasMiningImplementation),
            gasMiningInitData
        );

        // Cast the proxy address to the GasMining interface
        GasMining gasMining = GasMining(address(gasMiningProxy));

        // Fund the GasMining contract with initial tokens
        uint256 initialFunding = 1_000_000 * 10**18; // 1,000,000 tokens
        token.mintTo(address(gasMining), initialFunding);

        // Log deployment details
        console.log("---------------------------------------");
        console.log("Deployment Details:");
        console.log("---------------------------------------");
        console.log("SOLO Token Implementation deployed at:", address(tokenImplementation));
        console.log("SOLO Token Proxy deployed at:", address(tokenProxy));
        console.log("GasMining Implementation deployed at:", address(gasMiningImplementation));
        console.log("GasMining Proxy deployed at:", address(gasMiningProxy));
        console.log("---------------------------------------");
        console.log("Configuration:");
        console.log("Block reward:", blockReward / 10**18, "tokens per block");
        console.log("Epoch duration:", epochDuration, "blocks");
        console.log("Initial funding:", initialFunding / 10**18, "tokens");
        console.log("---------------------------------------");

        vm.stopBroadcast();
    }
}
