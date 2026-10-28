--!strict
-- Camp screen routing: every screen fills the viewport above the common dock.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local Inventory=require(script.Parent.Inventory)
local Crafting=require(script.Parent.Crafting)
local Skills=require(script.Parent.Skills)
local Character=require(script.Parent.Character)
local WorldMap=require(script.Parent.WorldMap)
local C={}
function C.Camp(v) Character.Show(v) end
function C.Inventory(v) Inventory.Show(v) end
function C.Crafting(v) Crafting.Show(v) end
function C.Skills(v) Skills.Show(v) end
function C.Stats(v) Character.Show(v) end
function C.Map(v) WorldMap.Show(v) end
function C.Codex(v)
 local sc=S.Scroll(v.root,15,28,1240,585)
 T.copy(sc,"RUN CODEX",45,T.c.gold)
 local r=v.state.run
 T.copy(sc,"Enemies defeated: "..r.kills,35,T.c.white)
 for _,name in ipairs(T.keys(r.trophies or {})) do T.copy(sc,name.."  ×"..r.trophies[name],30,T.c.mute) end
 S.Dock(v)
end
function C.Merchant(v)
 require(script.Parent.MerchantScreen).Show(v)
end
return C
