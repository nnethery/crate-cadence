<p align="center">
    <a href="https://digcrate.com/">
        <img height="100" src="assets/crate logo.png" />
        <img height="100" src="assets/crate written.png" />
    </a>
</p>

Crate is an NFT-based music platform that provides master-quality streaming, an integrated marketplace, and a powerful blockchain to verify every transaction

# Smart Contracts
- [Crate Utility Coin](contracts/CrateUtilityCoin.cdc): The measure of value on the blockchain.
- [Albums](contracts/Albums.cdc): The main NFT that Crate offers. An `Album` can contain many tracks or just one. Each `Album` has a serial number stored on-chain.
- [NFTStorefront](contracts/NFTStorefront.cdc): The resource that allows NFT buy/sell capabilities. 

# Usage
## Local
### 1. Start emulator
``` bash
docker-compose --env-file .env.dev --profile dev up -d
```
### 2. Deploy
Local:
``` bash
flow project deploy --network emulator
```

## Testnet
### 1. Deploy
``` bash
flow project deploy --network testnet -f flow.json -f flow.testnet.json --update
```
> Remember, you can't update smart contracts on the Mainnet.

<br>
<br>
<br>

<p align="center">
    <a href="https://onflow.org/">
        <img height="100" src="assets/flow logo.svg" />
    </a>
</p>
<p align="center">Built on Flow Blockchain</p>