import FungibleToken from "../../contracts/FungibleToken.cdc"
import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"

transaction(recipient: Address, amount: UFix64) {
    let tokenAdmin: &CrateUtilityCoin.Administrator
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.tokenAdmin = signer
        .borrow<&CrateUtilityCoin.Administrator>(from: CrateUtilityCoin.AdminStoragePath)
        ?? panic("Signer is not the token admin")

        self.tokenReceiver = getAccount(recipient)
        .getCapability(CrateUtilityCoin.ReceiverPublicPath)!
        .borrow<&{FungibleToken.Receiver}>()
        ?? panic("Unable to borrow receiver reference")
    }

    execute {
        let minter <- self.tokenAdmin.createNewMinter(allowedAmount: amount)
        let mintedVault <- minter.mintTokens(amount: amount)

        self.tokenReceiver.deposit(from: <-mintedVault)

        destroy minter
    }
}
