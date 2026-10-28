# Cool RPG — Original UI Recreation v0.3

This update uses the **original Roblox game archive `gamerpGggg.zip`** as the visual reference. It updates the working Cool RPG v0.2 prototype UI while retaining its server and progression code. It is **not a migration of the full original game**.

## Studio installation

1. Save a backup of the existing Roblox Studio place.
2. From the ZIP, extract `CoolRPG_OriginalUI_v0.3.rbxlx`.
3. In **Roblox Studio → File → Open from File**, select that `.rbxlx` place.
4. Press **Play**. UI is dynamically created by the LocalScript `StarterPlayer.StarterPlayerScripts.UI` and its `Views` ModuleScripts. Server stays in `ServerScriptService.Game`.
5. This place **replaces**, rather than updates in place, the existing Studio place. If you modified the previous version, merge relevant source files from `src/` instead of overwriting your custom place.

## Source inspection

Original `gamerpGggg.rbxl` (unzipped from the supplied ZIP) contained **2,732 Roblox instances** across 97 classes. It has one `StarterGui.MainUI` containing **23 directly nested UI screens or controllers** and extensive embedded class-specific UI including `Camp`, `InventoryPanel`, `CraftingPanel`, `WarCryTreePanel`, `PaladinPanel`, `HunterPanel`, `Combat`, `AdventureMap`, `CharacterCreation`, `PostCombat`, and other menus.

The original interface uses flat charcoal/near-black backgrounds, muted violet-gray panels, pale text, green primary buttons, separate left and right content columns, and a bottom campsite dock. Its combat GUI has a party column on the left, enemies on the right, central battlefield and turn order, plus a log/action area at the bottom.

## Implemented appearance changes

- **Main menu:** dark background, centered vertical buttons, green Play action.
- **Character creator:** original four-column layout — Races, Classes, Traits, Character preview; footer Back/Continue.
- **Campsite:** six wide bottom buttons (Adventure, Inventory, Crafting, Skills, Class Ability, Character), safe-haven panel, right character info.
- **Inventory:** equipment-slot rail, scrollable items, selected-item details and Equip/Use actions.
- **Crafting:** scrollable recipe list, ingredient preview, gated Craft button.
- **Skills:** skill list/detail split, universal Guard in the skills list.
- **Class ability:** the Warrior/Hunter/Paladin/Mage/Necromancer/Merchant backend connections from the prototype remain in their own class UI.
- **Combat:** original-inspired party-left/enemies-right arrangement, central battlefield, turn strip, fixed scrollable log, nested Attack/Skills/Items/Escape buttons. Guard replaces Defend.
- **Postcombat:** upgrade choices, grouped EXP & Gold / Items Dropped / Other Rewards sections, Continue to Camp.
- **Events/death:** original-style dark dialogue panels and result screens.

## Technical notes

- UI styles are centralized in `StarterPlayer/StarterPlayerScripts/Views/Kit.lua`.
- UI panels are in `Views/Menus.lua`, `Camp.lua`, `Combat.lua`, and `Class.lua`.
- `UI.client.lua` coordinates phases and calls the existing `RPGRequest` RemoteFunction.
- Game logic in `ReplicatedStorage/Shared` and `ServerScriptService/Game.server.lua` was preserved.
- Uses Roblox built-in GUI objects; **no external images, sounds, or permissions required**.
- UI is designed for a 1280×720 logical canvas and scales to fit other resolutions.
- Current build is a **close functional visual recreation**, not a pixel-perfect import of every original screen (many original panels require their own gameplay systems).

## Testing

A static check verifies the place XML, source script count, UI module paths, and RemoteFunction action names. **This version was not live-playtested inside Roblox Studio.** After import, verify character creation, campsite, inventory selection/equip, crafting, class ability, map, combat targeting, scrollable logs, upgrade selection, and return-to-camp flows. Inspect Studio Output for runtime errors.

## Files

- `CoolRPG_OriginalUI_v0.3.rbxlx`: Roblox Studio place.
- `src/`: complete editable Luau source.
- `default.project.json`: Rojo project mapping for source-based workflows.
- `original-ui-reference.json`: selected names, text, positions, sizes and colors extracted from the supplied original Roblox file for UI comparison. It is a reference only, not executed by Roblox.
