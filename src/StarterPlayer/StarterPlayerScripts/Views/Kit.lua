--!strict
-- Reusable, client-only dark-fantasy GUI primitives. Base canvas: 1280 x 720.
local T = {}
-- Original gamerpGggg.rbxl palette: main #14141E, camp #161616,
-- UI panels #1E1E1E, muted buttons #2D2D2D and green primary #329632.
T.c = {
 bg=Color3.fromRGB(20,20,30), panel=Color3.fromRGB(30,30,35),
 raised=Color3.fromRGB(45,45,53), soft=Color3.fromRGB(58,57,68),
 border=Color3.fromRGB(75,73,87), white=Color3.fromRGB(239,238,244),
 mute=Color3.fromRGB(164,162,180), gold=Color3.fromRGB(213,187,108),
 green=Color3.fromRGB(73,167,94), red=Color3.fromRGB(187,76,81),
 blue=Color3.fromRGB(86,124,192), purple=Color3.fromRGB(130,105,172),
}

function T.make(class, parent, props)
 local o=Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent
 return o
end
function T.rect(parent,x,y,w,h,color,alpha,radius)
 local f=T.make("Frame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color or T.c.panel,BackgroundTransparency=alpha or 0,BorderSizePixel=0})
 if radius ~= false then T.make("UICorner",f,{CornerRadius=UDim.new(0,radius or 10)}) end
 return f
end
function T.stroke(parent,color,thickness)
 return T.make("UIStroke",parent,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=color or T.c.border,Transparency=.45,Thickness=thickness or 1})
end
function T.panel(parent,x,y,w,h,title,accent)
 local p=T.rect(parent,x,y,w,h,T.c.panel,.01,6)
 T.stroke(p)
 if title then
  T.label(p,title,17,11,w-34,31,{size=18,bold=true,color=accent or T.c.gold})
  T.rect(p,17,48,w-34,1,T.c.border,.35,false)
 end
 return p
end
function T.label(parent,text,x,y,w,h,opt)
 opt=opt or {}
 return T.make("TextLabel",parent,{
  Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
  BackgroundTransparency=1,Text=tostring(text),Font=opt.bold and Enum.Font.GothamBold or Enum.Font.Gotham,
  TextSize=opt.size or 15,TextColor3=opt.color or T.c.white,
  TextWrapped=opt.wrap ~= false,TextXAlignment=opt.align or Enum.TextXAlignment.Left,
  TextYAlignment=opt.valign or Enum.TextYAlignment.Center,
  TextTruncate=opt.truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
 })
end
function T.button(parent,text,x,y,w,h,callback,accent,selected)
 local color=selected and Color3.fromRGB(63,70,69) or T.c.raised
 local b=T.make("TextButton",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
  BackgroundColor3=color,BorderSizePixel=0,AutoButtonColor=true,Text=tostring(text),
  Font=Enum.Font.GothamSemibold,TextSize=15,TextColor3=T.c.white,TextWrapped=true})
 T.make("UICorner",b,{CornerRadius=UDim.new(0,5)})
 T.stroke(b,selected and (accent or T.c.gold) or T.c.border,selected and 2 or 1)
 -- Flat button treatment matching the original UI; no ornamental side stripe.
 if selected then T.rect(b,0,h-3,w,3,accent or T.c.green,0,false) end
 if callback then b.Activated:Connect(callback) end
 return b
end
function T.scroll(parent,x,y,w,h)
 local sf=T.make("ScrollingFrame",parent,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
  BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),
  AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
  ScrollBarThickness=5,ScrollBarImageColor3=T.c.gold,ClipsDescendants=true})
 T.make("UIListLayout",sf,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)})
 T.make("UIPadding",sf,{PaddingBottom=UDim.new(0,9),PaddingRight=UDim.new(0,8)})
 return sf
