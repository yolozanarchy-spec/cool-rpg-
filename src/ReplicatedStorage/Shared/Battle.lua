--!strict
-- Server-side battle actions, targeting, cooldowns and status ticks.
local Content=require(script.Parent.Content)
local Enemies=require(script.Parent.Enemies)
local Progress=require(script.Parent.Progress)
local B={}
local function living(b)
 for _,enemy in ipairs(b.enemies) do if enemy.hp>0 then return enemy end end
 return nil
end
local function aliveCount(b)
 local n=0;for _,e in ipairs(b.enemies) do if e.hp>0 then n+=1 end end
 return n
end
local function addLog(b,text)
 table.insert(b.log,1,text)
 if #b.log>8 then table.remove(b.log) end
end
local function status(enemy,name,turns)
 enemy.status[name]=math.max(enemy.status[name] or 0,turns)
end
local function hurtEnemy(run,b,enemy,amount,magical)
 if enemy.hp<=0 then return end
 local stats=Progress.Stats(run)
 local defense=math.floor(enemy.defense*.45)
 local damage=math.max(1,math.floor(amount-defense))
 if magical then damage=math.max(1,math.floor(amount-math.floor(enemy.defense*.2))) end
 local critical=math.random(1,100)<=math.min(50,5+math.floor(stats.Luck*.5))
 if critical then damage=math.floor(damage*1.5) end
 enemy.hp=math.max(0,enemy.hp-damage)
 addLog(b,enemy.name.." took "..damage..(critical and " CRIT!" or "").." damage")
 if run.flags.Lifesteal then Progress.Heal(run,math.floor(damage*.15),0) end
 if enemy.hp<=0 then
  addLog(b,enemy.name.." defeated!")
  Progress.OnKill(run,enemy.name)
 end
end
local function barrierDamage(run,b,amount)
 local shield=math.min(b.barrier,amount)
 b.barrier-=shield;amount-=shield
 if shield>0 then addLog(b,"Barrier absorbed "..shield.." damage") end
 if b.guard then amount=math.floor(amount*.5) end
 if run.flags.Fortify then amount=math.floor(amount*.85) end
 if run.flags.Berserker then amount=math.ceil(amount*1.1) end
 run.hp=math.max(0,run.hp-amount)
