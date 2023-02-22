import FungibleToken from "FungibleToken"

access(all) contract Lumi {

    pub fun createStream(
        streamVault: @FungibleToken.Vault,
        receiverCapability: Capability<&{FungibleToken.Receiver}>,
        startTime: UFix64,
        endTime: UFix64
    ): @StreamSource{
        return <- create StreamSource(
            vault: <- streamVault, 
            receiverCapability: receiverCapability, 
            startTime: startTime,
            endTime: endTime
        )
    }

    pub resource StreamSource: StreamInfo{
        access(contract) let receiverCapability: Capability<&{FungibleToken.Receiver}>

        pub var claimed: UFix64
        pub var total: UFix64
        pub var startTime: UFix64
        pub var endTime: UFix64
        pub var vault: @FungibleToken.Vault 

        pub fun claimAvailable(){
            var currentTimeStamp = getCurrentBlock().timestamp
            var availableAmount = self.getAvailable(at: currentTimeStamp)

            self.claimed = self.claimed + availableAmount
            var vault <- self.vault.withdraw(amount: availableAmount)
            self.receiverCapability.borrow()!.deposit(from: <- vault)
        }

        pub fun getAvailable(at: UFix64): UFix64{            
            if(self.startTime < at){
                if(self.endTime > at){
                    var perSecond =  self.total/(self.endTime - self.startTime)
                    return (at - self.startTime)*perSecond - self.claimed
                }

                return self.total - self.claimed
            }

            return 0.0;
        }

        // initializer
        init (
            vault: @FungibleToken.Vault,
            receiverCapability: Capability<&{FungibleToken.Receiver}>,
            startTime: UFix64,
            endTime: UFix64
        ) {
            self.receiverCapability = receiverCapability
            self.startTime = startTime
            self.endTime = endTime
            self.total = vault.balance
            self.claimed = 0.0

            self.vault <- vault
        }

        destroy (){
            self.claimAvailable()
            destroy(self.vault)
        }
    }

    pub resource interface StreamInfo {
        pub var claimed: UFix64
        pub var total: UFix64
        pub var startTime: UFix64
        pub var endTime: UFix64

        pub fun getAvailable(at: UFix64): UFix64
    }

}

 