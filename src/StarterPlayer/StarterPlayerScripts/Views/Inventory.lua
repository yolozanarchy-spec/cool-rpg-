--!strict
-- Screenshot reference: equipment rail / filterable tile grid / details panel.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local I={};local c=T.c
local tabs={{"All","All"},{"⚔ Equipment","Equipment"},{"▰ Consumables","Consumables"},
 {"◆ Materials","Materials"},{"⚒ Monster Parts","Monster Parts"},
 {"▣ Tomes","Tomes"},{"✦ Relics","Relics"},{"▤ Quest Items","Quest"}}
local slots={{"Helmet",0,0,"Helmet"},{"Chest",1,0,"Armor"},
 {"Leggings",0,1,"Leggings"},{"Boots",1,1,"Boots"},
 {"Weapon",0,2,"Weapon"},{"Shield",1,2,"Shield"},
 {"Ring",0,3,"Ring"},{"Accessory",1,3,"Accessory"}}
local function fits(item,filter)
 if filter=="All" then return true end
 if filter=="Equipment" then return table.find({"Weapon","Armor","Shield","Ring"},item.kind)~=nil end
 if filter=="Consumables" then return item.kind=="Consumable" end
 if filter=="Materials" then return item.kind=="Material" end
 if filter=="Monster Parts" then return item.kind=="Part" end
 return false
end
local function colorFor(item)
 if item.kind=="Part" then return Color3.fromRGB(155,142,170) end
 if item.kind=="Consumable" then return Color3.fromRGB(101,181,123) end
 if item.kind=="Weapon" then return Color3.fromRGB(223,172,82) end
 return c.blue
