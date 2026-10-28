--!strict
-- Original gamerpGggg Combat layout: party cards left, enemy cards right,
-- central battle stage, horizontal turn-order strip, log and actions at bottom.
-- Updated design: Guard lives under Skills; items/skills replace action buttons.
local T=require(script.Parent.Kit)
local M={};local c=T.c

local function card(parent,name,level,hp,maxHP,x,y,w,mainColor)
 local f=T.rect(parent,x,y,w,84,c.raised,0,5)
 T.stroke(f,c.border,1)
 T.label(f,name,12,5,w-75,23,{size=14,bold=true})
 T.label(f,"Lv "..level, w-68,5,60,23,{size=12,color=c.mute,align=Enum.TextXAlignment.Right})
 T.label(f,hp.." / "..maxHP,12,28,w-24,22,{size=12,color=mainColor})
 T.progress(f,10,58,w-20,12,hp,maxHP,mainColor)
 return f
end

function M.Show(v)
 local r=v.state.run
 local b=r.combat
 if not b then return end
 local p=v.root;local localView=v.localState
 local stats=v.state.stats or {}
 local maxHP=stats.MaxHP or r.hp
 local maxMP=stats.MaxMP or r.mp
 local function act(action,skill)
  localView.combatTab="Actions"
  v.send("CombatAction",{action=action,index=localView.target or 1,skill=skill})
 end

 local headline=T.rect(p,0,58,1280,44,c.panel,.02,false)
 T.label(headline,"STAGE "..(r.stage or 1),18,0,160,43,{size=15,bold=true,color=c.gold})
 T.label(headline,"ROUND "..(b.round or 1),202,0,150,43,{size=15,color=c.mute})
 T.label(headline,"YOUR TURN",1090,0,161,43,{size=14,bold=true,color=c.green,align=Enum.TextXAlignment.Right})

 local party=T.panel(p,13,111,248,316,"PARTY",c.blue)
 card(party,r.race.." "..r.class,r.level,r.hp,maxHP,10,58,227,c.green)
 T.label(party,"MP "..r.mp.." / "..maxMP,22,151,195,27,{size=13,color=c.blue})
 T.progress(party,21,182,203,9,r.mp,maxMP,c.blue)
 T.label(party,"BARRIER "..(b.barrier or 0),21,204,199,25,{size=12,color=c.gold})
 if b.zombie then
  T.label(party,"SUMMON  •  UNDEAD",17,248,208,28,{size=13,bold=true,color=c.purple})
  T.label(party,"Attack "..(b.zombie.attack or 0),20,274,197,23,{size=13,color=c.mute})
 end

 local field=T.panel(p,275,111,686,316,"BATTLEFIELD",c.gold)
 local queue=T.rect(field,15,56,655,53,c.raised,0,4)
 T.label(queue,"TURN ORDER",10,5,120,41,{size=13,bold=true,color=c.mute})
 T.button(queue,"YOU",135,7,104,39,nil,c.green,true)
 local queuePos=245
 for i,e in ipairs(b.enemies) do
  if e.hp>0 and queuePos<591 then
   T.button(queue,string.format("%d %s",i,e.name),queuePos,7,109,39,function()
    localView.target=i;v.redraw()
   end,c.red,localView.target==i)
   queuePos+=115
  end
 end
 local selectedEnemy=b.enemies[localView.target] or b.enemies[1]
 if selectedEnemy and selectedEnemy.hp<=0 then
  for i,e in ipairs(b.enemies) do
   if e.hp>0 then localView.target=i;selectedEnemy=e;break end
  end
 end
 if selectedEnemy then
  T.label(field,selectedEnemy.name,22,147,632,50,
   {size=29,bold=true,align=Enum.TextXAlignment.Center})
  T.label(field,"Enemy level "..selectedEnemy.level.."  •  Armor "..selectedEnemy.defense,
   34,194,617,29,{size=15,color=c.mute,align=Enum.TextXAlignment.Center})
  local fx={}
  for name,duration in pairs(selectedEnemy.status or {}) do
   if duration>0 then table.insert(fx,name.." ×"..duration) end
  end
  T.label(field,table.concat(fx,"    "),30,235,626,30,
   {size=13,color=c.purple,align=Enum.TextXAlignment.Center})
 end
 T.label(field,"Click an enemy on the right to select a target.",25,271,635,25,
  {size=12,color=c.mute,align=Enum.TextXAlignment.Center})

 local enemies=T.panel(p,974,111,293,316,"ENEMIES",c.red)
 local enemyScroll=T.scroll(enemies,8,54,277,250)
 for i,e in ipairs(b.enemies) do
  if e.hp>0 then
   local label=e.name.."  •  LV "..e.level
   T.entry(enemyScroll,label,e.hp.." / "..e.maxHP.." HP",function()
    localView.target=i;v.redraw()
   end,c.red,71,localView.target==i)
  end
 end

 local log=T.panel(p,13,440,396,242,"COMBAT LOG",c.blue)
 T.label(log,"Scroll to review earlier actions",16,48,365,21,{size=12,color=c.mute})
 local sc=T.scroll(log,11,76,373,156)
 for _,msg in ipairs(b.log or {}) do
  T.copy(sc,"• "..msg,math.max(41,math.ceil(#msg/33)*20),c.white)
 end

 local commands=T.panel(p,421,440,846,242,"ACTIONS",c.green)
 local tab=localView.combatTab or "Actions"
 if tab=="Actions" then
  local actions={
   {"ATTACK",c.red,function() act("Attack") end},
   {"SKILLS",c.purple,function() localView.combatTab="Skills";v.redraw() end},
   {"ITEMS",c.blue,function() localView.combatTab="Items";v.redraw() end},
   {"ESCAPE",c.mute,function() act("Escape") end},
  }
  for i,a in ipairs(actions) do
   local col=(i-1)%2;local row=math.floor((i-1)/2)
   T.button(commands,a[1],14+col*415,61+row*84,399,73,a[3],a[2])
  end
 else
  T.button(commands,"BACK",672,9,160,39,function()
   localView.combatTab="Actions";v.redraw()
  end,c.mute)
  T.label(commands,tab:upper().."  •  SELECT AN ACTION",15,53,800,25,
   {size=14,color=c.mute})
  local choices=T.scroll(commands,14,85,818,147)
  if tab=="Skills" then
   T.entry(choices,"Guard","Universal skill  •  Damage reduction + Barrier",function()
    act("Skill","Guard") end,c.green,60)
   for _,name in ipairs(v.content.BaseSkills[r.class]) do
    local cd=b.cooldowns[name] or 0
    local info=cd>0 and ("Cooldown: "..cd.." turns") or "Use on selected target"
    if name=="Crafted Spell" then info=r.spell.name.."  •  "..info end
    T.entry(choices,name,info,function()
     if cd==0 then act("Skill",name) end
    end,cd>0 and c.border or c.purple,60)
   end
  else
   local count=0
   for _,name in ipairs(T.keys(r.inventory)) do
    local item=v.content.Items[name]
    if item and item.kind=="Consumable" and r.inventory[name]>0 then
     count+=1
     T.entry(choices,name.."  ×"..r.inventory[name],"Use this item",function()
      act("Item",name)
     end,c.blue,60)
    end
   end
   if count==0 then T.copy(choices,"No usable items in your inventory.",56,c.mute) end
  end
 end
end
return M
