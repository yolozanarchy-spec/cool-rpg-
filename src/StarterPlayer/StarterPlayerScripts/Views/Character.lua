--!strict
-- Long, scrollable character sheet with transparent stat breakdowns.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local C={};local c=T.c
local function section(sf,title)
 T.copy(sf,title,34,c.gold)
end
local function line(sf,name,value,col)
 local row=T.make("Frame",sf,{Size=UDim2.new(1,-14,0,31),BackgroundTransparency=1})
 T.label(row,name,3,0,990,31,{size=14,color=c.mute})
 T.label(row,tostring(value),1018,0,200,31,{size=14,bold=true,color=col or c.white,align=Enum.TextXAlignment.Right})
end
local function sub(sf,text,col)
 local row=T.make("TextLabel",sf,{Size=UDim2.new(1,-16,0,21),BackgroundTransparency=1,
  Text="    "..text,Font=Enum.Font.Gotham,TextSize=11,TextColor3=col or c.mute,
  TextXAlignment=Enum.TextXAlignment.Left})
 return row
end
function C.Show(v)
 local r=v.state.run;local stats=v.state.stats or {};local root=v.root
 local panel=S.Box(root,7,11,1266,608,Color3.fromRGB(29,29,30))
 local sc=S.Scroll(panel,0,0,1263,605)
 section(sc,"Primary Stats")
 for _,name in ipairs(v.content.Stats) do
  line(sc,name,stats[name] or 0,c.green)
  local race=(v.content.Races[r.race].stats[name] or 0)
  local trait=(v.content.Traits[r.trait].stats[name] or 0)
  local bonus=(r.bonusStats or {})[name] or 0
  local eq=0;local items={}
  for _,itemName in pairs(r.equipment or {}) do
   local itm=v.content.Items[itemName]
   if itm and itm.stat==name then eq+=itm.bonus;table.insert(items,itemName..": +"..itm.bonus)end
  end
  sub(sc,"Base: 3   •   "..r.race..": +"..race.."   •   "..r.trait..": +"..trait)
  if bonus~=0 then sub(sc,"Permanent upgrades: +"..bonus,c.green) end
  if eq~=0 then sub(sc,"Equipment: +"..eq.."   ("..table.concat(items,", ")..")",c.green) end
  if (r.blessings and next(r.blessings)) or (r.curses and next(r.curses)) then
   sub(sc,"Displayed total includes active blessing and curse modifiers.")
  end
 end
 section(sc,"Combat Stats")
 line(sc,"Current HP",r.hp.." / "..(stats.MaxHP or 0),c.red)
 line(sc,"Current MP",r.mp.." / "..(stats.MaxMP or 0),c.blue)
 line(sc,"Level",r.level,c.green)
 line(sc,"Experience",r.xp.." / "..(r.level*35),c.white)
 line(sc,"Critical Chance","5% base + Luck scaling",c.mute)
 section(sc,"Multipliers")
 sub(sc,"Only modifiers implemented in this prototype are displayed here.")
 for _,name in ipairs(T.keys(r.flags or {})) do
  if r.flags[name] then line(sc,name,"ACTIVE",c.green) end
 end
 if not next(r.flags or {}) then sub(sc,"No purchased multiplier upgrades.") end
 section(sc,"Equipment Bonuses")
 for _,slot in ipairs({"Weapon","Shield","Armor","Ring"}) do
  local itemName=(r.equipment or {})[slot]
  local item=itemName and v.content.Items[itemName]
  line(sc,slot,itemName or "Empty",item and c.white or c.mute)
  if item and item.stat then sub(sc,item.stat.." +"..item.bonus,c.green) end
 end
 section(sc,"Blessings")
 for _,name in ipairs(T.keys(r.blessings or {})) do line(sc,name,"×"..r.blessings[name],c.green) end
 if not next(r.blessings or {}) then sub(sc,"None") end
 section(sc,"Curses")
 for _,name in ipairs(T.keys(r.curses or {})) do line(sc,name,"×"..r.curses[name],c.red) end
 if not next(r.curses or {}) then sub(sc,"None") end
 section(sc,"Run Progress")
 line(sc,"Enemies killed",r.kills,c.white)
 line(sc,"Battles won",r.wins,c.white)
 line(sc,"Bosses defeated",r.bosses,c.white)
 line(sc,"Gold",r.gold,c.yellow)
 S.Gear(v);S.Dock(v)
end
return C
