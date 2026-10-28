--!strict
-- Screenshot: preview left, modifier chips and scrollable options right.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local P={};local c=T.c
local function pick(parent,title,options,y,field,v,width)
 T.label(parent,title,10,y,682,22,{size=13,bold=true,color=c.gold})
 local x=12
 for _,option in ipairs(options) do
  local value,label,cost=option[1],option[2],option[3]
  local active=v.draft[field]==value
  local b=S.Pill(parent,label,x,y+24,width,function()v.draft[field]=value;v.redraw()end,active)
  b.BackgroundColor3=active and Color3.fromRGB(99,144,84) or Color3.fromRGB(40,40,44)
  x+=width+6
 end
end
function P.Show(v)
 local p=v.root;local d=v.draft;local r=v.state.run
 local left=S.Box(p,0,13,564,605,Color3.fromRGB(30,30,35))
 local right=S.Box(p,628,13,644,605,Color3.fromRGB(28,28,32))
 T.label(p,"SPELLCRAFTING",0,1,1280,36,{size=21,bold=true,color=c.gold,align=Enum.TextXAlignment.Center})
 T.label(left,"SPELL PREVIEW",10,15,535,28,{size=14,bold=true,color=c.gold})
 local display=S.Box(left,4,49,548,468,Color3.fromRGB(35,35,41))
 local cost=4+(d.area and 4 or 0)+(d.effect~="None" and 2 or 0)
 local title=d.element..(d.area and " Wave" or " Bolt")
 T.label(display,"⚔  "..title,13,10,516,42,{size=19,bold=true,color=c.gold})
 T.label(display,"Type: Damage\nElement: "..d.element.."\nTarget: "..(d.area and "All Enemies" or "Single Enemy")..
  "\nStatus: "..d.effect.."\n\nCost: "..cost.." / 10 points\nCooldown: 3 turns",
  13,61,507,220,{size=15,color=c.mute})
 T.label(display,"Spell effects depend on your selections. Save to use this spell in battle.",13,315,514,95,{size=13,color=c.white})
 T.label(left,"Points: "..(10-cost).." / 10 remaining",1,540,252,31,{size=17,bold=true,color=cost<=10 and c.yellow or c.red})
 T.label(right,"MODIFIERS",10,15,621,25,{size=14,bold=true,color=c.gold})
 T.label(right,"SPELL TYPE    Damage",12,40,555,23,{size=12,color=c.mute})
 pick(right,"ELEMENT",{{"Fire","🔥 Fire"},{"Ice","❄ Ice"},{"Arcane","✦ Arcane"}},71,"element",v,120)
 pick(right,"TARGET",{{false,"👤 Single Enemy"},{true,"👥 All Enemies (+4)"}},141,"area",v,198)
 pick(right,"ADDITIONAL STATUS",{{"None","No Status"},{"Burn","🔥 Burn (+2)"},{"Poison","☠ Poison (+2)"}},211,"effect",v,174)
 local sc=S.Scroll(right,10,294,621,230)
 local definitions={{"+10% Damage","Use the base spell configuration.",false},
  {"Burn","Applies Burn to the chosen target.",d.effect=="Burn"},
  {"Poison","Applies Poison to the chosen target.",d.effect=="Poison"}}
 for _,o in ipairs(definitions) do
  local row=T.entry(sc,o[1],o[2],function()
   if o[1]=="Burn" then d.effect="Burn" elseif o[1]=="Poison" then d.effect="Poison" else d.effect="None" end
   v.redraw()
  end,c.green,57,o[3])
  row.BackgroundColor3=o[3] and Color3.fromRGB(83,126,79) or Color3.fromRGB(36,36,42)
 end
 T.button(right,"RESET",393,550,104,39,function()d.area=false;d.element="Fire";d.effect="None";v.redraw()end,c.mute)
 local save=T.button(right,"SAVE SPELL",503,550,129,39,function()v.send("CraftSpell",d)end,c.green)
 save.BackgroundColor3=cost<=10 and Color3.fromRGB(72,105,65) or c.raised
 S.Gear(v);S.Dock(v)
end
return P
