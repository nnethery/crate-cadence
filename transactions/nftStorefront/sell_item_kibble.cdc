import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"
import KittyItems from "../../contracts/KittyItems.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"

transaction(saleItemID: UInt64, saleItemPrice: UFix64) {

    let CUCReceiver: Capability<&CrateUtilityCoin.Vault{FungibleToken.Receiver}>
    let kittyItemsProvider: Capability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(account: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let kittyItemsCollectionProviderPrivatePath = /private/kittyItemsCollectionProvider

        self.CUCReceiver = account.getCapability<&CrateUtilityCoin.Vault{FungibleToken.Receiver}>(CrateUtilityCoin.ReceiverPublicPath)!
        
        assert(self.CUCReceiver.borrow() != nil, message: "Missing or mis-typed CrateUtilityCoin receiver")

        if !account.getCapability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(kittyItemsCollectionProviderPrivatePath)!.check() {
            account.link<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(kittyItemsCollectionProviderPrivatePath, target: KittyItems.CollectionStoragePath)
        }

        self.kittyItemsProvider = account.getCapability<&KittyItems.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(kittyItemsCollectionProviderPrivatePath)!
        assert(self.kittyItemsProvider.borrow() != nil, message: "Missing or mis-typed KittyItems.Collection provider")

        self.storefront = account.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.CUCReceiver,
            amount: saleItemPrice
        )
        self.storefront.createSaleOffer(
            nftProviderCapability: self.kittyItemsProvider,
            nftType: Type<@KittyItems.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@CrateUtilityCoin.Vault>(),
            saleCuts: [saleCut]
        )
    }
}
