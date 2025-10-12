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
### To get all the methods 

```shell
$ forge inspect DSCEngine methods
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
//forge test --match-test testRevertsIfTokenLengthDoesntMatchPriceFeeds

//forge coverage --report debug

/*

== Return ==
0: contract DecentralizedStableCoin 0x15B09287B8FFDc0aEC73c00342659ceF83828548
1: contract DSCEngine 0xcd7e61D8C74e3B4FB87b85C29A039c2d229B1cA6
2: contract HelperConfig 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141

*/

/* 
Verify contract:  forge verify-contract \                                    
  --chain sepolia \
  0x15B09287B8FFDc0aEC73c00342659ceF83828548 \
  src/DecentralizedStableCoin.sol:DecentralizedStableCoin \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.30+commit.73712a01 \
  --watch
*/
forge script script/DeployDsc.s.sol:DeployDsc \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast -vvv

cast code 0x15B09287B8FFDc0aEC73c00342659ceF83828548 --rpc-url $SEPOLIA_RPC_URL



//Ask yourself What are our invariants/properties here?

fuzz testing: Supply random data to your system in an attempt to break it.
invariant:  property of our system that should always hold
Symbolice execution/formal verifications

Add no of runs in foundry.tomal example file 

[fuzz]

runs = 10000

Things to do for fuzz testing:- 

1) Understand the invariants 
2) Write a fuzz test for invariant

Stateless fuzz testing: Where the state of the previous run is discarded for every new run 

Statefull fuzzing: fuzzing where the final state of previous run is starting state of the next run
use Invariant_ keyword to write stateful fuzz testing.

In foundry, 

fuzz tests = random data to one function 
invariant tests = random data and random function calls to many functions


foundry fuzzing = Stateless fuzzing
Foundry invarint = Stateful fuzzing

2. What is the primary purpose of fuzz testing in software development?

“To automatically supply random or pseudo-random data to a system to uncover bugs or vulnerabilities.”

This means a testing tool (called a fuzzer) automatically feeds lots of random or unexpected inputs into a program to see how it reacts.
If the program crashes, hangs, or behaves incorrectly, it reveals a bug or security flaw that developers might have missed.

8. In fuzz testing frameworks that simulate user behavior, what is the typical purpose of 'handler' functions?

To define specific actions or function calls that the fuzzer can randomly select and sequence to interact with the system under test.

