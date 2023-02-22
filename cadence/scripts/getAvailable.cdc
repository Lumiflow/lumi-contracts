import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import TestToken from "TestToken"

pub fun main(account: Address, timeOffset: UFix64): UFix64 {
    let acct = getAccount(account)
    let vaultRef = acct.getCapability<&FungibleToken.Vault{FungibleToken.Balance}>(/public/MainReceiver)
    let lumiRef = acct.getCapability<&Lumi.StreamSource{Lumi.StreamInfo}>(/public/MainSource)

    var currentTimeStamp = getCurrentBlock().timestamp

    return lumiRef.borrow()!.getAvailable(at: (currentTimeStamp+timeOffset))


}