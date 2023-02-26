import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import PoolWrapper from "PoolWrapper"
import TestToken from "TestToken"

transaction(amount: UFix64){
    prepare(acct: AuthAccount){

        var lendingAssetProvider = acct.borrow<&TestToken.Vault>(from: /storage/MainVault)
        ?? panic("Could not borrow reference to the owner's Vault!")

        var lendAsset <- lendingAssetProvider.withdraw(amount: amount);

        var vault <- PoolWrapper.wrap(to: acct.address, lendAsset: <- lendAsset)


        var ownerReceiverCapability = 
            acct.getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/poolWrapperReceiver)

        if(ownerReceiverCapability == nil){
            var vault <- PoolWrapper.createEmptyVault()
            acct.save<@FungibleToken.Vault>(<-vault, to: /storage/poolWrapper)

            // Create a public Receiver capability to the Vault
		    let ReceiverRef =
             acct.link<&FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}>
             (/public/poolWrapperReceiver, target: /storage/poolWrapper)

            ownerReceiverCapability = 
            acct.getCapability<&FungibleToken.Vault{FungibleToken.Receiver}>(/public/poolWrapperReceiver)
        }

        log("minted ".concat(vault.balance.toString()))

        ownerReceiverCapability.borrow()!.deposit(from: <- vault)
    }

    execute{

    }


}
 