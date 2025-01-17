# First, ensure your .env file has the necessary variables
# .env should contain:
# PRIVATE_KEY=your_private_key
# RPC_URL=your_rpc_url

# For local testing (anvil)
anvil

# In a separate terminal:
# Initial deployment (development)
forge script script/DeployScriptSOLOToken.s.sol:DeployScriptSOLOToken --rpc-url http://localhost:8545 --broadcast --verify -vvvv

# Initial deployment (testnet/mainnet)
forge script script/DeployScriptSOLOToken.s.sol:DeployScriptSOLOToken --rpc-url $RPC_URL --broadcast --verify -vvvv

# For future upgrades (development)
forge script script/UpgradeScriptSOLOToken.s.sol:UpgradeScriptSOLOToken --rpc-url http://localhost:8545 --broadcast --verify -vvvv

# For future upgrades (testnet/mainnet)
forge script script/UpgradeScriptSOLOToken.s.sol:UpgradeScriptSOLOToken --rpc-url $RPC_URL --broadcast --verify -vvvv

# Optional: Simulate before actual deployment
forge script script/DeployScriptSOLOToken.s.sol:DeployScriptSOLOToken --rpc-url $RPC_URL -vvvv

# For verification (if needed)
forge verify-contract [CONTRACT_ADDRESS] src/SOLOToken.sol:SOLOToken --chain-id [CHAIN_ID] --compiler-version v0.8.16 --watch
