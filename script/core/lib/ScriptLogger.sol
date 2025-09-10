// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/console.sol";
import "forge-std/console2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library ScriptLogger {
    string private constant SEPARATOR =
        "================================================================================";

    function logSimpleDeployment(
        string memory contractName,
        address contractAddress,
        address tokenAddress,
        uint256 blockReward,
        uint256 epochDuration,
        uint256 startBlock
    ) internal pure {
        console.log("%s", SEPARATOR);
        console.log(unicode"📦 %s DIRECT DEPLOYMENT", contractName);
        console.log("%s", SEPARATOR);

        console.log(unicode"\n🔧 Core Parameters:");
        console.log(unicode"  • Contract Address: %s", contractAddress);
        console.log(unicode"  • Reward Token: %s", tokenAddress);
        console.log(unicode"  • Block Reward: %s SOLO/block", Strings.toString(blockReward / 1e18));
        console.log(
            unicode"  • Epoch Duration: %s blocks (~%s hours)",
            Strings.toString(epochDuration),
            Strings.toString((epochDuration * 1) / 3600)
        ); // Assuming 1s block time
        console.log(unicode"  • Starts At Block: %s", Strings.toString(startBlock));

        console.log(unicode"\n✅ Deployment Successful");
        console.log("%s\n", SEPARATOR);

        console.log(unicode"📋 Verification command:");
        console.log("export GAS_MINING_ADDRESS=%s\n", contractAddress);
    }
}
