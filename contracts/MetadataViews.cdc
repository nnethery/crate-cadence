import FungibleToken from "FungibleToken.cdc"


pub contract MetadataViews {
    /*
    *  Royalty Views
    *  Defines the composable royalty standard that gives marketplaces a unified interface
    *  to support NFT royalties.
    *
    *  Marketplaces can query this `Royalties` struct from NFTs 
    *  and are expected to pay royalties based on these specifications.
    *
    */
    pub struct Royalties {

        /// Array that tracks the individual royalties
        access(self) let cutInfos: [Royalty]

        pub init(_ cutInfos: [Royalty]) {
            // Validate that sum of all cut multipliers should not be greater than 1.0
            var totalCut = 0.0
            for royalty in cutInfos {
                totalCut = totalCut + royalty.cut
            }
            assert(totalCut <= 1.0, message: "Sum of cutInfos multipliers should not be greater than 1.0")
            // Assign the cutInfos
            self.cutInfos = cutInfos
        }

        /// Return the cutInfos list
        pub fun getRoyalties(): [Royalty] {
            return self.cutInfos
        }
    }

    /// Struct to store details of a single royalty cut for a given NFT
    pub struct Royalty {

        /// Generic FungibleToken Receiver for the beneficiary of the royalty
        /// Can get the concrete type of the receiver with receiver.getType()
        /// Recommendation - Users should create a new link for a FlowToken receiver for this using `getRoyaltyReceiverPublicPath()`,
        /// and not use the default FlowToken receiver.
        /// This will allow users to update the capability in the future to use a more generic capability
        pub let receiver: Capability<&AnyResource{FungibleToken.Receiver}>

        /// Multiplier used to calculate the amount of sale value transferred to royalty receiver.
        /// Note - It should be between 0.0 and 1.0 
        /// Ex - If the sale value is x and multiplier is 0.56 then the royalty value would be 0.56 * x.
        ///
        /// Generally percentage get represented in terms of basis points
        /// in solidity based smart contracts while cadence offers `UFix64` that already supports
        /// the basis points use case because its operations
        /// are entirely deterministic integer operations and support up to 8 points of precision.
        pub let cut: UFix64

        /// Optional description: This can be the cause of paying the royalty,
        /// the relationship between the `wallet` and the NFT, or anything else that the owner might want to specify
        pub let description: String

        init(recepient: Capability<&AnyResource{FungibleToken.Receiver}>, cut: UFix64, description: String) {
            pre {
                cut >= 0.0 && cut <= 1.0 : "Cut value should be in valid range i.e [0,1]"
            }
            self.receiver = recepient
            self.cut = cut
            self.description = description
        }
    }

    /// Get the path that should be used for receiving royalties
    /// This is a path that will eventually be used for a generic switchboard receiver,
    /// hence the name but will only be used for royalties for now.
    pub fun getRoyaltyReceiverPublicPath(): PublicPath {
        return /public/GenericFTReceiver
    }
}
 