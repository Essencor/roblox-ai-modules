-- ============================================
-- SS Hub Actions Module v2.0 (Rethought)
-- Reliable character control for AI chatbots
-- ============================================

local Actions = {}
Actions.Version = "2.0"
Actions.State = {
    lastAction = "None",
    isExecuting = false,
    activeAnimations = {}
}

-- Get player
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function GetCharacter()
    return player and player.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Log action with consistent format
local function Log(action, status, details)
    local msg = string.format("[Actions] %s: %s", action, status)
    if details then
        msg = msg .. " - " .. details
    end
    print(msg)
end

-- ============================================
-- MOVEMENT ACTIONS
-- ============================================

function Actions.Jump()
    Log("Jump", "Started")
    
    local hum = GetHumanoid()
    local root = GetRootPart()
    
    if not hum or not root then
        Log("Jump", "Failed", "Missing humanoid or root")
        return false
    end
    
    -- Check if character is on ground using raycast
    local isGrounded = false
    pcall(function()
        local rayOrigin = root.Position
        local rayDirection = Vector3.new(0, -4, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {GetCharacter()}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        isGrounded = rayResult ~= nil
    end)
    
    if not isGrounded then
        Log("Jump", "Skipped", "Not grounded")
        return false
    end
    
    -- Method 1: Standard Jump with proper reset
    hum.Jump = true
    task.wait(0.1)
    hum.Jump = false  -- CRITICAL: Reset to prevent infinite jump
    
    -- Method 2: Physics impulse as backup
    task.wait(0.05)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X,
            50,
            root.AssemblyLinearVelocity.Z
        )
    end)
    
    Actions.State.lastAction = "Jump"
    Log("Jump", "Completed")
    return true
end

function Actions.Sit()
    Log("Sit", "Started")
    
    local hum = GetHumanoid()
    if not hum then
        Log("Sit", "Failed", "No humanoid")
        return false
    end
    
    hum.Sit = true
    Actions.State.lastAction = "Sit"
    Log("Sit", "Completed")
    return true
end

function Actions.Stand()
    Log("Stand", "Started")
    
    local hum = GetHumanoid()
    if not hum then
        Log("Stand", "Failed", "No humanoid")
        return false
    end
    
    hum.Sit = false
    Actions.State.lastAction = "Stand"
    Log("Stand", "Completed")
    return true
end

function Actions.WalkTo(position)
    Log("WalkTo", "Started", tostring(position))
    
    local hum = GetHumanoid()
    if not hum then
        Log("WalkTo", "Failed", "No humanoid")
        return false
    end
    
    if typeof(position) ~= "Vector3" then
        Log("WalkTo", "Failed", "Invalid position type")
        return false
    end
    
    hum:MoveTo(position)
    Actions.State.lastAction = "WalkTo"
    Log("WalkTo", "Completed")
    return true
end

function Actions.WalkToPlayer(playerName)
    Log("WalkToPlayer", "Started", playerName)
    
    local target = Players:FindFirstChild(playerName)
    if not target or not target.Character then
        Log("WalkToPlayer", "Failed", "Player not found or no character")
        return false
    end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        Log("WalkToPlayer", "Failed", "Target has no root part")
        return false
    end
    
    return Actions.WalkTo(targetRoot.Position)
end

function Actions.Stop()
    Log("Stop", "Started")
    
    local hum = GetHumanoid()
    local root = GetRootPart()
    
    if not hum or not root then
        Log("Stop", "Failed", "Missing humanoid or root")
        return false
    end
    
    hum:MoveTo(root.Position)
    Actions.State.lastAction = "Stop"
    Log("Stop", "Completed")
    return true
end

-- ============================================
-- EMOTE ACTIONS
-- ============================================

function Actions.PlayEmote(emoteName)
    Log("PlayEmote", "Started", emoteName)
    
    local hum = GetHumanoid()
    if not hum then
        Log("PlayEmote", "Failed", "No humanoid")
        return false
    end
    
    local success = pcall(function()
        hum:PlayEmote(emoteName)
    end)
    
    if success then
        Actions.State.lastAction = "Emote: " .. emoteName
        Log("PlayEmote", "Completed", emoteName)
        return true
    else
        Log("PlayEmote", "Failed", "Emote not available: " .. emoteName)
        return false
    end
end

