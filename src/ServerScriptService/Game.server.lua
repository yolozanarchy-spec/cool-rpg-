--!strict
-- One isolated run per player. Server validates every gameplay request.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Shared=ReplicatedStorage:WaitForChild("Shared")
local Content=require(Shared:WaitForChild("Content"))
local Progress=require(Shared:WaitForChild("Progress"))
local Adventure=require(Shared:WaitForChild("Adventure"))
local Battle=require(Shared:WaitForChild("Battle"))
local remote=Instance.new("RemoteFunction")
remote.Name="RPGRequest"
remote.Parent=ReplicatedStorage
local sessions={}
local lastCall={}
local function contains(t,k) return t and t[k]~=nil end
local function note(ctx,msg) ctx.message=msg end
local function enterReward(ctx,text,awarded)
 local r=ctx.run
 if ctx.map and ctx.map.selected then Adventure.Finish(ctx.map) end
 if ctx.map then r.stage=ctx.map.row end
 local levels=Progress.LevelUp(r)
 ctx.reward={summary=text,gold=awarded and awarded.gold or 0,xp=awarded and awarded.xp or 0,item=awarded and awarded.item or "",levelUps=levels,
  choices=levels>0 and Progress.ChooseUpgrades(r) or {},selected=levels==0}
 ctx.phase="Reward"
