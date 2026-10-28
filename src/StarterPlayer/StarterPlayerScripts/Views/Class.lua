--!strict
-- The special class screens retain their server-side ability logic.
local T=require(script.Parent.Kit)
local Camp=require(script.Parent.Camp)
local C={};local k=T.c
local function row(scroll,name,desc,func,color)
 T.entry(scroll,name,desc,func,color or k.purple,67)
end
function C.Show(v)
 local r=v.state.run
 local panel=Camp.Left(v,r.class:upper().."  •  CLASS ABILITY")
 local sc=T.scroll(panel,21,60,861,380)
 T.copy(sc,v.content.Classes[r.class],65,k.mute)
 if r.class=="Warrior" then
  T.copy(sc,"BATTLE CRY  •  "..r.cryPoints.." skill points available",45,k.gold)
  T.copy(sc,"Your skill tree is randomly generated on every new run. Unlock each branch from its first tier upward.",60,k.mute)
  for tier=1,3 do
   T.copy(sc,"TIER  "..tier,30,k.gold)
   for branch=1,3 do
    local i=(tier-1)*3+branch;local node=r.cryNodes[i]
    local owned=r.cryOwned[tostring(i)]
    local valid=not owned and r.cryPoints>0 and (tier==1 or r.cryOwned[tostring(i-3)])
    local label=owned and "UNLOCKED  ✓  " or valid and "UNLOCK  •  " or "LOCKED  •  "
    row(sc,label..node.name,node.desc,function() if valid then v.send("CryUnlock",{index=i}) end end,owned and k.green or valid and k.gold or k.border)
   end
  end
 elseif r.class=="Hunter" then
  T.copy(sc,"TROPHY DISPLAY  •  "..r.trophyTotal.." trophies",42,k.gold)
  T.copy(sc,"Every killed monster becomes a trophy. Gain +0.3% damage per trophy, capped at +25%.",54,k.mute)
  for _,name in ipairs(T.keys(r.trophies)) do T.copy(sc,name.."   ×"..r.trophies[name],30,k.green) end
  T.copy(sc,"TRAP MAKER  •  PRECOMBAT PREPARATION",43,k.gold)
  for _,name in ipairs({"Spike","Venom","Snare"}) do
   local desc={Spike="Deals damage to the strongest enemy",Venom="Poisons the strongest enemy",Snare="Stuns the strongest enemy"}
   row(sc,(r.trap==name and "SELECTED  •  " or "SET TRAP  •  ")..name,desc[name],function() v.send("Trap",{name=name}) end,r.trap==name and k.green or k.blue)
  end
  T.copy(sc,"BOUNTY BOARD",43,k.gold)
  if r.bounty then
   T.copy(sc,r.bounty.kind..":  "..r.bounty.progress.." / "..r.bounty.goal.." targets eliminated",55,k.green)
  else
   for _,kind in ipairs({"Any","Wild","Goblin","Undead"}) do
    row(sc,"ACCEPT  "..kind:upper().." BOUNTY","Defeat marked monsters for gold and XP",function() v.send("Bounty",{kind=kind}) end,k.gold)
   end
  end
 elseif r.class=="Paladin" then
  T.copy(sc,"DIVINE FAVOR  •  "..(r.charges or 0).." divine charges",42,k.gold)
  T.copy(sc,"Paladins have NO active blessing limit and may stack identical blessings. Pending blessings activate after victories; Divine Charges cleanse curses.",75,k.mute)
  T.copy(sc,"ACTIVE BLESSINGS",34,k.gold)
  for _,n in ipairs(T.keys(r.blessings)) do T.copy(sc,n.."  ×"..r.blessings[n],30,k.green) end
  T.copy(sc,"PENDING BLESSINGS  •  MAX 2",34,k.gold)
  for _,b in ipairs(r.pending or {}) do T.copy(sc,b.name.."  •  "..b.left.." victories left",30,k.mute) end
  T.copy(sc,"REQUEST BLESSING",38,k.gold)
  for _,n in ipairs(T.keys(v.content.Blessings)) do
   row(sc,n,v.content.Blessings[n].text,function() v.send("BlessRequest",{name=n}) end,k.gold)
  end
  T.copy(sc,"CLEANSE A CURSE  •  1 DIVINE CHARGE",40,k.red)
  for _,n in ipairs(T.keys(r.curses)) do row(sc,"REMOVE  "..n,"Use a Divine Charge to remove one curse stack",function() v.send("Cleanse",{name=n}) end,k.red) end
 elseif r.class=="Mage" then
  local d=v.draft;local cost=4+(d.area and 4 or 0)+(d.effect~="None" and 2 or 0)
  T.copy(sc,"CUSTOM SPELL CRAFTER  •  10-POINT LIMIT",47,k.gold)
  T.copy(sc,d.element.."  /  "..(d.area and "ALL ENEMIES" or "SINGLE ENEMY").."  /  "..d.effect.."    •    "..cost.." / 10 POINTS",62,cost>10 and k.red or k.green)
  T.copy(sc,"ELEMENT",30,k.gold)
  for _,el in ipairs({"Fire","Ice","Arcane"}) do
   row(sc,(d.element==el and "● " or "○ ")..el,"Elemental damage focus",function() d.element=el;v.redraw() end,k.purple)
  end
  T.copy(sc,"TARGET TYPE",30,k.gold)
  for _,opt in ipairs({{false,"One enemy"},{true,"All enemies (+4 points)"}}) do
   row(sc,(d.area==opt[1] and "● " or "○ ")..opt[2],"Choose how many foes are hit",function() d.area=opt[1];v.redraw() end,k.blue)
  end
  T.copy(sc,"ADDITIONAL EFFECT",30,k.gold)
  for _,name in ipairs({"None","Poison","Burn"}) do
   row(sc,(d.effect==name and "● " or "○ ")..name,"Additional status effect",function() d.effect=name;v.redraw() end,k.purple)
  end
  row(sc,"CRAFT SPELL","Apply your custom spell to combat",function() v.send("CraftSpell",d) end,k.gold)
 elseif r.class=="Necromancer" then
  T.copy(sc,"ZOMBIE WORKSHOP",43,k.gold)
  T.copy(sc,"Equip monster parts in five body slots to build your own undead companion. Your zombie attacks automatically.",64,k.mute)
  for _,slot in ipairs({"Head","Arms","Chest","Legs","Core"}) do
   T.copy(sc,slot:upper().."  •  "..(r.zombieParts[slot] or "Empty"),38,k.gold)
   for _,name in ipairs(T.keys(r.inventory)) do
    local itm=v.content.Items[name]
    if itm and itm.kind=="Part" then
     row(sc,"EQUIP  "..name.."  ×"..r.inventory[name],"+"..itm.bonus.." "..itm.stat,function() v.send("ZombieEquip",{slot=slot,name=name}) end,k.purple)
    end
   end
  end
 elseif r.class=="Merchant" then
  T.copy(sc,"MERCHANT'S CARAVAN",44,k.gold)
  T.copy(sc,"Buy equipment and supplies from your personal campsite shop. Refresh the entire stock for 20 MP.",81,k.mute)
  row(sc,"OPEN PERSONAL SHOP","Browse items, purchase equipment, and manage your supplies",function() v.send("OpenShop") end,k.gold)
 end
end
return C
