import FungibleToken from "FungibleToken"

access(all) contract Lumi {

    pub var toDestinationSources: {Address: {UInt64: Address}}

    pub fun createEmptyCollection(): @SourceCollection {
        return <- create SourceCollection()
    }

    pub fun createStream(
        streamVault: @FungibleToken.Vault,
        tag: String,
        receiverCapability: Capability<&{FungibleToken.Receiver}>,
        ownerReceiverCapability: Capability<&{FungibleToken.Receiver}>,
        startTime: UFix64,
        endTime: UFix64
    ): @StreamSource{
        var source <- create StreamSource(
            vault: <- streamVault, 
            tag: tag,
            receiverCapability: receiverCapability, 
            ownerReceiverCapability: ownerReceiverCapability,
            startTime: startTime,
            endTime: endTime
        )

        if(!self.toDestinationSources.containsKey(receiverCapability.address)){
            self.toDestinationSources[receiverCapability.address] = {}
        }
        self.toDestinationSources[receiverCapability.address]!.insert(key: source.uuid, ownerReceiverCapability.address)

        return <- source
    }

    pub struct Stream{
        pub(set) var claimed: UFix64
        pub(set) var total: UFix64
        pub(set) var startTime: UFix64
        pub(set) var endTime: UFix64
        pub var to: Address
        pub var uuid: UInt64
        pub var tag: String

        init(startTime: UFix64, endTime: UFix64, total: UFix64, to: Address, uuid: UInt64, tag: String) {
            self.startTime = startTime
            self.endTime = endTime
            self.total = total
            self.claimed = 0.0
            self.to = to
            self.uuid = uuid
            self.tag = tag
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
    }

    pub resource StreamSource{

        access(contract) let receiverCapability: Capability<&{FungibleToken.Receiver}>
        access(contract) let ownerReceiverCapability: Capability<&{FungibleToken.Receiver}>
        pub var info: Stream
        pub var vault: @FungibleToken.Vault

        pub fun claimAvailable() : UFix64{
            var currentTimeStamp = getCurrentBlock().timestamp
            var availableAmount = self.info.getAvailable(at: currentTimeStamp)

            self.info.claimed = self.info.claimed + availableAmount
            var vault <- self.vault.withdraw(amount: availableAmount)
            self.receiverCapability.borrow()!.deposit(from: <- vault)

            return availableAmount
        }

        pub fun getAvailable(at: UFix64): UFix64{            
            return self.info.getAvailable(at: at);
        }

        pub fun getInfo(): Stream{
            return self.info
        }

        init (
            vault: @FungibleToken.Vault,
            tag: String,
            receiverCapability: Capability<&{FungibleToken.Receiver}>,
            ownerReceiverCapability: Capability<&{FungibleToken.Receiver}>,
            startTime: UFix64,
            endTime: UFix64
        ) {
            self.ownerReceiverCapability = ownerReceiverCapability
            self.receiverCapability = receiverCapability
            self.info = Stream(startTime: startTime, endTime: endTime, total: vault.balance, to: receiverCapability.address, uuid: self.uuid, tag: tag)
            self.vault <- vault
        }

        destroy (){
            destroy(self.vault)
        }
    }

    pub resource SourceCollection: StreamInfoGetter, StreamClaimer {
        pub var myStreamSources: @{UInt64: StreamSource}

        pub fun claimAvailable(id: UInt64): UFix64{
            var stream <- self.myStreamSources.remove(key: id)!
            var amount = stream.claimAvailable()

            if(stream.info.claimed == stream.info.total){
                destroy stream
            }
            else{
                self.myStreamSources[id] <-! stream
            }

            return amount
        }

        pub fun getAvailable(id: UInt64, at: UFix64): UFix64{     
            var stream <- self.myStreamSources.remove(key: id)!
            var res = stream.getAvailable(at: at)
            self.myStreamSources[id] <-! stream
            return res
        }

        pub fun getInfo(id: UInt64): Stream{
            var stream <- self.myStreamSources.remove(key: id)!
            var res = stream.getInfo()
            self.myStreamSources[id] <-! stream
            return res
        }

        pub fun deposit(source: @StreamSource){
            self.myStreamSources[source.uuid] <-! source
        }

        pub fun getSourceStreamKeys(): [UInt64]{
            return self.myStreamSources.keys
        }

        init () {
            self.myStreamSources <- {}
        }

        destroy (){
            destroy(self.myStreamSources)
        }
    }

    pub resource interface StreamInfoGetter {
        pub fun getInfo(id: UInt64): Stream
        pub fun getAvailable(id: UInt64, at: UFix64): UFix64
        pub fun getSourceStreamKeys(): [UInt64]
    }

    pub resource interface StreamClaimer {
        pub fun claimAvailable(id: UInt64): UFix64
    }

    pub init(){
        self.toDestinationSources = {}
    }

}

 