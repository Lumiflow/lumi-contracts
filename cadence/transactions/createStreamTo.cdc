import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import TestToken from "TestToken"

transaction(receiver: Address){
    prepare(acct: AuthAccount){
        var currentTimeStamp = getCurrentBlock().timestamp;
        var vault <- TestToken.createVaultTEST(amount: 500.0)

        var receiverCapability = getAccount(receiver).getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/MainReceiver)
        var ownerReceiverCapability = acct.getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/MainReceiver)
        
        var streamResource <- Lumi.createStream(
            streamVault: <- vault, 
            receiverCapability: receiverCapability, 
            ownerReceiverCapability: ownerReceiverCapability,
            startTime: currentTimeStamp, 
            endTime: currentTimeStamp+10000.0)

        var streamCollection <- Lumi.createEmptyCollection()
        streamCollection.deposit(source: <- streamResource)

        acct.save<@Lumi.SourceCollection>(<-streamCollection, to: /storage/SourceCollection)
        let ReceiverRef = acct.link<&Lumi.SourceCollection{Lumi.StreamInfoGetter}>(/public/MainGetter, target: /storage/SourceCollection)
        let ClaimerRef = acct.link<&Lumi.SourceCollection{Lumi.StreamClaimer}>(/public/MainClaimer, target: /storage/SourceCollection)
    }

    execute{

    }


}