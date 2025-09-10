# Gas Mining Smart Contract System

A comprehensive smart contract system designed to reward users with SOLO tokens based on their gas usage, creating an incentive mechanism for network participation. The system supports both standard and upgradeable contract implementations.

## 📁 Project Structure

```
Contracts-Tx-Mining/
├── src/                          # Source contracts
│   ├── core/                     # Standard (non-upgradeable) contracts
│   │   ├── GasMining.sol         # Main gas mining contract
│   │   ├── interfaces/
│   │   │   └── IGasMining.sol    # Interface for GasMining contract
│   │   └── mock/
│   │       └── SOLOToken.sol     # Mock SOLO token for testing
│   └── upgradeable/              # Upgradeable contract implementations
│       ├── GasMining.sol         # Upgradeable gas mining contract
│       ├── interfaces/
│       │   └── IGasMining.sol    # Interface for upgradeable GasMining
│       └── mock/
│           └── SOLOToken.sol     # Upgradeable mock SOLO token
├── test/                         # Test files
│   ├── core/                     # Tests for standard contracts
│   │   ├── GasMining.t.sol       # Unit tests for GasMining
│   │   └── GasMiningFuzz.t.sol   # Fuzz tests for GasMining
│   └── upgradeable/              # Tests for upgradeable contracts
│       ├── GasMining.t.sol       # Unit tests for upgradeable GasMining
│       └── GasMiningFuzz.t.sol   # Fuzz tests for upgradeable GasMining
├── script/                       # Deployment and interaction scripts
│   ├── core/                     # Scripts for standard contracts
│   └── upgradeable/              # Scripts for upgradeable contracts
├── lib/                          # External dependencies
│   ├── forge-std/                # Foundry standard library
│   ├── openzeppelin-contracts/   # OpenZeppelin contracts
│   └── openzeppelin-contracts-upgradeable/ # OpenZeppelin upgradeable contracts
├── out/                          # Compiled contracts
├── broadcast/                    # Deployment artifacts
├── cache/                        # Foundry cache
└── foundry.toml                  # Foundry configuration
```

## 🏗️ Contract Architecture

### Core Contracts

#### GasMining.sol
The main contract that implements the gas mining reward system. It inherits from `Ownable` and implements the `IGasMining` interface.

**Key Features:**
- **Block-Based Rewards**: Users receive rewards based on their gas consumption in specific blocks
- **Epoch System**: Rewards are organized in epochs for better tracking and distribution
- **Dual Claiming Options**: 
  - Instant claiming with 50% burn penalty
  - Staking rewards to avoid burn penalty
- **Configurable Parameters**: Adjustable block rewards, epoch duration, and burn percentage
- **Admin Controls**: Owner-only functions for system management

**Inheritance Chain:**
```
GasMining → Ownable → Context
```

#### IGasMining.sol
Interface defining the complete API for the GasMining contract, including:
- View functions for querying user data and system state
- State-changing functions for claiming and staking rewards
- Admin functions for system configuration
- Events for tracking important contract activities

### Upgradeable Contracts

#### GasMining.sol (Upgradeable)
An upgradeable version of the GasMining contract that inherits from:
- `Initializable` - For proxy initialization
- `OwnableUpgradeable` - For upgradeable ownership
- `UUPSUpgradeable` - For Universal Upgradeable Proxy Standard

**Key Differences from Core Version:**
- Uses `initialize()` function instead of constructor
- Includes storage gap for future upgrades
- Implements `_authorizeUpgrade()` for upgrade authorization
- Uses OpenZeppelin's upgradeable contracts

## 🔧 Key Features

### Reward System
- **Block-Based Tracking**: Rewards are calculated and distributed based on specific block numbers
- **Epoch Management**: System operates in epochs for organized reward distribution
- **Flexible Claiming**: Users can choose between instant claiming (with burn) or staking (no burn)

### Security Features
- **Owner-Only Admin Functions**: Critical system parameters can only be modified by the owner
- **Safe Math Operations**: All arithmetic operations use SafeMath to prevent overflows
- **Claim Verification**: Multiple checks ensure proper reward distribution
- **Burn Mechanism**: Configurable burn percentage (default 50%) for instant claims

### Upgradeability (Upgradeable Version)
- **UUPS Proxy Pattern**: Uses Universal Upgradeable Proxy Standard for upgrades
- **Storage Gaps**: Reserved storage slots for future contract upgrades
- **Authorization**: Only owner can authorize contract upgrades

## 🚀 Quick Start

