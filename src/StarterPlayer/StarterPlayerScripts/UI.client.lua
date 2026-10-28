--!strict
-- Cool RPG 0.2: references the yolo game.pdf UI diagrams, no external assets.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remote=ReplicatedStorage:WaitForChild("RPGRequest")
local Content=require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Content"))
local Views=script.Parent:WaitForChild("Views")
local T=require(Views:WaitForChild("Kit"))
local Menus=require(Views:WaitForChild("Menus"))
local Camp=require(Views:WaitForChild("Camp"))
local Combat=require(Views:WaitForChild("Combat"))
local Class=require(Views:WaitForChild("Class"))
local gui=T.make("ScreenGui",Players.LocalPlayer:WaitForChild("PlayerGui"),{
 Name="CoolRPG",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10})
local canvas=T.rect(gui,0,0,1280,720,T.c.bg,0,false)
canvas.AnchorPoint=Vector2.new(.5,.5)
canvas.Position=UDim2.fromScale(.5,.5)
T.make("UIGradient",canvas,{Rotation=20,Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(13,18,31)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(34,27,45))})})
local scale=T.make("UIScale",canvas,{Scale=1})
local function resize()
 local camera=workspace.CurrentCamera
 if not camera then return end
 scale.Scale=math.min(camera.ViewportSize.X/1280,camera.ViewportSize.Y/720)
end
resize()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
local main=T.rect(canvas,0,0,1280,720,T.c.bg,1,false)
local current={phase="Menu"}
local choice={race="Human",class="Warrior",trait="Balanced"}
local draft={area=false,element="Fire",effect="None"}
local localState={target=1,combatTab="Actions"}
local busy=false
local render
local function clear()
 for _,obj in ipairs(main:GetChildren()) do obj:Destroy() end
end
local function send(op,data)
 if busy then return end
 busy=true
 local previous=current.phase
 local ok,result=pcall(function() return remote:InvokeServer(op,data or {}) end)
 busy=false
 if ok and typeof(result)=="table" then
  current=result
  if current.phase~=previous then
   localState.combatTab="Actions"
   if current.phase=="Combat" then localState.target=1 end
  end
 else current.message="Could not reach the server. See Roblox Studio Output." end
 render()
end
render=function()
 clear()
 local top=T.rect(main,0,0,1280,66,T.c.panel,0,false)
 T.rect(top,0,64,1280,2,T.c.gold,.16,false)
 T.label(top,"◈ COOL RPG",28,8,390,49,{size=26,bold=true,color=T.c.gold})
 local phase=current.phase or "Menu"
 local title=({Menu="FANTASY ROGUELIKE",Creation="CREATE YOUR HERO",Camp="CAMPSITE",Map="ADVENTURE MAP",
  Combat="COMBAT",Event="RANDOM EVENT",Reward="ENCOUNTER REWARDS",Inventory="INVENTORY",Crafting="CRAFTING",
  Skills="SKILLS",Class="CLASS ABILITY",Merchant="SHOP",Stats="CHARACTER INFO",Codex="CODEX",
  Info="INFORMATION",Victory="VICTORY",Death="DEFEAT"})[phase] or phase:upper()
 T.label(top,title,407,9,464,46,{size=16,bold=true,align=Enum.TextXAlignment.Center,color=T.c.white})
 if phase~="Info" and phase~="Menu" and phase~="Creation" then
  T.button(top,"SETTINGS",1127,12,135,39,function() send("Info",{kind="Settings"}) end,T.c.mute)
 end
 local view={root=main,state=current,send=send,redraw=render,choice=choice,draft=draft,
  localState=localState,content=Content}
 if phase=="Menu" then Menus.Menu(view)
 elseif phase=="Creation" then Menus.Creation(view)
 elseif phase=="Camp" then Camp.Camp(view)
 elseif phase=="Map" then Camp.Map(view)
 elseif phase=="Combat" then Combat.Show(view)
 elseif phase=="Event" then Menus.Event(view)
 elseif phase=="Reward" then Menus.Reward(view)
 elseif phase=="Inventory" then Camp.Inventory(view)
 elseif phase=="Crafting" then Camp.Crafting(view)
 elseif phase=="Skills" then Camp.Skills(view)
 elseif phase=="Class" then Class.Show(view)
 elseif phase=="Stats" then Camp.Stats(view)
 elseif phase=="Codex" then Camp.Codex(view)
 elseif phase=="Merchant" then Camp.Merchant(view)
 elseif phase=="Info" then Menus.Info(view)
 elseif phase=="Victory" or phase=="Death" then Menus.Finale(view)
 end
 local bottom=T.rect(main,0,690,1280,30,T.c.panel,.03,false)
 T.label(bottom,(current.message and current.message~="" and current.message) or "COOL RPG   •   2D TURN-BASED ROGUELIKE   •   UI 0.2",22,0,1210,30,{size=12,color=T.c.mute,truncate=true})
end
local ok,result=pcall(function() return remote:InvokeServer("Poll") end)
if ok and typeof(result)=="table" then current=result end
render()
