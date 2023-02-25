import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import TestToken from "TestToken"

transaction(receiver: Address, amount: UFix64, startTime: UFix64, endTime: UFix64, tag: String){
    prepare(acct: AuthAccount){
        var currentTimeStamp = getCurrentBlock().timestamp;

        var receiverCapability = getAccount(receiver).getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/MainReceiver)
        var ownerReceiverCapability = acct.getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/MainReceiver)
        var ownerProviderCapability = acct.borrow<&TestToken.Vault>(from: /storage/MainVault)
        		?? panic("Could not borrow reference to the owner's Vault!")

        var depositVault <- ownerProviderCapability.withdraw(amount: amount);
        
        var streamResource <- Lumi.createStream(
            streamVault: <- depositVault, 
            tag: tag,
            receiverCapability: receiverCapability, 
            ownerReceiverCapability: ownerReceiverCapability,
            startTime: startTime, 
            endTime: endTime)

        var streamCollection <- Lumi.createEmptyCollection()
        streamCollection.deposit(source: <- streamResource)

        acct.save<@Lumi.SourceCollection>(<-streamCollection, to: /storage/SourceCollection)
        let ReceiverRef = acct.link<&Lumi.SourceCollection{Lumi.StreamInfoGetter}>(/public/MainGetter, target: /storage/SourceCollection)
        let ClaimerRef = acct.link<&Lumi.SourceCollection{Lumi.StreamClaimer}>(/public/MainClaimer, target: /storage/SourceCollection)
    }

    execute{

    }


}