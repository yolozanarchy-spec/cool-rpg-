# Cool RPG — Screenshot UI Recreation v0.4

Roblox Studio place and editable Luau source for the screenshot-driven redesign of the Cool RPG prototype.

## Import

1. Download/extract `CoolRPG_ScreenshotUI_v0.4.rbxlx`.
2. Roblox Studio → **File → Open from File** → select `.rbxlx`.
3. Press **Play**, choose a race, class, and trait, and use the bottom bar to navigate.
4. Keep a backup before replacing any existing place; this is a separate project snapshot.

## UI references

The user supplied **ten actual original-game screenshots** on October 27, 2026. v0.4 uses their charcoal backgrounds, flat slate buttons, six-button dock, muted gold headings, and colored data indicators as its main layout references. These screenshots are not distributed as Roblox assets, nor are they claimed to be game screenshots of v0.4.

### Screens recreated

- **Inventory:** left equipment grid, scrolling filter tabs and inventory tiles, right item-details and compare panel. Equip, use, and unequip actions are wired to the server.
- **Crafting:** categories and recipe cards left; ingredient costs (red/green), item name, and server-gated craft action right.
- **Skills:** vertical scroll list left and detailed reference panel right. Enemy skill entries are *codex references*, not unlockable spells in the current prototype.
- **Character Stats:** one vertical scrolling sheet with attribute components, health/mana, multipliers actually available, equipment bonuses, blessings, curses and progress.
- **Adventure Map:** charcoal board, white path connectors, circular icons, red available nodes, stage/floor/boss header.
- **Necromancy:** body-slot mannequin, five tabs, owned monster part tiles, selection details, **Attach** action, zombie stat preview.
- **Spellcraft:** large preview left and element/target/status controls right with working **Save Spell** request. The present backend supports Fire/Ice/Arcane, single/all enemies, and None/Burn/Poison.
- **Bazaar:** two brown-and-gold shop panes, item prices, refresh using MP, and buy control.
- **War Cry:** circular branching skill nodes with a central yellow root, available points, dependency checking and server-validated unlocks.
- **Hunter and Paladin:** class-special UI remains interactive (trophies, traps, bounties, blessings and curses).

The bottom tab adapts to the selected class: War Cry, Necromancy, Spellcraft, Bazaar, Hunting or Divine Favor.

## Backend features added for UI

- Server-side `Unequip` handling: moves currently equipped items back into inventory; only valid equipment slots accepted.
- Campsite `Merchant` shortcut opens the personal Bazaar (existing shop logic reused).
- Four additional basic, data-driven crafting entries for the screenshot-themed bone equipment/materials. These are additions, not copies of the original game's entire recipe list.

## Technical organization

- `StarterPlayer/StarterPlayerScripts/UI.client.lua`: phase router and server requests.
- `Views/Kit.lua`, `Views/Shell.lua`: theme, low-level widgets, navigation dock.
- `Views/Inventory.lua`, `Views/Crafting.lua`, `Views/Skills.lua`, `Views/Character.lua`, `Views/WorldMap.lua`: independent screens.
- `Views/Necromancy.lua`, `Views/WarCry.lua`, `Views/Spellcraft.lua`, `Views/MerchantScreen.lua`, `Views/Class.lua`: class screens and routing.
- `ServerScriptService/Game.server.lua`: server-authoritative requests.
- `ReplicatedStorage/Shared/`: gameplay data/simulation.

Every Luau source file is less than 500 lines. No downloaded images, marketplace assets, or executable third-party code are used. The built place uses a 1280 × 720 logical canvas that scales to the user's viewport.

## Known limits / testing

This is a visual/functionality pass over a **limited playable prototype**, not a restoration of every system in the user's full original Roblox place. The screenshot images show more items, skills, spell modifiers, stats and skill-tree upgrades than are currently implemented in the prototype. Unsupported spell modifiers are deliberately not presented as playable. Multiplayer and persistent leaderboards are still out of scope.

**Validation:** The `.rbxlx` XML and all embedded script paths are validated locally. Roblox Studio runtime and layout testing cannot be performed in this environment. Test tabs at desktop and laptop viewport sizes, crafting, equipping/unequipping, map progression, each class ability and combat, and report runtime exceptions from Studio Output.
