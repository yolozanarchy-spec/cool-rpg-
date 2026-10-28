--!strict
-- Brown/gold Bazaar stock list, item details, refresh and purchase.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local M={};local c=T.c
function M.Show(v)
 local r=v.state.run;local st=v.localState;local p=v.root
 local shell=S.Box(p,9,8,1262,611,c.shopDark)
 T.make("UIStroke",shell,{Color=Color3.fromRGB(88,62,29),Thickness=1})
 local left=S.Box(shell,10,4,699,538,c.shop)
 local right=S.Box(shell,731,4,518,538,c.shop)
 T.make("UIStroke",right,{Color=Color3.fromRGB(103,66,29),Thickness=1})
 local listing=S.Scroll(left,11,11,676,465)
 local shop=v.state.shop or {};local selected=shop[st.shopIndex]
 for i,entry in ipairs(shop) do
  local itm=v.content.Items[entry.name]
  local row=T.entry(listing,"📦  "..entry.name, (itm and itm.kind or "Item").."     "..entry.price.."g",
   function()st.shopIndex=i;v.redraw()end,c.gold,54,st.shopIndex==i)
  row.BackgroundColor3=st.shopIndex==i and Color3.fromRGB(88,68,41) or Color3.fromRGB(56,40,23)
 end
 if #shop==0 then T.copy(listing,"The shop has no remaining stock.",60,c.mute) end
 if r.class=="Merchant" then
  local refresh=T.button(left,"⟳  Refresh Shop",12,478,300,34,function()v.send("RefreshShop")end,c.gold)
  refresh.BackgroundColor3=Color3.fromRGB(72,49,22)
  T.label(left,"Refresh: 20 MP",327,480,298,30,{size=12,color=c.gold})
 end
 if selected then
  local item=v.content.Items[selected.name]
  T.label(right,"📦  "..selected.name,14,15,489,43,{size=19,bold=true,color=c.gold})
  T.label(right,"Type: "..(item and item.kind or "Item"),14,71,484,32,{size=15,color=c.mute})
  T.label(right,item and item.stat and ("+"..item.bonus.." "..item.stat) or "Supplies for your adventure",14,109,482,55,{size=15,color=c.green})
  T.label(right,"Price: "..selected.price.." gold",14,172,483,31,{size=16,bold=true,color=c.yellow})
  local buy=T.button(right,"BUY",350,469,149,42,function()v.send("Buy",{index=st.shopIndex})end,c.green)
  buy.BackgroundColor3=r.gold>=selected.price and Color3.fromRGB(63,100,54) or c.raised
 else
  T.label(right,"Select an item...",12,18,480,34,{size=17,bold=true,color=c.gold})
 end
 local bottom=S.Box(shell,10,545,1239,57,Color3.fromRGB(54,36,20))
 T.label(bottom,"🪙  "..r.gold.."g",12,8,180,31,{size=14,bold=true,color=c.yellow})
 T.label(bottom,"MP: "..r.mp.." / "..(v.state.stats and v.state.stats.MaxMP or r.mp),1069,8,151,29,{size=13,color=c.blue,align=Enum.TextXAlignment.Right})
 S.Dock(v);S.Gear(v)
end
return M
