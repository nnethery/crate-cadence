import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"
import KittyItems from "../../contracts/KittyItems.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"

transaction(saleOfferResourceID: UInt64, storefrontAddress: Address) {

    let paymentVault: @FungibleToken.Vault
    let kittyItemsCollection: &KittyItems.Collection{NonFungibleToken.Receiver}
    let storefront: &NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}
    let saleOffer: &NFTStorefront.SaleOffer{NFTStorefront.SaleOfferPublic}

    prepare(account: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(
                NFTStorefront.StorefrontPublicPath
            )!
            .borrow()
            ?? panic("Cannot borrow Storefront from provided address")

        self.saleOffer = self.storefront.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID)
            ?? panic("No offer with that ID in Storefront")
        
        let price = self.saleOffer.getDetails().salePrice

        let mainCrateUtilityCoinVault = account.borrow<&CrateUtilityCoin.Vault>(from: CrateUtilityCoin.VaultStoragePath)
            ?? panic("Cannot borrow CrateUtilityCoin vault from account storage")
        
        self.paymentVault <- mainCrateUtilityCoinVault.withdraw(amount: price)

        self.kittyItemsCollection = account.borrow<&KittyItems.Collection{NonFungibleToken.Receiver}>(
            from: KittyItems.CollectionStoragePath
        ) ?? panic("Cannot borrow KittyItems collection receiver from account")
    }

    execute {
        let item <- self.saleOffer.accept(
            payment: <-self.paymentVault
        )

        self.kittyItemsCollection.deposit(token: <-item)

        self.storefront.cleanup(saleOfferResourceID: saleOfferResourceID)
    }
}
