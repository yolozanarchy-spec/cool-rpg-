--!strict
-- Branching randomized Battle Cry tree. The server is authoritative for unlocks.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local W={};local c=T.c
local positions={{270,100},{620,100},{955,100},
 {270,335},{620,335},{955,335},
 {270,495},{620,495},{955,495}}
function W.Show(v)
 local r=v.state.run;local p=v.root;local st=v.localState
 local bg=S.Box(p,0,0,1280,626,Color3.fromRGB(19,16,12))
 -- Lines first so nodes layer above them.
 local rootX,rootY=620,225
 for branch=1,3 do
  local x,y=positions[branch][1],positions[branch][2]
  S.Line(bg,rootX,rootY,x,y,Color3.fromRGB(61,52,37),7)
  local nx,ny=positions[branch+3][1],positions[branch+3][2]
  S.Line(bg,x,y,nx,ny,Color3.fromRGB(61,52,37),7)
  local fx,fy=positions[branch+6][1],positions[branch+6][2]
  S.Line(bg,nx,ny,fx,fy,Color3.fromRGB(61,52,37),7)
 end
 local center=T.button(bg,"War Cry",rootX-55,rootY-55,110,110,nil,c.yellow,true)
 center.BackgroundColor3=c.yellow;center.TextColor3=Color3.fromRGB(18,17,12);center.TextSize=16
 center.UICorner.CornerRadius=UDim.new(1,0)
 for i,node in ipairs(r.cryNodes or {}) do
  local branch=math.floor((i-1)%3)+1
  local tier=math.floor((i-1)/3)+1
  local x,y=positions[(tier-1)*3+branch][1],positions[(tier-1)*3+branch][2]
  local owned=r.cryOwned[tostring(i)]
  local can=not owned and r.cryPoints>0 and (tier==1 or r.cryOwned[tostring(i-3)])
  local selected=st.cryChoice==i
  local button=T.button(bg,node.name,x-44,y-44,88,88,function()
   st.cryChoice=i
   if can then v.send("CryUnlock",{index=i}) else v.redraw() end
  end,c.gold,selected)
  button.UICorner.CornerRadius=UDim.new(1,0)
  button.BackgroundColor3=owned and Color3.fromRGB(90,69,38) or Color3.fromRGB(42,36,29)
  button.TextColor3=owned and c.yellow or c.white
  button.TextSize=11
  local points=T.rect(bg,x+20,y+23,22,22,Color3.fromRGB(43,32,15),0,11)
  T.label(points,tostring(tier),0,0,22,22,{size=11,bold=true,color=c.yellow,align=Enum.TextXAlignment.Center})
 end
 T.label(bg,"BATTLE CRY  ·  RANDOMIZED TREE",18,9,565,33,{size=20,bold=true,color=c.gold})
 T.label(bg,"Available skill points: "..r.cryPoints,18,40,507,27,{size=14,color=c.yellow})
 local n=st.cryChoice;local node=n and r.cryNodes[n]
 if node then
  local detail=S.Box(bg,1026,17,233,113,Color3.fromRGB(34,29,22))
  T.label(detail,node.name,8,7,214,30,{size=13,bold=true,color=c.yellow})
  T.label(detail,node.desc,9,36,212,68,{size=11,color=c.mute})
 end
 T.label(bg,"Click a node to view or unlock it. Each branch requires the previous tier.",13,591,1150,25,{size=12,color=c.mute})
 S.Gear(v);S.Dock(v)
end
return W
