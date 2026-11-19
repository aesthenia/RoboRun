# DECISIONS.md

I used Claude as my AI agent. I tested everything myself in Godot 4.7.

## Weeks 8–9 (mobile kickoff)
- 05.11  My game is in Godot, not Unity, so I had to find the Godot versions of everything: Canvas Scaler = stretch mode, Library/ = .godot/. Godot has no Device Simulator, so we made F1–F3 keys that resize the window to a phone, a notch phone and an iPad.
- 05.11  At first the UI scaled with "expand" and on the iPad everything got tiny. Changed it to "keep_height", which works like Match = 1 in Unity.
- 05.11  The pause button was too small (90 px) and some text was 26 px. Made all buttons at least 120 px and text at least 36 px, and moved them into a SafeArea panel so nothing goes under the notch.
- 05.11  The device simulator script didn't compile because of `:=` on Variant values. Wrote the types by hand.

## Week 10 (enemies)
- 18.11  Asked Claude for 3 enemies: a bomb that chases you and explodes, a turret with a laser, and a charger that dashes. Each one has its own states, and they can't see you through walls.
- 18.11  The enemies didn't move at all. Turned out the navmesh was 0.5 m above the ground and the agent never reached its first point. Fixed it with path_height_offset.
- 18.11  The player took damage just by touching an enemy, before any warning. Now only the actual attacks do damage.
- 18.11  The charger's red dash line wasn't visible (it was inside the ground) and the turret laser was too thin. Moved the line up and made the laser thicker.

## Week 11 (data and saves)
- 19.11  Godot doesn't have ScriptableObjects, so I used Resource files (.tres) instead. All the numbers (player, enemies, boss, items) are in the data folder now, not in the code.
- 19.11  Levels are built from LevelData files now: one game scene loads the islands and spawns the coins and enemies from the data.
- 19.11  When Claude split my old levels into separate files, it lost the links to the resources and the scenes stopped loading. Fixed the script and checked that all 4 levels open.
- 19.11  Saves go to save.json. If the file is missing or broken, the game just starts with default values. Godot reads every number from JSON as a float, so the loading code checks the types too.
- 19.11  The game saves after a level, when you change the volume, and when the app goes to the background.
