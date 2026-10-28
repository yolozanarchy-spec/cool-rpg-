--!strict
-- Screenshot: dark map board, circular color-coded nodes and connected paths.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local M={};local c=T.c
local colors={Combat=Color3.fromRGB(196,51,55),Event=Color3.fromRGB(59,59,63),
 Merchant=Color3.fromRGB(54,54,60),Special=Color3.fromRGB(75,54,95),
 Rest=Color3.fromRGB(57,90,69),Boss=Color3.fromRGB(57,75,169)}
local icons={Combat="⚔",Event="?",Merchant="$",Rest="♨",Special="✦",Boss="♛"}
local function coords(col,row)
 -- Slight row-based horizontal drift gives the branching map screenshot appearance.
 local drift=math.sin(row*2.3)*48
 return 225+(col-1)*420+drift,554-(row-1)*50
end
function M.Show(v)
 local map=v.state.map; local p=v.root
 local top=T.rect(p,0,0,1280,80,c.bg,0,false)
 local back=T.button(top,"Back",8,12,152,39,function()v.send("BackCamp")end,c.red)
 back.BackgroundColor3=Color3.fromRGB(118,41,43);back.TextSize=25
 T.label(top,"Stage 1\nAncient Ruins",180,9,168,54,{size=13,bold=true,color=c.yellow,align=Enum.TextXAlignment.Center})
 T.label(top,"Floor "..map.row.." / 10",375,4,518,60,{size=26,bold=true,align=Enum.TextXAlignment.Center})
 T.label(top,"Boss in "..(11-map.row).." Floors",888,4,367,60,{size=24,bold=true,color=c.purple,align=Enum.TextXAlignment.Center})
 local board=S.Box(p,88,109,1104,566,Color3.fromRGB(28,32,36))
 local sf=T.make("ScrollingFrame",board,{Position=UDim2.fromOffset(2,6),Size=UDim2.fromOffset(1097,549),
  BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,560),
  ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,ScrollBarImageColor3=c.border})
 local completed={}
 for _,e in ipairs(map.history or {}) do completed[e.row.."-"..e.col]=true end
 -- Keep the path behind the clickable nodes.
 for row=1,9 do
  for _,node in ipairs(map.rows[row]) do
   local ax,ay=coords(node.col,row)
   for _,dest in ipairs(node.links) do
    local bx,by=coords(dest,row+1)
    S.Line(sf,ax,ay,bx,by,Color3.fromRGB(151,150,157),4)
   end
  end
 end
 for row=1,10 do
  for _,node in ipairs(map.rows[row]) do
   local x,y=coords(node.col,row)
   local can=row==map.row and table.find(map.available,node.col)~=nil
   local done=completed[row.."-"..node.col]
   local shade=can and Color3.fromRGB(199,56,59) or done and Color3.fromRGB(73,111,83)
    or colors[node.kind] or c.raised
   local button=T.make("TextButton",sf,{Position=UDim2.fromOffset(x-36,y-36),Size=UDim2.fromOffset(72,72),
    BackgroundColor3=shade,BorderSizePixel=0,Font=Enum.Font.GothamBold,Text=done and "✓" or icons[node.kind] or "?",
    TextSize=31,TextColor3=c.white,AutoButtonColor=can})
   T.make("UICorner",button,{CornerRadius=UDim.new(1,0)})
   if can then T.make("UIStroke",button,{Color=Color3.fromRGB(245,92,94),Thickness=2}) end
   button.Activated:Connect(function()if can then v.send("ChooseNode",{index=node.col})end end)
  end
 end
end
return M
