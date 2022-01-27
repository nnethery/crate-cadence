import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"
import Albums from "../../contracts/Albums.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"

transaction(saleItemID: UInt64, saleItemPrice: UFix64) {

    let CUCReceiver: Capability<&CrateUtilityCoin.Vault{FungibleToken.Receiver}>
    let albumsProvider: Capability<&Albums.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront

    prepare(account: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let albumsCollectionProviderPrivatePath = /private/albumsCollectionProvider

        self.CUCReceiver = account.getCapability<&CrateUtilityCoin.Vault{FungibleToken.Receiver}>(CrateUtilityCoin.ReceiverPublicPath)!
        
        assert(self.CUCReceiver.borrow() != nil, message: "Missing or mis-typed CrateUtilityCoin receiver")

        if !account.getCapability<&Albums.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(albumsCollectionProviderPrivatePath)!.check() {
            account.link<&Albums.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(albumsCollectionProviderPrivatePath, target: Albums.CollectionStoragePath)
        }

        self.albumsProvider = account.getCapability<&Albums.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(albumsCollectionProviderPrivatePath)!
        assert(self.albumsProvider.borrow() != nil, message: "Missing or mis-typed Albums.Collection provider")

        self.storefront = account.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")
    }

    execute {
        let saleCut = NFTStorefront.SaleCut(
            receiver: self.CUCReceiver,
            amount: saleItemPrice
        )
        self.storefront.createSaleOffer(
            nftProviderCapability: self.albumsProvider,
            nftType: Type<@Albums.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@CrateUtilityCoin.Vault>(),
            saleCuts: [saleCut]
        )
    }
}
