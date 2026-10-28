--!strict
-- Front-end screens: central menu, three-column creation, events, rewards, death.
local T=require(script.Parent.Kit)
local M={}
local c=T.c
local function runStats(choices,content)
 local s={}
 for _,key in ipairs(content.Stats) do
  s[key]=3+(content.Races[choices.race].stats[key] or 0)+(content.Traits[choices.trait].stats[key] or 0)
 end
 return s
end
function M.Menu(v)
 local p=v.root
 T.label(p,"YOUR ADVENTURE BEGINS",0,119,1280,46,{size=31,bold=true,align=Enum.TextXAlignment.Center,color=c.gold})
 T.label(p,"CREATE A HERO  •  CHOOSE YOUR PATH  •  SURVIVE",0,172,1280,31,{size=15,align=Enum.TextXAlignment.Center,color=c.mute})
 local center=T.panel(p,470,230,340,365,nil)
 local items={{"INFO","Info","Info",c.blue},{"PLAY","Play",nil,c.gold},
  {"MULTIPLAYER","Info","Multiplayer",c.purple},{"ACHIEVEMENTS","Info","Achievements",c.blue},
  {"LEADERBOARD","Info","Leaderboard",c.blue},{"SETTINGS","Info","Settings",c.mute}}
 for i,item in ipairs(items) do
  T.button(center,item[1],32,17+(i-1)*56,276,46,function()
   if item[2]=="Play" then v.send("Play") else v.send("Info",{kind=item[3]}) end
  end,item[4])
 end
 T.label(p,"A turn-based fantasy roguelike inspired by branching adventure RPGs.",255,614,770,31,{size=13,align=Enum.TextXAlignment.Center,color=c.mute})
end
function M.Creation(v)
 local p=v.root;local choice=v.choice;local content=v.content
 T.subtitle(p,"CHARACTER CREATION",40,85,950)
 T.label(p,"Choose one class, one race and one trait. Inspect your final build before continuing.",40,119,1110,28,{size=14,color=c.mute})
 local defs={{"CLASS","class",content.Classes,c.purple},{"RACE","race",content.Races,c.blue},{"TRAIT","trait",content.Traits,c.green}}
 for col,d in ipairs(defs) do
  local x=36+(col-1)*282
  local panel=T.panel(p,x,165,268,426,d[1],d[4])
  local list=T.scroll(panel,12,60,244,350)
  for _,name in ipairs(T.keys(d[3])) do
   local selected=choice[d[2]]==name
   local info=d[2]=="class" and d[3][name] or d[3][name].description
   T.entry(list,name,info,function() choice[d[2]]=name;v.redraw() end,selected and c.gold or d[4],67,selected)
  end
 end
 local view=T.panel(p,882,165,361,426,"CHARACTER PREVIEW",c.gold)
 T.label(view,choice.race.."  "..choice.class,18,61,325,36,{size=21,bold=true,color=c.gold})
 T.label(view,"Trait: "..choice.trait,18,103,325,23,{size=14,color=c.green})
 T.label(view,content.Classes[choice.class],18,134,323,92,{size=14,color=c.mute})
 T.rect(view,17,233,325,1,c.border,.2,false)
 T.label(view,"STARTING ATTRIBUTES",18,242,324,26,{size=14,color=c.gold,bold=true})
 local st=runStats(choice,content)
 for i,key in ipairs(content.Stats) do
  local row=math.floor((i-1)/2);local col=(i-1)%2
  T.label(view,key.."  "..st[key],18+col*166,280+row*29,163,28,{size=13})
 end
 T.button(p,"← BACK",510,611,115,44,function() v.send("BackCreation") end,c.mute)
 T.button(p,"BEGIN ADVENTURE →",640,611,245,44,function() v.send("Confirm",choice) end,c.green)
