import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"
import Albums from "../../contracts/Albums.cdc"

pub struct SaleItem {
    pub let itemID: UInt64
    pub let typeID: String
    pub let owner: Address
    pub let price: UFix64
    pub let serialNo: String

    init(itemID: UInt64, typeID: String, serialNo: String, owner: Address, price: UFix64) {
        self.itemID = itemID
        self.typeID = typeID
        self.owner = owner
        self.price = price
        self.serialNo = serialNo
    }
}

pub fun main(address: Address, saleOfferResourceID: UInt64): SaleItem? {
    let account = getAccount(address)

    if let storefrontRef = account.getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath).borrow() {
        if let saleOffer = storefrontRef.borrowSaleOffer(saleOfferResourceID: saleOfferResourceID) {
            let details = saleOffer.getDetails()

            let itemID = details.nftID
            let itemPrice = details.salePrice

            if let collection = account.getCapability<&Albums.Collection{NonFungibleToken.CollectionPublic, Albums.AlbumsCollectionPublic}>(Albums.CollectionPublicPath).borrow() {
                if let item = collection.borrowAlbum(id: itemID) {
                    return SaleItem(itemID: itemID, typeID: item.typeID, serialNo: item.serialNo, owner: address, price: itemPrice)
                }
            }
        }
    }
        
    return nil
}
