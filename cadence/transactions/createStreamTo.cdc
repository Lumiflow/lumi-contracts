import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import TestToken from "TestToken"

transaction(receiver: Address){
    prepare(acct: AuthAccount){
        var currentTimeStamp = getCurrentBlock().timestamp;
        var vault <- TestToken.createVaultTEST(amount: 500.0)

        var receiverCapability = getAccount(receiver).getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/MainReceiver)

        var streamResource <- Lumi.createStream(streamVault: <- vault, receiverCapability: receiverCapability, startTime: currentTimeStamp, endTime: currentTimeStamp+10000.0)

        acct.save<@Lumi.StreamSource>(<-streamResource, to: /storage/Source)
        let ReceiverRef = acct.link<&Lumi.StreamSource{Lumi.StreamInfo}>(/public/MainSource, target: /storage/Source)
    }

    execute{

    }


}