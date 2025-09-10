// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../../src/upgradeable/mock/SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./lib/ScriptLogger.sol";

contract UpgradeScriptSOLOToken is Script {
    using ScriptLogger for *;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("SOLO_PROXY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        SOLOToken newImplementation = new SOLOToken();

        // Upgrade proxy to new implementation
        SOLOToken proxy = SOLOToken(proxyAddress);
        proxy.upgradeToAndCall(address(newImplementation), "");

        vm.stopBroadcast();

        ScriptLogger.logUpgrade("SOLO_TOKEN", address(newImplementation), proxyAddress);
    }
}