### Prerequisites
1. [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
2. Ethereum RPC URL
3. Private key for deployment
4. [Etherscan API Key](https://etherscan.io/apis) (for verification)

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd Contracts-Tx-Mining

# Install dependencies
forge install
```

### Building
```bash
# Build all contracts
forge build
```

### Testing
```bash
# Run all tests
forge test

# Run tests with detailed output
forge test -vv

# Run specific test suite
forge test --match-path "test/core/*"
forge test --match-path "test/upgradeable/*"

# Run fuzz tests with more iterations
forge test --fuzz-runs 1000

# Generate gas report
forge test --gas-report
```

## 📋 Contract Parameters

### Core Parameters
- **`token`**: Address of the SOLO token contract (ERC20)
- **`blockReward`**: Amount of tokens distributed per block
- **`epochDuration`**: Number of blocks in one epoch
- **`latestClaimableBlock`**: Latest block number for which rewards can be claimed
- **`burnBasisPoints`**: Percentage of rewards burned on instant claim (default: 5000 = 50%)

### User Claim Structure
```solidity
struct UserClaim {
    uint256 lastClaimedBlock;        // Last block user claimed rewards
    uint256 totalClaimAmount;        // Total amount ever claimed
    uint256 pendingClaimAmount;      // Current pending rewards
    uint256[] claimedBlocks;         // Array of blocks with claims
    mapping(uint256 => uint256) blockClaimAmounts; // Amount per block
}
```

## 🔄 Usage Examples

### Update User Claims (Admin Only)
```solidity
uint256[] memory blocks = [100, 101, 102];
uint256[] memory amounts = [10e18, 20e18, 30e18];
uint256[] memory emptyArray = new uint256[](0);

gasMining.updateUserClaim(
    userAddress,
    blocks,
    amounts,
    emptyArray,  // preboostAmounts
    emptyArray,  // comparativeAmounts
    0,           // multiplierWeight
    0,           // stSOLOAmount
    ""           // stSOLOTier
);
```

### Claim Rewards Instantly (50% Burn)
```solidity
gasMining.instantClaimRewards();
```

### Stake Rewards (No Burn)
```solidity
address stakingContract = 0x...;
gasMining.stakeClaim(stakingContract);
```

### Query User Information
```solidity
// Get pending claim amount
uint256 pending = gasMining.getPendingClaimAmount(userAddress);

// Get total claim amount
uint256 total = gasMining.getTotalClaimAmount(userAddress);

// Get detailed unclaimed information
IGasMining.UnclaimedDetails memory details = gasMining.getUnclaimedDetails(userAddress);
```

## 🚀 Deployment

### Local Deployment (Anvil)
```bash
# Start local node
anvil

# Deploy core contracts
forge script script/core/Deploy.s.sol:DeployScript \
    --rpc-url http://localhost:8545 \
    --private-key $PRIVATE_KEY \
    --broadcast

# Deploy upgradeable contracts
forge script script/upgradeable/DeployScriptGasMining.s.sol:DeployScriptGasMining \
    --rpc-url http://localhost:8545 \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Testnet/Mainnet Deployment
```bash
# Deploy with verification
forge script script/core/Deploy.s.sol:DeployScript \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY
```

## 🔍 Contract Verification

### Verify on Etherscan
```bash
# Core contract verification
forge verify-contract \
    --chain-id <chain_id> \
    --compiler-version <compiler_version> \
    --constructor-args $(cast abi-encode "constructor(address,uint256,uint256,uint256)" <token_address> <block_reward> <epoch_duration> <latest_claimable_block>) \
    <deployed_address> \
    src/core/GasMining.sol:GasMining \
    $ETHERSCAN_API_KEY

# Upgradeable contract verification
forge verify-contract \
    --chain-id <chain_id> \
    --compiler-version <compiler_version> \
    <deployed_address> \
    src/upgradeable/GasMining.sol:GasMining \
    $ETHERSCAN_API_KEY
```

## 🧪 Advanced Testing

### Gas Snapshots
```bash
# Create gas snapshots
forge snapshot
```

### Coverage Report
```bash
# Generate test coverage report
forge coverage
```

### Slither Analysis
```bash
# Run Slither security analysis
slither .
```

## 🔐 Security Considerations

The contracts include several security features:
- **Access Control**: Owner-only administrative functions
- **Safe Math**: All arithmetic operations are protected against overflows
- **Input Validation**: Comprehensive checks on all user inputs
- **Claim Verification**: Multiple safety checks ensure proper reward distribution
- **Upgrade Authorization**: Only owner can authorize contract upgrades (upgradeable version)

## 📊 Events

The contract emits the following events for tracking:

- `InstantRewardClaimed`: When a user claims rewards instantly
- `RewardStaked`: When a user stakes rewards instead of claiming
- `UserClaimUpdated`: When admin updates user claim data
- `BlockRewardUpdated`: When block reward is changed
- `EpochDurationUpdated`: When epoch duration is changed
- `LatestClaimableBlockUpdated`: When claimable block is updated
- `AdminWithdraw`: When admin withdraws tokens
- `BurnBasisPointsUpdated`: When burn percentage is changed

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This system is designed for educational and development purposes. Please conduct thorough testing and security audits before deploying to mainnet.