end
function M.Event(v)
 local s=v.state
 T.subtitle(v.root,"A NEW ENCOUNTER",42,87,600)
 local panel=T.panel(v.root,42,129,1196,482,s.eventName or "Mysterious encounter",c.purple)
 T.label(panel,"An unexpected choice lies along your journey. Your decision may change your rewards or lead directly into combat.",30,66,1090,75,{size=18,color=c.mute})
 local opts=s.eventChoices or {}
 for i,opt in ipairs(opts) do
  T.button(panel,opt.label,40,175+(i-1)*80,420,62,function() v.send("EventChoice",{choice=opt.id}) end,i==#opts and c.mute or c.purple)
 end
 T.panel(panel,516,160,628,256,"THE ROAD AHEAD",c.gold)
 T.label(panel,"There is always a way to walk away from a random encounter. Fighting, bargaining and exploring can have very different results.",544,226,568,112,{size=17,color=c.mute})
end
function M.Reward(v)
 local s=v.state;local r=s.reward;local p=v.root
 T.subtitle(p,"ENCOUNTER COMPLETE",48,84,900)
 local rewards=T.panel(p,48,360,1185,266,"REWARDS",c.green)
 T.label(rewards,r.summary or "You survived.",23,57,1070,36,{size=19,bold=true})
 T.label(rewards,"+"..(r.xp or 0).." EXP",24,112,240,33,{size=23,bold=true,color=c.blue})
 T.label(rewards,"+"..(r.gold or 0).." GOLD",275,112,258,33,{size=23,bold=true,color=c.gold})
 T.label(rewards,(r.item and r.item~="") and ("ITEM FOUND  •  "..r.item) or "NO ITEM FOUND",541,112,600,33,{size=16,color=c.mute})
 T.button(rewards,r.selected and "CONTINUE TO CAMP →" or "CHOOSE AN UPGRADE ABOVE",440,202,307,44,function()
  if r.selected then v.send("Continue") end
 end,r.selected and c.green or c.mute)
 if r.levelUps>0 then
  local upgradePanel=T.panel(p,48,125,1185,219,"LEVEL UP!  •  CHOOSE ONE UPGRADE",c.gold)
  for i,u in ipairs(r.choices or {}) do
   local x=23+(i-1)*386
   local card=T.button(upgradePanel,u.name,x,67,367,53,function()
    if not r.selected then v.send("Upgrade",{name=u.name}) end
   end,r.selected and c.mute or c.gold)
   T.label(upgradePanel,u.desc,x+11,128,345,57,{size=15,color=c.mute})
  end
 else
  local top=T.panel(p,48,125,1185,219,"JOURNEY PROGRESS",c.gold)
  T.label(top,"No level-up this time. Return to camp to manage inventory, skills and your class ability.",25,80,1120,70,{size=18,color=c.mute})
 end
end
function M.Finale(v)
 local p=v.root;local r=v.state.run;local dead=v.state.phase=="Death"
 local panel=T.panel(p,250,155,780,400,dead and "YOUR JOURNEY HAS ENDED" or "VICTORY!",dead and c.red or c.gold)
 T.label(panel,dead and "YOU HAVE FALLEN" or "THE FINAL BOSS IS DEFEATED",25,75,730,65,{size=29,bold=true,align=Enum.TextXAlignment.Center,color=dead and c.red or c.gold})
 T.label(panel,"Level "..r.level.."     •     "..r.kills.." foes defeated     •     "..r.wins.." combats won",60,155,660,55,{size=17,color=c.mute,align=Enum.TextXAlignment.Center})
 T.button(panel,"START NEW GAME",211,266,358,51,function() v.send("NewRun") end,c.green)
end
function M.Info(v)
 local s=v.state;local topic=s.info or "INFO"
 local panel=T.panel(v.root,178,117,926,492,topic:upper(),c.blue)
 local copy={
  Multiplayer="Multiplayer is not playable in this first prototype. Synchronized parties and four-player combat require a future server update.",
  Achievements="Achievements can eventually unlock classes, races, traits, and special starting options. This early build does not persist those unlocks.",
  Leaderboard="Longest-run leaderboards are planned. Global ranking and DataStore persistence have not been implemented in this prototype.",
  Settings="The in-game settings panel is planned. You can adjust game audio and graphics through Roblox's built-in settings menu.",
  Info="STRENGTH increases physical damage. DEFENSE increases health and damage reduction. SPEED influences evasion. INTELLIGENCE increases magic damage and MP. LUCK influences critical hits. CHARISMA supports economy and encounters. HOLINESS improves healing and holy effects.",
 }
 T.label(panel,copy[topic] or copy.Info,40,91,838,217,{size=19,color=c.mute})
 T.button(panel,"← BACK",341,385,246,48,function() v.send("BackInfo") end,c.blue)
end
return M
