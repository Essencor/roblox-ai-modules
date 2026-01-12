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
   print("[Actions] Jump called")
   
   if not player then
      print("[Actions] Jump FAILED: No player")
      return false
   end
   
   if not player.Character then
      print("[Actions] Jump FAILED: No character")
      return false
   end
   
   local hum = player.Character:FindFirstChild("Humanoid")
   if not hum then
      print("[Actions] Jump FAILED: No humanoid")
      return false
   end
   
   local root = player.Character:FindFirstChild("HumanoidRootPart")
   if not root then
      print("[Actions] Jump FAILED: No HumanoidRootPart")
      return false
   end
   
   print("[Actions] Jump: Setting Jump = true")
   hum.Jump = true
   
   Actions.lastAction = "Jump"
   print("[Actions] Jump COMPLETED")
   
   return true
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
   print("[Actions] Dance called")
   
   if not player.Character then
      print("[Actions] Dance FAILED: No character")
      return false
   end
   
   local hum = player.Character:FindFirstChild("Humanoid")
   if not hum then
      print("[Actions] Dance FAILED: No humanoid")
      return false
   end
   
   print("[Actions] Dance: Trying emotes...")
   
   -- Try multiple dance emote names
   local danceEmotes = {"dance", "dance1", "dance2", "dance3"}
   
   for _, emoteName in ipairs(danceEmotes) do
      local success, err = pcall(function()
         hum:PlayEmote(emoteName)
      end)
      
      if success then
         Actions.lastAction = "Dance"
         print("[Actions] Dance COMPLETED with emote:", emoteName)
         return true
      else
         print("[Actions] Dance: Emote failed:", emoteName, err)
      end
   end
   
   -- Fallback: try loading default dance animation
   print("[Actions] Dance: Trying animation fallback...")
   local success, err = pcall(function()
      local animate = player.Character:FindFirstChild("Animate")
      if animate then
         local dance = animate:FindFirstChild("dance")
         if dance then
            local anim = dance:FindFirstChildOfClass("Animation")
            if anim then
               local track = hum:LoadAnimation(anim)
               track:Play()
               Actions.lastAction = "Dance"
               print("[Actions] Dance COMPLETED via animation")
               return true
            end
         end
      end
   end)
   
   if not success then
      print("[Actions] Dance FAILED: Animation fallback failed:", err)
   end
   
   print("[Actions] Dance FAILED: All methods exhausted")
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
