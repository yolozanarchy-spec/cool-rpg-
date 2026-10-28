--!strict
-- Shared stat/progression functions. Invoked only by the server.
local Content = require(script.Parent.Content)
local P = {}
local function add(t, key, n) t[key] = (t[key] or 0) + n end
P.Add = add
function P.Stats(run)
 local out = {}
 for _,stat in ipairs(Content.Stats) do
  out[stat] = 3 + (Content.Races[run.race].stats[stat] or 0) + (Content.Traits[run.trait].stats[stat] or 0) + (run.bonusStats[stat] or 0)
 end
 for slot,itemName in pairs(run.equipment) do
  local item = Content.Items[itemName]
  if item and item.stat then out[item.stat] += item.bonus end
 end
 for name,count in pairs(run.blessings) do
  local b=Content.Blessings[name]
  if b then out[b.stat] *= (1+b.percent)^count end
 end
 for name,count in pairs(run.curses) do
  local c=Content.Curses[name]
  if c then out[c.stat] *= (1+c.percent)^count end
 end
 for k,v in pairs(out) do out[k]=math.max(0,math.floor(v+.5)) end
 out.MaxHP=math.floor((50+out.Strength*5+out.Defense*3+10*(run.level-1)+run.bonusHP)*(run.trait=="Glass Cannon" and .8 or 1))
 out.MaxMP=30+out.Intelligence*3
 return out
