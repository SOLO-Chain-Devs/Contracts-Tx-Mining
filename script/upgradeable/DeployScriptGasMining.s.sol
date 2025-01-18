// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../../src/upgradeable/GasMining.sol";
import "../../src/upgradeable/mock/SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./lib/ScriptLogger.sol";

contract DeployScriptGasMining is Script {
    using ScriptLogger for *;
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("SOLO_PROXY_ADDRESS"); 

        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        GasMining implementation = new GasMining();

        uint256 blockReward = 5549213597000000000;    // ~5.55 eth tokens per block
        uint256 epochDuration = 10800;                   // ~3 hours in blocks/sec on SOLO
        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            GasMining.initialize.selector,
            tokenAddress,   
            blockReward,    
            epochDuration,  
            block.number   
        );

        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        ScriptLogger.logDeployment(
            "GAS_MINING",
            address(implementation),
            address(proxy),
            tokenAddress,
            blockReward,
            epochDuration,
            block.number
        );
    }
}
