import Lumi from "Lumi"

transaction(streamId: UInt64){
    prepare(acct: AuthAccount){
        var sender = Lumi.toDestinationSources[acct.address]![streamId] ?? panic("No stream with this id")
        let lumiStreamClaimer = getAccount(sender).getCapability<&Lumi.SourceCollection{Lumi.StreamClaimer}>(/public/MainClaimer)
    
        var amountClaimed = lumiStreamClaimer.borrow()!.claimAvailable(id: streamId) 
        log("Claimed ".concat(amountClaimed.toString()))
    }

    execute{

    }
}