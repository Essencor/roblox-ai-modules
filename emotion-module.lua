-- ============================================
-- SS Hub Emotion Module v1.0
-- Mood system for AI character behavior
-- ============================================

local EmotionModule = {}
EmotionModule.Version = "1.0"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MOODS = {
    calm     = { emote = nil,     description = "feeling calm and relaxed" },
    happy    = { emote = "wave",  description = "feeling happy and friendly" },
    excited  = { emote = "cheer", description = "feeling excited and energetic" },
    curious  = { emote = "point", description = "feeling curious and inquisitive" },
    bored    = { emote = nil,     description = "feeling a little bored" },
    annoyed  = { emote = nil,     description = "feeling slightly annoyed" },
    startled = { emote = "jump",  description = "feeling startled by something nearby" },
}

local POSITIVE_WORDS = {
    "hi", "hello", "hey", "thanks", "thank", "cool", "nice", "awesome", "great",
    "good", "love", "fun", "amazing", "wow", "yay", "happy", "interesting", "help",
    "please", "curious", "question", "friendly",
}
local NEGATIVE_WORDS = {
    "shut", "bad", "stupid", "dumb", "boring", "hate", "stop", "go away",
    "useless", "annoying", "terrible", "worst", "awful",
}

local State = {
    currentMood    = "calm",
    moodIntensity  = 0,
    lastMessageTime = tick(),
    lastEmoteTime  = 0,
    emoteInterval  = 45,
    idleThreshold  = 90,
    active         = true,
}

local function Log(msg)
    print("[Emotion] " .. tostring(msg))
end

local function DetectSentiment(text)
    local lower = tostring(text or ""):lower()
    local score = 0
    for _, w in ipairs(POSITIVE_WORDS) do
        if lower:find(w, 1, true) then score = score + 1 end
    end
    for _, w in ipairs(NEGATIVE_WORDS) do
        if lower:find(w, 1, true) then score = score - 1 end
    end
    if lower:find("%?") then score = score + 0.5 end
    return score
end

local function ShiftMood(newMood, delta)
    if not MOODS[newMood] then return end
    State.currentMood = newMood
    State.moodIntensity = math.clamp((State.moodIntensity or 0) + (delta or 1), -3, 3)
    Log("Mood -> " .. newMood .. " (intensity " .. State.moodIntensity .. ")")
end

local function StartDriftLoop()
    task.spawn(function()
        while State.active do
            task.wait(30)
            if not State.active then break end

            local idle = tick() - State.lastMessageTime

            if idle > State.idleThreshold and State.currentMood ~= "bored" then
                ShiftMood("bored", 2)
            end

            if State.moodIntensity > 0 then
                State.moodIntensity = State.moodIntensity - 1
            elseif State.moodIntensity < 0 then
                State.moodIntensity = State.moodIntensity + 1
            end

            if State.moodIntensity == 0 and State.currentMood ~= "calm" and State.currentMood ~= "bored" then
                State.currentMood = "calm"
                Log("Drifted back to calm")
            end
        end
    end)
end

-- ============================================
-- PUBLIC API
-- ============================================

function EmotionModule.GetMood()
    return State.currentMood
end

function EmotionModule.GetMoodIntensity()
    return State.moodIntensity
end

-- Returns a context string injected into the AI system prompt.
function EmotionModule.GetMoodContext()
    local mood = MOODS[State.currentMood]
    if not mood then return "" end
    return "Current mood: you are " .. mood.description
        .. ". Let this subtly shape your tone and word choice — do not announce it unless asked."
end

-- Call this when a player sends a chat message.
function EmotionModule.OnPlayerMessage(username, text)
    State.lastMessageTime = tick()
    local score = DetectSentiment(text)

    if score >= 2 then
        ShiftMood("happy", 2)
    elseif score >= 1 then
        ShiftMood("curious", 1)
    elseif score <= -2 then
        ShiftMood("annoyed", 2)
    elseif score <= -1 then
        ShiftMood("annoyed", 1)
    else
        if State.currentMood == "bored" then
            ShiftMood("calm", 1)
        end
    end
end

-- Call this from the event awareness system.
function EmotionModule.OnEvent(eventType)
    if eventType == "explosion" or eventType == "death" then
        ShiftMood("startled", 3)
    elseif eventType == "projectile" and State.currentMood ~= "startled" then
        ShiftMood("curious", 1)
    end
end

function EmotionModule.SetMood(moodName, intensity)
    if not MOODS[moodName] then
        Log("Unknown mood: " .. tostring(moodName))
        return false
    end
    State.currentMood = moodName
    State.moodIntensity = math.clamp(intensity or 2, -3, 3)
    Log("Mood set to: " .. moodName)
    return true
end

-- Returns the emote name that matches the current mood, or nil if none.
function EmotionModule.GetMoodEmote()
    local mood = MOODS[State.currentMood]
    return mood and mood.emote or nil
end

-- Plays the mood-appropriate emote if the cooldown has passed.
-- Pass the Actions module table as the first argument.
function EmotionModule.TriggerEmote(actionsModule)
    if not actionsModule then return false end
    if tick() - State.lastEmoteTime < State.emoteInterval then return false end

    local emoteName = EmotionModule.GetMoodEmote()
    if not emoteName then return false end

    local ok = pcall(function()
        if emoteName == "jump" then
            actionsModule.Jump()
        else
            actionsModule.PlayEmote(emoteName)
        end
    end)

    if ok then
        State.lastEmoteTime = tick()
        Log("Triggered mood emote: " .. emoteName)
    end
    return ok
end

function EmotionModule.GetStatus()
    return {
        mood        = State.currentMood,
        intensity   = State.moodIntensity,
        idleSeconds = math.floor(tick() - State.lastMessageTime),
        description = MOODS[State.currentMood] and MOODS[State.currentMood].description or "unknown",
    }
end

function EmotionModule.Destroy()
    State.active = false
end

-- ============================================
-- INITIALIZATION
-- ============================================

StartDriftLoop()

print("========================================")
print("SS Hub Emotion Module v" .. EmotionModule.Version)
print("Status: Ready | Starting mood: calm")
print("Moods: calm, happy, excited, curious, bored, annoyed, startled")
print("========================================")

return EmotionModule
