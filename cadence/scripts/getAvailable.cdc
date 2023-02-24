import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import TestToken from "TestToken"

pub fun main(account: Address, timeOffset: UFix64): UFix64 {
    let acct = getAccount(account)
    //let vaultRef = acct.getCapability<&FungibleToken.Vault{FungibleToken.Balance}>(/public/MainReceiver)
    var currentTimeStamp = getCurrentBlock().timestamp

    //get first stream sender to this account
    var sender = Lumi.toDestinationSources[account]!.values[0]
    //get first stream resource id
    var streamId = Lumi.toDestinationSources[account]!.keys[0]
    //get source collection resource
    let lumiStreamGetter = getAccount(sender).getCapability<&Lumi.SourceCollection{Lumi.StreamInfoGetter}>(/public/MainGetter)

    return lumiStreamGetter.borrow()!.getAvailable(id: streamId, at: (currentTimeStamp+timeOffset))
    


}