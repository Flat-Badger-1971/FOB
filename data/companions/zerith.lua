local FOB = _G.FOB
local cid = GetCompanionCollectibleId(FOB.DefIds.Zerith)
local name, _, icon = GetCollectibleInfo(cid)

-- getting a bounty/assaulting someone, innocent with blade of woe, stealing medical, religious or sentimental items,
-- using pardon edict (71779) or leniency edict (73754), fencing stolen goods

FOB.Functions[FOB.DefIds.Zerith] = {Sort = name}
