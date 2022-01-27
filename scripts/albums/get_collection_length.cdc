import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Albums from "../../contracts/Albums.cdc"

// This script returns the size of an account's Albums collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(Albums.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}
