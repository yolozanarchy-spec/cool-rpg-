--!strict
-- Campsite layout + persistent bottom dock + adventure map and utility screens.
local T=require(script.Parent.Kit)
local C={};local k=T.c
local function dock(v,selected)
 local entries={{"ADVENTURE","Map",k.gold},{"INVENTORY","Inventory",k.blue},
  {"CRAFTING","Crafting",k.green},{"SKILLS","Skills",k.purple},{"CLASS ABILITY","Class",k.gold}}
 for i,e in ipairs(entries) do
  T.button(v.root,e[1],32+(i-1)*184,610,172,44,function() v.send("CampTab",{tab=e[2]}) end,e[3],selected==e[2])
 end
 T.button(v.root,"STATS / CODEX",961,610,285,44,function() v.send("CampTab",{tab="Stats"}) end,k.mute,selected=="Stats")
end
local function left(v,title)
 T.subtitle(v.root,"CAMPSITE  /  "..title,32,81,850)
 local panel=T.panel(v.root,32,124,905,469,title,k.gold)
 T.sheet(v.root,v.state.run,v.state.stats,961,101,285,492)
 dock(v,v.state.phase=="Camp" and nil or v.state.phase)
 return panel
end
local function listPanel(panel)
 return T.scroll(panel,22,62,860,382)
end
function C.Camp(v)
 local panel=left(v,"YOUR SAFE HAVEN")
 T.label(panel,"THE FIRE IS STILL BURNING",30,71,815,48,{size=24,bold=true,color=k.gold})
 T.label(panel,"The campsite is your home between encounters. Check your equipment, craft supplies, study your skills and develop your unique class ability before entering the next node.",30,137,795,111,{size=18,color=k.mute})
 T.label(panel,"Choose a destination using the five buttons along the bottom of the screen.",30,287,808,57,{size=17,color=k.green})
 T.button(panel,"OPEN ADVENTURE MAP →",30,385,320,51,function() v.send("CampTab",{tab="Map"}) end,k.gold)
end
function C.Inventory(v)
 local r=v.state.run;local panel=left(v,"INVENTORY & EQUIPMENT");local sc=listPanel(panel)
 T.copy(sc,"EQUIPPED  •  "..table.concat({"Weapon: "..(r.equipment.Weapon or "None"),"Shield: "..(r.equipment.Shield or "None"),"Armor: "..(r.equipment.Armor or "None"),"Ring: "..(r.equipment.Ring or "None")},"    /    "),66,k.gold)
 for _,name in ipairs(T.keys(r.inventory)) do
  local item=v.content.Items[name]
  if item then
   local detail=item.kind..(item.stat and "   +"..item.bonus.." "..item.stat or "").."    x"..r.inventory[name]
   local action=nil
   if item.kind=="Consumable" then action=function() v.send("UseItem",{name=name}) end end
   if table.find({"Weapon","Shield","Armor","Ring"},item.kind) then action=function() v.send("Equip",{name=name}) end end
   T.entry(sc,name..(action and "  •  CLICK TO USE / EQUIP" or ""),detail,action,item.kind=="Consumable" and k.green or k.blue,60)
  end
 end
end
function C.Crafting(v)
 local r=v.state.run;local panel=left(v,"CRAFTING BENCH");local sc=listPanel(panel)
 T.copy(sc,"Recipes appear when you collect at least one required ingredient. The server checks all ingredients before crafting.",61,k.mute)
 local n=0
 for _,recipe in ipairs(v.content.Recipes) do
  local found=false;local need={}
  for name,count in pairs(recipe.need) do
   local have=r.inventory[name] or 0
   if have>0 then found=true end
   table.insert(need,name.." "..have.."/"..count)
  end
  if found then n+=1;T.entry(sc,"CRAFT  "..recipe.name,table.concat(need,"    •    "),function() v.send("Craft",{name=recipe.name}) end,k.gold,67) end
 end
 if n==0 then T.copy(sc,"No recipes discovered. Collect materials through combat and random events.",65,k.mute) end
end
function C.Skills(v)
 local r=v.state.run;local panel=left(v,"SKILL COMPENDIUM");local sc=listPanel(panel)
 T.copy(sc,"These skills appear on the combat action panel. Select SKILLS to scroll through them. Guard is available to every class.",63,k.mute)
 T.entry(sc,"Guard","Universal defensive skill: halve the next enemy attacks and gain 3 Barrier.",nil,k.green,72)
 for _,name in ipairs(v.content.BaseSkills[r.class]) do
  local desc=name=="Crafted Spell" and (r.spell.name.."   •   "..r.spell.points.." points") or "Class ability • available in battle when its cooldown and resource requirements permit"
  T.entry(sc,name,desc,nil,k.purple,70)
 end
