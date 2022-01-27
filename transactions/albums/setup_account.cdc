import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Albums from "../../contracts/Albums.cdc"

// This transaction configures an account to hold Albums.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&Albums.Collection>(from: Albums.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Albums.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: Albums.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Albums.Collection{NonFungibleToken.CollectionPublic, Albums.AlbumsCollectionPublic}>(Albums.CollectionPublicPath, target: Albums.CollectionStoragePath)
        }
    }
}
