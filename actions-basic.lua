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
   
   -- Method 1: Direct Jump property
   print("[Actions] Jump: Method 1 - Setting Jump = true")
   hum.Jump = true
   task.wait(0.05)
   
   -- Method 2: ChangeState to Jumping
   print("[Actions] Jump: Method 2 - ChangeState")
   pcall(function()
      hum:ChangeState(Enum.HumanoidStateType.Jumping)
   end)
   task.wait(0.05)
   
   -- Method 3: Apply upward velocity
   print("[Actions] Jump: Method 3 - BodyVelocity")
   local root = player.Character:FindFirstChild("HumanoidRootPart")
   if root then
      pcall(function()
         local bv = Instance.new("BodyVelocity")
         bv.MaxForce = Vector3.new(0, math.huge, 0)
         bv.Velocity = Vector3.new(0, 50, 0)
         bv.Parent = root
         game:GetService("Debris"):AddItem(bv, 0.1)
      end)
   end
   
   Actions.lastAction = "Jump"
   print("[Actions] Jump COMPLETED (attempted all methods)")
   
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

-- DANCE (stores animation track for stopping)
Actions.currentDanceTrack = nil

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
   
   -- Stop any previous dance
   if Actions.currentDanceTrack then
      Actions.currentDanceTrack:Stop()
      Actions.currentDanceTrack = nil
   end
   
   print("[Actions] Dance: Method 1 - PlayEmote")
   -- Try PlayEmote (like /e dance)
   local success = pcall(function()
      hum:PlayEmote("dance")
   end)
   
   if success then
      Actions.lastAction = "Dance"
      print("[Actions] Dance COMPLETED via PlayEmote")
      return true
   end
   
   -- Fallback: Load and play dance animation
   print("[Actions] Dance: Method 2 - Animation")
   local animateSuccess = pcall(function()
      local animate = player.Character:FindFirstChild("Animate")
      if animate then
         local dance = animate:FindFirstChild("dance")
         if dance then
            local anim = dance:FindFirstChildOfClass("Animation")
            if anim then
               local track = hum:LoadAnimation(anim)
               track:Play()
               Actions.currentDanceTrack = track
               Actions.lastAction = "Dance"
               print("[Actions] Dance COMPLETED via animation")
               return true
            end
         end
      end
   end)
   
   if animateSuccess then
      return true
   end
   
   print("[Actions] Dance FAILED: All methods exhausted")
   return false
end

-- STOP DANCE
function Actions.StopDance()
   print("[Actions] StopDance called")
   
   if Actions.currentDanceTrack then
      Actions.currentDanceTrack:Stop()
      Actions.currentDanceTrack = nil
      print("[Actions] StopDance: Stopped animation track")
   end
   
   if not player.Character then return false end
   local hum = player.Character:FindFirstChild("Humanoid")
   if hum then
      -- Stop any playing emotes
      pcall(function()
         hum:PlayEmote("idle")
      end)
      print("[Actions] StopDance: Set to idle")
   end
   
   Actions.lastAction = "StopDance"
   return true
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
      Emotes = {"Dance", "StopDance", "Wave", "Point", "Cheer", "Laugh"},
      Tools = {"EquipTool", "UnequipTool", "UseTool", "ListTools"},
      Utility = {"GetStatus", "GetAvailableActions"}
   }
end

print("SS Hub Actions Module v" .. Actions.Version .. " loaded")

return Actions
