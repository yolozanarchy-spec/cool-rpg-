--!strict
-- Original Cool RPG-inspired: flat dark menu, four-column creator,
-- encounter dialogues and separate reward sections from the original MainUI.
local T=require(script.Parent.Kit)
local M={}
local c=T.c

local function statsFor(choice,content)
 local stats={}
 for _,name in ipairs(content.Stats) do
  stats[name]=3+(content.Races[choice.race].stats[name] or 0)
   +(content.Traits[choice.trait].stats[name] or 0)
 end
 return stats
end

function M.Menu(v)
 local p=v.root
 T.rect(p,0,0,1280,720,Color3.fromRGB(20,20,30),0,false)
 T.label(p,"COOL RPG",0,55,1280,65,{size=41,bold=true,align=Enum.TextXAlignment.Center})
 T.label(p,"TURN-BASED ROGUELIKE RPG",0,123,1280,30,
  {size=16,color=c.mute,align=Enum.TextXAlignment.Center})
 local options={
  {"PLAY","Play",nil,c.green},
  {"MULTIPLAYER","Info","Multiplayer",c.purple},
  {"ACHIEVEMENTS","Info","Achievements",c.blue},
  {"INFO / CODEX","Info","Info",c.blue},
  {"LEADERBOARD","Info","Leaderboard",c.blue},
  {"SETTINGS","Info","Settings",c.mute},
 }
 for i,o in ipairs(options) do
  local y=214+(i-1)*66
  local b=T.button(p,o[1],469,y,342,54,function()
   if o[2]=="Play" then v.send("Play") else v.send("Info",{kind=o[3]}) end
  end,o[4])
  b.BackgroundColor3=i==1 and Color3.fromRGB(44,113,58) or c.raised
 end
 T.label(p,"Explore • Fight • Gather • Upgrade • Survive",0,649,1280,25,
  {size=14,color=c.mute,align=Enum.TextXAlignment.Center})
end

function M.Creation(v)
 local p=v.root;local choice=v.choice;local content=v.content
 T.label(p,"Choose your race, class and trait. Preview your character on the right.",28,77,1220,28,
  {size=15,color=c.mute})
 local groups={
  {"RACES","race",content.Races,c.blue,0},
  {"CLASSES","class",content.Classes,c.red,1},
  {"TRAITS","trait",content.Traits,c.purple,2},
 }
 for _,g in ipairs(groups) do
  local x=27+g[5]*285
  local col=T.panel(p,x,115,272,480,g[1],g[4])
  local scroll=T.scroll(col,12,57,248,407)
  for _,name in ipairs(T.keys(g[3])) do
   local item=g[3][name]
   local info=g[2]=="class" and item or item.description
   T.entry(scroll,name,info,function()
    choice[g[2]]=name
    v.redraw()
   end,g[4],75,choice[g[2]]==name)
  end
 end
 local col=T.panel(p,884,115,365,480,"CHARACTER",c.gold)
 T.label(col,choice.race.."  "..choice.class,18,61,326,37,{size=24,bold=true})
 T.label(col,"Trait: "..choice.trait,18,101,330,23,{size=15,color=c.green})
 T.label(col,content.Classes[choice.class],18,138,324,100,
  {size=15,color=c.mute})
 T.rect(col,17,252,330,1,c.border,.4,false)
 T.label(col,"STARTING STATS",18,263,329,28,{size=16,bold=true,color=c.gold})
 local stats=statsFor(choice,content)
 for i,key in ipairs(content.Stats) do
  T.label(col,key,22,300+(i-1)*22,225,23,{size=13,color=c.mute})
  T.label(col,tostring(stats[key]),267,300+(i-1)*22,60,23,
   {size=14,bold=true,align=Enum.TextXAlignment.Right})
 end
 local footer=T.rect(p,0,607,1280,77,c.panel,0,false)
 T.button(footer,"BACK",31,13,197,48,function() v.send("BackCreation") end,c.mute)
 local start=T.button(footer,"CONTINUE",1040,13,203,48,
  function() v.send("Confirm",choice) end,c.green)
 start.BackgroundColor3=Color3.fromRGB(44,113,58)
end

