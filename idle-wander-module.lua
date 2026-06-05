-- ============================================
-- SS Hub Idle Wander Module v1.0
-- Natural idle behavior when the bot is not chatting
-- ============================================

local IdleWander = {}
IdleWander.Version = "1.0"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {
    IdleThreshold    = 60,       -- seconds of silence before wandering starts
    WanderRadius     = 30,       -- studs to wander from current position
    WanderMinWait    = 8,        -- min seconds between wander steps
    WanderMaxWait    = 22,       -- max seconds between wander steps
    FacePlayerRadius = 25,       -- look at nearby players within this range
    EmoteChance      = 0.35,     -- probability of emote per wander step
    EmoteInterval    = 30,       -- min seconds between emotes
}

local IDLE_EMOTES = { "wave", "point", "cheer", "laugh" }

local State = {
    active          = false,
    lastChatTime    = tick(),
    lastEmoteTime   = 0,
    pathfinding     = nil,
    actions         = nil,
    emotion         = nil,
}

local function Log(msg)
    print("[IdleWander] " .. tostring(msg))
end

local function GetRootPart()
    local char = LocalPlayer and LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function FindClosestPlayerRoot()
    local root = GetRootPart()
    if not root then return nil end
    local myPos = root.Position
    local best, bestDist = nil, Config.FacePlayerRadius

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - myPos).Magnitude
                if d < bestDist then
                    best, bestDist = r, d
                end
            end
        end
    end
    return best
end

local function FaceToward(targetPart)
    local root = GetRootPart()
    if not root or not targetPart then return end
    pcall(function()
        local dir = (targetPart.Position - root.Position) * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0.1 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position + dir.Unit)
        end
    end)
end

local function TryIdleEmote()
    if tick() - State.lastEmoteTime < Config.EmoteInterval then return end
    if not State.actions then return end

    local emoteName
    if State.emotion then
        emoteName = State.emotion.GetMoodEmote()
    end
    if not emoteName then
        emoteName = IDLE_EMOTES[math.random(1, #IDLE_EMOTES)]
    end

    local ok = pcall(function() State.actions.PlayEmote(emoteName) end)
    if ok then
        State.lastEmoteTime = tick()
        Log("Idle emote: " .. emoteName)
    end
end

local function PickWanderTarget()
    local root = GetRootPart()
    if not root then return nil end
    local r     = Config.WanderRadius
    local angle = math.random() * math.pi * 2
    local dist  = r * 0.3 + math.random() * r * 0.7
    return root.Position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
end

local function DoWanderStep()
    -- Face a nearby player first
    local nearbyRoot = FindClosestPlayerRoot()
    if nearbyRoot then
        FaceToward(nearbyRoot)
        task.wait(1.5)
    end

    -- Occasionally play an idle emote
    if math.random() < Config.EmoteChance then
        TryIdleEmote()
        task.wait(2)
    end

    -- Walk somewhere nearby
    if State.pathfinding then
        local target = PickWanderTarget()
        if target then
            Log("Wandering to " .. tostring(math.floor(target.X)) .. ", " .. tostring(math.floor(target.Z)))
            pcall(function()
                State.pathfinding.Navigate(target, "basic")
            end)
        end
    end
end

local function WanderLoop()
    task.spawn(function()
        while State.active do
            local wait = Config.WanderMinWait
                + math.random() * (Config.WanderMaxWait - Config.WanderMinWait)
            task.wait(wait)
            if not State.active then break end

            local idle = tick() - State.lastChatTime
            if idle >= Config.IdleThreshold then
                pcall(DoWanderStep)
            end
        end
    end)
end

-- ============================================
-- PUBLIC API
-- ============================================

-- Call after modules are loaded. Starts the background wander loop.
function IdleWander.Start(pathfindingModule, actionsModule, emotionModule)
    if State.active then return end
    State.pathfinding = pathfindingModule
    State.actions     = actionsModule
    State.emotion     = emotionModule
    State.active      = true
    WanderLoop()
    Log("Started — idle threshold: " .. Config.IdleThreshold .. "s")
end

function IdleWander.Stop()
    State.active = false
    if State.pathfinding then
        pcall(function() State.pathfinding.Stop() end)
    end
    Log("Stopped")
end

-- Call this whenever a chat message is received to reset the idle timer.
function IdleWander.OnChat()
    State.lastChatTime = tick()
    if State.pathfinding then
        pcall(function() State.pathfinding.Stop() end)
    end
end

function IdleWander.SetConfig(key, value)
    if Config[key] ~= nil then
        Config[key] = value
    end
end

function IdleWander.GetStatus()
    local idle = math.floor(tick() - State.lastChatTime)
    return {
        active        = State.active,
        idleSeconds   = idle,
        isWandering   = State.active and idle >= Config.IdleThreshold,
        idleThreshold = Config.IdleThreshold,
    }
end

-- ============================================
-- INITIALIZATION
-- ============================================

print("========================================")
print("SS Hub Idle Wander Module v" .. IdleWander.Version)
print("Status: Ready | Idle threshold: " .. Config.IdleThreshold .. "s")
print("========================================")

return IdleWander