end
local function rewardCombat(ctx)
 local r=ctx.run
 local count=0;local value=0
 for _,e in ipairs(r.combat.enemies) do count+=1;value+=e.level end
 local xp=12+value*9+(r.combat.battleKind=="Boss" and 80 or 0)
 local gold=12+value*7+(r.combat.battleKind=="Boss" and 100 or 0)
 r.xp+=xp;r.gold+=gold
 if r.combat.battleKind=="Boss" then r.bosses+=1 end
 local drops={"Herbs","Oak Wood","Iron Ore","Rabbit Hide","Wolf Pelt","Goblin Tooth","Health Potion","Bone Fragment"}
 local drop=drops[math.random(#drops)]
 Progress.AddItem(r,drop,1)
 Progress.OnVictory(r)
 if r.class=="Hunter" and r.lastBounty then note(ctx,r.lastBounty);r.lastBounty=nil end
 r.combat=nil
 enterReward(ctx,"Combat complete!",{xp=xp,gold=gold,item=drop})
end
local function ensureShop(ctx)
 ctx.shop={}
 local names={"Health Potion","Mana Potion","Antidote","Iron Sword","Steel Sword","Nature Staff","Bone Bow","Wooden Shield","Leather Armor","Lucky Ring","Major Health Potion","Knight Armor"}
 for i=1,6 do
  local name=names[math.random(#names)]
  local discount=(ctx.run.class=="Merchant" and .85 or 1)
  table.insert(ctx.shop,{name=name,price=math.floor(Content.Items[name].price*discount)})
 end
end
local function startBattle(ctx,kind,forced)
 Battle.Start(ctx.run,kind,forced)
 ctx.phase="Combat"
end
local function doEvent(ctx,choice)
 local e=ctx.eventName
 local legal=false
 for _,opt in ipairs(Adventure.EventChoices(e)) do if opt.id==choice then legal=true end end
 if not legal then return note(ctx,"Invalid event choice") end
 local r=ctx.run
 local reward={xp=0,gold=0,item=""}
 local message="You safely depart."
 if choice=="fight" then startBattle(ctx,"Event",e=="Mysterious Stranger" and "Bandit Rogue" or "Bandit Captain");return end
 if choice=="bribe" then
  if r.gold<20 then return note(ctx,"Not enough gold") end
  r.gold-=20;message="You paid off the bandits."
 elseif choice=="open" or choice=="loot" then
  reward.gold=math.random(25,65)
  reward.item=choice=="loot" and "Monster Essence" or "Herbs"
  Progress.AddItem(r,reward.item,1);r.gold+=reward.gold
  message="You found a stash of supplies."
  if choice=="loot" then r.curses["Curse of Weakness"]=(r.curses["Curse of Weakness"] or 0)+1;message="Treasure claimed, but a curse followed!" end
 elseif choice=="talk" or choice=="train" then
  reward.xp=math.random(20,45);r.xp+=reward.xp;message="You learned from the encounter."
 elseif choice=="rest" then Progress.Heal(r,40,20);message="You rested and recovered."
 elseif choice=="pray" then
  local names={};for n in pairs(Content.Blessings) do table.insert(names,n) end;table.sort(names)
  local bless=names[math.random(#names)]
  local success,msg=Progress.Bless(r,bless);message=msg
  if success then Progress.Heal(r,5,0) end
 elseif choice=="curse" then
  local names={};for n in pairs(Content.Curses) do table.insert(names,n) end
  local curse=names[math.random(#names)]
  r.curses[curse]=(r.curses[curse] or 0)+1
  r.bonusStats.Strength=(r.bonusStats.Strength or 0)+5
  message="+5 Strength, but you gained "..curse
 end
 enterReward(ctx,message,reward)
end
local function handle(ctx,op,p)
 local phase=ctx.phase
 local r=ctx.run
 if op=="Poll" then return end
 if op=="Play" and phase=="Menu" then ctx.phase="Creation";return end
 if op=="BackCreation" and phase=="Creation" then ctx.phase="Menu";return end
 if op=="Info" and phase~="Info" then ctx.info= p and p.kind or "Info";ctx.beforeInfo=phase;ctx.phase="Info";return end
 if op=="BackInfo" and phase=="Info" then ctx.phase=ctx.beforeInfo or "Menu";return end
 if op=="Confirm" and phase=="Creation" then
  if typeof(p)~="table" or not contains(Content.Races,p.race) or not contains(Content.Classes,p.class) or not contains(Content.Traits,p.trait) then return note(ctx,"Invalid character") end
  ctx.run=Progress.New(p.race,p.class,p.trait)
  ctx.map=Adventure.Generate()
  ctx.phase="Camp";note(ctx,"Your adventure begins!")
  return
 end
 if not r then return end
 if op=="CampTab" and (table.find({"Camp","Inventory","Crafting","Skills","Class","Stats","Codex"},phase) or (phase=="Merchant" and not ctx.shopEvent)) then
  local t=p and p.tab
  if t=="Map" then ctx.phase="Map"
  elseif table.find({"Inventory","Crafting","Skills","Class","Stats","Codex"},t) then ctx.phase=t
  else return end
  return
 end
 if op=="BackCamp" and table.find({"Map","Inventory","Crafting","Skills","Class","Stats","Codex","Merchant"},phase) then
  if phase=="Merchant" and ctx.shopEvent then ctx.shopEvent=nil;enterReward(ctx,"You leave the traveling merchant",{});return end
  ctx.phase="Camp";return
 end
 if op=="ChooseNode" and phase=="Map" then
  local node=Adventure.Choose(ctx.map,p and p.index)
  if not node then return note(ctx,"That node is not connected to your path") end
  if node=="Combat" or node=="Boss" then startBattle(ctx,node)
  elseif node=="Merchant" then ctx.shopEvent=true;ensureShop(ctx);ctx.phase="Merchant"
  elseif node=="Rest" then Progress.Heal(r,math.ceil(Progress.Stats(r).MaxHP*.5),25);enterReward(ctx,"Resting place: your wounds have healed.",{})
  else ctx.eventName=node=="Special" and "Ancient Shrine" or Adventure.RandomEvent();ctx.phase="Event" end
  return
 end
 if op=="EventChoice" and phase=="Event" then if typeof(p)=="table" and typeof(p.choice)=="string" then doEvent(ctx,p.choice) end;return end
 if op=="CombatAction" and phase=="Combat" then
  if typeof(p)~="table" then return end
  local ok,outcome=Battle.Action(r,p.action,p.index,p.skill)
  if not ok then return note(ctx,outcome) end
  if outcome=="Victory" then rewardCombat(ctx)
  elseif outcome=="Defeat" then ctx.phase="Death";r.combat=nil
  elseif outcome=="Escaped" then r.combat=nil;enterReward(ctx,"You escaped the encounter without rewards.",{}) end
  return
 end
 if op=="Upgrade" and phase=="Reward" and not ctx.reward.selected then
  if typeof(p)~="table" or typeof(p.name)~="string" then return end
  if Progress.ApplyUpgrade(r,p.name,ctx.reward.choices) then ctx.reward.selected=true;note(ctx,"Upgrade chosen: "..p.name) end
  return
 end
 if op=="Continue" and phase=="Reward" and ctx.reward.selected then
  if ctx.map.completed then ctx.phase="Victory" else ctx.phase="Camp" end
  return
 end
 if op=="NewRun" and (phase=="Death" or phase=="Victory") then
  ctx.run=nil;ctx.map=nil;ctx.phase="Menu";ctx.reward=nil;return
 end
 if op=="UseItem" and (phase=="Inventory" or phase=="Camp") then
  local name=p and p.name;local item=Content.Items[name]
  if not item or item.kind~="Consumable" or (r.inventory[name] or 0)<1 then return end
  r.inventory[name]-=1;if r.inventory[name]==0 then r.inventory[name]=nil end
  Progress.Heal(r,item.heal or 0,item.mana or 0);note(ctx,"Used "..name);return
 end
 if op=="Equip" and phase=="Inventory" then
  if Progress.Equip(r,p and p.name) then note(ctx,"Equipment changed") end;return
 end
 if op=="Craft" and phase=="Crafting" then
  if Progress.Craft(r,p and p.name) then note(ctx,"Crafted "..p.name) else note(ctx,"Missing ingredients") end;return
 end
 if op=="OpenShop" and phase=="Class" and r.class=="Merchant" then
  ctx.shopEvent=false;if #r.shop==0 then ensureShop(ctx);r.shop=ctx.shop end
  ctx.shop=r.shop;ctx.phase="Merchant";return
 end
 if op=="RefreshShop" and phase=="Merchant" then
  if ctx.shopEvent then return note(ctx,"Traveling merchants cannot refresh") end
  if r.mp<20 then return note(ctx,"Refresh costs 20 MP") end
  r.mp-=20;ensureShop(ctx);r.shop=ctx.shop;return
 end
 if op=="Buy" and phase=="Merchant" then
  local slot=p and p.index
  if typeof(slot)~="number" or slot%1~=0 then return end
  local item=ctx.shop[slot];if not item then return end
  if r.gold<item.price then return note(ctx,"Not enough gold") end
  r.gold-=item.price;Progress.AddItem(r,item.name,1);table.remove(ctx.shop,slot)
  note(ctx,"Purchased "..item.name);return
 end
 if op=="Trap" and phase=="Class" and r.class=="Hunter" then
  if table.find({"Spike","Venom","Snare"},p and p.name) then r.trap=p.name end;return
 end
 if op=="Bounty" and phase=="Class" and r.class=="Hunter" then
  if Progress.PickBounty(r,p and p.kind) then note(ctx,"Bounty accepted") else note(ctx,"Complete your current bounty first") end;return
 end
 if op=="CryUnlock" and phase=="Class" then
  if Progress.UnlockCry(r,p and p.index) then note(ctx,"Battle Cry node unlocked") end;return
 end
 if op=="CraftSpell" and phase=="Class" then
  local ok,msg=Progress.CraftSpell(r,p and p.area,p and p.element,p and p.effect)
  note(ctx,msg);return
 end
 if op=="BlessRequest" and phase=="Class" then
  if Progress.AddBlessingRequest(r,p and p.name) then note(ctx,"Blessing requested! Win combats to activate it") else note(ctx,"Pending blessings full or invalid") end;return
 end
 if op=="Cleanse" and phase=="Class" and r.class=="Paladin" then
  if (r.charges or 0)<1 then return note(ctx,"Gain Divine Charges by completing blessings") end
  if Progress.RemoveCurse(r,p and p.name) then r.charges-=1;note(ctx,"Curse cleansed") end;return
 end
 if op=="ZombieEquip" and phase=="Class" and r.class=="Necromancer" then
  local slot=p and p.slot;local name=p and p.name
  if not table.find({"Head","Arms","Chest","Legs","Core"},slot) then return end
  if not Content.Items[name] or Content.Items[name].kind~="Part" or (r.inventory[name] or 0)<1 then return end
  local prev=r.zombieParts[slot]
  if prev then Progress.AddItem(r,prev,1) end
  r.zombieParts[slot]=name;r.inventory[name]-=1
  if r.inventory[name]==0 then r.inventory[name]=nil end
  note(ctx,"Zombie "..slot.." equipped")
  return
 end
 note(ctx,"This action is not available here")
end
local function publicView(ctx)
 -- No Instances or cyclic source references are ever sent to clients.
 local data={phase=ctx.phase,info=ctx.info,message=ctx.message,run=ctx.run,map=ctx.map,reward=ctx.reward,shop=ctx.shop,eventName=ctx.eventName,stats=ctx.run and Progress.Stats(ctx.run) or nil}
 if ctx.eventName then data.eventChoices=Adventure.EventChoices(ctx.eventName) end
 return data
end
remote.OnServerInvoke=function(player,op,p)
 if typeof(op)~="string" or #op>35 then return {phase="Menu",message="Bad request"} end
 local now=os.clock()
 if op~="Poll" and (now-(lastCall[player] or 0))<.06 then
  return publicView(sessions[player] or {phase="Menu"})
 end
 if op~="Poll" then lastCall[player]=now end
 local ctx=sessions[player]
 if not ctx then ctx={phase="Menu",message="Welcome to Cool RPG"};sessions[player]=ctx end
 ctx.message=""
 local ok,err=pcall(handle,ctx,op,p)
 if not ok then warn("[Cool RPG] Server action error for",player.UserId,op,err);ctx.message="Action failed on server; check Output" end
 return publicView(ctx)
end
Players.PlayerRemoving:Connect(function(player) sessions[player]=nil;lastCall[player]=nil end)
