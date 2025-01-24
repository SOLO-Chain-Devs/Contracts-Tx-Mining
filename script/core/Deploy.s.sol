// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/core/GasMining.sol";
import "../../src/core/mock/SOLOToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/ScriptLogger.sol"; 

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address tokenAddress = vm.envAddress("NON_PROXY_SOLO_TOKEN_ADDRESS");
        IERC20 token = IERC20(tokenAddress);


        uint256 blockReward = 5549213597000000000;    
        uint256 epochDuration = 10800;          

        GasMining gasMining = new GasMining(
            address(token),
            blockReward,
            epochDuration,
            block.number
        );
        console.log("GasMining contract deployed at:", address(gasMining));

        // Log deployment details
        ScriptLogger.logSimpleDeployment(
            "GasMining",
            address(gasMining),
            tokenAddress,
            blockReward,
            epochDuration,
            block.number
        );

        vm.stopBroadcast();
    }
}
