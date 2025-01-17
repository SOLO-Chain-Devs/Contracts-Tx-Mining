// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/mock/SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeScriptSOLOToken is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        SOLOToken newImplementation = new SOLOToken();

        // Upgrade proxy to new implementation
        SOLOToken proxy = SOLOToken(proxyAddress);
        proxy.upgradeToAndCall(address(newImplementation), "");

        vm.stopBroadcast();

        // Update implementation address in .env
        string memory newImplementationAddress = vm.toString(address(newImplementation));
        
        // Update .env file with new implementation
        string[] memory inputs = new string[](3);
        inputs[0] = "echo";
        inputs[1] = string(abi.encodePacked(
            "IMPLEMENTATION_ADDRESS=", newImplementationAddress, "\n",
            "PROXY_ADDRESS=", vm.toString(proxyAddress), "\n"
        ));
        inputs[2] = ">.env";
        vm.ffi(inputs);
    }
}
