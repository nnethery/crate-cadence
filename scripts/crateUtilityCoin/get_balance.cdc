import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"

// This script returns an account's CrateUtilityCoin balance.

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)
    
    let vaultRef = account.getCapability(CrateUtilityCoin.BalancePublicPath)!.borrow<&CrateUtilityCoin.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
