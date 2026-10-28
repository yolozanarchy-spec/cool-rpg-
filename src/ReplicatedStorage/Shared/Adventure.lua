--!strict
local A={}
local TYPES={"Combat","Combat","Combat","Combat","Combat","Event","Event","Event","Merchant","Rest","Special"}
function A.Generate()
 local map={rows={},row=1,available={1,2,3},history={},selected=nil,completed=false}
 for row=1,10 do
  local nodes={}
  local count=(row==10 and 1 or 3)
  for i=1,count do
   local kind=row==10 and "Boss" or TYPES[math.random(#TYPES)]
   local targets={}
   if row==9 then targets={1}
   elseif row<9 then
    -- Always connect to the same column, with random side branches.
    targets={i}
    for t=1,3 do if t~=i and math.abs(t-i)<=1 and math.random()<.38 then table.insert(targets,t) end end
   end
   nodes[i]={id=row.."-"..i,kind=kind,col=i,links=targets}
  end
  map.rows[row]=nodes
 end
 return map
end
function A.Allowed(map,index)
 if typeof(index)~="number" or index%1~=0 then return false end
 return map.selected==nil and table.find(map.available,index)~=nil and map.rows[map.row] and map.rows[map.row][index]~=nil
end
function A.Choose(map,index)
 if not A.Allowed(map,index) then return nil end
 map.selected=index
 return map.rows[map.row][index].kind
end
function A.Finish(map)
 if not map.selected then return false end
 local node=map.rows[map.row][map.selected]
 table.insert(map.history,{row=map.row,col=map.selected,kind=node.kind})
 map.available=table.clone(node.links)
 map.selected=nil
 map.row+=1
 if map.row>10 then map.completed=true end
 return true
end
function A.RandomEvent()
 local options={"Treasure","Mysterious Stranger","Ancient Shrine","Training Ground","Forgotten Crypt","Bandit Ambush"}
 return options[math.random(#options)]
end
function A.EventChoices(name)
 if name=="Treasure" then return {{id="open",label="Open the chest (+gold, materials)"},{id="skip",label="Leave it"}} end
 if name=="Mysterious Stranger" then return {{id="talk",label="Talk cautiously (+XP)"},{id="fight",label="Attack (combat)"},{id="skip",label="Ignore and return"}} end
 if name=="Ancient Shrine" then return {{id="pray",label="Pray for a blessing"},{id="curse",label="Accept power and a curse"},{id="skip",label="Pass by"}} end
 if name=="Training Ground" then return {{id="train",label="Train (+XP)"},{id="rest",label="Rest (+HP)"},{id="skip",label="Leave"}} end
 if name=="Forgotten Crypt" then return {{id="loot",label="Search for relics (+loot, risk)"},{id="skip",label="Leave"}} end
 return {{id="fight",label="Fight the bandits"},{id="bribe",label="Pay 20 gold to escape"},{id="skip",label="Sneak away"}}
end
return A
