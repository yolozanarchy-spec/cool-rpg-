--!strict
-- Values transcribed from the supplied catalog. Skills simplified in first build.
local E = { Normal = {}, Boss = {}, Elite = {} }
E.Normal["Rabbit"]={level=1,hp=20,attack=5,defense=1,speed=12,luck=10,skills={"Bite","Hop"}}
E.Normal["Slime"]={level=1,hp=25,attack=3,defense=5,speed=2,luck=2,skills={"AcidSpit"}}
E.Normal["Goblin"]={level=2,hp=35,attack=8,defense=4,speed=6,luck=3,skills={"Bite","ClubSwing"}}
E.Normal["Wolf"]={level=3,hp=30,attack=8,defense=3,speed=7,luck=5,skills={"Bite","Howl"}}
E.Normal["Plague Rat"]={level=2,hp=20,attack=6,defense=1,speed=12,luck=3,skills={"Infect","Bite","DiseaseCloud"}}
E.Normal["Zombie"]={level=2,hp=35,attack=8,defense=2,speed=4,luck=2,skills={"DiseaseBite","Regenerate","Grab"}}
E.Normal["Forest Spider"]={level=3,hp=30,attack=6,defense=2,speed=10,luck=5,skills={"VenomBite","WebShot"}}
E.Normal["Skeleton Archer"]={level=4,hp=28,attack=10,defense=3,speed=8,luck=4,skills={"PowerShot","PiercingArrow","QuickShot"}}
E.Normal["Skeleton Knight"]={level=4,hp=40,attack=10,defense=8,speed=6,luck=3,skills={"ShieldBash","DefensiveStance","SwordSlash"}}
E.Normal["Goblin Scout"]={level=2,hp=25,attack=7,defense=2,speed=14,luck=8,skills={"QuickStab","SmokeBomb","ThrowingKnife"}}
E.Normal["Goblin Warrior"]={level=3,hp=35,attack=10,defense=5,speed=10,luck=5,skills={"SlashSkill","ShieldBlock","BattleCry"}}
E.Normal["Goblin Shaman"]={level=4,hp=30,attack=6,defense=3,speed=8,luck=6,skills={"FireBolt","HealingTotem","TribalBlessing"}}
E.Normal["Orc Brute"]={level=5,hp=55,attack=14,defense=6,speed=4,luck=2,skills={"GroundSlam","Cleave"}}
E.Normal["Orc Berserker"]={level=5,hp=45,attack=15,defense=3,speed=12,luck=3,skills={"Frenzy","WildSwing","RecklessCharge"}}
E.Normal["Troll"]={level=4,hp=90,attack=15,defense=10,speed=2,luck=2,skills={"ClubSwing","Howl"}}
E.Normal["Vampire Bat"]={level=3,hp=25,attack=10,defense=2,speed=16,luck=5,skills={"BloodBite","Screech","Flyby"}}
E.Normal["Ghost"]={level=3,hp=28,attack=8,defense=2,speed=10,luck=5,skills={"Haunt","Fade","SpiritTouch"}}
E.Normal["Wraith"]={level=5,hp=35,attack=10,defense=3,speed=12,luck=5,skills={"SoulDrain","ShadowStrike","PhaseShift"}}
E.Normal["Cultist"]={level=4,hp=30,attack=6,defense=3,speed=8,luck=5,skills={"DarkRitual","CurseSkill","Sacrifice"}}
E.Normal["Dark Mage"]={level=6,hp=35,attack=5,defense=3,speed=8,luck=6,skills={"FireballSkill","IceLance","ArcaneBlast","ManaShield"}}
E.Normal["Acid Slime"]={level=3,hp=30,attack=8,defense=2,speed=6,luck=3,skills={"AcidSpit","CorrodeArmor","Split"}}
E.Normal["Fire Elemental"]={level=5,hp=35,attack=10,defense=3,speed=10,luck=5,skills={"FireballSkill","FlameWave","Ignite"}}
E.Normal["Ice Elemental"]={level=5,hp=40,attack=8,defense=5,speed=8,luck=5,skills={"IceShard","FrostNova","FreezeSkill"}}
E.Normal["Storm Elemental"]={level=6,hp=35,attack=8,defense=3,speed=14,luck=5,skills={"LightningBolt","ChainLightning","StaticCharge"}}
E.Normal["Treant"]={level=6,hp=60,attack=12,defense=10,speed=4,luck=3,skills={"RootSmash","Regrowth","RootSnare"}}
E.Normal["Ent Sapling"]={level=3,hp=25,attack=6,defense=4,speed=6,luck=3,skills={"HealSkill","NaturesBlessing","VineWhip"}}
E.Normal["Cave Troll"]={level=7,hp=80,attack=16,defense=8,speed=5,luck=3,skills={"ClubSmash","Regenerate","BoulderThrow"}}
E.Normal["Mimic"]={level=5,hp=45,attack=14,defense=6,speed=8,luck=10,skills={"SurpriseBite","TongueLash","Devour"}}
E.Normal["Bandit Rogue"]={level=3,hp=30,attack=10,defense=3,speed=14,luck=10,skills={"Backstab","StealGold","SmokeBomb"}}
E.Normal["Bandit Captain"]={level=5,hp=45,attack=14,defense=6,speed=10,luck=6,skills={"Rally","SteelSlash","CommandStrike"}}
E.Normal["Harpy"]={level=4,hp=30,attack=10,defense=2,speed=16,luck=5,skills={"DiveBomb","Screech","WingGust"}}
E.Normal["Crystal Golem"]={level=6,hp=55,attack=12,defense=12,speed=4,luck=3,skills={"CrystalPunch","CrystalBarrier","CrystalReflection"}}
E.Boss["Dragon"]={level=10,hp=200,attack=25,defense=15,speed=8,luck=10,skills={"Fireball","ClubSwing"}}
E.Boss["Necromancer"]={level=8,hp=150,attack=10,defense=10,speed=12,luck=8,skills={"RaiseDead","Fireball"}}
E.Boss["Goblin King"]={level=8,hp=150,attack=20,defense=12,speed=7,luck=8,skills={"ClubSwing","Howl","BattleCry"}}
E.Boss["Fallen Knight"]={level=10,hp=250,attack=22,defense=15,speed=8,luck=10,skills={"CrushingSlash","ShieldWall","IntimidatingRoar","Execute"}}
E.Boss["Ancient Guardian"]={level=5,hp=400,attack=18,defense=20,speed=5,luck=5,skills={"CrushingSlash","Earthquake","ShieldWall","Cleave"}}
E.Boss["Plague Queen"]={level=8,hp=200,attack=14,defense=8,speed=18,luck=12,skills={"VenomBite","ToxicCloud","PoisonBite","AcidSpit"}}
E.Boss["Cursed King"]={level=11,hp=300,attack=20,defense=14,speed=10,luck=10,skills={"CrushingSlash","IntimidatingRoar","SoulTax","ShieldWall","Execute"}}
E.Boss["Arcane Construct"]={level=14,hp=280,attack=10,defense=12,speed=12,luck=8,skills={"Fireball","Meteor","Overload","ShieldWall"}}
E.Boss["Beast Alpha"]={level=17,hp=350,attack=26,defense=14,speed=14,luck=10,skills={"Howl","ClubSwing","Cleave","BattleCry"}}
E.Boss["Corrupted Hero"]={level=20,hp=500,attack=28,defense=18,speed=16,luck=15,skills={"CrushingSlash","ShieldWall","BattleCry","Fireball","PoisonDart","Execute"}}
E.Elite["Giant Rabbit"]={level=5,hp=60,attack=12,defense=6,speed=10,luck=15,skills={"Bite","Hop"}}
E.Elite["Goblin Chief"]={level=6,hp=80,attack=15,defense=8,speed=6,luck=5,skills={"ClubSwing","Howl","BattleCry"}}
return E
