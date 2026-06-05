-- ============================================
-- SS Hub Game Detector Module v1.0
-- Analyzes workspace to classify game type
-- ============================================

local GameDetector = {}
GameDetector.Version = "1.0"

local Players = game:GetService("Players")

local SIGNATURES = {
    obby = {
        parts  = {"kill", "checkpoint", "stage", "start", "finish", "lava", "acid", "killbrick", "jump"},
        models = {"stage", "checkpoint", "section", "obby", "course"},
        stats  = {"stage", "checkpoint", "level", "wins"},
    },
    roleplay = {
        parts  = {"door", "npc", "house", "shop", "bed", "chair", "desk", "counter", "sign"},
        models = {"npc", "building", "house", "shop", "character", "store", "room"},
        stats  = {"cash", "money", "job", "role", "salary"},
    },
    simulator = {
        parts  = {"egg", "pet", "island", "boost", "rebirth", "ore", "mine", "crop"},
        models = {"egg", "pet", "island", "shop", "crate", "chest"},
        stats  = {"coins", "gems", "tokens", "rebirths", "pets", "power", "strength"},
    },
    combat = {
        parts  = {"sword", "gun", "weapon", "bomb", "health", "respawn", "armor", "shield"},
        models = {"weapon", "gun", "sword", "arena", "base", "turret"},
        stats  = {"kills", "deaths", "kdr", "wins", "score", "points"},
    },
    social = {
        parts  = {"dance", "seat", "couch", "stage", "spotlight", "screen"},
        models = {"dance", "lounge", "hangout", "club", "theater"},
        stats  = {"friends", "likes", "visits"},
    },
}

local GAME_CONTEXTS = {
    obby     = "You are in an obstacle course (obby). Players are trying to complete stages. Be encouraging and react to their progress.",
    roleplay = "You are in a roleplay game. Engage immersively with the setting and stay in character.",
    simulator = "You are in a simulator game. Players are grinding resources and upgrades. Be enthusiastic about their gains.",
    combat   = "You are in a combat or PvP game. Players are fighting each other. Be energetic and aware of the action.",
    social   = "You are in a social hangout game. Players are here to chat and have fun. Be friendly and conversational.",
    unknown  = "",
}

local function ScoreName(name, keywords)
    local lower = name:lower()
    local count = 0
    for _, kw in ipairs(keywords) do
        if lower:find(kw, 1, true) then count = count + 1 end
    end
    return count
end

local function RunDetection()
    local scores = { obby=0, roleplay=0, simulator=0, combat=0, social=0 }

    -- Sample up to 600 workspace descendants
    local sampled = 0
    for _, desc in ipairs(workspace:GetDescendants()) do
        if sampled >= 600 then break end
        sampled = sampled + 1
        if desc:IsA("BasePart") or desc:IsA("Model") then
            local name = desc.Name
            for gtype, sig in pairs(SIGNATURES) do
                scores[gtype] = scores[gtype]
                    + ScoreName(name, sig.parts)
                    + ScoreName(name, sig.models)
            end
        end
    end

    -- Weight leaderstats 3x (very reliable signal)
    for _, plr in ipairs(Players:GetPlayers()) do
        local ls = plr:FindFirstChild("leaderstats")
        if ls then
            for _, stat in ipairs(ls:GetChildren()) do
                for gtype, sig in pairs(SIGNATURES) do
                    scores[gtype] = scores[gtype] + ScoreName(stat.Name, sig.stats) * 3
                end
            end
            break -- one player's leaderstats is enough
        end
    end

    -- Also weight game.Name
    local gameName = tostring(game.Name or ""):lower()
    for gtype, sig in pairs(SIGNATURES) do
        scores[gtype] = scores[gtype] + ScoreName(gameName, sig.parts) * 2
    end

    local bestType, bestScore, total = "unknown", 0, 0
    for gtype, score in pairs(scores) do
        total = total + score
        if score > bestScore then
            bestScore = score
            bestType = gtype
        end
    end

    local confidence = total > 0 and math.min(1, bestScore / total) or 0
    if bestScore == 0 then bestType = "unknown" end

    return {
        gameType   = bestType,
        confidence = confidence,
        scores     = scores,
        gameName   = game.Name,
        context    = GAME_CONTEXTS[bestType] or "",
    }
end

local _cache = nil

-- ============================================
-- PUBLIC API
-- ============================================

function GameDetector.Detect(forceRefresh)
    if _cache and not forceRefresh then return _cache end
    _cache = RunDetection()
    return _cache
end

-- Returns the prompt context string, empty string if confidence too low.
function GameDetector.GetContext()
    local r = GameDetector.Detect()
    if r.confidence < 0.25 or r.gameType == "unknown" then return "" end
    return r.context
end

function GameDetector.GetGameType()
    return GameDetector.Detect().gameType
end

function GameDetector.GetStatus()
    return GameDetector.Detect()
end

-- ============================================
-- INITIALIZATION
-- ============================================

task.spawn(function()
    task.wait(4)
    local r = GameDetector.Detect()
    print(string.format("[GameDetector] %q — type: %s (%.0f%% confidence)",
        tostring(r.gameName), r.gameType, r.confidence * 100))
end)

print("========================================")
print("SS Hub Game Detector Module v" .. GameDetector.Version)
print("Status: Ready")
print("========================================")

return GameDetector
