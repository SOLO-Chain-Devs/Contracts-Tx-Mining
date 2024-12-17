// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GasMining.sol";
import "../src/mock/DummyToken.sol";


contract GasMiningTest is Test {
    GasMining public gasMining;
    DummyToken public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        token = new DummyToken();
        gasMining = new GasMining(
            address(token),
            100 * 10**18,
            7200
        );

        // Fund with large amount for testing
        token.transfer(address(gasMining), 1000000 * 10**18);
    }

    function testFuzzBlockReward(uint256 newReward) public {
        newReward = bound(newReward, 10**12, 10**24);
        gasMining.setBlockReward(newReward);
        assertEq(gasMining.blockReward(), newReward);
    }

    function testFuzzEpochDuration(uint256 newDuration) public {
        newDuration = bound(newDuration, 300, 172800);
        gasMining.setEpochDuration(newDuration);
        assertEq(gasMining.epochDuration(), newDuration);
    }

    function testFuzzSingleClaim(uint256 blockNumber, uint256 amount) public {
        blockNumber = bound(blockNumber, block.number, block.number + 1000000);
        amount = bound(amount, 10**16, 10**22);

        uint256[] memory blocks = new uint256[](1);
        blocks[0] = blockNumber;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        gasMining.updateUserClaim(user1, blocks, amounts);
        gasMining.updateLatestClaimableBlock(blockNumber + 1);

        assertEq(gasMining.getPendingClaimAmount(user1), amount);
        assertEq(gasMining.getBlockClaimAmount(user1, blockNumber), amount);
    }

    function testFuzzMultipleClaims(
        uint256 blockStart,
        uint256 claimCount,
        uint256 baseAmount
    ) public {
        blockStart = bound(blockStart, block.number, block.number + 1000000);
        claimCount = bound(claimCount, 1, 20);
        baseAmount = bound(baseAmount, 10**16, 10**20); // Reduced upper bound

        uint256[] memory blocks = new uint256[](claimCount);
        uint256[] memory amounts = new uint256[](claimCount);
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < claimCount; i++) {
            blocks[i] = blockStart + i;
            amounts[i] = baseAmount;
            totalAmount += amounts[i];
        }

        gasMining.updateUserClaim(user1, blocks, amounts);
        gasMining.updateLatestClaimableBlock(blockStart + claimCount);

        assertEq(gasMining.getPendingClaimAmount(user1), totalAmount);
    }

    function testFuzzRunway(uint256 blockReward) public {
        blockReward = bound(blockReward, 10**16, 10**22);
        gasMining.setBlockReward(blockReward);
        
        uint256 balance = token.balanceOf(address(gasMining));
        uint256 expectedRunway = balance / blockReward;
        assertEq(gasMining.getRunway(), expectedRunway);
    }

    function testFuzzMultipleUsersClaiming(
        uint256[10] memory amounts
    ) public {
        uint256 blockNumber = block.number;
        address[] memory testUsers = new address[](10);
        
        // Create test users
        for(uint256 i = 0; i < 10; i++) {
            testUsers[i] = makeAddr(string(abi.encodePacked("user", vm.toString(i))));
        }

        uint256[] memory blocks = new uint256[](1);
        blocks[0] = blockNumber;

        uint256 totalBalance = token.balanceOf(address(gasMining));
        uint256 maxAmountPerUser = totalBalance / 20; // Ensure we don't exceed contract balance

        for (uint256 i = 0; i < 10; i++) {
            // Bound the amount between minimum value and max allowed per user
            uint256 boundedAmount = bound(amounts[i], 10**16, maxAmountPerUser);
            
            uint256[] memory userAmounts = new uint256[](1);
            userAmounts[0] = boundedAmount;

            gasMining.updateUserClaim(testUsers[i], blocks, userAmounts);

            // Verify the claim was set correctly
            assertEq(gasMining.getPendingClaimAmount(testUsers[i]), boundedAmount);
        }
        
        gasMining.updateLatestClaimableBlock(blockNumber + 1);

        // Claim for each user
        for (uint256 i = 0; i < 10; i++) {
            uint256 expectedAmount = gasMining.getPendingClaimAmount(testUsers[i]);
            if (expectedAmount > 0) {
                uint256 balanceBefore = token.balanceOf(testUsers[i]);
                vm.prank(testUsers[i]);
                gasMining.instantClaimRewards();
                assertEq(token.balanceOf(testUsers[i]) - balanceBefore, expectedAmount);
            }
        }
    }

    function testMultipleEpochsClaim() public {
        // Move to a specific block for deterministic testing
        vm.roll(7200); // Start at epoch 1

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
        
        assertEq(gasMining.getCurrentEpoch(), 2);

        vm.prank(user1);
        gasMining.instantClaimRewards();

        assertEq(token.balanceOf(user1), 60 * 10**18);
    }

    function testFuzzClaimInvariant(uint256 numClaims) public {
        // Bound number of claims to a reasonable range
        numClaims = bound(numClaims, 1, 20);
        
        uint256[] memory blocks = new uint256[](numClaims);
        uint256[] memory amounts = new uint256[](numClaims);
        uint256 contractBalance = token.balanceOf(address(gasMining));
        uint256 totalClaimed = 0;

        for (uint256 i = 0; i < numClaims; i++) {
            blocks[i] = block.number + i;
            // Ensure total claims don't exceed contract balance
            amounts[i] = bound(
                uint256(keccak256(abi.encode(i))),
                10**16,
                (contractBalance - totalClaimed) / (numClaims - i)
            );
            totalClaimed += amounts[i];
        }

        gasMining.updateUserClaim(user1, blocks, amounts);
        assertLe(totalClaimed, contractBalance);
    }
}