function M.Event(v)
 local s=v.state;local p=v.root
 local panel=T.panel(p,79,100,1122,510,s.eventName or "RANDOM EVENT",c.gold)
 T.label(panel,"You encounter something unexpected along your route. How will you respond?",
  32,59,1040,66,{size=18,color=c.white})
 T.rect(panel,27,137,1068,2,c.border,.45,false)
 local options=s.eventChoices or {}
 for i,opt in ipairs(options) do
  T.button(panel,opt.label,34,166+(i-1)*83,480,61,
   function() v.send("EventChoice",{choice=opt.id}) end,
   i==#options and c.mute or c.gold)
 end
 local info=T.panel(panel,552,158,536,284,"EVENT DETAILS",c.blue)
 T.label(info,"Your choices influence the next encounter, the items you find, and the gold you earn.",
  18,63,486,101,{size=17,color=c.mute})
 T.label(info,"Some encounters can lead into a special battle. Skipping an event is always an option when offered.",
  18,184,486,71,{size=14,color=c.mute})
end

function M.Reward(v)
 local s=v.state;local r=s.reward;local p=v.root
 local hasLevel=(r.levelUps or 0)>0
 local offset=hasLevel and 0 or 100
 if hasLevel then
  local level=T.panel(p,56,83,1168,249,"LEVEL UP  •  CHOOSE AN UPGRADE",c.gold)
  for i,u in ipairs(r.choices or {}) do
   local x=24+(i-1)*386
   T.button(level,u.name,x,65,364,67,function()
    if not r.selected then v.send("Upgrade",{name=u.name}) end
   end,r.selected and c.mute or c.green)
   T.label(level,u.desc,x+8,143,347,76,{size=15,color=c.mute})
  end
 else
  T.label(p,"ENCOUNTER COMPLETE",0,101,1280,65,
   {size=31,bold=true,align=Enum.TextXAlignment.Center,color=c.green})
 end
 local rewards=T.panel(p,112,348-offset,1056,287,"VICTORY REWARDS",c.green)
 T.label(rewards,"EXP & GOLD",22,57,340,25,{size=15,bold=true,color=c.gold})
 T.label(rewards,"+"..(r.xp or 0).." EXP      +"..(r.gold or 0).." GOLD",22,83,968,25,
  {size=17,bold=true})
 T.rect(rewards,19,119,1016,1,c.border,.45,false)
 T.label(rewards,"ITEMS DROPPED",22,131,340,25,{size=15,bold=true,color=c.blue})
 T.label(rewards,(r.item and r.item~="") and r.item or "No item found",22,157,968,25,
  {size=16})
 T.rect(rewards,19,195,1016,1,c.border,.45,false)
 T.label(rewards,"OTHER REWARDS",22,206,340,25,{size=15,bold=true,color=c.purple})
 T.label(rewards,r.summary or "Encounter completed",22,234,968,27,
  {size=15,color=c.mute})
 T.button(p,"CONTINUE",492,648,296,41,function()
  if r.selected then v.send("Continue") end
 end,r.selected and c.green or c.mute)
 if not r.selected then T.label(p,"Select an upgrade above before continuing",802,649,380,38,{size=13,color=c.mute}) end
end

function M.Finale(v)
 local dead=v.state.phase=="Death";local r=v.state.run;local p=v.root
 local panel=T.panel(p,247,131,786,495,dead and "YOU HAVE FALLEN" or "VICTORY",dead and c.red or c.green)
 T.label(panel,dead and "YOUR ADVENTURE ENDS HERE" or "THE JOURNEY IS COMPLETE",
  30,79,726,85,{size=27,bold=true,color=dead and c.red or c.green,
   align=Enum.TextXAlignment.Center})
 T.label(panel,string.format("Level %d  •  %d enemies defeated  •  %d victories",
  r.level,r.kills,r.wins),40,175,706,51,{size=17,color=c.mute,align=Enum.TextXAlignment.Center})
 T.button(panel,"START A NEW GAME",200,282,386,57,function() v.send("NewRun") end,c.green)
 T.label(panel,"The original game also offers a run summary and a main menu return.",
  40,372,700,39,{size=13,color=c.mute,align=Enum.TextXAlignment.Center})
end

function M.Info(v)
 local s=v.state;local topic=s.info or "Info"
 local panel=T.panel(v.root,158,112,965,480,topic:upper(),c.blue)
 local details={
  Multiplayer="The four-player party mode is not yet playable in this prototype. The original project's party menus have not been connected to this build.",
  Achievements="Achievements unlock races, classes, traits and other content. Long-term achievement saving is planned but not implemented here.",
  Leaderboard="The original project tracks longest runs. The new prototype does not yet persist global leaderboards.",
  Settings="Adjust Roblox audio and controls in the built-in settings. More game-specific options will follow.",
  Info="STRENGTH: physical damage. DEFENSE: HP and damage reduction. SPEED: turn order and evasion. INTELLIGENCE: magical damage. LUCK: criticals. CHARISMA: gold and events. HOLINESS: healing.",
 }
 T.label(panel,details[topic] or details.Info,33,90,899,205,{size=19,color=c.white})
 T.button(panel,"BACK",342,367,280,52,function() v.send("BackInfo") end,c.mute)
end
return M
