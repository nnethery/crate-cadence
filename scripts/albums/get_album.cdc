import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Albums from "../../contracts/Albums.cdc"

pub struct AccountItem {
  pub let itemID: UInt64
  pub let typeID: String
  pub let serialNo: String
  pub let resourceID: UInt64
  pub let owner: Address

  init(itemID: UInt64, typeID: String, serialNo:String, resourceID: UInt64, owner: Address) {
    self.itemID = itemID
    self.typeID = typeID
    self.resourceID = resourceID
    self.owner = owner
    self.serialNo = serialNo
  }
}

pub fun main(address: Address, itemID: UInt64): AccountItem? {
  if let collection = getAccount(address).getCapability<&Albums.Collection{NonFungibleToken.CollectionPublic, Albums.AlbumsCollectionPublic}>(Albums.CollectionPublicPath).borrow() {
    if let item = collection.borrowAlbum(id: itemID) {
      return AccountItem(itemID: itemID, typeID: item.typeID, serialNo: item.serialNo, resourceID: item.uuid, owner: address)
    }
  }

  return nil
}
