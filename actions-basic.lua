--[[
    SS Hub - Actions Module (Basic)
    Version: 1.0
    
    Provides basic character actions for AI control:
    - Movement (jump, sit, walk)
    - Emotes (dance, wave, laugh, etc.)
    - Item/Tool usage
    
    Usage:
    local Actions = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/actions-basic.lua"))()
    Actions.Jump()
    Actions.Dance()
]]--

local Actions = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Status tracking
Actions.Status = {
   isExecuting = false,
   lastAction = "None",
   lastActionTime = 0
}

--[[
    MOVEMENT ACTIONS
]]--

-- Make character jump
function Actions.Jump()
   if not LocalPlayer.Character then
      warn("Actions.Jump - No character found")
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if not humanoid then
      warn("Actions.Jump - No humanoid found")
      return false
   end
   
   humanoid.Jump = true
   Actions.Status.lastAction = "Jump"
   Actions.Status.lastActionTime = tick()
   
   print("Actions: Jumped")
   return true
end

-- Make character sit
function Actions.Sit()
   if not LocalPlayer.Character then
      warn("Actions.Sit - No character found")
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if not humanoid then
      warn("Actions.Sit - No humanoid found")
      return false
   end
   
   humanoid.Sit = true
   Actions.Status.lastAction = "Sit"
   Actions.Status.lastActionTime = tick()
   
   print("Actions: Sat down")
   return true
end

-- Make character stand up
function Actions.Stand()
   if not LocalPlayer.Character then
      warn("Actions.Stand - No character found")
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if not humanoid then
      warn("Actions.Stand - No humanoid found")
      return false
   end
   
   humanoid.Sit = false
   Actions.Status.lastAction = "Stand"
   Actions.Status.lastActionTime = tick()
   
   print("Actions: Stood up")
   return true
end

-- Walk to a position
function Actions.WalkTo(position)
   if not LocalPlayer.Character then
      warn("Actions.WalkTo - No character found")
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if not humanoid then
      warn("Actions.WalkTo - No humanoid found")
      return false
   end
   
   if type(position) ~= "userdata" or not position.X then
      warn("Actions.WalkTo - Invalid position (expected Vector3)")
      return false
   end
   
   humanoid:MoveTo(position)
   Actions.Status.lastAction = "WalkTo"
   Actions.Status.lastActionTime = tick()
   
   print("Actions: Walking to", position)
   return true
end

-- Walk to a player
function Actions.WalkToPlayer(playerName)
   local targetPlayer = Players:FindFirstChild(playerName)
   
   if not targetPlayer then
      warn("Actions.WalkToPlayer - Player not found:", playerName)
      return false
   end
   
   if not targetPlayer.Character then
      warn("Actions.WalkToPlayer - Target has no character:", playerName)
      return false
   end
   
   local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
   if not targetRoot then
      warn("Actions.WalkToPlayer - Target has no HumanoidRootPart:", playerName)
      return false
   end
   
   return Actions.WalkTo(targetRoot.Position)
end

--[[
    EMOTE ACTIONS
]]--

-- Play an emote by name
function Actions.PlayEmote(emoteName)
   if not LocalPlayer.Character then
      warn("Actions.PlayEmote - No character found")
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if not humanoid then
      warn("Actions.PlayEmote - No humanoid found")
      return false
   end
   
   -- Try to play the emote
   local success = pcall(function()
      humanoid:PlayEmote(emoteName)
   end)
   
   if success then
      Actions.Status.lastAction = "Emote: " .. emoteName
      Actions.Status.lastActionTime = tick()
      print("Actions: Played emote -", emoteName)
      return true
   else
      warn("Actions.PlayEmote - Failed to play emote:", emoteName)
      return false
   end
end

-- Specific emote shortcuts
function Actions.Dance()
   return Actions.PlayEmote("dance") or Actions.PlayEmote("dance1") or Actions.PlayEmote("dance2")
end

function Actions.Wave()
   return Actions.PlayEmote("wave")
end

function Actions.Point()
   return Actions.PlayEmote("point")
end

function Actions.Cheer()
   return Actions.PlayEmote("cheer")
end

function Actions.Laugh()
   return Actions.PlayEmote("laugh")
end

function Actions.Stadium()
   return Actions.PlayEmote("stadium")
end

--[[
    TOOL/ITEM ACTIONS
]]--

