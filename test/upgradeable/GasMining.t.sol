// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/upgradeable/GasMining.sol";
import "../../src/upgradeable/mock//SOLOToken.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract GasMiningTest is Test {
    GasMining public gasMining;
    GasMining public implementation; // Added this line
    SOLOToken public token;
    address public owner;
    address public user1;
    address public user2;
    uint256[] emptyArray;
    uint256 zeroValue = 0;
    string emptyString = "";

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy implementations
        implementation = new GasMining();
        SOLOToken tokenImplementation = new SOLOToken();

        // Deploy token proxy first
        bytes memory tokenInitData = abi.encodeWithSelector(SOLOToken.initialize.selector);
        ERC1967Proxy tokenProxy = new ERC1967Proxy(address(tokenImplementation), tokenInitData);
        token = SOLOToken(address(tokenProxy));

        // Deploy gas mining proxy
        bytes memory initData = abi.encodeWithSelector(
            GasMining.initialize.selector,
            address(token), // Note: now using proxy address
            100 * 10 ** 18,
            7200,
            0
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        gasMining = GasMining(address(proxy));

        // Fund the contract through proxy
        token.mintTo(address(proxy), 1000000 * 10 ** 18);
    }

    function testInitialSetup() public view {
        assertEq(address(gasMining.token()), address(token));
        assertEq(gasMining.blockReward(), 100 * 10 ** 18);
        assertEq(gasMining.epochDuration(), 7200);
    }

    function testUpdateUserClaim() public {
        // Prepare claim data
        uint256[] memory blocks = new uint256[](3);
        blocks[0] = 100;
        blocks[1] = 101;
        blocks[2] = 102;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 10 * 10 ** 18;
        amounts[1] = 20 * 10 ** 18;
        amounts[2] = 30 * 10 ** 18;

        // Update user claim
        gasMining.updateUserClaim(user1, blocks, amounts, emptyArray, emptyArray, zeroValue, zeroValue, emptyString);

        // Verify claim amounts
        assertEq(gasMining.getPendingClaimAmount(user1), 60 * 10 ** 18); // 10 + 20 + 30
        assertEq(gasMining.getBlockClaimAmount(user1, 100), 10 * 10 ** 18);
        assertEq(gasMining.getBlockClaimAmount(user1, 101), 20 * 10 ** 18);
        assertEq(gasMining.getBlockClaimAmount(user1, 102), 30 * 10 ** 18);
    }

    function testClaimRewards() public {
        // Setup claim for user1
        uint256[] memory blocks = new uint256[](1);
        blocks[0] = 100;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 50 * 10 ** 18;

        gasMining.updateUserClaim(user1, blocks, amounts, emptyArray, emptyArray, zeroValue, zeroValue, emptyString);
        gasMining.updateLatestClaimableBlock(101);

        // Claim as user1
        vm.prank(user1);
        gasMining.instantClaimRewards();

        // Verify token transfer
        assertEq(token.balanceOf(user1), 25 * 10 ** 18);
        assertEq(gasMining.getPendingClaimAmount(user1), 0);
    }

    function test_RevertWhen_ClaimWithoutUpdatedBlock() public {
        // Setup claim for user1
        uint256[] memory blocks = new uint256[](1);
        blocks[0] = 100;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 50 * 10 ** 18;

        gasMining.updateUserClaim(user1, blocks, amounts, emptyArray, emptyArray, zeroValue, zeroValue, emptyString);

        // Try to claim without updating latest claimable block
        vm.prank(user1);
        vm.expectRevert();
        gasMining.instantClaimRewards(); // Should revert
    }

    function testRunway() public view {
        uint256 runway = gasMining.getRunway();
        uint256 expectedRunway = token.balanceOf(address(gasMining)) / gasMining.blockReward();
        assertEq(runway, expectedRunway);
    }

    function testMultipleEpochsClaim() public {
        // Set the initial block number
        vm.roll(7200); // Start at the beginning of epoch 1

        // Setup claims across multiple epochs
        uint256[] memory blocks = new uint256[](3);
        blocks[0] = 7199; // Last block of epoch 0
        blocks[1] = 7200; // First block of epoch 1
        blocks[2] = 14399; // Last block of epoch 1

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 10 * 10 ** 18;
        amounts[1] = 20 * 10 ** 18;
        amounts[2] = 30 * 10 ** 18;

        gasMining.updateUserClaim(user1, blocks, amounts, emptyArray, emptyArray, zeroValue, zeroValue, emptyString);
        gasMining.updateLatestClaimableBlock(14400);

        // Move to block 14400 (start of epoch 2)
        vm.roll(14400);

        // Now verify epoch calculation
        assertEq(gasMining.getCurrentEpoch(), 2); // We're at block 14400, so epoch 2

        // Claim rewards
        vm.prank(user1);
        gasMining.instantClaimRewards();

        assertEq(token.balanceOf(user1), 30 * 10 ** 18);
    }

    function testOnlyOwnerFunctions() public {
        vm.prank(user1);
        vm.expectRevert(); // Should revert as user1 is not owner
        gasMining.setBlockReward(200 * 10 ** 18);

        // Test owner can set block reward
        gasMining.setBlockReward(200 * 10 ** 18);
        assertEq(gasMining.blockReward(), 200 * 10 ** 18);
    }

    function testUpgradeability() public {
        // Deploy new implementation
        GasMining newImplementation = new GasMining();

        // Only owner can upgrade
        vm.prank(user1);
        vm.expectRevert(); // Updated error
        gasMining.upgradeToAndCall(address(newImplementation), "");

        // Owner can upgrade
        gasMining.upgradeToAndCall(address(newImplementation), "");

        // Verify implementation changed
        bytes32 slot = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
        assertEq(address(uint160(uint256(vm.load(address(gasMining), slot)))), address(newImplementation));
    }

    function testTokenUpgradeability() public {
        // Test that token initialize cannot be called twice
        vm.expectRevert();
        token.initialize();

        // Test that only owner can authorize upgrade
        address newImpl = makeAddr("newImplementation");
        vm.prank(user1);
        vm.expectRevert(); // Updated error
        token.upgradeToAndCall(newImpl, "");
    }
}
