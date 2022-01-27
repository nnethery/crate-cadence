import FungibleToken from "../../contracts/FungibleToken.cdc"
import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"

// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the CrateUtilityCoin

transaction {

    prepare(signer: AuthAccount) {

        if signer.borrow<&CrateUtilityCoin.Vault>(from: CrateUtilityCoin.VaultStoragePath) == nil {
            // Create a new CrateUtilityCoin Vault and put it in storage
            signer.save(<-CrateUtilityCoin.createEmptyVault(), to: CrateUtilityCoin.VaultStoragePath)

            // Create a public capability to the Vault that only exposes
            // the deposit function through the Receiver interface
            signer.link<&CrateUtilityCoin.Vault{FungibleToken.Receiver}>(
                CrateUtilityCoin.ReceiverPublicPath,
                target: CrateUtilityCoin.VaultStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            signer.link<&CrateUtilityCoin.Vault{FungibleToken.Balance}>(
                CrateUtilityCoin.BalancePublicPath,
                target: CrateUtilityCoin.VaultStoragePath
            )
        }
    }
}
