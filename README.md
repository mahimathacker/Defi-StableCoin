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
Mission:- 
1) ( Relative Stability ) Anchored or pegged -> 1. 00
-> Using Chainlink price feeds
-> Set a function to exchange ETH & BTC -> $$$
2) Stability machenism: Algorithmic ( Decentralized )
-> People can only mint stablecoins with enough collatoral
3) Collateral: Exogenous (crypto) -> 1) wETH 2) wBTC

//forge install openzeppelin/openzeppelin-contracts
//forge install smartcontractkit/chainlink-brownie-contracts@0.6.1
