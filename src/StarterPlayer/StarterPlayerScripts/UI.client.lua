--!strict
-- Responsive 2D menu-driven RPG interface; no external images or plugins needed.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local remote=ReplicatedStorage:WaitForChild("RPGRequest")
local Shared=ReplicatedStorage:WaitForChild("Shared")
local Content=require(Shared:WaitForChild("Content"))
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui")
gui.Name="CoolRPG";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=10
-- Parent to PlayerGui so Roblox generates and maintains the complete UI.
gui.Parent=player:WaitForChild("PlayerGui")
local COLOR={bg=Color3.fromRGB(16,18,24),panel=Color3.fromRGB(29,33,43),raised=Color3.fromRGB(41,46,59),
 border=Color3.fromRGB(66,75,92),text=Color3.fromRGB(234,238,246),sub=Color3.fromRGB(167,177,198),
 gold=Color3.fromRGB(231,189,103),green=Color3.fromRGB(113,205,152),red=Color3.fromRGB(232,118,123),blue=Color3.fromRGB(107,165,237),purple=Color3.fromRGB(174,137,229)}
local state={phase="Menu"}
local choice={race="Human",class="Warrior",trait="Balanced"}
local target=1
local draft={area=false,element="Fire",effect="None"}
local busy=false
local function instance(class,properties,parent)
 local o=Instance.new(class) for k,v in pairs(properties or {}) do o[k]=v end
 o.Parent=parent;return o
end
local function round(obj,r)
 instance("UICorner",{CornerRadius=UDim.new(0,r or 10)},obj)
end
local function outline(obj)
 instance("UIStroke",{Color=COLOR.border,Transparency=.35,Thickness=1},obj)
