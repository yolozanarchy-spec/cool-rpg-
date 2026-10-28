--!strict
-- Switches class-specific panels while retaining server-authoritative actions.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local C={};local c=T.c
local function row(sc,name,detail,callback,color)
 local b=T.entry(sc,name,detail,callback,color or c.gold,67)
 b.BackgroundColor3=Color3.fromRGB(38,38,40)
end
function C.Show(v)
 local r=v.state.run
 if r.class=="Necromancer" then require(script.Parent.Necromancy).Show(v);return end
 if r.class=="Mage" then require(script.Parent.Spellcraft).Show(v);return end
 if r.class=="Warrior" then require(script.Parent.WarCry).Show(v);return end
 if r.class=="Merchant" then
  local p=S.Box(v.root,200,120,880,420,c.shop)
  T.label(p,"MERCHANT'S CARAVAN",24,27,821,46,{size=25,bold=true,color=c.gold})
  T.label(p,"Open your personal shop and spend gold or refresh inventory using MP.",25,92,823,94,{size=18,color=c.mute})
  T.button(p,"OPEN BAZAAR",255,273,365,65,function()v.send("OpenShop")end,c.gold)
  S.Dock(v);return
 end
 local panel=S.Box(v.root,17,12,1246,615,Color3.fromRGB(29,29,31))
 local sc=S.Scroll(panel,15,13,1212,580)
 T.copy(sc,r.class:upper().."  ·  CLASS ABILITY",42,c.gold)
 T.copy(sc,v.content.Classes[r.class],74,c.mute)
 if r.class=="Hunter" then
  T.copy(sc,"TROPHY DISPLAY  ·  "..r.trophyTotal.." kills collected",38,c.gold)
  T.copy(sc,"Each monster you kill becomes a trophy, increasing your starting damage.",45,c.mute)
  for _,name in ipairs(T.keys(r.trophies)) do T.copy(sc,name.." ×"..r.trophies[name],29,c.green) end
  T.copy(sc,"PRE-COMBAT TRAP MAKER",42,c.gold)
  for _,name in ipairs({"Spike","Venom","Snare"}) do
   row(sc,(r.trap==name and "✓ " or "")..name,"Triggers on the strongest enemy at combat start",function()v.send("Trap",{name=name})end,c.blue)
  end
  T.copy(sc,"BOUNTY BOARD",40,c.gold)
  if r.bounty then T.copy(sc,r.bounty.kind.." — "..r.bounty.progress.." / "..r.bounty.goal.." kills",39,c.green)
  else for _,kind in ipairs({"Any","Wild","Goblin","Undead"}) do
    row(sc,"Accept "..kind.." bounty","Complete this contract for XP and gold",function()v.send("Bounty",{kind=kind})end,c.yellow)
   end
  end
 elseif r.class=="Paladin" then
  T.copy(sc,"DIVINE FAVOR  ·  Charges: "..(r.charges or 0),45,c.gold)
  T.copy(sc,"UNLIMITED active blessing stacks. Divine Charges remove curses.",45,c.mute)
  T.copy(sc,"ACTIVE BLESSINGS",35,c.green)
  for _,name in ipairs(T.keys(r.blessings)) do T.copy(sc,name.." ×"..r.blessings[name],30,c.green) end
  T.copy(sc,"PENDING BLESSINGS",35,c.gold)
  for _,b in ipairs(r.pending or {}) do T.copy(sc,b.name.." — "..b.left.." victories remaining",36,c.mute) end
  T.copy(sc,"REQUEST A BLESSING",38,c.gold)
  for _,name in ipairs(T.keys(v.content.Blessings)) do
   row(sc,name,v.content.Blessings[name].text,function()v.send("BlessRequest",{name=name})end,c.gold)
  end
  T.copy(sc,"CLEANSE CURSE (1 CHARGE)",40,c.red)
  for _,name in ipairs(T.keys(r.curses)) do
   row(sc,name,"Remove one curse stack",function()v.send("Cleanse",{name=name})end,c.red)
  end
 end
 S.Gear(v);S.Dock(v)
end
return C
