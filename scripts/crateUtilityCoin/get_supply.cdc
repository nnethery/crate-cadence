import CrateUtilityCoin from "../../contracts/CrateUtilityCoin.cdc"

// This script returns the total amount of CrateUtilityCoin currently in existence.

pub fun main(): UFix64 {

    let supply = CrateUtilityCoin.totalSupply

    log(supply)

    return supply
}
