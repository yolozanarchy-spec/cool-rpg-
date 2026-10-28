--!strict
-- Config only: class/race/trait choices, items, blessings and upgrades.
local D = {}
D.Stats = {"Strength","Defense","Speed","Intelligence","Luck","Charisma","Holiness"}
D.Races = {
 Human = {description="Versatile explorer", stats={Strength=2,Defense=2,Speed=2,Intelligence=2,Luck=2,Charisma=2,Holiness=2}},
 Elf = {description="Magical and swift", stats={Intelligence=5,Speed=4,Luck=3}},
 Dwarf = {description="Durable frontliner", stats={Strength=4,Defense=5}},
 Orc = {description="Powerful physical fighter", stats={Strength=6}},
}
D.Traits = {
 Lucky={description="+3 Luck and improved loot", stats={Luck=3}},
 ["Glass Cannon"]={description="+40% damage; -20% maximum HP", stats={}},
 Tough={description="+10 HP, +3 Defense, +1 Strength", stats={Defense=3,Strength=1}},
 Swift={description="+3 Speed", stats={Speed=3}},
 Brilliant={description="+3 Intelligence", stats={Intelligence=3}},
 Charismatic={description="+3 Charisma", stats={Charisma=3}},
 Holy={description="+3 Holiness", stats={Holiness=3}},
 Balanced={description="+1 to every attribute", stats={Strength=1,Defense=1,Speed=1,Intelligence=1,Luck=1,Charisma=1,Holiness=1}},
}
D.Classes = {
 Warrior="Randomized Battle Cry skill tree. Earn points as you level and unlock new effects.",
 Mage="Build your own spell by selecting range and elemental effects within a ten-point budget.",
 Hunter="Each enemy killed grants a trophy. Prepare traps and complete bounty board contracts.",
 Necromancer="Build a zombie companion by equipping fallen monsters' body parts.",
 Paladin="Earn and stack unlimited blessings. Cleanse curses with Divine Charges.",
 Merchant="Open a traveling shop at camp and refresh its stock with MP.",
}
D.Items = {
 ["Stick"]={kind="Weapon",price=3,stat="Strength",bonus=1},
 ["Iron Sword"]={kind="Weapon",price=55,stat="Strength",bonus=3},
 ["Steel Sword"]={kind="Weapon",price=95,stat="Strength",bonus=5},
 ["Nature Staff"]={kind="Weapon",price=85,stat="Intelligence",bonus=4},
 ["Bone Bow"]={kind="Weapon",price=85,stat="Speed",bonus=4},
 ["Wooden Shield"]={kind="Shield",price=45,stat="Defense",bonus=3},
 ["Leather Armor"]={kind="Armor",price=65,stat="Defense",bonus=4},
 ["Knight Armor"]={kind="Armor",price=180,stat="Defense",bonus=8},
 ["Lucky Ring"]={kind="Ring",price=100,stat="Luck",bonus=4},
 ["Health Potion"]={kind="Consumable",price=25,heal=30},
 ["Major Health Potion"]={kind="Consumable",price=55,heal=60},
 ["Mana Potion"]={kind="Consumable",price=25,mana=20},
 ["Antidote"]={kind="Consumable",price=20,cure="Poison"},
 ["Iron Ore"]={kind="Material",price=8},
 ["Oak Wood"]={kind="Material",price=7},
 ["Herbs"]={kind="Material",price=6},
 ["Wolf Pelt"]={kind="Material",price=10},
 ["Goblin Tooth"]={kind="Material",price=10},
 ["Bone Fragment"]={kind="Part",price=10,stat="Defense",bonus=2},
 ["Wolf Fang"]={kind="Part",price=12,stat="Strength",bonus=2},
 ["Venom Sac"]={kind="Part",price=20,stat="Intelligence",bonus=2},
 ["Dragon Scale"]={kind="Part",price=90,stat="Defense",bonus=7},
 ["Rabbit Hide"]={kind="Material",price=8},
 ["Spider Silk"]={kind="Material",price=12},
 ["Monster Essence"]={kind="Part",price=15,stat="Strength",bonus=1},
 ["Bone Arrows"]={kind="Material",price=14},
 ["Bone Glue"]={kind="Material",price=9},
 ["Bone Plate"]={kind="Material",price=16},
}
D.Recipes = {
 {name="Bone Bow",need={["Bone Fragment"]=4,["Spider Silk"]=1},qty=1},
 {name="Bone Arrows",need={["Bone Fragment"]=2,["Oak Wood"]=1},qty=2},
 {name="Bone Glue",need={["Bone Fragment"]=1,["Herbs"]=1},qty=1},
 {name="Bone Plate",need={["Bone Fragment"]=3,["Bone Glue"]=1},qty=1},
 {name="Health Potion",need={Herbs=2},qty=1},
 {name="Iron Sword",need={["Iron Ore"]=3,["Oak Wood"]=1},qty=1},
 {name="Wooden Shield",need={["Oak Wood"]=3},qty=1},
 {name="Leather Armor",need={["Wolf Pelt"]=2,["Rabbit Hide"]=1},qty=1},
 {name="Steel Sword",need={["Iron Ore"]=5,["Goblin Tooth"]=1},qty=1},
}
D.Blessings={
 ["Blessing of Strength"]={text="+20% Strength", stat="Strength",percent=.20},
 ["Blessing of Fortune"]={text="+15% Luck", stat="Luck",percent=.15},
 ["Blessing of Light"]={text="+25% Holiness", stat="Holiness",percent=.25},
 ["Blessing of Wisdom"]={text="+20% Intelligence",stat="Intelligence",percent=.20},
 ["Blessing of Valor"]={text="+25% Defense",stat="Defense",percent=.25},
 ["Blessing of Purity"]={text="+25% Holiness",stat="Holiness",percent=.25},
}
D.Curses={
 ["Curse of Weakness"]={stat="Strength",percent=-.20},
 ["Curse of Slowness"]={stat="Speed",percent=-.30},
 ["Curse of Frailty"]={stat="Defense",percent=-.20},
 ["Curse of Misfortune"]={stat="Luck",percent=-.30},
}
D.Upgrades={
 {name="Vigor",desc="+15 maximum HP", bonusHP=15},
 {name="Power",desc="+3 Strength",stat="Strength",amount=3},
 {name="Fortitude",desc="+3 Defense",stat="Defense",amount=3},
 {name="Swiftness",desc="+4 Speed",stat="Speed",amount=4},
 {name="Fortune",desc="+5 Luck",stat="Luck",amount=5},
 {name="Brilliance",desc="+3 Intelligence",stat="Intelligence",amount=3},
 {name="Faith",desc="+3 Holiness",stat="Holiness",amount=3},
 {name="Charm",desc="+3 Charisma",stat="Charisma",amount=3},
 {name="Iron Skin",desc="+10 HP, +5 Defense",bonusHP=10,stat="Defense",amount=5},
 {name="Lifesteal",desc="Heal 15% damage dealt",flag="Lifesteal"},
 {name="Berserker's Fury",desc="Deal 30% more damage; take 10% more",flag="Berserker"},
 {name="Fortify",desc="Take 15% less damage",flag="Fortify"},
}
D.CryNodes={
 {name="Rallying Roar",desc="Battle Cry adds +15% damage",power=.15},
 {name="Iron Chorus",desc="Battle Cry grants 6 barrier",barrier=6},
 {name="War Drums",desc="Battle Cry grants 3 Speed",speed=3},
 {name="Bloody Oath",desc="Battle Cry restores 6 HP",heal=6},
 {name="Thunder Shout",desc="Battle Cry deals 6 damage to foes",blast=6},
 {name="Stalwart Call",desc="Battle Cry grants 4 Defense",defense=4},
 {name="Endless Echo",desc="Battle Cry duration +1 turn",duration=1},
 {name="Overwhelming Voice",desc="Battle Cry damage +10%",power=.10},
 {name="Last Stand",desc="Battle Cry restores 8 HP",heal=8},
 {name="War Banner",desc="Battle Cry grants 4 barrier",barrier=4},
 {name="Death Knell",desc="Battle Cry blasts for 4 more damage",blast=4},
}
D.BaseSkills={
 Warrior={"Power Strike","Battle Cry"}, Mage={"Fireball","Crafted Spell"},
 Hunter={"Sniper Shot","Volley"}, Necromancer={"Soul Bolt","Zombie Strike"},
 Paladin={"Holy Light","Smite"}, Merchant={"Throw Gold","Coin Flick"},
}
return D
