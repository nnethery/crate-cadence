import Albums from "../../contracts/Albums.cdc"

// This scripts returns the number of Albums currently in existence.

pub fun main(): UInt64 {    
    return Albums.totalSupply
}
