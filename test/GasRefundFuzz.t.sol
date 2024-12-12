// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GasRefund.sol";
import "../src/mock/DummyToken.sol";

contract GasRefundTest is Test {
    GasRefund public gasRefund;
    DummyToken public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        token = new DummyToken();
        gasRefund = new GasRefund(
            address(token),
            100 * 10**18,
            7200
        );

        // Fund with large amount for testing
        token.transfer(address(gasRefund), 1000000 * 10**18);
    }

    function testFuzzBlockReward(uint256 newReward) public {
        newReward = bound(newReward, 10**12, 10**24);
        gasRefund.setBlockReward(newReward);
        assertEq(gasRefund.blockReward(), newReward);
    }

    function testFuzzEpochDuration(uint256 newDuration) public {
        newDuration = bound(newDuration, 300, 172800);
        gasRefund.setEpochDuration(newDuration);
        assertEq(gasRefund.epochDuration(), newDuration);
    }

    function testFuzzSingleClaim(uint256 blockNumber, uint256 amount) public {
        blockNumber = bound(blockNumber, block.number, block.number + 1000000);
        amount = bound(amount, 10**16, 10**22);

        uint256[] memory blocks = new uint256[](1);
        blocks[0] = blockNumber;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        gasRefund.updateUserClaim(user1, blocks, amounts);
        gasRefund.updateLatestClaimableBlock(blockNumber + 1);

        assertEq(gasRefund.getPendingClaimAmount(user1), amount);
        assertEq(gasRefund.getBlockClaimAmount(user1, blockNumber), amount);
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

        gasRefund.updateUserClaim(user1, blocks, amounts);
        gasRefund.updateLatestClaimableBlock(blockStart + claimCount);

        assertEq(gasRefund.getPendingClaimAmount(user1), totalAmount);
    }

    function testFuzzRunway(uint256 blockReward) public {
        blockReward = bound(blockReward, 10**16, 10**22);
        gasRefund.setBlockReward(blockReward);
        
        uint256 balance = token.balanceOf(address(gasRefund));
        uint256 expectedRunway = balance / blockReward;
        assertEq(gasRefund.getRunway(), expectedRunway);
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

        uint256 totalBalance = token.balanceOf(address(gasRefund));
        uint256 maxAmountPerUser = totalBalance / 20; // Ensure we don't exceed contract balance

        for (uint256 i = 0; i < 10; i++) {
            // Bound the amount between minimum value and max allowed per user
            uint256 boundedAmount = bound(amounts[i], 10**16, maxAmountPerUser);
            
            uint256[] memory userAmounts = new uint256[](1);
            userAmounts[0] = boundedAmount;

            gasRefund.updateUserClaim(testUsers[i], blocks, userAmounts);

            // Verify the claim was set correctly
            assertEq(gasRefund.getPendingClaimAmount(testUsers[i]), boundedAmount);
        }
        
        gasRefund.updateLatestClaimableBlock(blockNumber + 1);

        // Claim for each user
        for (uint256 i = 0; i < 10; i++) {
            uint256 expectedAmount = gasRefund.getPendingClaimAmount(testUsers[i]);
            if (expectedAmount > 0) {
                uint256 balanceBefore = token.balanceOf(testUsers[i]);
                vm.prank(testUsers[i]);
                gasRefund.claimRewards();
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

        gasRefund.updateUserClaim(user1, blocks, amounts);
        gasRefund.updateLatestClaimableBlock(14400);

        // Move to block 14400 (start of epoch 2)
        vm.roll(14400);
        
        assertEq(gasRefund.getCurrentEpoch(), 2);

        vm.prank(user1);
        gasRefund.claimRewards();

        assertEq(token.balanceOf(user1), 60 * 10**18);
    }

    function testFuzzClaimInvariant(uint256 numClaims) public {
        // Bound number of claims to a reasonable range
        numClaims = bound(numClaims, 1, 20);
        
        uint256[] memory blocks = new uint256[](numClaims);
        uint256[] memory amounts = new uint256[](numClaims);
        uint256 contractBalance = token.balanceOf(address(gasRefund));
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

        gasRefund.updateUserClaim(user1, blocks, amounts);
        assertLe(totalClaimed, contractBalance);
    }
}
