import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

// Albums
// NFT items for Music Lovers
//
pub contract Albums: NonFungibleToken {

    // Events
    //
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, typeID: String)

    // Named Paths
    //
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    // totalSupply
    // The total number of Albums that have been minted
    //
    pub var totalSupply: UInt64

    // NFT
    // An Album as an NFT
    //
    pub resource NFT: NonFungibleToken.INFT {
        // The token's ID
        pub let id: UInt64
        // The token's type, this is a string unique to Crate to fetch metadata
        pub let typeID: String

        pub let serialNo: String

        // initializer
        //
        init(initID: UInt64, initTypeID: String, initSerialNo: String) {
            self.id = initID
            self.typeID = initTypeID
            self.serialNo = initSerialNo
        }
    }

    // This is the interface that users can cast their Albums Collection as
    // to allow others to deposit Albums into their Collection. It also allows for reading
    // the details of Albums in the Collection.
    pub resource interface AlbumsCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowAlbum(id: UInt64): &Albums.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Album reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection
    // A collection of Album NFTs owned by an account
    //
    pub resource Collection: AlbumsCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        //
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // withdraw
        // Removes an NFT from the collection and moves it to the caller
        //
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        // deposit
        // Takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @Albums.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        // getIDs
        // Returns an array of the IDs that are in the collection
        //
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT
        // Gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowAlbum
        // Gets a reference to an NFT in the collection as a Album,
        // exposing all of its fields (including the typeID).
        // This is safe as there are no functions that can be called on the Album.
        //
        pub fun borrowAlbum(id: UInt64): &Albums.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &Albums.NFT
            } else {
                return nil
            }
        }

        // destructor
        destroy() {
            destroy self.ownedNFTs
        }

        // initializer
        //
        init () {
            self.ownedNFTs <- {}
        }
    }

    // createEmptyCollection
    // public function that anyone can call to create a new empty collection
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    // NFTMinter
    // Resource that an admin or something similar would own to be
    // able to mint new NFTs
    //
	pub resource NFTMinter {

		// mintNFT
        // Mints a new NFT with a new ID
		// and deposit it in the recipients collection using their collection reference
        //
		pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, typeID: String, serialNo: String) {
            emit Minted(id: Albums.totalSupply, typeID: typeID)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-create Albums.NFT(initID: Albums.totalSupply, initTypeID: typeID, initSerialNo: serialNo))

            Albums.totalSupply = Albums.totalSupply + (1 as UInt64)
		}
	}

    // fetch
    // Get a reference to a Album from an account's Collection, if available.
    // If an account does not have a Albums.Collection, panic.
    // If it has a collection but does not contain the itemID, return nil.
    // If it has a collection and that collection contains the itemID, return a reference to that.
    //
    pub fun fetch(_ from: Address, itemID: UInt64): &Albums.NFT? {
        let collection = getAccount(from)
            .getCapability(Albums.CollectionPublicPath)!
            .borrow<&Albums.Collection{Albums.AlbumsCollectionPublic}>()
            ?? panic("Couldn't get collection")
        // We trust Albums.Collection.borowAlbum to get the correct itemID
        // (it checks it before returning it).
        return collection.borrowAlbum(id: itemID)
    }

    // initializer
    //
	init() {
        // Set our named paths
        self.CollectionStoragePath = /storage/albumsCollection
        self.CollectionPublicPath = /public/albumsCollection
        self.MinterStoragePath = /storage/albumsMinter

        // Initialize the total supply
        self.totalSupply = 0

        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}
