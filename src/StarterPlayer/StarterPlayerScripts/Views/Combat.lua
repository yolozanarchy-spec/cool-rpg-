--!strict
-- Combat layout follows PDF: turn queue left, enemies center, fixed scroll log right,
-- bottom 2x2 action buttons, and skills/items replacing the action grid.
local T=require(script.Parent.Kit)
local M={};local c=T.c
local function hpCard(parent,name,now,total,x,y,w,color)
 T.label(parent,name,x+8,y,w-16,23,{size=14,bold=true})
 T.label(parent,now.." / "..total.." HP",x+8,y+29,w-16,25,{size=13,color=color})
 T.progress(parent,x+8,y+60,w-16,9,now,total,color)
end
function M.Show(v)
 local s=v.state;local r=s.run;local b=r.combat;local localView=v.localState
 if not b then return end
 local root=v.root
 T.subtitle(root,b.battleKind=="Boss" and "BOSS COMBAT" or "COMBAT",228,79,620)
 T.label(root,"STAGE "..(r.stage or 1).."    •    ROUND "..b.round,16,78,182,30,{size=13,bold=true,color=c.gold})
 local queue=T.panel(root,13,112,181,514,"TURN ORDER",c.gold)
 T.label(queue,"YOUR TURN",12,52,157,27,{size=13,bold=true,color=c.green})
 T.button(queue,"01  YOU",12,86,155,46,nil,c.green,true)
 local y=151
 for i,e in ipairs(b.enemies) do
  if e.hp>0 then
   T.button(queue,string.format("%02d  %s",i+1,e.name),12,y,155,48,function()
    localView.target=i;v.redraw()
   end,c.red,localView.target==i)
   y+=58
  end
 end
 local field=T.panel(root,206,112,782,270,"BATTLEFIELD",c.red)
 T.label(field,"Select a living enemy, then choose an action.",16,46,750,25,{size=13,color=c.mute})
 local alive={}
 for i,e in ipairs(b.enemies) do if e.hp>0 then table.insert(alive,i) end end
 local count=math.max(1,#alive)
 local cardWidth=math.min(222,math.floor(726/count)-8)
 local left=math.floor((782-count*(cardWidth+10)+10)/2)
 for displayIndex,i in ipairs(alive) do
  local e=b.enemies[i];local x=left+(displayIndex-1)*(cardWidth+10)
  local selected=localView.target==i
  local card=T.button(field,e.name,x,84,cardWidth,148,function() localView.target=i;v.redraw() end,selected and c.gold or c.red,selected)
  T.label(card,"LV "..e.level.."   •   DEF "..e.defense,13,38,cardWidth-23,25,{size=12,color=c.mute})
  T.label(card,e.hp.." / "..e.maxHP.." HP",13,68,cardWidth-23,27,{size=14,bold=true,color=c.green})
  T.progress(card,13,101,cardWidth-26,10,e.hp,e.maxHP,c.green)
  local effects={}
  for name,turns in pairs(e.status or {}) do if turns>0 then table.insert(effects,name.." "..turns) end end
  T.label(card,table.concat(effects,"  "),13,116,cardWidth-22,21,{size=11,color=c.purple})
 end
 if #alive==0 then T.label(field,"VICTORY!",240,109,302,80,{size=31,bold=true,color=c.green,align=Enum.TextXAlignment.Center}) end
 local log=T.panel(root,1001,112,263,514,"COMBAT LOG",c.blue)
 T.label(log,"Newest actions first",13,50,230,19,{size=12,color=c.mute})
 local scroll=T.scroll(log,12,77,237,419)
 for _,msg in ipairs(b.log or {}) do
  local label=T.copy(scroll,"•  "..msg,math.max(45,math.ceil(#msg/25)*19),c.white)
  label.TextXAlignment=Enum.TextXAlignment.Left
 end
 local actions=T.panel(root,206,394,782,230,"SELECT ACTION",c.gold)
 local tab=localView.combatTab or "Actions"
 local function act(action,skill)
  localView.combatTab="Actions"
  v.send("CombatAction",{action=action,index=localView.target or 1,skill=skill})
 end
 if tab=="Actions" then
  local opts={
   {"ATTACK",c.red,function() act("Attack") end},
   {"ITEMS",c.blue,function() localView.combatTab="Items";v.redraw() end},
   {"ESCAPE",c.mute,function() act("Escape") end},
   {"SKILLS",c.purple,function() localView.combatTab="Skills";v.redraw() end},
  }
  for i,o in ipairs(opts) do
   local col=(i-1)%2;local row=math.floor((i-1)/2)
   T.button(actions,o[1],16+col*382,60+row*77,369,64,o[3],o[2])
  end
 else
  T.button(actions,"← BACK TO ACTIONS",15,10,230,36,function() localView.combatTab="Actions";v.redraw() end,c.mute)
  local itemScroll=T.scroll(actions,15,56,752,159)
  if tab=="Skills" then
   T.entry(itemScroll,"Guard","Universal skill • halves incoming attacks and grants 3 Barrier",function() act("Skill","Guard") end,c.green,65)
   for _,name in ipairs(v.content.BaseSkills[r.class]) do
    local cd=b.cooldowns[name] or 0
    local desc=cd>0 and ("ON COOLDOWN  •  "..cd.." turns") or "Select to use this skill on your target"
    if name=="Crafted Spell" then desc=r.spell.name.."   •   "..desc end
    T.entry(itemScroll,name,desc,function() if cd==0 then act("Skill",name) end end,cd>0 and c.border or c.purple,65)
   end
  else
   local n=0
   for _,name in ipairs(T.keys(r.inventory)) do
    local item=v.content.Items[name]
    if item and item.kind=="Consumable" and r.inventory[name]>0 then
     n+=1;T.entry(itemScroll,name.."   ×"..r.inventory[name],"Use this item during your turn",function() act("Item",name) end,c.blue,60)
    end
   end
   if n==0 then T.copy(itemScroll,"No consumable items available.",50,c.mute) end
  end
 end
 local stats=s.stats or {}
 local user=T.rect(root,206,637,782,39,c.raised,.02,9);T.stroke(user)
 T.label(user,""..r.race.." "..r.class.."   |   LEVEL "..r.level,13,3,250,32,{size=13,bold=true})
 T.label(user,"HP "..r.hp.."/"..(stats.MaxHP or "?").."     MP "..r.mp.."/"..(stats.MaxMP or "?").."     BARRIER "..b.barrier,290,4,470,31,{size=14,bold=true,color=c.green})
end
return M