end
function C.Stats(v)
 local r=v.state.run;local panel=left(v,"CHARACTER RECORD");local sc=listPanel(panel)
 T.copy(sc,r.race.."  /  "..r.class.."  /  "..r.trait.."     •     "..r.kills.." monsters defeated     •     "..r.bosses.." bosses",48,k.gold)
 for _,field in ipairs(v.content.Stats) do T.copy(sc,field.."   "..tostring(v.state.stats[field] or 0),34,k.white) end
 T.copy(sc,"ACTIVE BLESSINGS",36,k.gold)
 for _,name in ipairs(T.keys(r.blessings)) do T.copy(sc,name.."  ×"..r.blessings[name],30,k.green) end
 T.copy(sc,"ACTIVE CURSES",36,k.red)
 for _,name in ipairs(T.keys(r.curses)) do T.copy(sc,name.."  ×"..r.curses[name],30,k.red) end
 T.button(panel,"VIEW CODEX",656,17,214,33,function() v.send("CampTab",{tab="Codex"}) end,k.blue)
end
function C.Codex(v)
 local r=v.state.run;local panel=left(v,"CODEX & RECORDS");local sc=listPanel(panel)
 T.copy(sc,"Discover your enemies, items and class mechanics as you explore. Full persistent discovery tracking is planned.",74,k.mute)
 T.copy(sc,"COMBATS WON: "..r.wins,40,k.gold)
 T.copy(sc,"ENEMIES DEFEATED: "..r.kills,40,k.gold)
 if r.class=="Hunter" then
  T.copy(sc,"TROPHIES: "..r.trophyTotal,38,k.green)
  for _,n in ipairs(T.keys(r.trophies)) do T.copy(sc,n.."  ×"..r.trophies[n],32) end
 end
end
function C.Merchant(v)
 local s=v.state;local r=s.run;local panel=left(v,"MERCHANT SHOP");local sc=listPanel(panel)
 T.copy(sc,"Available gold: "..r.gold.."      Mana: "..r.mp,40,k.gold)
 for i,item in ipairs(s.shop or {}) do
  T.entry(sc,item.name.."    "..item.price.." GOLD",v.content.Items[item.name].kind,function() v.send("Buy",{index=i}) end,k.blue,63)
 end
 if r.class=="Merchant" then T.entry(sc,"REFRESH STOCK","Costs 20 MP to refresh the personal shop.",function() v.send("RefreshShop") end,k.purple,69) end
 T.button(panel,"← RETURN TO CAMP",648,17,217,33,function() v.send("BackCamp") end,k.mute)
end
local shades={Combat=k.red,Event=k.mute,Merchant=k.blue,Rest=k.green,Special=k.purple,Boss=k.blue}
local function linkLine(parent,ax,ay,bx,by,color)
 local dx=bx-ax;local dy=by-ay
 local f=T.rect(parent,(ax+bx)/2,(ay+by)/2,math.sqrt(dx*dx+dy*dy),2,color,.4,false)
 f.AnchorPoint=Vector2.new(.5,.5)
 f.Rotation=math.deg(math.atan2(dy,dx))
end
function C.Map(v)
 local map=v.state.map;local p=v.root
 T.subtitle(p,"ADVENTURE MAP",36,80,600)
 T.label(p,"Select an available connected node. Completing it returns you to camp.",38,111,1050,26,{size=14,color=k.mute})
 local board=T.panel(p,33,150,1215,470,nil)
 T.label(board,"PATH LEGEND",23,22,240,27,{size=16,bold=true,color=k.gold})
 for i,l in ipairs({{"ENEMIES",k.red},{"BOSS",k.blue},{"EVENTS",k.mute},{"MERCHANT",k.blue},{"REST",k.green},{"SPECIAL",k.purple}}) do
  T.rect(board,26,62+(i-1)*41,14,14,l[2],0,3)
  T.label(board,l[1],53,52+(i-1)*41,190,34,{size=14})
 end
 T.label(board,"CURRENT ROW  "..map.row.." / 10",28,358,210,29,{size=15,bold=true,color=k.gold})
 local tx={418,639,860}
 local function nodeX(col) return tx[col] or 639 end
 local function nodeY(row) return 420-(row-1)*43 end
 for row=1,9 do
  for _,node in ipairs(map.rows[row]) do
   for _,to in ipairs(node.links) do
    linkLine(board,nodeX(node.col),nodeY(row),nodeX(to),nodeY(row+1),k.border)
   end
  end
 end
 local visited={}
 for _,h in ipairs(map.history or {}) do visited[h.row.."-"..h.col]=true end
 for row=1,10 do
  for _,node in ipairs(map.rows[row]) do
   local can=row==map.row and table.find(map.available,node.col)~=nil
   local done=visited[row.."-"..node.col]
   local current=row==map.row
   local on=can or done
   local col=on and (shades[node.kind] or k.mute) or k.border
   local text=(done and "✓ " or can and "◆ " or "◇ ")..node.kind
   T.button(board,text,nodeX(node.col)-66,nodeY(row)-14,132,30,function()
    if can then v.send("ChooseNode",{index=node.col}) end
   end,col,current and can)
  end
 end
 T.button(p,"← RETURN TO CAMP",33,635,205,37,function() v.send("BackCamp") end,k.mute)
end
C.Left=left
return C
