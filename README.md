## Explanation


Gas Refund Smart Contract
The Gas Refund Smart Contract is a powerful tool designed to incentivize user participation and reward contributions to the network. By tracking gas spent by users and distributing tokens based on their proportional contributions, this contract creates a fair, transparent, and engaging ecosystem.
Features

Proportional Rewards: Users receive rewards in proportion to the gas they spend on transactions within each block. The more gas a user spends relative to others, the larger their share of the block reward.
Flexible Configuration: The contract owner can adjust key parameters such as the block reward and epoch duration, allowing the system to adapt to changing network conditions and requirements.
Transparent Tracking: Detailed view functions provide visibility into a user's claim history, pending rewards, and total claimed amounts, promoting trust and accountability.
Secure Claiming: Users can claim their pending rewards at any time, with the contract ensuring that only eligible rewards are distributed and that claimed amounts are properly updated.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
