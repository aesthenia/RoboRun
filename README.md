# Robo Run

A mobile 3D platformer: a little robot runs and jumps across floating sky islands, collects every coin to open the exit portal and finally defeats the Stone King.

- **Engine:** Godot 4.7, Mobile renderer, GDScript
- **Platform:** Android, landscape (reference resolution 1920 × 1080)
- **Course:** Game Development Fundamentals, Narxoz University, weeks 9–15 project
- **GDD:** [docs/RoboRun_GDD.pdf](docs/RoboRun_GDD.pdf)

## How to run
Open `project.godot` in Godot 4.7 and press F5. The main scene is `scenes/ui/main_menu.tscn`.

## Screens
- **Main menu**: title, Play, Quit
- **HUD**: hearts, coins (score), pause button, virtual stick, JUMP and FIRE
- **Pause**: Resume, Restart, Main menu; the game tree is paused while it is open

## Mobile UI setup
- Stretch mode `canvas_items`, aspect `keep_height`, base size 1920 × 1080 (the Godot equivalent of Unity's Scale With Screen Size with Match = 1)
- Every control is anchored to its corner, edge or center; full-screen panels are stretched
- Buttons and text live inside a **SafeArea** control (`scripts/ui/safe_area.gd`), which reads `DisplayServer.get_display_safe_area()` on the phone
- Buttons are at least 120 × 120 px in the reference resolution, and text is at least 36 px

## Testing on three devices (editor)
The `DeviceSim` autoload (`scripts/autoload/device_sim.gd`) works only in debug builds on desktop:

| Key | Device |
|-----|--------|
| F1 | 16:9 phone, 1920 × 1080 |
| F2 | iPhone 13, 19.5:9, 2532 × 1170, notch and safe area shown |
| F3 | iPad, 4:3, 2048 × 1536 |
| F4 | simulator off |
| F9 | screenshot to `screenshots/` |

## Assets
See `README.txt` for the full list of models, sounds and licences.