end
function P.New(race,className,trait)
 local r={race=race,class=className,trait=trait,level=1,xp=0,gold=80,bonusStats={},bonusHP=0,flags={},
  inventory={["Health Potion"]=2,["Mana Potion"]=1,["Herbs"]=1},equipment={Weapon="Stick"},
  blessings={},curses={},trophies={},trophyTotal=0,bounty=nil,trap="Spike",cryNodes={},cryOwned={},cryPoints=0,
  spell={area=false,element="Fire",effect="None",name="Ember Bolt",points=4},zombieParts={},
  shop={},kills=0,wins=0,bosses=0,stage=1,log={},timeStart=os.time()}
 local s=P.Stats(r)
 r.hp=s.MaxHP;r.mp=s.MaxMP
 if className=="Warrior" then
  local bag=table.clone(Content.CryNodes)
  for i=1,9 do local j=math.random(#bag);r.cryNodes[i]=table.remove(bag,j) end
  r.cryPoints=1
 end
 if className=="Necromancer" then r.inventory["Bone Fragment"]=1 end
 return r
end
function P.AddItem(run,name,count)
 if not Content.Items[name] then return end
 add(run.inventory,name,count or 1)
end
function P.Heal(run,hp,mp)
 local s=P.Stats(run)
 run.hp=math.min(s.MaxHP,run.hp+(hp or 0))
 run.mp=math.min(s.MaxMP,run.mp+(mp or 0))
end
function P.LevelUp(run)
 local gained=0
 while run.xp >= run.level*35 do
  run.xp-=run.level*35;run.level+=1; gained+=1
  if run.class=="Warrior" then run.cryPoints+=1 end
 end
 if gained>0 then P.Heal(run,12*gained,7*gained) end
 return gained
end
function P.ChooseUpgrades(run)
 local bag=table.clone(Content.Upgrades)
 local choices={}
 for _=1,math.min(3,#bag) do
  local index=math.random(#bag)
  table.insert(choices,table.remove(bag,index))
 end
 return choices
end
function P.ApplyUpgrade(run,name,choices)
 for _,u in ipairs(choices or {}) do
  if u.name==name then
   if u.stat then add(run.bonusStats,u.stat,u.amount) end
   if u.bonusHP then run.bonusHP+=u.bonusHP end
   if u.flag then run.flags[u.flag]=true end
   P.Heal(run,5,0)
   return true
  end
 end
 return false
end
function P.Bless(run,name)
 if not Content.Blessings[name] then return false,"Unknown blessing" end
 local distinct=0
 for _,n in pairs(run.blessings) do if n>0 then distinct+=1 end end
 if run.class~="Paladin" and ((run.blessings[name] or 0)>0 or distinct>=2) then
  return false,"Other classes may hold only two different blessings, no repeats"
 end
 add(run.blessings,name,1)
 return true,"Blessing received: "..name
end
function P.RemoveCurse(run,name)
 if (run.curses[name] or 0)<1 then return false end
 run.curses[name]-=1
 if run.curses[name]==0 then run.curses[name]=nil end
 return true
end
function P.OnKill(run,enemyName)
 run.kills+=1
 if run.class=="Hunter" then
  add(run.trophies,enemyName,1)
  run.trophyTotal+=1
  if run.bounty then
   local b=run.bounty
   local found = (b.kind=="Any" or (b.kind=="Wild" and (string.find(enemyName,"Wolf") or string.find(enemyName,"Rabbit") or string.find(enemyName,"Harpy")))
    or (b.kind=="Goblin" and string.find(enemyName,"Goblin")) or (b.kind=="Undead" and (string.find(enemyName,"Skeleton") or string.find(enemyName,"Zombie") or string.find(enemyName,"Ghost"))))
   if found then
    b.progress+=1
    if b.progress>=b.goal then
     run.gold+=b.gold;run.xp+=b.xp
     run.lastBounty="Bounty complete: +"..b.gold.." gold, +"..b.xp.." XP"
     run.bounty=nil
    end
   end
  end
 end
 if run.class=="Necromancer" and math.random()<.3 then
  local options={"Bone Fragment","Wolf Fang","Venom Sac","Monster Essence"}
  P.AddItem(run,options[math.random(#options)],1)
 end
end
function P.TrophyBonus(run)
 if run.class~="Hunter" then return 1 end
 return 1+math.min(.25,run.trophyTotal*.003)
end
function P.PickBounty(run,kind)
 if run.class~="Hunter" or run.bounty then return false end
 local defs={Any={goal=5,gold=75,xp=50},Wild={goal=3,gold=50,xp=35},Goblin={goal=2,gold=55,xp=40},Undead={goal=2,gold=65,xp=45}}
 local d=defs[kind];if not d then return false end
 run.bounty={kind=kind,goal=d.goal,progress=0,gold=d.gold,xp=d.xp};return true
end
function P.UnlockCry(run,index)
 if run.class~="Warrior" or run.cryPoints<=0 or typeof(index)~="number" or index%1~=0 then return false end
 if index<1 or index>9 or run.cryOwned[tostring(index)] then return false end
 if index>3 and not run.cryOwned[index-3] then return false end
 run.cryOwned[tostring(index)]=true;run.cryPoints-=1;return true
end
function P.CraftSpell(run,area,element,effect)
 if run.class~="Mage" then return false,"Not a Mage" end
 if typeof(area)~="boolean" or not table.find({"Fire","Ice","Arcane"},element) or not table.find({"None","Poison","Burn"},effect) then return false,"Invalid spell" end
 local points=4+(area and 4 or 0)+(effect~="None" and 2 or 0)
 if points>10 then return false,"Spell exceeds 10 points" end
 run.spell={area=area,element=element,effect=effect,points=points,name=element..(area and " Wave" or " Bolt")}
 return true,"Spell created"
end
function P.AddBlessingRequest(run,name)
 if run.class~="Paladin" or not Content.Blessings[name] then return false end
 run.pending=run.pending or {}
 if #run.pending>=2 then return false end
 table.insert(run.pending,{name=name,left=math.random(2,4)})
 return true
end
function P.OnVictory(run)
 run.wins+=1
 if run.class=="Paladin" then
  for i=#(run.pending or {}),1,-1 do
   local p=run.pending[i];p.left-=1
   if p.left<=0 then
    P.Bless(run,p.name)
    run.charges=(run.charges or 0)+1
    table.remove(run.pending,i)
   end
  end
 end
end
function P.Equip(run,name)
 local item=Content.Items[name]
 if not item or (run.inventory[name] or 0)<1 or not table.find({"Weapon","Armor","Ring","Shield"},item.kind) then return false end
 local old=run.equipment[item.kind]
 if old then P.AddItem(run,old,1) end
 run.equipment[item.kind]=name;run.inventory[name]-=1
 if run.inventory[name]==0 then run.inventory[name]=nil end
 P.Heal(run,0,0)
 return true
end
function P.Craft(run,name)
 for _,r in ipairs(Content.Recipes) do
  if r.name==name then
   for ingredient,amount in pairs(r.need) do if (run.inventory[ingredient] or 0)<amount then return false end end
   for ingredient,amount in pairs(r.need) do run.inventory[ingredient]-=amount;if run.inventory[ingredient]==0 then run.inventory[ingredient]=nil end end
   P.AddItem(run,name,r.qty)
   return true
  end
 end
 return false
end
function P.ZombieStats(run)
 local stats={hp=35,attack=5,defense=2}
 if run.class~="Necromancer" then return stats end
 for _,partName in pairs(run.zombieParts) do
  local item=Content.Items[partName]
  if item then
   if item.stat=="Strength" then stats.attack+=item.bonus elseif item.stat=="Defense" then stats.defense+=item.bonus;stats.hp+=item.bonus*3 else stats.attack+=1 end
  end
 end
 return stats
end
return P
