import Lumi from "Lumi"

pub fun main(account: Address): [Lumi.Stream] {
    var res: [Lumi.Stream] = []

    let lumiStreamGetter = getAccount(account).getCapability<&Lumi.SourceCollection{Lumi.StreamInfoGetter}>(/public/MainGetter)

    var keys = lumiStreamGetter.borrow()!.getSourceStreamKeys()

    for id in keys {
        res.append(lumiStreamGetter.borrow()!.getInfo(id: id)) 
    }

    return res
}