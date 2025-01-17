// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/mock/SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScriptSOLOToken is Script {
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

        // Save addresses to .env file
        string memory implementationAddress = vm.toString(address(implementation));
        string memory proxyAddress = vm.toString(address(proxy));
        
        // Create or update .env file
        string[] memory inputs = new string[](3);
        inputs[0] = "echo";
        inputs[1] = string(abi.encodePacked(
            "IMPLEMENTATION_ADDRESS=", implementationAddress, "\n",
            "PROXY_ADDRESS=", proxyAddress, "\n"
        ));
        inputs[2] = ">.env";
        vm.ffi(inputs);

        // Optionally update .env.example
        inputs[2] = ">.env.example";
        vm.ffi(inputs);
    }
}
