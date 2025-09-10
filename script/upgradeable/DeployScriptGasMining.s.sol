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
        SOLOToken soloToken = SOLOToken(payable(tokenAddress));

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


        ScriptLogger.logDeployment(
            "GAS_MINING",
            address(implementation),
            address(proxy),
            tokenAddress,
            blockReward,
            epochDuration,
            block.number
        );

    // Mint SOLO tokens to the GasMining contract, about enough for 1 year
    // 365*24*60*60* blockReward
    uint256 mintToAmount = 17500000000000000000000000;
    soloToken.mintTo(address(proxy), mintToAmount);
    vm.stopBroadcast();
    console.log("Minted SOLO tokens to GasMining contract at:", address(proxy));
    console.log("Amount minted (ether):", mintToAmount / 1e18);

    }
}
