--!strict
-- Shared fixed bottom dock, gear icon and full-width two-column primitives.
local T=require(script.Parent.Kit)
local S={}; local c=T.c
S.TOP=12; S.BOTTOM=626
function S.Dock(v)
 local class=v.state.run and v.state.run.class or ""
 local classTitle=({Necromancer="NECROMANCY",Mage="SPELLCRAFT",Warrior="WAR CRY",Merchant="BAZAAR",Hunter="HUNTING",Paladin="DIVINE FAVOR"})[class] or "CLASS"
 local tabs={{"ADVENTURE","Map"},{"CHARACTER","Stats"},{classTitle,"Class"},
  {"CRAFTING","Crafting"},{"INVENTORY","Inventory"},{"SKILLS","Skills"}}
 local dock=T.rect(v.root,0,644,1280,76,Color3.fromRGB(28,28,29),0,false)
 T.rect(dock,0,0,1280,3,Color3.fromRGB(15,15,16),0,false)
 local width=164;local gap=11;local start=90
 for i,pair in ipairs(tabs) do
  local active=v.state.phase==pair[2] or (v.state.phase=="Merchant" and pair[2]=="Class")
  local b=T.button(dock,pair[1],start+(i-1)*(width+gap),12,width,51,function()
   if v.state.phase=="Merchant" and pair[2]=="Class" then return end
   if pair[2]=="Class" and class=="Merchant" then
    v.send("CampTab",{tab="Merchant"})
   else v.send("CampTab",{tab=pair[2]}) end
  end,c.blue,active)
  b.BackgroundColor3=active and Color3.fromRGB(52,59,67) or Color3.fromRGB(45,45,46)
  b.Font=Enum.Font.GothamBold;b.TextSize=14
 end
end
function S.Gear(v)
 local g=T.button(v.root,"⚙",1219,9,51,40,function()v.send("Info",{kind="Settings"})end,c.mute)
 g.TextSize=29;g.BackgroundColor3=Color3.fromRGB(36,38,41)
 return g
end
function S.Title(v,title)
 T.label(v.root,title,15,13,910,43,{size=25,bold=true,color=c.gold})
end
function S.Box(parent,x,y,w,h,color)
 local p=T.rect(parent,x,y,w,h,color or c.panel,0,7)
 return p
end
function S.Scroll(parent,x,y,w,h)
 local sf=T.scroll(parent,x,y,w,h)
 sf.ScrollBarImageColor3=Color3.fromRGB(68,69,74)
 return sf
end
function S.Separator(parent,x,y,w)
 T.rect(parent,x,y,w,1,Color3.fromRGB(65,64,66),0,false)
end
function S.Pill(parent,text,x,y,w,onClick,active)
 local b=T.button(parent,text,x,y,w,27,onClick,c.blue,active)
 b.TextSize=11;b.Font=Enum.Font.Gotham
 b.BackgroundColor3=active and Color3.fromRGB(53,91,131) or Color3.fromRGB(35,35,39)
 return b
end
function S.Line(parent,ax,ay,bx,by,color,thick)
 local dx=bx-ax;local dy=by-ay
 local o=T.rect(parent,(ax+bx)/2,(ay+by)/2,math.sqrt(dx*dx+dy*dy),thick or 4,color or c.border,0,false)
 o.AnchorPoint=Vector2.new(.5,.5);o.Rotation=math.deg(math.atan2(dy,dx));return o
end
return S
