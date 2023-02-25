import Lumi from "Lumi"

pub fun main(account: Address): [Lumi.Stream] {
    var res: [Lumi.Stream] = []

    for key in Lumi.toDestinationSources[account]!.keys {
        var sender = Lumi.toDestinationSources[account]![key]!
        let lumiStreamGetter = getAccount(sender).getCapability<&Lumi.SourceCollection{Lumi.StreamInfoGetter}>(/public/MainGetter)

        res.append(lumiStreamGetter.borrow()!.getInfo(id: key)) 
    }

    return res
}