end
function I.Show(v)
 local run=v.state.run;local root=v.root;local st=v.localState
 S.Title(v,"INVENTORY");S.Gear(v)
 T.label(root,"Gold:",1085,14,80,25,{size=16,bold=true,color=c.gold})
 T.label(root,tostring(run.gold),1170,14,71,25,{size=16,bold=true,color=c.yellow,align=Enum.TextXAlignment.Right})
 local left=S.Box(root,9,60,310,558,Color3.fromRGB(36,36,37))
 T.label(left,"Equipment",0,7,310,35,{size=18,bold=true,color=c.mute,align=Enum.TextXAlignment.Center})
 for _,slot in ipairs(slots) do
  local name,xc,yc,kind=slot[1],slot[2],slot[3],slot[4]
  local equipped=run.equipment[kind]
  local b=T.button(left,equipped or name,101+xc*58,50+yc*55,52,52,function()
   st.selectedItem=equipped;st.equippedSlot=kind;st.compare=false;v.redraw()
  end,c.blue,st.selectedItem==equipped and equipped~=nil)
  b.TextSize=10;b.Font=Enum.Font.Gotham
  b.BackgroundColor3=equipped and Color3.fromRGB(66,65,68) or Color3.fromRGB(46,46,48)
  if not equipped then b.TextColor3=Color3.fromRGB(116,116,118) end
 end
 local middle=S.Box(root,325,60,505,558,Color3.fromRGB(28,30,33))
 local filters=T.make("ScrollingFrame",middle,{Position=UDim2.fromOffset(4,2),
  Size=UDim2.fromOffset(497,30),CanvasSize=UDim2.fromOffset(808,0),
  BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
  ScrollBarImageColor3=c.border,ScrollingDirection=Enum.ScrollingDirection.X})
 local x=4
 for _,tab in ipairs(tabs) do
  local width=math.min(119,math.max(49,#tab[1]*7))
  S.Pill(filters,tab[1],x,0,width,function()st.inventoryCategory=tab[2];v.redraw()end,st.inventoryCategory==tab[2])
  x+=width+4
 end
 filters.CanvasSize=UDim2.fromOffset(x+4,0)
 S.Separator(middle,1,33,502)
 local sf=T.make("ScrollingFrame",middle,{Position=UDim2.fromOffset(4,35),Size=UDim2.fromOffset(497,520),
  BackgroundTransparency=1,ScrollBarThickness=4,ScrollBarImageColor3=c.border,
  CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0})
 T.make("UIPadding",sf,{PaddingTop=UDim.new(0,3),PaddingLeft=UDim.new(0,6)})
 T.make("UIGridLayout",sf,{CellSize=UDim2.fromOffset(66,66),CellPadding=UDim2.fromOffset(5,5),
  SortOrder=Enum.SortOrder.LayoutOrder})
 local all=T.keys(run.inventory);local visible=0
 for _,name in ipairs(all) do
  local item=v.content.Items[name]
  if item and (run.inventory[name] or 0)>0 and fits(item,st.inventoryCategory or "All") then
   visible+=1
   local chosen=st.selectedItem==name
   local tile=T.make("TextButton",sf,{BackgroundColor3=chosen and Color3.fromRGB(83,117,153) or Color3.fromRGB(86,86,89),
    BorderSizePixel=0,Text="",AutoButtonColor=true,LayoutOrder=visible})
   T.make("UICorner",tile,{CornerRadius=UDim.new(0,5)})
   T.label(tile,({Weapon="⚔",Armor="◈",Shield="▣",Ring="◇",Part="☠",Material="◆",Consumable="✚"})[item.kind] or "■",0,4,66,22,{size=19,color=colorFor(item),align=Enum.TextXAlignment.Center})
   T.label(tile,name,2,29,62,31,{size=11,color=c.white,align=Enum.TextXAlignment.Center})
   T.label(tile,"×"..run.inventory[name],41,1,23,18,{size=10,bold=true,align=Enum.TextXAlignment.Right})
   tile.Activated:Connect(function()st.selectedItem=name;st.equippedSlot=nil;st.compare=false;v.redraw()end)
  end
 end
 if visible==0 then T.label(middle,"No items in this category.",23,82,400,32,{size=15,color=c.mute}) end
 local right=S.Box(root,837,60,434,558,Color3.fromRGB(36,36,37))
 local name=st.selectedItem;local item=name and v.content.Items[name]
 if not item then
  T.label(right,"Select an item",13,14,410,35,{size=20,bold=true,color=c.mute})
  T.label(right,"Choose an inventory tile or equipped slot to view its details.",14,63,403,76,{size=14,color=c.mute})
 else
  T.label(right,name,14,10,406,35,{size=20,bold=true,color=c.mute})
  T.label(right,(name=="Stick" and "A simple stick. Better than nothing!") or
   ("An item used for "..(item.kind=="Part" and "undead crafting" or item.kind:lower()).."."),
   15,50,405,54,{size=14,color=c.mute})
  T.label(right,"Type: "..item.kind,15,113,397,26,{size=16,color=c.green})
  if item.stat then
   T.label(right,item.stat..": +"..tostring(item.bonus),15,140,393,27,{size=15,color=c.green})
  end
  T.label(right,"Value: "..tostring(item.price or 0).." gold",15,189,397,26,{size=15,color=c.gold})
  T.label(right,"Quantity: "..tostring(run.inventory[name] or 0),15,224,397,26,{size=14,color=c.mute})
  if st.compare and item.stat then
   local equipped=run.equipment[item.kind];local previous=equipped and v.content.Items[equipped]
   local old=previous and previous.stat==item.stat and previous.bonus or 0
   local delta=item.bonus-old
   T.label(right,"Compared with "..(equipped or "empty slot")..": "..(delta>=0 and "+" or "")..delta.." "..item.stat,
    15,282,397,57,{size=14,color=delta>=0 and c.green or c.red})
  end
  if item.stat then
   T.button(right,st.compare and "HIDE COMPARISON" or "COMPARE",119,507,129,35,function()st.compare=not st.compare;v.redraw()end,c.blue)
  end
  if st.equippedSlot and run.equipment[st.equippedSlot]==name then
   local b=T.button(right,"UNEQUIP",259,507,111,35,function()v.send("Unequip",{slot=st.equippedSlot})end,c.red)
   b.BackgroundColor3=Color3.fromRGB(125,39,41)
  elseif (run.inventory[name] or 0)>0 then
   if table.find({"Weapon","Armor","Shield","Ring"},item.kind) then
    T.button(right,"EQUIP",259,507,111,35,function()v.send("Equip",{name=name})end,c.green)
   elseif item.kind=="Consumable" then
    T.button(right,"USE",259,507,111,35,function()v.send("UseItem",{name=name})end,c.green)
   end
  end
 end
 S.Dock(v)
end
return I