end
local root=instance("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=COLOR.bg,BorderSizePixel=0},gui)
local backdrop=instance("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=COLOR.bg,BorderSizePixel=0},root)
instance("UIGradient",{Rotation=30,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(17,21,30)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,26,43))})},backdrop)
local shell=instance("Frame",{Size=UDim2.new(1,-30,1,-26),Position=UDim2.new(0,15,0,13),BackgroundColor3=COLOR.panel,BorderSizePixel=0},root)
round(shell,16);outline(shell)
local header=instance("Frame",{Size=UDim2.new(1,-32,0,84),Position=UDim2.fromOffset(16,12),BackgroundColor3=COLOR.raised,BorderSizePixel=0},shell)
round(header,11)
local heading=instance("TextLabel",{Size=UDim2.new(1,-26,0,36),Position=UDim2.fromOffset(13,8),BackgroundTransparency=1,Text="COOL RPG",Font=Enum.Font.GothamBold,TextSize=26,TextColor3=COLOR.gold,TextXAlignment=Enum.TextXAlignment.Left},header)
local subtitle=instance("TextLabel",{Size=UDim2.new(1,-26,0,27),Position=UDim2.fromOffset(13,43),BackgroundTransparency=1,Text="A dark fantasy roguelike adventure",Font=Enum.Font.Gotham,TextSize=14,TextColor3=COLOR.sub,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},header)
local scroll=instance("ScrollingFrame",{Size=UDim2.new(1,-34,1,-155),Position=UDim2.fromOffset(17,104),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=COLOR.gold,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y},shell)
instance("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
instance("UIPadding",{PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,8)},scroll)
local footer=instance("TextLabel",{Size=UDim2.new(1,-35,0,36),Position=UDim2.new(0,18,1,-42),BackgroundColor3=COLOR.raised,TextColor3=COLOR.sub,Font=Enum.Font.Gotham,TextSize=13,Text="",TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},shell)
round(footer,7);instance("UIPadding",{PaddingLeft=UDim.new(0,12)},footer)
local function clear()
 for _,c in ipairs(scroll:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
 scroll.CanvasPosition=Vector2.new(0,0)
end
local function txt(value,h,color,fontSize,bold)
 local t=instance("TextLabel",{Size=UDim2.new(1,-7,0,h or 32),BackgroundTransparency=1,Text=tostring(value),Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=fontSize or 16,TextColor3=color or COLOR.text,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true},scroll)
 return t
end
local function section(name)
 txt(name,38,COLOR.gold,21,true)
end
local function button(label,callback,color,detail)
 local frame=instance("TextButton",{Size=UDim2.new(1,-8,0,detail and 67 or 49),BackgroundColor3=COLOR.raised,Text="",AutoButtonColor=true},scroll)
 round(frame,10);outline(frame)
 local left=instance("Frame",{Size=UDim2.new(0,4,1,-16),Position=UDim2.fromOffset(7,8),BackgroundColor3=color or COLOR.blue,BorderSizePixel=0},frame);round(left,3)
 instance("TextLabel",{Size=UDim2.new(1,-38,0,detail and 32 or 46),Position=UDim2.fromOffset(21,detail and 4 or 2),BackgroundTransparency=1,Text=tostring(label),Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=COLOR.text,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},frame)
 if detail then instance("TextLabel",{Size=UDim2.new(1,-40,0,27),Position=UDim2.fromOffset(22,36),BackgroundTransparency=1,Text=tostring(detail),Font=Enum.Font.Gotham,TextSize=13,TextColor3=COLOR.sub,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},frame) end
 frame.Activated:Connect(callback)
 return frame
end
local function numbers(a)
 local parts={}
 for _,key in ipairs(Content.Stats) do table.insert(parts,key..": "..math.floor(a[key] or 0)) end
 return table.concat(parts,"  •  ")
end
local function orderedKeys(d)
 local result={};for k in pairs(d or {}) do table.insert(result,k) end;table.sort(result);return result
end
local function call(op,p)
 if busy then return end
 busy=true
 local ok,result=pcall(function() return remote:InvokeServer(op,p or {}) end)
 busy=false
 if ok and typeof(result)=="table" then state=result else state.message="Could not contact game server" end
end
local render
local function send(op,p)
 call(op,p)
 if render then render() end
end
local function back()
 button("← Back to campsite",function() send("BackCamp") end,COLOR.sub)
end
local function itemCount(r,name) return (r.inventory and r.inventory[name]) or 0 end
local function helpStat(r)
 txt("Level "..r.level.."   •   HP "..r.hp.."/"..r.stats.MaxHP.."   •   MP "..r.mp.."/"..r.stats.MaxMP.."   •   "..r.gold.." gold",38,COLOR.green,17,true)
 txt(numbers(r.stats),69,COLOR.sub,14)
end
local function showCreation()
 section("CREATE YOUR CHARACTER")
 txt("Choose your race, class, and trait. They affect starting stats and your unique campsite ability.",54,COLOR.sub)
 for _,field in ipairs({"race","class","trait"}) do
  txt(string.upper(field).." — "..choice[field],38,COLOR.gold,17,true)
  local values=field=="race" and Content.Races or (field=="class" and Content.Classes or Content.Traits)
  for _,name in ipairs(orderedKeys(values)) do
   local desc=field=="class" and values[name] or values[name].description
   button((choice[field]==name and "● " or "○ ")..name,function() choice[field]=name;render() end,choice[field]==name and COLOR.gold or COLOR.blue,desc)
  end
 end
 button("START ADVENTURE →",function() send("Confirm",choice) end,COLOR.green)
end
local function showMenu()
 section("A WORLD OF CHOICES")
 txt("Build a hero. Explore branching paths. Survive strategic turn-based battles. Grow stronger—or lose your run.",68,COLOR.sub)
 button("PLAY",function() send("Play") end,COLOR.gold,"Begin a single-player roguelike run")
 button("MULTIPLAYER",function() send("Info",{kind="Multiplayer"}) end,COLOR.purple,"Party play is planned but is not yet playable")
 button("ACHIEVEMENTS",function() send("Info",{kind="Achievements"}) end,COLOR.blue)
 button("INFO / CODEX",function() send("Info",{kind="Info"}) end,COLOR.blue)
 button("SETTINGS",function() send("Info",{kind="Settings"}) end,COLOR.sub)
end
local function showCamp(r)
 section("CAMPSITE • PREPARE FOR YOUR NEXT JOURNEY")
 helpStat(r)
 button("ADVENTURE MAP",function() send("CampTab",{tab="Map"}) end,COLOR.gold,"Choose one connected node to advance the run")
 button("INVENTORY & EQUIPMENT",function() send("CampTab",{tab="Inventory"}) end,COLOR.blue)
 button("CRAFTING",function() send("CampTab",{tab="Crafting"}) end,COLOR.blue)
 button("SKILLS",function() send("CampTab",{tab="Skills"}) end,COLOR.blue)
 button("CLASS ABILITY — "..r.class,function() send("CampTab",{tab="Class"}) end,COLOR.purple,Content.Classes[r.class])
 button("CHARACTER STATS",function() send("CampTab",{tab="Stats"}) end,COLOR.sub)
 button("CODEX / TROPHY RECORDS",function() send("CampTab",{tab="Codex"}) end,COLOR.sub)
 txt("Runs cannot be restarted from camp. Defeat the final boss or fall in battle to begin again.",49,COLOR.sub,13)
end
local function showMap(map)
 section("BRANCHING ADVENTURE MAP")
 txt("Choose one reachable node in row "..map.row.."/10. The tenth row contains the boss.",54,COLOR.sub)
 local colors={Combat=COLOR.red,Event=COLOR.sub,Merchant=COLOR.blue,Rest=COLOR.green,Special=COLOR.purple,Boss=COLOR.gold}
 for i,node in ipairs(map.rows[map.row] or {}) do
  local accessible=table.find(map.available,i)~=nil
  button((accessible and "◆ " or "◇ ").."Path "..i..": "..node.kind,function() if accessible then send("ChooseNode",{index=i}) end end,accessible and colors[node.kind] or COLOR.border,accessible and "AVAILABLE — select this encounter" or "NOT CONNECTED — unavailable")
 end
 for row=map.row+1,math.min(10,map.row+3) do
  local parts={};for _,n in ipairs(map.rows[row]) do table.insert(parts,n.kind) end
  txt("UPCOMING ROW "..row.."  •  "..table.concat(parts," / "),31,COLOR.sub,14)
 end
 back()
end
local function showCombat(r)
 local b=r.combat
 section(b.battleKind=="Boss" and "BOSS BATTLE" or "TURN-BASED COMBAT")
 helpStat(r)
 txt("TURN "..b.round.."   •   BARRIER "..b.barrier.."   •   Select enemy below, then take an action.",35,COLOR.gold)
 for i,e in ipairs(b.enemies) do
  local label=(target==i and "▶ " or "  ")..e.name.." • Lv "..e.level.."    "..e.hp.."/"..e.maxHP.." HP"
  local effects={};for n,duration in pairs(e.status) do if duration>0 then table.insert(effects,n.."("..duration..")") end end
  button(label,function() target=i;render() end,e.hp<=0 and COLOR.border or (target==i and COLOR.gold or COLOR.red),e.hp<=0 and "DEFEATED" or ("DEF "..e.defense.."   "..table.concat(effects,", ")))
 end
 section("CHOOSE AN ACTION")
 button("ATTACK",function() send("CombatAction",{action="Attack",index=target}) end,COLOR.red,"A physical attack that scales with Strength")
 for _,name in ipairs(Content.BaseSkills[r.class]) do
  local cd=b.cooldowns[name] or 0
  local detail=(cd>0 and ("Cooldown: "..cd.." turns") or "Ready if you have enough MP")
  if name=="Crafted Spell" then detail=r.spell.name.." • "..r.spell.points.." points • "..detail end
  button("SKILL • "..name,function() send("CombatAction",{action="Skill",index=target,skill=name}) end,cd>0 and COLOR.border or COLOR.purple,detail)
 end
 button("DEFEND",function() send("CombatAction",{action="Defend"}) end,COLOR.green,"Halve the next enemy attacks and gain 3 barrier")
 for _,name in ipairs({"Health Potion","Major Health Potion","Mana Potion","Antidote"}) do
  if itemCount(r,name)>0 then button("USE "..name.." ×"..itemCount(r,name),function() send("CombatAction",{action="Item",skill=name}) end,COLOR.blue) end
 end
 section("BATTLE LOG")
 for _,line in ipairs(b.log) do txt("• "..line,31,COLOR.sub,14) end
end
local function showReward(reward)
 section("ENCOUNTER COMPLETE")
 txt(reward.summary,60,COLOR.green,18,true)
 txt("+"..reward.gold.." gold    +"..reward.xp.." experience",41,COLOR.gold,17)
 if reward.item~="" then txt("LOOT  •  "..reward.item,42,COLOR.blue) end
 if reward.levelUps>0 then
  section("LEVEL UP! CHOOSE ONE UPGRADE")
  for _,u in ipairs(reward.choices) do
   button((reward.selected and "✓ " or "◆ ")..u.name,function() if not reward.selected then send("Upgrade",{name=u.name}) end end,reward.selected and COLOR.sub or COLOR.gold,u.desc)
  end
 end
 if reward.selected then button("RETURN TO CAMP →",function() send("Continue") end,COLOR.green) else txt("Select an upgrade to continue.",38,COLOR.sub) end
end
local function showEvent(s)
 section("ENCOUNTER • "..s.eventName)
 txt("Your choices can lead to treasure, a blessing, a curse, training, or an unexpected battle.",55,COLOR.sub)
 for _,option in ipairs(s.eventChoices or {}) do button(option.label,function() send("EventChoice",{choice=option.id}) end,COLOR.purple) end
end
local function showInventory(r)
 section("INVENTORY & EQUIPMENT")
 helpStat(r)
 for _,slot in ipairs({"Weapon","Shield","Armor","Ring"}) do txt(slot..": "..(r.equipment[slot] or "Empty"),34,COLOR.gold) end
 for _,name in ipairs(orderedKeys(r.inventory)) do
  local item=Content.Items[name]
  local description=item.kind..(item.stat and "  •  +"..item.bonus.." "..item.stat or "")
  if item.kind=="Consumable" then
   button(name.." ×"..r.inventory[name].."  • USE",function() send("UseItem",{name=name}) end,COLOR.green,description)
  elseif table.find({"Weapon","Shield","Armor","Ring"},item.kind) then
   button(name.." ×"..r.inventory[name].."  • EQUIP",function() send("Equip",{name=name}) end,COLOR.blue,description)
  else txt("• "..name.." ×"..r.inventory[name].."  ("..description..")",34,COLOR.sub,15) end
 end
 back()
end
local function showCrafting(r)
 section("CRAFTING BENCH")
 txt("Recipes appear when you have at least one of their ingredients. Crafting uses your materials.",55,COLOR.sub)
 local visible=0
 for _,recipe in ipairs(Content.Recipes) do
  local unlocked=false;local parts={}
  for ingredient,amount in pairs(recipe.need) do
   local have=itemCount(r,ingredient)
   if have>0 then unlocked=true end
   table.insert(parts,ingredient.." "..have.."/"..amount)
  end
  if unlocked then
   visible+=1
   button("CRAFT "..recipe.name,function() send("Craft",{name=recipe.name}) end,COLOR.gold,table.concat(parts,"    •    "))
  end
 end
 if visible==0 then txt("No recipes discovered. Collect materials on your journey.",55,COLOR.sub) end
 back()
end
local function showSkills(r)
 section("CLASS SKILLS • "..r.class)
 for _,name in ipairs(Content.BaseSkills[r.class]) do txt("◆ "..name,39,COLOR.purple,17,true) end
 txt("Attack and Defend are always available. Skills use cooldowns and some require MP or gold.",55,COLOR.sub)
 if r.class=="Mage" then txt("Current crafted spell: "..r.spell.name.." ("..r.spell.points.." points)",45,COLOR.gold) end
 back()
end
local function showClass(r)
 section(r.class.." • UNIQUE CLASS ABILITY")
 txt(Content.Classes[r.class],67,COLOR.sub,16)
 if r.class=="Warrior" then
  txt("BATTLE CRY SKILL TREE   •   "..r.cryPoints.." available points",50,COLOR.gold,18,true)
  txt("Each run randomly generates nine nodes. Unlock a node above its predecessor in the same branch.",56,COLOR.sub,14)
  for tier=1,3 do
   txt("TIER "..tier,32,COLOR.gold,16,true)
   for branch=1,3 do
    local i=(tier-1)*3+branch;local n=r.cryNodes[i]
    local unlocked=r.cryOwned[tostring(i)]
    local canUnlock=not unlocked and r.cryPoints>0 and (tier==1 or r.cryOwned[tostring(i-3)])
    button((unlocked and "✓ " or (canUnlock and "◇ " or "🔒 "))..n.name,function() if canUnlock then send("CryUnlock",{index=i}) end end,unlocked and COLOR.green or (canUnlock and COLOR.gold or COLOR.border),n.desc)
   end
  end
 elseif r.class=="Hunter" then
  txt("TROPHY CABINET • "..r.trophyTotal.." total trophies",46,COLOR.gold,19,true)
  txt("Every defeated enemy becomes a trophy. Each trophy grants +0.3% damage, capped at +25%.",58,COLOR.sub)
  for _,name in ipairs(orderedKeys(r.trophies)) do txt("🏆 "..name.." ×"..r.trophies[name],30,COLOR.green,15) end
  section("TRAP MAKER • BEFORE EVERY BATTLE")
  for _,name in ipairs({"Spike","Venom","Snare"}) do
   local desc={Spike="Damage the strongest enemy",Venom="Poison the strongest enemy",Snare="Stun the strongest enemy"}
   button((r.trap==name and "✓ " or "  ")..name,function() send("Trap",{name=name}) end,r.trap==name and COLOR.green or COLOR.blue,desc[name])
  end
  section("BOUNTY BOARD")
  if r.bounty then txt(r.bounty.kind..": "..r.bounty.progress.."/"..r.bounty.goal.." defeated",44,COLOR.green)
  else
   for _,kind in ipairs({"Any","Wild","Goblin","Undead"}) do
    button("ACCEPT "..kind.." bounty",function() send("Bounty",{kind=kind}) end,COLOR.gold,"Kill eligible enemies to receive gold and XP")
   end
  end
 elseif r.class=="Paladin" then
  txt("DIVINE FAVOR • "..(r.charges or 0).." divine charges",49,COLOR.gold,19,true)
  txt("Paladins can stack blessings without any active blessing limit. Request up to two pending blessings; each activates after several victories and grants a cleansing charge.",78,COLOR.sub)
  section("ACTIVE BLESSINGS")
  for _,name in ipairs(orderedKeys(r.blessings)) do txt(name.." ×"..r.blessings[name],33,COLOR.green) end
  section("PENDING BLESSINGS")
  for _,p in ipairs(r.pending or {}) do txt(p.name.." • "..p.left.." victories remaining",34,COLOR.gold) end
  section("REQUEST A BLESSING")
  for _,name in ipairs(orderedKeys(Content.Blessings)) do
   button(name,function() send("BlessRequest",{name=name}) end,COLOR.gold,Content.Blessings[name].text)
  end
  section("CLEANSE CURSES • 1 CHARGE EACH")
  for _,name in ipairs(orderedKeys(r.curses)) do
   button("REMOVE "..name.." ×"..r.curses[name],function() send("Cleanse",{name=name}) end,COLOR.red)
  end
 elseif r.class=="Mage" then
  section("CUSTOM SPELL CRAFTER • TEN POINTS")
  txt("Spell: "..draft.element.." / "..(draft.area and "All Enemies" or "Single Enemy").." / "..draft.effect,50,COLOR.gold)
  local cost=4+(draft.area and 4 or 0)+(draft.effect~="None" and 2 or 0)
  txt("Total spell cost: "..cost.."/10 points",34,cost>10 and COLOR.red or COLOR.green)
  for _,element in ipairs({"Fire","Ice","Arcane"}) do button((draft.element==element and "● " or "○ ")..element,function() draft.element=element;render() end,COLOR.purple) end
  for _,v in ipairs({false,true}) do button((draft.area==v and "● " or "○ ")..(v and "Hit every enemy (+4)" or "Hit one enemy (+0)"),function() draft.area=v;render() end,COLOR.blue) end
  for _,effect in ipairs({"None","Poison","Burn"}) do button((draft.effect==effect and "● " or "○ ")..effect,function() draft.effect=effect;render() end,COLOR.blue) end
  button("CRAFT THIS SPELL",function() send("CraftSpell",draft) end,COLOR.gold)
 elseif r.class=="Necromancer" then
  section("ZOMBIE WORKSHOP")
  txt("Equip parts into body slots to improve your ally's HP and attack. The zombie automatically attacks once each combat turn.",62,COLOR.sub)
  for _,slot in ipairs({"Head","Arms","Chest","Legs","Core"}) do
   txt(slot.." • "..(r.zombieParts[slot] or "Empty"),39,COLOR.gold,16,true)
   for _,name in ipairs(orderedKeys(r.inventory)) do
    local item=Content.Items[name]
    if item.kind=="Part" then
     button("EQUIP "..name.." ×"..r.inventory[name],function() send("ZombieEquip",{slot=slot,name=name}) end,COLOR.purple,"+"..item.bonus.." "..item.stat)
    end
   end
  end
 elseif r.class=="Merchant" then
  txt("Purchase equipment and consumables whenever you camp. Store inventory refreshes with 20 MP.",62,COLOR.sub)
  button("OPEN PERSONAL SHOP",function() send("OpenShop") end,COLOR.gold)
 end
 back()
end
local function showMerchant(s)
 section(s.run.class=="Merchant" and "MERCHANT'S CARAVAN" or "TRAVELING MERCHANT")
 txt(s.run.gold.." GOLD   •   "..s.run.mp.." MP",35,COLOR.gold)
 for i,item in ipairs(s.shop or {}) do
  button(item.name.."  •  "..item.price.." gold",function() send("Buy",{index=i}) end,COLOR.blue,Content.Items[item.name].kind)
 end
 if s.run.class=="Merchant" then button("REFRESH SHOP • 20 MP",function() send("RefreshShop") end,COLOR.purple) end
 back()
end
local function showStats(r)
 section("CHARACTER SHEET")
 helpStat(r)
 txt("Race: "..r.race.."    Class: "..r.class.."    Trait: "..r.trait,42,COLOR.gold)
 txt("Level "..r.level.."    XP "..r.xp.."/"..(r.level*35).."    Defeated foes: "..r.kills.."    Combats won: "..r.wins,45,COLOR.sub)
 txt("Bosses defeated: "..r.bosses.."   •  Hunter trophies: "..r.trophyTotal,42,COLOR.sub)
 section("BLESSINGS")
 for _,n in ipairs(orderedKeys(r.blessings)) do txt(n.." ×"..r.blessings[n],32,COLOR.green) end
 section("CURSES")
 for _,n in ipairs(orderedKeys(r.curses)) do txt(n.." ×"..r.curses[n],32,COLOR.red) end
 back()
end
local function showInfo(s)
 section(s.info or "INFO")
 if s.info=="Multiplayer" then txt("This build is a single-player vertical slice. Four-player synchronized party combat, summon ownership and party matchmaking are not implemented yet.",93,COLOR.sub)
 elseif s.info=="Achievements" then txt("Achievements and long-run leaderboards are planned. This version tracks kills, boss victories, and trophy counts only for the current run; they are not saved between sessions.",95,COLOR.sub)
 elseif s.info=="Settings" then txt("Visuals use built-in Roblox GUI objects. For now, adjust volume through Roblox's own settings menu. Custom accessibility controls are planned.",78,COLOR.sub)
 else txt("Strength: physical damage. Defense: damage reduction and HP. Speed: evasion. Intelligence: magic and MP. Luck: critical hits. Charisma: economy. Holiness: holy damage and healing. The campsite is your hub between encounters.",150,COLOR.sub) end
 button("← BACK",function() send("BackInfo") end,COLOR.blue)
end
render=function()
 clear()
 local s=state;local phase=s.phase or "Menu";local r=s.run
 heading.Text="COOL RPG  /  "..string.upper(phase)
 subtitle.Text=r and (r.race.." "..r.class.." • "..r.trait.." • Floor "..((s.map and math.min(10,s.map.row)) or 1)) or "Fantasy • Choices • Consequences"
 footer.Text=(s.message and s.message~="" and s.message) or "COOL RPG  •  Prototype build 0.1  •  Server-authoritative combat"
 if r then r.stats={};end
 -- Stats are computed on the server and included as a separate field.
 if r and s.stats then r.stats=s.stats end
 if phase=="Menu" then showMenu()
 elseif phase=="Creation" then showCreation()
 elseif phase=="Camp" then showCamp(r)
 elseif phase=="Map" then showMap(s.map)
 elseif phase=="Combat" then showCombat(r)
 elseif phase=="Event" then showEvent(s)
 elseif phase=="Reward" then showReward(s.reward)
 elseif phase=="Inventory" then showInventory(r)
 elseif phase=="Crafting" then showCrafting(r)
 elseif phase=="Skills" then showSkills(r)
 elseif phase=="Class" then showClass(r)
 elseif phase=="Merchant" then showMerchant(s)
 elseif phase=="Stats" or phase=="Codex" then showStats(r)
 elseif phase=="Info" then showInfo(s)
 elseif phase=="Death" then
  section("YOU HAVE FALLEN")
  txt("Your journey ended. Enemies defeated: "..r.kills.." • Battles won: "..r.wins,65,COLOR.red)
  button("BEGIN A NEW RUN",function() send("NewRun") end,COLOR.gold)
 elseif phase=="Victory" then
  section("VICTORY! THE FINAL BOSS IS DEFEATED")
  txt("Your adventure is complete. You defeated "..r.kills.." enemies and reached level "..r.level..".",80,COLOR.green)
  txt("Endless mode is planned but not included in this first build.",56,COLOR.sub)
  button("BEGIN A NEW RUN",function() send("NewRun") end,COLOR.gold)
 else txt("Unknown UI state: "..phase,60,COLOR.red) end
end
local ok,result=pcall(function() return remote:InvokeServer("Poll") end)
if ok and result then state=result end
render()
