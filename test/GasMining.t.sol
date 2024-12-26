// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GasMining.sol";
import "../src/mock/SOLOToken.sol";
 
contract GasMiningTest is Test {
    GasMining public gasMining;
    SOLOToken public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        // Setup accounts
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy contracts
        token = new SOLOToken();
        gasMining = new GasMining(
            address(token),
            100 * 10**18, // 100 tokens per block
            7200          // epoch duration
        );

        // Fund the contract
        token.transfer(address(gasMining), 1000000 * 10**18); // 1M tokens
    }

    function testInitialSetup() view public {
        assertEq(address(gasMining.token()), address(token));
        assertEq(gasMining.blockReward(), 100 * 10**18);
        assertEq(gasMining.epochDuration(), 7200);
    }

    function testUpdateUserClaim() public {
        // Prepare claim data
        uint256[] memory blocks = new uint256[](3);
        blocks[0] = 100;
        blocks[1] = 101;
        blocks[2] = 102;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 10 * 10**18;
        amounts[1] = 20 * 10**18;
        amounts[2] = 30 * 10**18;

        // Update user claim
        gasMining.updateUserClaim(user1, blocks, amounts);

        // Verify claim amounts
        assertEq(gasMining.getPendingClaimAmount(user1), 60 * 10**18); // 10 + 20 + 30
        assertEq(gasMining.getBlockClaimAmount(user1, 100), 10 * 10**18);
        assertEq(gasMining.getBlockClaimAmount(user1, 101), 20 * 10**18);
        assertEq(gasMining.getBlockClaimAmount(user1, 102), 30 * 10**18);
    }

    function testClaimRewards() public {
        // Setup claim for user1
        uint256[] memory blocks = new uint256[](1);
        blocks[0] = 100;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 50 * 10**18;

        gasMining.updateUserClaim(user1, blocks, amounts);
        gasMining.updateLatestClaimableBlock(101);

        // Claim as user1
        vm.prank(user1);
        gasMining.instantClaimRewards();

        // Verify token transfer
        assertEq(token.balanceOf(user1), 50 * 10**18);
        assertEq(gasMining.getPendingClaimAmount(user1), 0);
    }

    function testFailClaimWithoutUpdatedBlock() public {
        // Setup claim for user1
        uint256[] memory blocks = new uint256[](1);
        blocks[0] = 100;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 50 * 10**18;

        gasMining.updateUserClaim(user1, blocks, amounts);

        // Try to claim without updating latest claimable block
        vm.prank(user1);
        gasMining.instantClaimRewards(); // Should revert
    }

    function testRunway() view public {
        uint256 runway = gasMining.getRunway();
        uint256 expectedRunway = token.balanceOf(address(gasMining)) / gasMining.blockReward();
        assertEq(runway, expectedRunway);
    }

    function testMultipleEpochsClaim() public {
        // Set the initial block number
        vm.roll(7200);  // Start at the beginning of epoch 1
        
        // Setup claims across multiple epochs
        uint256[] memory blocks = new uint256[](3);
        blocks[0] = 7199;  // Last block of epoch 0
        blocks[1] = 7200;  // First block of epoch 1
        blocks[2] = 14399; // Last block of epoch 1

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 10 * 10**18;
        amounts[1] = 20 * 10**18;
        amounts[2] = 30 * 10**18;

        gasMining.updateUserClaim(user1, blocks, amounts);
        gasMining.updateLatestClaimableBlock(14400);

        // Move to block 14400 (start of epoch 2)
        vm.roll(14400);

        // Now verify epoch calculation
        assertEq(gasMining.getCurrentEpoch(), 2); // We're at block 14400, so epoch 2

        // Claim rewards
        vm.prank(user1);
        gasMining.instantClaimRewards();

        assertEq(token.balanceOf(user1), 60 * 10**18);
    }


    function testOnlyOwnerFunctions() public {
        vm.prank(user1);
        vm.expectRevert(); // Should revert as user1 is not owner
        gasMining.setBlockReward(200 * 10**18);

        // Test owner can set block reward
        gasMining.setBlockReward(200 * 10**18);
        assertEq(gasMining.blockReward(), 200 * 10**18);
    }
}
