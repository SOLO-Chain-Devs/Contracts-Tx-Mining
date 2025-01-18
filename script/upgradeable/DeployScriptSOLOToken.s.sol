// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../../src/upgradeable/mock/SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./lib/ScriptLogger.sol";
contract DeployScriptSOLOToken is Script {
    using ScriptLogger for *;
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        SOLOToken implementation = new SOLOToken();
        
        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            SOLOToken.initialize.selector
        );

        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        vm.stopBroadcast();

        ScriptLogger.logDeployment(
            "SOLO_TOKEN",            // Contract name
            address(implementation), // Implementation address
            address(proxy),         // Proxy address
            address(0),             // Token address (not needed for SOLO token)
            0,                      // Block reward (not needed for SOLO token)
            0,                      // Epoch duration (not needed for SOLO token)
            block.number            // Starting block
        );
    }
}
