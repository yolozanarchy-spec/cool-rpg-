--!strict
-- Screen reference: grouped recipe list on left, requirements on right.
local T=require(script.Parent.Kit)
local S=require(script.Parent.Shell)
local C={};local c=T.c
local function category(name,kind)
 if kind=="Weapon" or kind=="Shield" or kind=="Armor" then return "Weapons" end
 if kind=="Consumable" then return "Consumables" end
 return "Materials"
end
function C.Show(v)
 local p=v.root;local r=v.state.run;local st=v.localState
 local left=S.Box(p,7,13,518,604,Color3.fromRGB(29,29,30))
 local right=S.Box(p,548,13,724,604,Color3.fromRGB(30,30,31))
 local sc=S.Scroll(left,7,13,504,575)
 local groups={"Weapons","Consumables","Materials"};local found=false
 for _,group in ipairs(groups) do
  T.copy(sc,group,28,c.gold);found=true
  S.Separator(sc,0,0,470)
  for _,recipe in ipairs(v.content.Recipes) do
   local item=v.content.Items[recipe.name]
   if item and category(recipe.name,item.kind)==group then
    local ready=true
    for material,number in pairs(recipe.need) do
     if (r.inventory[material] or 0)<number then ready=false end
    end
    local row=T.entry(sc,recipe.name,group.."  ·  Workbench",function()
     st.selectedRecipe=recipe.name;v.redraw()
    end,ready and c.blue or c.red,52,st.selectedRecipe==recipe.name)
    row.BackgroundColor3=st.selectedRecipe==recipe.name and Color3.fromRGB(61,94,121)
     or ready and Color3.fromRGB(37,56,66) or Color3.fromRGB(49,29,30)
   end
  end
 end
 if not found then T.copy(sc,"No recipes available",40,c.mute) end
 local selected=st.selectedRecipe
 local recipe=nil
 for _,item in ipairs(v.content.Recipes) do if item.name==selected then recipe=item end end
 if recipe then
  T.label(right,recipe.name,12,14,693,29,{size=16,bold=true,color=c.yellow})
  T.label(right,"Category: "..category(recipe.name,v.content.Items[recipe.name].kind).."  |  Station: Workbench",12,42,692,28,{size=12,color=c.mute})
  T.label(right,"Ingredients:",12,74,686,25,{size=13,bold=true})
  local names=T.keys(recipe.need);local can=true
  for i,name in ipairs(names) do
   local count=r.inventory[name] or 0;local need=recipe.need[name]
   if count<need then can=false end
   T.label(right,name.." ("..count.."/"..need..")",12,101+(i-1)*29,680,26,
    {size=13,color=count>=need and c.green or c.red})
  end
  T.label(right,"Result: "..recipe.name.." ×"..(recipe.qty or 1),12,223,689,30,{size=14,color=c.gold})
  T.button(right,can and "CRAFT ITEM" or "MISSING MATERIALS",474,542,231,41,
   function()if can then v.send("Craft",{name=recipe.name}) end end,can and c.green or c.mute)
 else
  T.label(right,"Select a recipe",16,18,660,34,{size=21,bold=true,color=c.mute})
  T.label(right,"Choose a recipe from the list to see its ingredients and result.",17,60,665,55,{size=14,color=c.mute})
 end
 S.Gear(v);S.Dock(v)
end
return C
