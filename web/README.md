# COOL RPG: Ashen Paths — HTML5 prototype v1.0

A standalone, itch.io-ready browser adaptation of the **Cool RPG** Roblox design. This is a new playable web prototype, **not** a full conversion of all content and systems in the original Roblox game.

## Upload to itch.io (HTML Game)

1. Upload `CoolRPG_itch_HTML5_v1.0.zip` to your itch.io game's project page.
2. Set **Kind of project** to **HTML**.
3. Tick **This file will be played in the browser**. You do not need a Roblox file for this version.
4. Suggested embed width **1280px**, height **720px**, and enable fullscreen. The layout responds to resize.
5. Save as draft initially, open your itch.io draft game page in a regular browser, and test the game before publishing.
6. Leave the ZIP structure unchanged: `index.html`, `main.js`, `engine.js`, `network.js`, `rtc-config.js`, `data.js`, `style.css` and `assets/` must be at the top level. All files are static and use relative URLs; there is no npm install or build step.

**Local testing:** run `python3 -m http.server 8000` from this directory, then browse to `http://localhost:8000`. Opening `index.html` directly with `file://` may prevent ES module loading.

Official instructions: https://itch.io/docs/creators/html5

## Play

Solo Adventure → pick race/class/trait/name → Campsite → Adventure Map → choose any glowing connected node. Combat is turn-based. Defeat enemies, collect XP/gold/items, and continue back to camp. Manage inventory, craft equipment, choose class upgrades, and follow a new procedurally generated route each run. The final node is the boss. At victory you may enter a new endless act.

### Multiplayer: peer-to-peer co-op (up to 4 players)

The current build supports **host-authoritative synchronized multiplayer using WebRTC data channels and manual invite/answer exchange**. There is no hosted matchmaking server, account service, or permanent session storage. There is one active campaign shared by the party; each player has their own character, class, inventory, stats, turn, and upgrade choice. The host chooses routes/events and starts the session. Guests control their own combat turn and progression actions.

**Connection procedure:**

1. Host: choose **Host Multiplayer** → **Generate a Player Invite** → send the displayed offer code to one friend (Discord/message).
2. Guest: choose **Join Multiplayer**, set a name, paste the offer code → **Generate Answer / Connect**, then send the answer code back to the host.
3. Host: paste that guest's answer into the **Guest Answer Code** box → **Connect Invited Player**.
4. When connected, both should see the party member in the lobby. Repeat for each additional guest (max 3 guests, 4 players total).
5. All players select Race/Class/Trait (and click **Update Character**), then the host clicks **Start Party Adventure**.
6. During battle, wait for your turn before selecting attack, skill, consumable, guard or escape. The host's browser processes all actions and sends synchronized snapshots to guests. During a reward screen, everyone who leveled up selects one upgrade; only then can the host continue.

**Important connectivity limitation:** This is direct WebRTC with public STUN. It can work across different computers/networks when they can establish a direct peer connection, but it will **not** work on every combination of networks. Symmetric NATs, some mobile carriers, schools and workplaces may require a TURN relay. There is **no bundled TURN service**. To add one you control, edit `rtc-config.js` and repack the ZIP. TURN usernames/passwords embedded in static files are public; use temporary credentials in a production setup. No live cross-network connection could be verified in the build environment because its Chromium instance exposes no ICE candidates. Do **not** advertise universal internet multiplayer until you test two real devices from different networks using the itch.io embed.

There are no automatic room codes or public matchmaking. Invite codes are long (WebRTC session descriptions), but can be copied and shared privately. For a production itch.io release with reliable online multiplayer, add a hosted signaling/room backend **plus TURN relay**, or another verified multiplayer backend. This build avoids requiring a server at the expense of manual setup and network compatibility.

## Recent additions

**Adventure map:** Slay-the-Spire-like branching map, 10 procedural floors plus a boss, animated-style curved connections, accessible reachable nodes, encounter icons and progress states. Only connected routes can be chosen.

**Character screen:** clear explanations of primary stats, how they're calculated, equipment contributions, combat multipliers, and sources. Expand/collapse individual stat entries.

**Necromancer:** starts with a permanently active zombie ally (55 starting HP). The zombie attacks after its owner and can be directly targeted by enemies. Its health, equipment and Summon Zombie cooldown persist between encounters. It doesn't regenerate after combat. If it dies, the Necromancer must use **Summon Zombie** in combat, consuming their entire action and restoring it to full HP; the cooldown is **12 of the owner's combat turns** and carries between encounters. Summoning can also heal a living zombie. Parts can be attached in the Necromancy menu.

**Warrior:** each character gets a newly generated 16-upgrade Battle Cry tree with four branches of four nodes. Eight tags: Debuff, Buff, Ranged Damage, Melee Damage, Risk & Reward, Raw Stats, Control, Sustain. Every upgrade has two tags; nodes on the same branch share a tag with their parent. Each of the eight tags appears on at least three different upgrades (verified by generator tests). Spend points earned from leveling up to unlock connected nodes. Effects include stat increases, damage, heal/shield, crowd control and trade-offs.

**Merchant:** when leveling, Merchant receives a class-upgrade option mixed with normal upgrades. Available perks include Tome Bargains (cheaper upgrade tomes), Blood Merchant (HP instead of gold), Expanded Shelves, Endless Stock, Savvy Seller, Grand Bazaar, Quick Restock, Golden Touch, Black Market, Haggler, and Grand Sale. These change pricing, shop stock, refreshing and rewards.

**More:** custom Mage spell editor, Hunter trophy display/pre-combat traps/bounty board, unlimited stacking Paladin blessings and Divine Charges, loot/crafting/inventory, turn-based battles, post-combat upgrade options, core event/merchant/rest nodes. Some class details are simplified compared with the original Roblox game; not every item/skill/status/enemy from the full design catalog has been ported.

## Testing performed

- JavaScript syntax verified with Node 22.
- Warrior tree generator checked through 1,000 random trees: 16 nodes, connected tags, all eight tags represented ≥3 times per tree.
- Solo browser rendering and UI interactions checked with Chromium/Playwright: creation, campsite, character, inventory, crafting, skills, necromancy part attachment, adventure map, combat and reward transitions; no JavaScript page errors on these paths.
- Multiplayer signaling protocol, two-person lobby synchronization, shared map state and guest action relay verified using the deterministic RTC mock in `tests/test-multiplayer.mjs`.
- Real WebRTC connection **NOT** validated on the testing machine due to its network administrator blocking all ICE candidates. The test is of game/networking logic, not proof of internet connectivity.

## Technical notes and known limitations

- Prototype uses a mutable host-owned session state and WebRTC. Hosts can cheat; no backend anti-cheat, transactional persistence or dedicated lobby service.
- State is lost when the host closes the tab. Single-player runs also reset on page refresh; autosave and long-term unlocks are not in this build.
- Some gameplay systems, item catalogs, status definitions, animations and artwork remain incomplete relative to the Roblox original.
- For serious online release, provide authoritative server hosting or robust relay/TURN and persist profiles in a service; manual exchange is intended as a low-infrastructure prototype.
- Preview images and tests are optional and are not required to run the game.

## Icon licensing

The hand-picked SVG assets come from the user-provided `game-icons.net.svg.zip` icon package and remain attributed to their original creators. **Icons made by their respective creators (including Lorc, Delapouite, and other listed contributors).** See `assets/ICON_CREDITS.txt` and `assets/ICON_ATTRIBUTION.md` for licensing and per-file authors. CC BY 3.0 or CC0 as specified by the original package. Do not remove attribution when distributing.