end
function B.Start(run,kind,forced)
 local b={enemies={},round=1,log={},guard=false,barrier=0,cooldowns={},effects={},battleKind=kind}
 local list={}
 if forced then table.insert(list,forced)
 elseif kind=="Boss" then
  local keys={"Goblin King","Ancient Guardian","Plague Queen","Dragon","Corrupted Hero"}
  table.insert(list,keys[math.random(#keys)])
 else
  local names={}
  for name,e in pairs(Enemies.Normal) do if e.level<=math.min(7,run.level+3) then table.insert(names,name) end end
  table.sort(names)
  local count=math.random(1,math.min(3,1+math.floor(run.stage/3)))
  for i=1,count do table.insert(list,names[math.random(#names)]) end
 end
 for i,name in ipairs(list) do
  local ref=Enemies.Normal[name] or Enemies.Boss[name] or Enemies.Elite[name] or {hp=35,attack=8,defense=3,speed=6,level=3,skills={}}
  local scale=1+math.max(0,run.stage-ref.level)*.10
  table.insert(b.enemies,{id=i,name=name,level=ref.level,hp=math.floor(ref.hp*scale),maxHP=math.floor(ref.hp*scale),attack=math.floor(ref.attack*scale),defense=ref.defense,speed=ref.speed,skills=ref.skills,status={}})
 end
 run.combat=b
 if run.class=="Hunter" then
  local strongest=b.enemies[1]
  for _,e in ipairs(b.enemies) do if e.maxHP>strongest.maxHP then strongest=e end end
  if run.trap=="Spike" then strongest.hp=math.max(0,strongest.hp-10-2*run.level);addLog(b,"PREPARED SPIKE TRAP hit "..strongest.name)
  elseif run.trap=="Venom" then status(strongest,"Poison",4);addLog(b,"VENOM TRAP poisoned "..strongest.name)
  else status(strongest,"Stun",1);addLog(b,"SNARE TRAP stunned "..strongest.name) end
  if strongest.hp==0 then Progress.OnKill(run,strongest.name) end
 end
 if run.class=="Necromancer" then b.zombie=Progress.ZombieStats(run) end
 addLog(b,kind=="Boss" and "BOSS ENCOUNTER!" or "Enemies approach!")
 return b
end
local function skill(run,b,enemy,name)
 local s=Progress.Stats(run)
 local costs={ ["Power Strike"]=0,["Battle Cry"]=0,["Fireball"]=7,["Crafted Spell"]=9,["Sniper Shot"]=0,["Volley"]=5,["Soul Bolt"]=5,["Zombie Strike"]=0,["Holy Light"]=7,["Smite"]=5,["Throw Gold"]=0,["Coin Flick"]=0 }
 local cost=costs[name]
 if cost==nil or run.mp<cost or (b.cooldowns[name] or 0)>0 then return false end
 run.mp-=cost
 local damage=(6+s.Strength*1.6)*(1+(b.cry and b.cry.power or 0))
 local magic=8+s.Intelligence*1.9
 if name=="Holy Light" then
  Progress.Heal(run,math.floor(18+s.Holiness*2),0);b.cooldowns[name]=4;addLog(b,"Holy Light restored health")
 elseif name=="Battle Cry" then
  local power,shield,heal,blast,speed,defense,duration=.12,0,0,0,0,0,3
  for i=1,9 do
   if run.cryOwned[tostring(i)] then
    local n=run.cryNodes[i];power+=n.power or 0;shield+=n.barrier or 0;heal+=n.heal or 0
    blast+=n.blast or 0;speed+=n.speed or 0;defense+=n.defense or 0;duration+=n.duration or 0
   end
  end
  b.cry={turns=duration,power=power,speed=speed,defense=defense}
  b.barrier+=shield;Progress.Heal(run,heal,0)
  for _,e in ipairs(b.enemies) do if e.hp>0 and blast>0 then hurtEnemy(run,b,e,blast,true) end end
  b.cooldowns[name]=4;addLog(b,"Battle Cry shakes the arena!")
 elseif name=="Crafted Spell" then
  local sp=run.spell
  b.cooldowns[name]=3
  local power=magic+(sp.element=="Fire" and 3 or 0)
  for _,e in ipairs(b.enemies) do
   if e.hp>0 and (sp.area or e==enemy) then
    hurtEnemy(run,b,e,power,true)
    if e.hp>0 and sp.effect~="None" then status(e,sp.effect,3) end
    if e.hp>0 and sp.element=="Ice" then status(e,"Slow",2) end
   end
  end
 elseif name=="Volley" then
  for _,e in ipairs(b.enemies) do if e.hp>0 then hurtEnemy(run,b,e,damage*.7*Progress.TrophyBonus(run),false) end end
  b.cooldowns[name]=3
 elseif name=="Sniper Shot" then hurtEnemy(run,b,enemy,damage*1.75*Progress.TrophyBonus(run),false);b.cooldowns[name]=3
 elseif name=="Fireball" then
  hurtEnemy(run,b,enemy,magic*1.3,true);if enemy.hp>0 then status(enemy,"Burn",3) end;b.cooldowns[name]=2
 elseif name=="Soul Bolt" then hurtEnemy(run,b,enemy,magic*1.2,true);b.cooldowns[name]=2
 elseif name=="Smite" then hurtEnemy(run,b,enemy,magic+s.Holiness*1.4,true);b.cooldowns[name]=3
 elseif name=="Throw Gold" then
  if run.gold<10 then return false end
  run.gold-=10;hurtEnemy(run,b,enemy,damage*2,true);b.cooldowns[name]=2
 else
  local mult=name=="Power Strike" and 1.65 or 1
  hurtEnemy(run,b,enemy,damage*mult*Progress.TrophyBonus(run),false)
  if name=="Power Strike" then b.cooldowns[name]=2 end
 end
 return true
end
local function enemyTurn(run,b)
 for _,enemy in ipairs(b.enemies) do
  if enemy.hp>0 then
   if enemy.status.Stun and enemy.status.Stun>0 then addLog(b,enemy.name.." is stunned")
   else
    local s=Progress.Stats(run)
    local defense=s.Defense+(b.cry and b.cry.defense or 0)
    local amount=math.max(1,math.floor(enemy.attack-defense*.4))
    if math.random()<.13 then amount=math.floor(amount*1.3) end
    if math.random(1,100)>math.min(30,math.floor(s.Speed*.7)) then barrierDamage(run,b,amount);addLog(b,enemy.name.." attacks for "..amount)
    else addLog(b,"Dodged "..enemy.name.."'s attack") end
    if enemy.skills and (table.find(enemy.skills,"VenomBite") or table.find(enemy.skills,"Infect") or table.find(enemy.skills,"AcidSpit")) and math.random()<.17 then b.effects.Poison=math.max(b.effects.Poison or 0,3) end
   end
  end
 end
end
local function tick(run,b)
 for name,remaining in pairs(b.effects) do
  if remaining>0 then
   if name=="Poison" then barrierDamage(run,b,math.max(2,math.ceil(Progress.Stats(run).MaxHP*.04)));addLog(b,"Poison hurts you") end
   b.effects[name]-=1
  end
 end
 for _,enemy in ipairs(b.enemies) do
  if enemy.hp>0 then
   for name,turns in pairs(enemy.status) do
    if turns>0 then
     if name=="Poison" then enemy.hp=math.max(0,enemy.hp-math.max(2,math.ceil(enemy.maxHP*.04))) end
     if name=="Burn" then enemy.hp=math.max(0,enemy.hp-7) end
     enemy.status[name]-=1
    end
   end
   if enemy.hp==0 then addLog(b,enemy.name.." fell to a status effect");Progress.OnKill(run,enemy.name) end
  end
 end
end
function B.Action(run,action,index,skillName)
 local b=run.combat;if not b or run.hp<=0 then return false,"No battle" end
 if not table.find({"Attack","Skill","Defend","Item"},action) then return false,"Invalid action" end
 local target=b.enemies[index] or living(b)
 if action~="Defend" and action~="Item" and (not target or target.hp<=0) then return false,"Choose a living enemy" end
 b.guard=false
 if action=="Attack" then
  local s=Progress.Stats(run)
  hurtEnemy(run,b,target,(7+s.Strength*1.8)*(1+(b.cry and b.cry.power or 0))*(run.flags.Berserker and 1.3 or 1)*Progress.TrophyBonus(run),false)
 elseif action=="Skill" then
  if not table.find(Content.BaseSkills[run.class],skillName) then return false,"Unknown skill" end
  if not skill(run,b,target,skillName) then return false,"Skill unavailable: cooldown, mana, or gold" end
 elseif action=="Defend" then b.guard=true;b.barrier+=3;addLog(b,"You brace for impact")
 elseif action=="Item" then
  if not Content.Items[skillName] or Content.Items[skillName].kind~="Consumable" or (run.inventory[skillName] or 0)<1 then return false,"Item unavailable" end
  local item=Content.Items[skillName]
  run.inventory[skillName]-=1;if run.inventory[skillName]==0 then run.inventory[skillName]=nil end
  Progress.Heal(run,item.heal or 0,item.mana or 0)
  if item.cure then b.effects[item.cure]=nil end
  addLog(b,"Used "..skillName)
 end
 if aliveCount(b)==0 then return true,"Victory" end
 for n,cd in pairs(b.cooldowns) do if cd>0 then b.cooldowns[n]=cd-1 end end
 if b.zombie and living(b) then
  local foe=living(b)
  foe.hp=math.max(0,foe.hp-b.zombie.attack)
  addLog(b,"Zombie strikes "..foe.name.." for "..b.zombie.attack)
  if foe.hp==0 then Progress.OnKill(run,foe.name) end
 end
 if aliveCount(b)==0 then return true,"Victory" end
 tick(run,b)
 if aliveCount(b)==0 then return true,"Victory" end
 if run.hp>0 then enemyTurn(run,b) end
 if b.cry then b.cry.turns-=1;if b.cry.turns<=0 then b.cry=nil end end
 b.round+=1
 if run.hp<=0 then return true,"Defeat" end
 return true,"Continue"
end
return B