-- Equip a tool from backpack by name
function Actions.EquipTool(toolName)
   if not LocalPlayer.Character then
      warn("Actions.EquipTool - No character found")
      return false
   end
   
   local backpack = LocalPlayer:FindFirstChild("Backpack")
   if not backpack then
      warn("Actions.EquipTool - No backpack found")
      return false
   end
   
   -- Find tool in backpack
   local tool = backpack:FindFirstChild(toolName)
   
   if not tool then
      warn("Actions.EquipTool - Tool not found in backpack:", toolName)
      return false
   end
   
   -- Equip the tool
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if humanoid then
      humanoid:EquipTool(tool)
      Actions.Status.lastAction = "Equipped: " .. toolName
      Actions.Status.lastActionTime = tick()
      print("Actions: Equipped tool -", toolName)
      return true
   end
   
   return false
end

-- Unequip currently equipped tool
function Actions.UnequipTool()
   if not LocalPlayer.Character then
      warn("Actions.UnequipTool - No character found")
      return false
   end
   
   -- Find equipped tool
   local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
   
   if not tool then
      print("Actions: No tool equipped")
      return false
   end
   
   -- Unequip by moving to backpack
   local backpack = LocalPlayer:FindFirstChild("Backpack")
   if backpack then
      tool.Parent = backpack
      Actions.Status.lastAction = "Unequipped tool"
      Actions.Status.lastActionTime = tick()
      print("Actions: Unequipped tool -", tool.Name)
      return true
   end
   
   return false
end

-- Use currently equipped tool (activate)
function Actions.UseTool()
   if not LocalPlayer.Character then
      warn("Actions.UseTool - No character found")
      return false
   end
   
   local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
   
   if not tool then
      warn("Actions.UseTool - No tool equipped")
      return false
   end
   
   -- Activate the tool
   local success = pcall(function()
      tool:Activate()
   end)
   
   if success then
      Actions.Status.lastAction = "Used: " .. tool.Name
      Actions.Status.lastActionTime = tick()
      print("Actions: Used tool -", tool.Name)
      return true
   else
      warn("Actions.UseTool - Failed to activate tool:", tool.Name)
      return false
   end
end

-- List all available tools
function Actions.ListTools()
   local backpack = LocalPlayer:FindFirstChild("Backpack")
   if not backpack then
      return {}
   end
   
   local tools = {}
   for _, item in ipairs(backpack:GetChildren()) do
      if item:IsA("Tool") then
         table.insert(tools, item.Name)
      end
   end
   
   return tools
end

--[[
    UTILITY ACTIONS
]]--

-- Stop all current actions
function Actions.Stop()
   if not LocalPlayer.Character then
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if humanoid then
      humanoid:Move(Vector3.new(0, 0, 0))
      Actions.Status.lastAction = "Stop"
      Actions.Status.lastActionTime = tick()
      print("Actions: Stopped")
      return true
   end
   
   return false
end

-- Reset character
function Actions.Reset()
   if not LocalPlayer.Character then
      warn("Actions.Reset - No character found")
      return false
   end
   
   local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
   if humanoid then
      humanoid.Health = 0
      Actions.Status.lastAction = "Reset"
      Actions.Status.lastActionTime = tick()
      print("Actions: Character reset")
      return true
   end
   
   return false
end

-- Get current status
function Actions.GetStatus()
   return {
      lastAction = Actions.Status.lastAction,
      timeSinceLastAction = tick() - Actions.Status.lastActionTime,
      hasCharacter = LocalPlayer.Character ~= nil,
      isAlive = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0
   }
end

-- Get available actions list
function Actions.GetAvailableActions()
   return {
      Movement = {"Jump", "Sit", "Stand", "WalkTo", "WalkToPlayer", "Stop"},
      Emotes = {"Dance", "Wave", "Point", "Cheer", "Laugh", "Stadium", "PlayEmote"},
      Tools = {"EquipTool", "UnequipTool", "UseTool", "ListTools"},
      Utility = {"Reset", "GetStatus", "GetAvailableActions"}
   }
end

--[[
    MODULE INFO
]]--

Actions.Version = "1.0"
Actions.Author = "SS Hub"
Actions.Description = "Basic character actions module for AI control"

print("========================================")
print("SS Hub - Actions Module Loaded")
print("Version:", Actions.Version)
print("Available actions:", #Actions.GetAvailableActions().Movement + #Actions.GetAvailableActions().Emotes + #Actions.GetAvailableActions().Tools)
print("========================================")

return Actions
