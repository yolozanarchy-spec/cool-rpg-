--!strict
-- Scrollable skill compendium: list left, richly formatted details right.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local K={};local c=T.c
local data={
 ["Guard"]={icon="🛡",kind="Buff",target="Self",cd=1,desc="Reduce damage taken and gain Barrier for this turn.",effect="Barrier | 1 turn"},
 ["Power Strike"]={icon="⚔",kind="Physical",target="One Enemy",cd=1,desc="A heavy weapon strike that scales with Strength."},
 ["Battle Cry"]={icon="📢",kind="Buff",target="Party",cd=3,desc="Rally your team. Unlock extra effects in the randomly generated War Cry tree.",effect="Attack Up | 3 turns"},
 ["Fireball"]={icon="🔥",kind="Intelligence",target="One Enemy",cd=1,desc="Launch a burning projectile at an enemy.",effect="Burn"},
 ["Crafted Spell"]={icon="✨",kind="Intelligence",target="Selected Enemy",cd=3,desc="A custom spell made at the Spellcrafting workbench."},
 ["Sniper Shot"]={icon="🏹",kind="Physical",target="One Enemy",cd=2,desc="A carefully aimed high-damage shot."},
 ["Volley"]={icon="🏹",kind="Physical",target="All Enemies",cd=3,desc="Loose arrows at all enemies."},
 ["Soul Bolt"]={icon="💀",kind="Intelligence",target="One Enemy",cd=2,desc="Strike an enemy with necromantic power."},
 ["Zombie Strike"]={icon="🧟",kind="Physical",target="One Enemy",cd=2,desc="Command your equipped zombie to attack."},
 ["Holy Light"]={icon="✦",kind="Heal",target="Ally",cd=2,desc="Restore health using holy energy."},
 ["Smite"]={icon="⚡",kind="Holy",target="One Enemy",cd=2,desc="Punish an enemy with holy damage."},
 ["Throw Gold"]={icon="🪙",kind="Physical",target="One Enemy",cd=1,desc="Spend coins to deal damage."},
 ["Coin Flick"]={icon="🪙",kind="Physical",target="One Enemy",cd=1,desc="Flick a coin at an enemy."},
}
-- Documented enemy skills shown as reference, not claimable player skills.
local enemy={
 {group="Cultist",list={{"Arcane Blast","✨","Intelligence",3,"A blast of arcane energy hitting all enemies."},
  {"Curse","💀","Debuff",2,"Weakens the target."},
  {"Dark Ritual","🕯","Buff",4,"Perform a dark ritual. Boost all allies' Attack and Magic."},
  {"Fire Bolt","🔥","Intelligence",1,"Hurls a ball of flame."},
  {"Ice Lance","🧊","Intelligence",2,"A piercing lance of ice."},
  {"Mana Shield","🟣","Buff",3,"Creates a shield of pure mana."},
  {"Sacrifice","❤️","Heal",3,"Heals an ally at the cost of own HP."}}},
 {group="Goblin",list={{"Battle Cry (Enemy)","📢","Buff",4,"Rallies allies with increased attack."},
  {"Smoke Bomb","💨","Buff",3,"Creates a cloud of smoke to aid evasion."},
  {"Throwing Knife","🗡","Physical",2,"Throws a sharpened knife."}}},
}
function K.Show(v)
 local root=v.root;local st=v.localState;local r=v.state.run
 local left=S.Box(root,4,13,239,611,Color3.fromRGB(28,28,31))
 local scroll=S.Scroll(left,0,0,238,609)
 T.copy(scroll,"YOUR SKILLS",27,c.gold)
 local names={"Guard"}
 for _,n in ipairs(v.content.BaseSkills[r.class] or {}) do table.insert(names,n) end
 for _,name in ipairs(names) do
  local d=data[name] or {icon="✦",kind="Skill",target="Enemy",cd=0,desc="Class skill"}
  local row=T.entry(scroll,d.icon.."  "..name,d.kind.."   CD "..d.cd,function()st.selectedSkill=name;v.redraw()end,
   c.green,53,st.selectedSkill==name)
  row.BackgroundColor3=st.selectedSkill==name and Color3.fromRGB(52,97,66) or c.bg
 end
 T.copy(scroll,"ENEMY SKILL CODEX  ·  Reference only",45,c.mute)
 for _,set in ipairs(enemy) do
  T.copy(scroll,set.group,24,c.gold)
  for _,e in ipairs(set.list) do
   local row=T.entry(scroll,e[2].." "..e[1],e[3].."   CD "..e[4],function()st.selectedSkill=e[1];v.redraw()end,
    c.green,54,st.selectedSkill==e[1])
   row.BackgroundColor3=st.selectedSkill==e[1] and Color3.fromRGB(52,97,66) or c.bg
  end
 end
 local right=S.Box(root,249,13,1023,610,Color3.fromRGB(17,17,20))
 S.Separator(right,12,42,995)
 local chosen=st.selectedSkill or "Guard"
 local d=data[chosen]
 local enemySkill=false
 if not d then
  for _,set in ipairs(enemy) do for _,e in ipairs(set.list) do if e[1]==chosen then
   d={icon=e[2],kind=e[3],target=e[1]=="Dark Ritual" and "Party" or "Enemy",cd=e[4],desc=e[5],effect=e[1]=="Dark Ritual" and "Attack Up | 1 Stack | 3 Turns\nIntelligence Up | 1 Stack | 3 Turns" or nil}
   enemySkill=true
  end end end
 end
 if d then
  T.label(right,d.icon.."  "..chosen,18,58,984,44,{size=22,bold=true,color=c.yellow})
  local function chip(text,x,w,col)
   local b=S.Pill(right,text,x,111,w,nil,true);b.BackgroundColor3=col;b.TextSize=12
  end
  chip(d.kind,18,94,Color3.fromRGB(54,69,60))
  chip(enemySkill and "Enemy Reference" or "Known Skill",118,135,Color3.fromRGB(60,47,61))
  T.label(right,"Target",18,157,500,24,{size=13,bold=true,color=c.mute})
  T.label(right,(d.target=="Party" and "👥  " or "🎯  ")..d.target,19,181,634,27,{size=15,color=c.green})
  T.label(right,"Scaling",18,223,520,25,{size=13,bold=true,color=c.mute})
  T.label(right,d.kind=="Intelligence" and "Scales with Intelligence" or d.kind=="Physical" and "Scales with Strength" or "Based on skill's effects",18,249,770,29,{size=14})
  T.label(right,"Status Effects",18,291,520,25,{size=13,bold=true,color=c.mute})
  T.label(right,d.effect or "None",19,319,950,47,{size=14,color=d.effect and c.purple or c.mute})
  T.label(right,"Cooldown",18,377,520,22,{size=13,bold=true,color=c.mute})
  T.label(right,"⏱  "..d.cd.." Turns",18,402,790,28,{size=15,color=c.blue})
  T.label(right,"Description",18,445,520,22,{size=13,bold=true,color=c.mute})
  T.label(right,d.desc,18,470,963,61,{size=15})
  T.label(right,"Lore",18,536,520,23,{size=13,bold=true,color=c.mute})
  T.label(right,enemySkill and "An enemy ability recorded in the codex; not usable by your class." or "Learned from your class or universal training.",18,559,959,33,{size=13,color=c.mute})
 else
  T.label(right,"Select a skill",20,68,982,40,{size=21,bold=true,color=c.mute})
 end
 S.Dock(v)
end
return K
