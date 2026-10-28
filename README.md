# Cool RPG — Roblox Studio prototype v0.1

This is a **new playable vertical slice**, not a finished implementation of the full 23-section design document. It was created from the supplied design files because the GitHub repository was empty. It has not been tested inside a running Roblox Studio session.

## Fastest way to open

1. Install/open **Roblox Studio** on your computer.
2. Use **File → Open from File** and select `CoolRPG_Prototype.rbxlx`.
3. Press **Play**. The on-screen `COOL RPG` menu opens automatically.
4. If you want to publish, use Studio's **File → Publish to Roblox As…**.

The `.rbxlx` file is the complete Studio place format, including the scripts. You do **not** need Rojo to open it. It generates a 2D UI in the PlayerGui and a simple spawn platform. The viewport behind the UI is not a finished game world.

## Source-code import (optional)

The `src/` tree and `default.project.json` form a **Rojo** project. If you use Rojo, sync `default.project.json` into an existing Roblox place. Do not mix the Rojo sync and `.rbxlx` import into the *same* place, or you will duplicate scripts.

## What is implemented

- Main menu, character creator, **4 races, 6 playable base classes, 8 traits**, campsite and stats pages.
- Procedural map with reachable branch connections, combats, merchants, events, rests and boss on row 10.
- Server-controlled per-player single-player battle loop, target selection, physical/magic attacks, skill cooldowns, consumables, evasion, critical hits, barrier, guard, Poison, Burn, Stun.
- Gold, XP, levels, random 3-upgrade selection, class/equipment modifiers, loot, inventory/equip, five crafting recipes, loot merchant, shop refresh for Merchant class.
- **Warrior:** randomly generated 3-lane × 3-tier Battle Cry tree per run, points gained on level-up and unique Battle Cry effects in combat.
- **Hunter:** one trophy for **every** defeated enemy (+0.3% damage, up to +25%); precombat Spike/Venom/Snare trap automatically targets the strongest enemy; accepting and completing bounties gives XP/gold.
- **Paladin:** repeated blessings can stack indefinitely, no active blessing slot limit; request up to 2 pending blessings, which activate after 2–4 won combats and grant Divine Charges to cleanse curses.
- **Mage:** ten-point custom spell builder combining Fire/Ice/Arcane, single/all target, and optional Poison/Burn, with a battle action.
- **Necromancer:** zombie ally that automatically attacks and has Head/Arms/Chest/Legs/Core part slots.
- **Merchant:** camp-only personal shop; MP-spending shop refresh.
- Enemy database contains the supplied **32 normal enemies, 2 elites and 10 bosses** with their names and core stats. Combat behavior is simplified and does not yet implement each enemy's distinct skill.
- Separate, modular Luau script files, 48–364 lines each; shared data and single authoritative server entry point.

## Not yet implemented — important

- No live multiplayer party/cooperative combat, party matchmaking, or up to four player summons.
- No DataStore persistence, achievement unlock persistence, or global leaderboards. A run is memory-only and is lost when that server/session ends.
- The full 25-recipe crafting set, every equipment catalog entry, boss phase changes, 16 independent status-effect rules, complete class perk trees and their artwork are not yet implemented.
- The skill cost/MP rules, boss schedule and several damage/status formulas still have conflicting earlier design notes; this version chooses a functional prototype behavior rather than pretending the conflicts are settled.
- No implemented endless-mode loop, challenge difficulty, sound/audio, gamepad-specific UI, item art, paid assets or tutorial.
- Enemies have catalog attack/HP/defense/speed values, but **do not use unique AI skills** yet; combat is a simplified per-player encounter for this first build.
- No actual Roblox Studio runtime tests have been performed here. Bugs may remain. Check **View → Output** in Studio if anything fails.

## Updated class rules (source of truth)

**Warrior:** Battle Cry is upgraded through a *randomly generated skill tree each run*, not a fixed linear perk list.

**Hunter:** trophy cabinet records each enemy slain and grants a small scaling bonus; trap maker sets a **precombat trap that strikes the strongest enemy**; bounty board offers contracts for gold/XP.

**Paladin:** blessings may **stack**, with **no active blessing count limit**. Pending blessings are capped at two in this build to stop instant farming; curse removal costs one Divine Charge, gained from completed pending blessings.

## Testing checklist

- Play → race/class/trait selection → Start → Camp → Map → Combat → Reward → Camp.
- Check skill cooldowns and ability use in combat; defeat enemy and claim level-up upgrade.
- Hunter: select Snare, then start combat; trap should stun highest-max-HP foe. Check trophy count and bounty progress after kills.
- Warrior: inspect randomized tree, spend a point, cast Battle Cry.
- Paladin: request same blessing twice across battles; check stacking and cleansing.
- Mage: craft 10-point all-target effect spell and use it in battle.
- Merchant: buy/refresh stock. Necromancer: equip part and watch zombie attack.
- Open `View → Output` if a request fails and use the warning label in the footer.

## File map

```
ReplicatedStorage/Shared/Content.lua     Race/class/trait/item/upgrade data
ReplicatedStorage/Shared/Enemies.lua     Enemy catalog data
ReplicatedStorage/Shared/Adventure.lua   Map branching and events
ReplicatedStorage/Shared/Progress.lua    Stats, inventory, class progression
ReplicatedStorage/Shared/Battle.lua      Server combat engine
ServerScriptService/Game.server.lua      Remote validation and game loop
StarterPlayer/StarterPlayerScripts/UI.client.lua  Full on-screen 2D UI
```