function Actions.Dance()
    Log("Dance", "Started")
    
    -- Stop any existing dance
    if Actions.State.activeAnimations.dance then
        Actions.StopDance()
    end
    
    local hum = GetHumanoid()
    if not hum then
        Log("Dance", "Failed", "No humanoid")
        return false
    end
    
    -- Try PlayEmote first (works like /e dance)
    local success = pcall(function()
        hum:PlayEmote("dance")
    end)
    
    if success then
        Actions.State.lastAction = "Dance"
        Log("Dance", "Completed via PlayEmote")
        return true
    end
    
    -- Fallback: Load animation manually
    local char = GetCharacter()
    if not char then return false end
    
    local animate = char:FindFirstChild("Animate")
    if animate then
        local danceFolder = animate:FindFirstChild("dance")
        if danceFolder then
            local anim = danceFolder:FindFirstChildOfClass("Animation")
            if anim then
                local track = hum:LoadAnimation(anim)
                track:Play()
                Actions.State.activeAnimations.dance = track
                Actions.State.lastAction = "Dance"
                Log("Dance", "Completed via Animation")
                return true
            end
        end
    end
    
    Log("Dance", "Failed", "No dance animation found")
    return false
end

function Actions.StopDance()
    Log("StopDance", "Started")
    
    if Actions.State.activeAnimations.dance then
        Actions.State.activeAnimations.dance:Stop()
        Actions.State.activeAnimations.dance = nil
        Log("StopDance", "Stopped animation track")
    end
    
    local hum = GetHumanoid()
    if hum then
        pcall(function()
            hum:PlayEmote("idle")
        end)
        Log("StopDance", "Set to idle")
    end
    
    Actions.State.lastAction = "StopDance"
    return true
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

-- ============================================
-- TOOL ACTIONS
-- ============================================

function Actions.EquipTool(toolName)
    Log("EquipTool", "Started", toolName)
    
    local char = GetCharacter()
    local backpack = player and player:FindFirstChild("Backpack")
    
    if not char or not backpack then
        Log("EquipTool", "Failed", "No character or backpack")
        return false
    end
    
    local tool = backpack:FindFirstChild(toolName)
    if not tool then
        Log("EquipTool", "Failed", "Tool not found: " .. toolName)
        return false
    end
    
    local hum = GetHumanoid()
    if hum then
        hum:EquipTool(tool)
        Actions.State.lastAction = "Equipped: " .. toolName
        Log("EquipTool", "Completed", toolName)
        return true
    end
    
    return false
end

function Actions.UnequipTool()
    Log("UnequipTool", "Started")
    
    local char = GetCharacter()
    if not char then
        Log("UnequipTool", "Failed", "No character")
        return false
    end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        Log("UnequipTool", "Nothing equipped")
        return false
    end
    
    local backpack = player and player:FindFirstChild("Backpack")
    if backpack then
        tool.Parent = backpack
        Actions.State.lastAction = "Unequipped: " .. tool.Name
        Log("UnequipTool", "Completed", tool.Name)
        return true
    end
    
    return false
end

function Actions.UseTool()
    Log("UseTool", "Started")
    
    local char = GetCharacter()
    if not char then
        Log("UseTool", "Failed", "No character")
        return false
    end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        Log("UseTool", "Failed", "No tool equipped")
        return false
    end
    
    pcall(function()
        tool:Activate()
    end)
    
    Actions.State.lastAction = "Used: " .. tool.Name
    Log("UseTool", "Completed", tool.Name)
    return true
end

function Actions.ListTools()
    local tools = {}
    local backpack = player and player:FindFirstChild("Backpack")
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, item.Name)
            end
        end
    end
    
    return tools
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

function Actions.GetStatus()
    local hum = GetHumanoid()
    return {
        lastAction = Actions.State.lastAction,
        isExecuting = Actions.State.isExecuting,
        hasCharacter = GetCharacter() ~= nil,
        isAlive = hum and hum.Health > 0 or false,
        health = hum and hum.Health or 0
    }
end

function Actions.GetAvailableActions()
    return {
        Movement = {"Jump", "Sit", "Stand", "WalkTo", "WalkToPlayer", "Stop"},
        Emotes = {"Dance", "StopDance", "Wave", "Point", "Cheer", "Laugh", "PlayEmote"},
        Tools = {"EquipTool", "UnequipTool", "UseTool", "ListTools"},
        Utility = {"GetStatus", "GetAvailableActions"}
    }
end

-- ============================================
-- MODULE INITIALIZATION
-- ============================================

print("========================================")
print("SS Hub Actions Module v" .. Actions.Version)
print("Status: Ready")
print("Character:", GetCharacter() and "Found" or "Not found")
print("========================================")

return Actions
