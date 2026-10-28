--!strict
-- Recreation of original Camp.MainUI: fixed bottom navigation, inventory
-- equipment slots/item details, recipe selection + craft, and skill details.
local T=require(script.Parent.Kit)
local C={};local k=T.c

local function dock(v,selected)
 local labels={{"ADVENTURE","Map"},{"INVENTORY","Inventory"},
  {"CRAFTING","Crafting"},{"SKILLS","Skills"},
  {"CLASS ABILITY","Class"},{"CHARACTER","Stats"}}
 local bar=T.rect(v.root,0,610,1280,79,k.panel,0,false)
 for i,tab in ipairs(labels) do
  local tabX=16+(i-1)*210
  T.button(bar,tab[1],tabX,12,194,52,function()
   v.send("CampTab",{tab=tab[2]})
  end,selected==tab[2] and k.green or k.mute,selected==tab[2])
 end
end

local function left(v,title)
 local panel=T.panel(v.root,20,77,930,514,title,k.gold)
 T.sheet(v.root,v.state.run,v.state.stats,971,78,289,513)
 dock(v,v.state.phase=="Camp" and "" or v.state.phase)
 return panel
end

function C.Camp(v)
 local panel=left(v,"WELCOME BACK")
 T.label(panel,"THE CAMPSITE",28,85,868,51,{size=30,bold=true,color=k.white})
 T.label(panel,"Prepare for your next encounter. Inspect equipment, gather supplies, craft recipes and improve your class ability.",
  30,151,839,97,{size=18,color=k.mute})
 T.label(panel,"Select a menu along the bottom of the screen.",29,276,858,31,{size=17,color=k.green})
 T.button(panel,"ADVENTURE MAP",28,357,277,54,function()
  v.send("CampTab",{tab="Map"}) end,k.green)
 if v.state.run.class=="Merchant" then
  T.button(panel,"MERCHANT'S CARAVAN",321,357,304,54,function()
   v.send("CampTab",{tab="Merchant"}) end,k.gold)
 end
end

local function slot(parent,label,value,x,y,w)
 local p=T.rect(parent,x,y,w,65,k.raised,0,4);T.stroke(p)
 T.label(p,label:upper(),10,3,w-20,21,{size=12,bold=true,color=k.mute})
 T.label(p,value or "Empty",10,26,w-20,33,{size=13,color=k.white,truncate=true})
end

function C.Inventory(v)
 local run=v.state.run;local root=left(v,"INVENTORY")
 local equipment=T.panel(root,12,57,214,437,"EQUIPMENT",k.blue)
 local list={"Weapon","Shield","Armor","Ring"}
 for i,kind in ipairs(list) do
  slot(equipment,kind,run.equipment[kind],12,62+(i-1)*91,188)
 end
 local grid=T.panel(root,238,57,344,437,"ITEMS",k.gold)
 local scroll=T.scroll(grid,10,57,324,363)
 local selected=v.localState.selectedItem
 local valid=selected and run.inventory[selected] and run.inventory[selected]>0
 if not valid then selected=nil end
 local info=T.panel(root,594,57,324,437,"ITEM DETAILS",k.blue)
 local function show(name)
  v.localState.selectedItem=name
  v.redraw()
 end
 for _,name in ipairs(T.keys(run.inventory)) do
  local item=v.content.Items[name]
  if item then
   T.entry(scroll,name.."  ×"..run.inventory[name],item.kind, function() show(name) end,
    k.blue,63,selected==name)
  end
 end
 if selected then
  local item=v.content.Items[selected]
  T.label(info,selected,13,64,295,50,{size=20,bold=true})
  T.label(info,"TYPE: "..(item.kind or "Item"),14,123,285,29,{size=14,color=k.mute})
  T.label(info,(item.stat and ("+"..item.bonus.." "..item.stat) or "No stat modifiers"),
   13,169,289,71,{size=15,color=k.white})
  T.label(info,"Quantity: "..run.inventory[selected],14,258,273,28,{size=14,color=k.mute})
  if item.kind=="Consumable" then
   T.button(info,"USE ITEM",14,344,292,49,function() v.send("UseItem",{name=selected}) end,k.green)
  elseif table.find(list,item.kind) then
   T.button(info,"EQUIP",14,344,292,49,function() v.send("Equip",{name=selected}) end,k.green)
  end
 else
  T.label(info,"Select an item to see its stats and available actions.",
   16,84,282,128,{size=17,color=k.mute})
 end
end

