import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import PoolWrapper from "PoolWrapper"
import TestToken from "TestToken"

transaction(amount: UFix64){
    prepare(acct: AuthAccount){

        var lendingAssetProvider = acct.borrow<&TestToken.Vault>(from: /storage/MainVault)
        ?? panic("Could not borrow reference to the owner's Vault!")

        var lendAsset <- lendingAssetProvider.withdraw(amount: amount);

        var vault <- PoolWrapper.wrap(lendAsset: <- lendAsset)


        var ownerVault = acct.borrow<&PoolWrapper.Vault>(from: /storage/poolWrapper)

        if(ownerVault == nil){
            var emptyVault <- PoolWrapper.createEmptyVault()
            acct.save<@FungibleToken.Vault>(<-emptyVault, to: /storage/poolWrapper)

            // Create a public Receiver capability to the Vault
		    let ReceiverRef =
                acct.link<&FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}>
                (/public/poolWrapperReceiver, target: /storage/poolWrapper)

            ownerVault = acct.borrow<&PoolWrapper.Vault>(from: /storage/poolWrapper)
        }

        log("minted ".concat(vault.balance.toString()))

        ownerVault!.deposit(from: <- vault)
    }

    execute{

    }


}
 