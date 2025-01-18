// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/GasMining.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./lib/ScriptLogger.sol";  

contract UpgradeScriptGasMining is Script {
    using ScriptLogger for *;
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("GASMINING_PROXY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        GasMining newImplementation = new GasMining();

        // Upgrade proxy to new implementation
        GasMining proxy = GasMining(proxyAddress);
        proxy.upgradeToAndCall(address(newImplementation), "");

        vm.stopBroadcast();

        // Log upgrade information
        ScriptLogger.logUpgrade(
            "GAS_MINING",
            address(newImplementation),
            proxyAddress
        );
    }
}