end
function T.entry(scroll,title,detail,callback,accent,height,selected)
 height=height or (detail and 68 or 46)
 local b=T.make("TextButton",scroll,{Size=UDim2.new(1,-3,0,height),BackgroundColor3=selected and T.c.soft or T.c.raised,
  BorderSizePixel=0,Text="",AutoButtonColor=callback~=nil})
 T.make("UICorner",b,{CornerRadius=UDim.new(0,5)})
 T.stroke(b,selected and (accent or T.c.gold) or T.c.border,selected and 2 or 1)
 if selected then T.rect(b,0,height-3,4,3,accent or T.c.green,0,false) end
 T.label(b,title,14,4,1000,detail and 28 or height-8,{size=15,bold=true,truncate=true})
 -- The label must fit the list's current width rather than overflow.
 local titleLabel=b:FindFirstChildOfClass("TextLabel")
 if titleLabel then titleLabel.Size=UDim2.new(1,-27,0,detail and 29 or height-8) end
 if detail then T.label(b,detail,14,33,1,25,{size=12,color=T.c.mute,truncate=true}).Size=UDim2.new(1,-27,0,25) end
 if callback then b.Activated:Connect(callback) end
 return b
end
function T.copy(parent,text,height,color)
 local label=T.make("TextLabel",parent,{Size=UDim2.new(1,-12,0,height or 34),BackgroundTransparency=1,
  Text=tostring(text),TextSize=14,Font=Enum.Font.Gotham,TextColor3=color or T.c.mute,
  TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center})
 return label
end
function T.progress(parent,x,y,w,h,now,max,color)
 T.rect(parent,x,y,w,h,T.c.soft,0,4)
 local fraction=math.clamp((now or 0)/math.max(1,max or 1),0,1)
 if fraction>0 then T.rect(parent,x,y,math.max(2,w*fraction),h,color or T.c.green,0,4) end
end
function T.keys(dict)
 local out={}
 for k in pairs(dict or {}) do table.insert(out,k) end
 table.sort(out)
 return out
end
function T.subtitle(parent,text,x,y,w)
 T.label(parent,text,x,y,w or 950,26,{size=17,bold=true,color=T.c.gold})
end
function T.sheet(parent,run,stats,x,y,w,h)
 local p=T.panel(parent,x,y,w,h,"CHARACTER INFO",T.c.gold)
 if not run then return p end
 T.label(p,run.race.."  /  "..run.class,16,53,w-32,28,{size=15,bold=true})
 T.label(p,"LV "..run.level.."    XP "..run.xp.."/"..(run.level*35),16,84,w-32,22,{size=13,color=T.c.mute})
 T.label(p,"HP  "..run.hp.." / "..stats.MaxHP,16,111,w-32,22,{size=13,color=T.c.green})
 T.progress(p,16,137,w-32,9,run.hp,stats.MaxHP,T.c.green)
 T.label(p,"MP  "..run.mp.." / "..stats.MaxMP,16,153,w-32,21,{size=13,color=T.c.blue})
 T.progress(p,16,178,w-32,8,run.mp,stats.MaxMP,T.c.blue)
 T.label(p,"GOLD  "..run.gold,16,195,w-32,26,{size=14,bold=true,color=T.c.gold})
 T.rect(p,16,228,w-32,1,T.c.border,.25,false)
 T.label(p,"MAIN STATS",16,234,w-32,29,{size=14,bold=true,color=T.c.gold})
 for i,key in ipairs({"Strength","Defense","Speed","Intelligence","Luck","Charisma","Holiness"}) do
  T.label(p,key,17,263+(i-1)*26,w-80,25,{size=13,color=T.c.mute})
  T.label(p,tostring(stats[key] or 0),w-67,263+(i-1)*26,47,25,{size=14,bold=true,align=Enum.TextXAlignment.Right})
 end
 T.rect(p,16,457,w-32,1,T.c.border,.25,false)
 T.label(p,"MORE INFO",16,462,w-32,29,{size=14,bold=true,color=T.c.gold})
 T.label(p,"Kills: "..run.kills.."   Wins: "..run.wins.."   Bosses: "..run.bosses,16,492,w-30,24,{size=12,color=T.c.mute})
 return p
end
return T
