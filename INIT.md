# roblox-ai-modules

Small Roblox/Luau module repo for the SS Hub AI chatbot.

## Files

- `ss-chatbot`
  - Public loader for the SS Hub AI Chatbot.
  - Fetches the original hub source, patches runtime issues, adds current model options, adds the raycasting UI, and loads modules from this repo.

- `actions-basic.lua`
  - Basic character action module.
  - Supports movement/emote/tool actions like jump, sit, stand, dance, wave, equip, use tool, and simple walk commands.

- `pathfinding-module`
  - Navigation module.
  - Uses Roblox `PathfindingService`, waypoint following, jump handling, ladder assist, rerouting, stuck recovery, and direct fallback movement when Roblox pathfinding cannot make a route.

- `raycasting_vision-module`
  - Raycast vision/navigation helper.
  - Scans forward, circular/360, ground, cliffs, hazards, ladders, movement segments, and background dome/reflection mapping.

## Load Order

Recommended order inside `ss-chatbot`:

1. Load `raycasting_vision-module` if raycasting is enabled.
2. Load `pathfinding-module`.
3. Call `Pathfinding.SetRaycastingModule(Raycasting)` when both are loaded.
4. Load `actions-basic.lua` only when action commands are enabled.

## Raw URLs

```lua
local URLs = {
   Chatbot = "https://raw.githubusercontent.com/Essencor/roblox-ai-modules/refs/heads/main/ss-chatbot",
   Actions = "https://raw.githubusercontent.com/Essencor/roblox-ai-modules/refs/heads/main/actions-basic.lua",
   Pathfinding = "https://raw.githubusercontent.com/Essencor/roblox-ai-modules/refs/heads/main/pathfinding-module",
   Raycasting = "https://raw.githubusercontent.com/Essencor/roblox-ai-modules/refs/heads/main/raycasting_vision-module"
}
```

## Main Entry

Normal user entry is:

```lua
getgenv().SS_CHATBOT_OPENROUTER_KEY = "YOUR_OPENROUTER_KEY"
loadstring(game:HttpGet("https://raw.githubusercontent.com/Essencor/roblox-ai-modules/refs/heads/main/ss-chatbot"))()
```

## Notes

- Keep files saved as UTF-8 without BOM. A BOM can make Roblox `loadstring` fail and show `attempt to call a nil value`.
- `pathfinding-module` returns `PathfindingModule`.
- `raycasting_vision-module` returns `RaycastingVision`.
- `actions-basic.lua` returns `Actions`.
