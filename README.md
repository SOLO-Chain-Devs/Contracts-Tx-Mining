# Gas Mining Smart Contract

A smart contract system designed to reward users with tokens based on their gas usage, creating an incentive mechanism for network participation.

## Overview

The Gas Mining Smart Contract allows users to claim rewards proportional to their gas usage within specific blocks. It features a flexible reward system, epoch-based tracking, and secure claiming mechanism.

### Key Features

- **Block-Based Rewards**: Users receive rewards based on their gas consumption in specific blocks
- **Epoch System**: Rewards are organized in epochs for better tracking and distribution
- **Configurable Parameters**: Adjustable block rewards and epoch duration
- **Secure Claiming**: Multiple safety checks ensure proper reward distribution
- **Detailed Tracking**: Comprehensive tracking of user claims and rewards

## Contract Architecture

- `GasMining.sol`: Main contract handling reward distribution and claims
- `DummyToken.sol`: ERC20 token used for testing and reward distribution

## Prerequisites

1. [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
2. Ethereum RPC URL
3. Private key for deployment
4. [Etherscan API Key](https://etherscan.io/apis) (for verification)

## Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd gas-refund

# Install dependencies
forge install
```

## Building

```bash
# Build the contracts
forge build
```

## Testing

### Run all tests
```bash
forge test
```

### Run tests with detailed output
```bash
forge test -vv
```

### Run tests with extra detailed output (including logs)
```bash
forge test -vvv
```

### Run specific test
```bash
forge test --match-test testFuzzMultipleClaims
```

### Run tests with more fuzz runs
```bash
forge test --fuzz-runs 1000
```

### Run tests with gas report
```bash
forge test --gas-report
```

## Deployment

### Local Deployment (Anvil)
```bash
# Start local node
anvil

# Deploy to local network
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url http://localhost:8545 \
    --private-key $PRIVATE_KEY\
    --broadcast
```

### Testnet/Mainnet Deployment
```bash
# Deploy to network
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url <your_rpc_url> \
    --private-key <your_private_key> \
    --broadcast
```

## Contract Verification

### Verify on Etherscan
```bash
forge verify-contract \
    --chain-id <chain_id> \
    --compiler-version <compiler_version> \
    --constructor-args $(cast abi-encode "constructor(address,uint256,uint256)" <token_address> <block_reward> <epoch_duration>) \
    <deployed_address> \
    src/GasMining.sol:GasMining \
    <etherscan_api_key>
```

### Verify on Blockscout
```bash
forge verify-contract \
    --chain-id <chain_id> \
    --compiler-version <compiler_version> \
    --constructor-args $(cast abi-encode "constructor(address,uint256,uint256)" <token_address> <block_reward> <epoch_duration>) \
    <deployed_address> \
    src/GasMining.sol:GasMining \
    --verifier-url <blockscout_api_url> \
    <blockscout_api_key>
```

## Environment Setup

1. Create a `.env` file in the root directory:
```bash
cp .env.local .env
```

2. Fill in your `.env` file with your credentials:
```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=your_rpc_url_here
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

3. Source the environment file before running scripts:
```bash
source .env
```

## Deployment

### Using Environment Variables
```bash
# First source your environment
source .env

# Then deploy
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### With Verification
```bash
# Source environment and deploy with verification
source .env

forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY
```

## Contract Verification

### Verify on Etherscan using ENV
```bash
source .env

forge verify-contract \
    --chain-id <chain_id> \
    --compiler-version <compiler_version> \
    --constructor-args $(cast abi-encode "constructor(address,uint256,uint256)" <token_address> <block_reward> <epoch_duration>) \
    <deployed_address> \
    src/GasMining.sol:GasMining \
    $ETHERSCAN_API_KEY
```

### Using Foundry's Built-in Verification
```bash
source .env

forge verify-contract \
    <deployed_address> \
    src/GasMining.sol:GasMining \
    --chain <chain_id> \
    --constructor-args $(cast abi-encode "constructor(address,uint256,uint256)" <token_address> <block_reward> <epoch_duration>) \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --compiler-version <compiler_version>
```

## Contract Parameters

- `blockReward`: Amount of tokens distributed per block
- `epochDuration`: Number of blocks in one epoch
- `token`: ERC20 token used for rewards

## Usage Examples

### Update User Claims
```solidity
// Update claims for a user
uint256[] memory blocks = [block1, block2];
uint256[] memory amounts = [amount1, amount2];
gasMining.updateUserClaim(userAddress, blocks, amounts);
```

### Claim Rewards
```solidity
// Claim available rewards
gasMining.claimRewards();
```

## Advanced Testing

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
# Run Slither analysis
slither .
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Security

The contract includes several security features:
- Owner-only administrative functions
- Safe math operations
- Proper access controls
- Claim verification checks

## License

[MIT](LICENSE)
