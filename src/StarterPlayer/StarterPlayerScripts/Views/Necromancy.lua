--!strict
-- Reference: zombie doll on the left, monster-part inventory center, attach/details right.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local N={};local c=T.c
local slots={"Arms","Chest","Core","Head","Legs"}
local positions={Head={230,41,76,68},Arms={153,113,75,103},Chest={228,113,76,103},Core={304,113,75,103},Legs={229,218,76,119}}
local function zombieStats(r,items)
 local hp,atk,def=35,5,2
 for _,name in pairs(r.zombieParts or {}) do
  local item=items[name]
  if item and item.bonus then
   if item.stat=="Strength" then atk+=item.bonus
   elseif item.stat=="Defense" then def+=item.bonus;hp+=item.bonus*3
   else atk+=1 end
  end
 end
 return hp,atk,def
end
function N.Show(v)
 local p=v.root;local r=v.state.run;local st=v.localState
 local left=S.Box(p,0,0,529,621,Color3.fromRGB(30,30,33))
 local mid=S.Box(p,535,0,377,621,Color3.fromRGB(25,25,28))
 local right=S.Box(p,918,0,362,621,Color3.fromRGB(25,25,28))
 T.rect(p,529,0,4,625,Color3.fromRGB(77,76,91),0,false)
 T.rect(p,912,0,4,625,Color3.fromRGB(61,60,69),0,false)
 -- Part-body silhouette uses six inactive equip placeholders and a distinct zombie head.
 local head=T.rect(left,220,40,72,75,Color3.fromRGB(41,41,47),0,6)
 local b=T.button(head,"🧟\nZombie",2,2,68,70,function()st.selectedSlot="Head";v.redraw()end,c.blue,st.selectedSlot=="Head")
 b.TextSize=13;b.BackgroundColor3=Color3.fromRGB(129,129,129)
 for _,slot in ipairs({"Arms","Chest","Core","Legs"}) do
  local d=positions[slot]
  local value=r.zombieParts[slot]
  local equip=T.button(left,value or "Empty",d[1],d[2],d[3],d[4],function()
   st.selectedSlot=slot;st.selectedPart=nil;v.redraw()
  end,c.blue,st.selectedSlot==slot)
  equip.TextSize=12;equip.BackgroundColor3=Color3.fromRGB(36,36,41)
  if not value then equip.TextColor3=c.mute end
 end
 local hp,attack,def=zombieStats(r,v.content.Items)
 T.label(left,"SUMMON STATS",2,394,300,25,{size=13,bold=true,color=c.purple})
 T.label(left,"HP: "..hp.." / "..hp,2,425,250,24,{size=13,color=c.red})
 T.label(left,"MP: 0 / 0",2,450,250,22,{size=13,color=c.blue})
 T.label(left,"Health: "..hp.."\nAttack: "..attack.."\nDefense: "..def.."",2,485,250,87,{size=13,color=c.white})
 for i,slot in ipairs(slots) do
  S.Pill(mid,slot,8+(i-1)*72,6,70,function()st.selectedSlot=slot;st.selectedPart=nil;v.redraw()end,st.selectedSlot==slot)
 end
 T.label(mid,st.selectedSlot.." — Available monster parts",11,42,347,24,{size=12,color=c.mute})
 local items=T.keys(r.inventory)
 local n=0
 for _,name in ipairs(items) do
  local item=v.content.Items[name]
  if item and item.kind=="Part" and r.inventory[name]>0 then
   local x=15+(n%4)*85;local y=72+math.floor(n/4)*88
   local cell=T.button(mid,name, x,y,78,78,function()st.selectedPart=name;v.redraw()end,
    c.blue,st.selectedPart==name)
   cell.TextSize=11;cell.BackgroundColor3=st.selectedPart==name and Color3.fromRGB(74,111,149) or Color3.fromRGB(78,78,81)
   T.label(cell,"×"..r.inventory[name],54,1,20,17,{size=11,bold=true,align=Enum.TextXAlignment.Right})
   n+=1
  end
 end
 if n==0 then T.label(mid,"No monster parts. Defeat enemies to find new parts.",14,88,346,67,{size=13,color=c.mute}) end
 local partName=st.selectedPart;local part=partName and v.content.Items[partName]
 T.label(right,partName or "Select a part",12,13,343,30,{size=17,bold=true,color=c.white})
 if part then
  T.label(right,"Slot: "..st.selectedSlot,13,64,336,28,{size=14,color=c.blue})
  T.label(right,"Type: Monster Part\n"..part.stat..": +"..part.bonus,13,108,331,71,{size=15,color=c.green})
  T.label(right,"Attach this part to your zombie's "..st.selectedSlot:lower().." slot. Any replaced part returns to inventory.",13,213,337,90,{size=13,color=c.mute})
  local b=T.button(right,"ATTACH",14,548,335,47,function()
   v.send("ZombieEquip",{slot=st.selectedSlot,name=partName});st.selectedPart=nil
  end,c.green)
  b.BackgroundColor3=Color3.fromRGB(55,106,65)
 else
  T.label(right,"Click a monster part from the inventory to view its stats.",12,65,334,95,{size=13,color=c.mute})
  local b=T.button(right,"ATTACH",14,548,335,47,nil,c.mute)
  b.BackgroundColor3=Color3.fromRGB(49,49,50);b.TextColor3=Color3.fromRGB(119,119,121)
 end
 S.Dock(v)
end
return N