function C.Crafting(v)
 local run=v.state.run;local root=left(v,"CRAFTING")
 local recipes=T.panel(root,12,57,425,437,"AVAILABLE RECIPES",k.blue)
 local scroll=T.scroll(recipes,10,57,405,361)
 local selected=v.localState.selectedRecipe
 local found=0
 for _,recipe in ipairs(v.content.Recipes) do
  local unlocked=false
  for ingredient in pairs(recipe.need) do
   if (run.inventory[ingredient] or 0)>0 then unlocked=true end
  end
  if unlocked then
   found+=1
   T.entry(scroll,recipe.name,"Select recipe to inspect requirements",function()
    v.localState.selectedRecipe=recipe.name;v.redraw()
   end,k.gold,60,selected==recipe.name)
  end
 end
 if found==0 then T.copy(scroll,"No recipes discovered yet. Gather materials on adventures.",74,k.mute) end
 local detail=T.panel(root,452,57,464,437,"RECIPE DETAILS",k.gold)
 local recipeData=nil
 for _,recipe in ipairs(v.content.Recipes) do if recipe.name==selected then recipeData=recipe end end
 if recipeData then
  T.label(detail,recipeData.name,16,68,429,36,{size=21,bold=true})
  T.label(detail,"MATERIALS REQUIRED",16,126,420,31,{size=15,bold=true,color=k.gold})
  local canCraft=true;local i=0
  for name,amount in pairs(recipeData.need) do
   i+=1
   local have=run.inventory[name] or 0
   if have<amount then canCraft=false end
   T.label(detail,name.."     "..have.." / "..amount,17,164+(i-1)*35,414,30,
    {size=15,color=have>=amount and k.green or k.red})
  end
  T.button(detail,"CRAFT",142,352,180,52,function()
   if canCraft then v.send("Craft",{name=recipeData.name}) end
  end,canCraft and k.green or k.mute)
 else
  T.label(detail,"Select a recipe to see its ingredients and result.",
   27,116,406,131,{size=20,color=k.mute})
 end
end

function C.Skills(v)
 local r=v.state.run;local panel=left(v,"SKILLS")
 local leftList=T.panel(panel,12,57,427,437,"SKILL LIST",k.purple)
 local scroll=T.scroll(leftList,10,57,407,361)
 local skillNames={"Guard"}
 for _,skill in ipairs(v.content.BaseSkills[r.class]) do table.insert(skillNames,skill) end
 for _,name in ipairs(skillNames) do
  T.entry(scroll,name,"Click to view description",function()
   v.localState.selectedSkill=name;v.redraw()
  end,k.purple,64,v.localState.selectedSkill==name)
 end
 local d=T.panel(panel,451,57,465,437,"SKILL DETAILS",k.gold)
 local name=v.localState.selectedSkill
 if name then
  T.label(d,name,20,77,423,39,{size=24,bold=true})
  local desc=name=="Guard" and "Universal skill. Reduce incoming damage and gain Barrier. This replaces the old separate Defend action."
   or name=="Crafted Spell" and ("Custom Mage spell: "..r.spell.name)
   or "This class skill appears in your combat menu, provided its cooldown and resource requirements are met."
  T.label(d,desc,20,145,422,154,{size=18,color=k.mute})
 else
  T.label(d,"Select a skill on the left to view its description.",
   21,112,419,130,{size=19,color=k.mute})
 end
end

function C.Stats(v)
 local r=v.state.run;local panel=left(v,"CHARACTER INFO");local sc=T.scroll(panel,18,57,891,421)
 T.copy(sc,r.race.."  /  "..r.class.."  /  "..r.trait,44,k.gold)
 for _,name in ipairs(v.content.Stats) do
  T.copy(sc,name.."     "..tostring(v.state.stats[name] or 0),31,k.white)
 end
 T.copy(sc,"ACTIVE BLESSINGS",38,k.green)
 for _,name in ipairs(T.keys(r.blessings)) do T.copy(sc,name.." ×"..r.blessings[name],31,k.white) end
 T.copy(sc,"ACTIVE CURSES",38,k.red)
 for _,name in ipairs(T.keys(r.curses)) do T.copy(sc,name.." ×"..r.curses[name],31,k.white) end
 T.button(panel,"OPEN CODEX",662,12,242,36,function() v.send("CampTab",{tab="Codex"}) end,k.blue)
end

function C.Codex(v)
 local r=v.state.run;local panel=left(v,"CODEX");local sc=T.scroll(panel,18,57,891,421)
 T.copy(sc,"Discoveries, items and enemies encountered during this run.",49,k.mute)
 T.copy(sc,"Combats won: "..r.wins,34,k.white)
 T.copy(sc,"Enemies defeated: "..r.kills,34,k.white)
 if r.class=="Hunter" then
  T.copy(sc,"TROPHY DISPLAY  •  "..r.trophyTotal.." trophies",40,k.green)
  for _,name in ipairs(T.keys(r.trophies)) do T.copy(sc,name.."  ×"..r.trophies[name],32,k.white) end
 end
 T.button(panel,"← CHARACTER",662,12,242,36,function()
  v.send("CampTab",{tab="Stats"}) end,k.mute)
end

function C.Merchant(v)
 local r=v.state.run;local root=left(v,"MERCHANT'S CARAVAN")
 local stock=T.panel(root,12,57,904,437,"STOCK",k.gold)
 local sc=T.scroll(stock,13,62,876,348)
 T.copy(sc,"Gold: "..r.gold.."    Mana: "..r.mp,39,k.gold)
 for i,item in ipairs(v.state.shop or {}) do
  local record=v.content.Items[item.name]
  T.entry(sc,item.name.."    "..item.price.." GOLD",record and record.kind or "Item",function()
   v.send("Buy",{index=i})
  end,k.blue,63)
 end
 if r.class=="Merchant" then T.entry(sc,"REFRESH SHOP","20 MP",function() v.send("RefreshShop") end,k.green,63) end
 T.button(root,"RETURN TO CAMP",661,13,243,35,function() v.send("BackCamp") end,k.mute)
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
