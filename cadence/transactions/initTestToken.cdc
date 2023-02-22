import Lumi from "Lumi"
import FungibleToken from "FungibleToken"
import TestToken from "TestToken"

transaction(){
    prepare(acct: AuthAccount){
        var vault <- TestToken.createVaultTEST(amount: 5.0)
        acct.save<@FungibleToken.Vault>(<-vault, to: /storage/MainVault)

        log("Empty Vault stored")

        // Create a public Receiver capability to the Vault
		    let ReceiverRef = acct.link<&FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}>(/public/MainReceiver, target: /storage/MainVault)
    }

    execute{

    }


}