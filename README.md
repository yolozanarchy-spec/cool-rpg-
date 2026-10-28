# Cool RPG — Roblox Studio UI redesign v0.2

This is the updated Studio place for your existing **Cool RPG** prototype, based on the 32-page `yolo game .pdf` UI reference. It preserves the v0.1 game loop, character abilities, enemies and progression. It has **not** been tested by launching Roblox Studio in this environment.

## Import into Roblox Studio

1. Download `CoolRPG_UI_v0.2.rbxlx` (or open `CoolRPG_Prototype.rbxlx` in the repository).
2. In Roblox Studio, choose **File > Open from File** and select the `.rbxlx` file.
3. Select **Play**. Your new UI should appear in the same game.
4. If you need to keep your existing published place, publish this file with **File > Publish to Roblox As…** and select the appropriate experience. **Back up your existing place first**, because replacing a published place overwrites its server-side scripts and content.

This full-place import is intended for the standalone v0.1 Cool RPG prototype. If you've made local changes since importing v0.1, merge the `src/` changes instead of overwriting your customized place.

## What changed visually

- **Main menu (PDF p. 4):** centered vertical column of Info, Play, Multiplayer, Achievements, Leaderboard, and Settings.
- **Creation (PDF p. 7):** independent scrolling Class, Race and Trait columns, live preview panel with descriptions and starting stats, Back and Begin Adventure.
- **Campsite (PDF pp. 9–11):** five buttons along bottom for Adventure, Inventory, Crafting, Skills and Class Ability; right-hand character sheet remains visible in utility menus. Stats / Codex is an additional control.
- **Map (PDF p. 3):** ten visual rows with branching connection lines and red enemy, blue boss and gray event nodes; merchant/rest/special also have their own colors. Only connected nodes in the current row can be clicked.
- **Combat (PDF pp. 2, 13):** left turn order, centrally selectable enemy panels, bottom action grid of Attack / Items / Escape / Skills; selecting Items or Skills replaces the grid with a scrolling list; a fixed-size scrollable combat log sits on the right. Enemy and player health information always stays visible.
- **Reward (PDF p. 15):** three level-up choices across the upper area, reward/loot/EXP summary beneath, Continue to Camp.
- **Event and death (PDF pp. 16–17):** clear event choices and a separate defeat menu.
- Dark fantasy styling with subtle borders, accessible text contrast, gold/blue/green accents, and a 1280×720 letterboxed scaling layout for different desktop sizes.

## Gameplay bridge additions

- **Guard is now a universal skill** selectable through Skills; it provides 3 Barrier and 50% guard damage reduction for the following enemy attack cycle. The old standalone Defend button is removed.
- **Escape** is an action in combat with a 70% success chance; bosses cannot be escaped. Failing an escape uses a turn, allowing enemies to attack. Successfully escaping ends the encounter without rewards, advances the map and opens the post-encounter summary.
- Server now accepts Back from character creation, campsite tab-switching from utility tabs, and Settings/info navigation across more screens.
- Combat log retains up to 120 actions (previously 8) and the client displays them in a fixed-size scrolling panel.

## Important limitations

- This is a functional layout implementation built with native Roblox UI objects, **not a pixel-exact recreation of the screenshots** or a new 3D scene. The source PDF contains both wireframes and example images; this version adapts their placement and interactions to the existing 2D prototype.
- The UI is scaled for desktop first. Mobile, console/gamepad focus navigation, localization and screen-reader-specific accessibility need dedicated testing.
- Multiplayer and persistent achievements/leaderboards remain placeholders, as in v0.1. The settings screen explains how to use Roblox's built-in settings.
- No Roblox Studio runtime, network latency or gameplay simulation test has been run here; after importing, verify the output log for errors.

## Files

The Rojo-compatible `src` directory is included for targeted merging. The largest script is about 230 lines.

```
ReplicatedStorage/Shared/Adventure.lua
ReplicatedStorage/Shared/Battle.lua          # Escape, Guard, extended combat log
ReplicatedStorage/Shared/Content.lua
ReplicatedStorage/Shared/Enemies.lua
ReplicatedStorage/Shared/Progress.lua
ServerScriptService/Game.server.lua        # transitions, Escape outcome, navigation
StarterPlayer/StarterPlayerScripts/UI.client.lua
StarterPlayer/StarterPlayerScripts/Views/Kit.lua
StarterPlayer/StarterPlayerScripts/Views/Menus.lua
StarterPlayer/StarterPlayerScripts/Views/Camp.lua
StarterPlayer/StarterPlayerScripts/Views/Combat.lua
StarterPlayer/StarterPlayerScripts/Views/Class.lua
```

## Suggested Studio smoke test

1. Info > Back > Play > choose a different class/race/trait > preview updates > Begin Adventure.
2. Camp > Inventory > Crafting > Skills > Class ability > Adventure. Confirm bottom nav remains useful and character stats stay visible.
3. Map > select a red Combat node; verify enemy and turn queue/scroll log.
4. Combat > Skills > Guard > enemy turn; Skills > class ability; Items > potion; Attack; Escape (success/failure).
5. Win another encounter to check rewards and optional level-up choices, then Continue to Camp.
6. Try Hunter trophies/trap/bounty, Warrior's randomized skill tree and Paladin's unlimited blessing stacking.
7. Check View > Output and test at multiple resolutions.
