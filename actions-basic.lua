-- SS Hub - Actions Module v1.1
-- Simplified and optimized for Roblox executors

local Actions = {}
Actions.Version = "1.1"

-- Get services and player
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Status
Actions.lastAction = "None"

-- JUMP
function Actions.Jump()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      hum.Jump = true
      Actions.lastAction = "Jump"
      return true
   end
   return false
end

-- SIT
function Actions.Sit()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      hum.Sit = true
      Actions.lastAction = "Sit"
      return true
   end
   return false
end

-- STAND
function Actions.Stand()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      hum.Sit = false
      Actions.lastAction = "Stand"
      return true
   end
   return false
end

-- DANCE
function Actions.Dance()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      local success = pcall(function()
         hum:PlayEmote("dance")
      end)
      if success then
         Actions.lastAction = "Dance"
         return true
      end
      -- Try dance1, dance2, dance3
      for i = 1, 3 do
         success = pcall(function()
            hum:PlayEmote("dance" .. i)
         end)
         if success then
            Actions.lastAction = "Dance"
            return true
         end
      end
   end
   return false
end

-- WAVE
function Actions.Wave()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      pcall(function() hum:PlayEmote("wave") end)
      Actions.lastAction = "Wave"
      return true
   end
   return false
end

-- POINT
function Actions.Point()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      pcall(function() hum:PlayEmote("point") end)
      Actions.lastAction = "Point"
      return true
   end
   return false
end

-- CHEER
function Actions.Cheer()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      pcall(function() hum:PlayEmote("cheer") end)
      Actions.lastAction = "Cheer"
      return true
   end
   return false
end

-- LAUGH
function Actions.Laugh()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      pcall(function() hum:PlayEmote("laugh") end)
      Actions.lastAction = "Laugh"
      return true
   end
   return false
end

-- WALK TO POSITION
function Actions.WalkTo(position)
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum and typeof(position) == "Vector3" then
      hum:MoveTo(position)
      Actions.lastAction = "WalkTo"
      return true
   end
   return false
end

-- WALK TO PLAYER
function Actions.WalkToPlayer(playerName)
   local target = Players:FindFirstChild(playerName)
   if not target or not target.Character then return false end
   local root = target.Character:FindFirstChild("HumanoidRootPart")
   if root then
      return Actions.WalkTo(root.Position)
   end
   return false
end

-- STOP
function Actions.Stop()
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      hum:MoveTo(player.Character.HumanoidRootPart.Position)
      Actions.lastAction = "Stop"
      return true
   end
   return false
end

-- EQUIP TOOL
function Actions.EquipTool(toolName)
   local backpack = player:FindFirstChild("Backpack")
   if not backpack then return false end
   local tool = backpack:FindFirstChild(toolName)
   if tool and player.Character then
      local hum = player.Character:FindFirstChild("Humanoid")
      if hum then
         hum:EquipTool(tool)
         Actions.lastAction = "Equipped: " .. toolName
         return true
      end
   end
   return false
end

-- UNEQUIP TOOL
function Actions.UnequipTool()
   if not player.Character then return false end
   local tool = player.Character:FindFirstChildOfClass("Tool")
   if tool then
      local backpack = player:FindFirstChild("Backpack")
      if backpack then
         tool.Parent = backpack
         Actions.lastAction = "Unequipped tool"
         return true
      end
   end
   return false
end

-- USE TOOL
function Actions.UseTool()
   if not player.Character then return false end
   local tool = player.Character:FindFirstChildOfClass("Tool")
   if tool then
      pcall(function() tool:Activate() end)
      Actions.lastAction = "Used: " .. tool.Name
      return true
   end
   return false
end

-- LIST TOOLS
function Actions.ListTools()
   local tools = {}
   local backpack = player:FindFirstChild("Backpack")
   if backpack then
      for _, item in ipairs(backpack:GetChildren()) do
         if item:IsA("Tool") then
            table.insert(tools, item.Name)
         end
      end
   end
   return tools
end

-- GET STATUS
function Actions.GetStatus()
   return {
      lastAction = Actions.lastAction,
      hasCharacter = player.Character ~= nil,
      isAlive = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
   }
end

-- GET AVAILABLE ACTIONS
function Actions.GetAvailableActions()
   return {
      Movement = {"Jump", "Sit", "Stand", "WalkTo", "WalkToPlayer", "Stop"},
      Emotes = {"Dance", "Wave", "Point", "Cheer", "Laugh"},
      Tools = {"EquipTool", "UnequipTool", "UseTool", "ListTools"},
      Utility = {"GetStatus", "GetAvailableActions"}
   }
end

print("SS Hub Actions Module v" .. Actions.Version .. " loaded")

return Actions
