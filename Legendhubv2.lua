-- SERVICES
-- ════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ════════════════════════════════════════
-- IMMUNE USERS (Kill Aura will NEVER target these)
-- ════════════════════════════════════════
local IMMUNE_USERS = {
    ["villain63935"] = true,
    ["zicooooi"] = true,
    ["lilufxc"] = true,
}

local function isImmune(name)
    return IMMUNE_USERS[name:lower()] == true
end

-- ════════════════════════════════════════
-- SAVE / PERSIST
-- ════════════════════════════════════════
local SAVE = _G.LH_Saves or {}
_G.LH_Saves = SAVE
SAVE.kaTargets = SAVE.kaTargets or ""
SAVE.kaFriends = SAVE.kaFriends or ""
SAVE.headSit = SAVE.headSit or ""
SAVE.curTheme = SAVE.curTheme or "legend"
SAVE.keybinds = SAVE.keybinds or {}

pcall(function()
    if writefile then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile("lh_data.json")) end)
        if ok and type(d) == "table" then
            for k, v in pairs(d) do SAVE[k] = v end
        end
    end
end)

local function DoSave()
    pcall(function()
        if writefile then
            writefile("lh_data.json", HttpService:JSONEncode({
                kaTargets = SAVE.kaTargets,
                kaFriends = SAVE.kaFriends,
                headSit = SAVE.headSit,
                curTheme = SAVE.curTheme,
                keybinds = SAVE.keybinds,
            }))
        end
    end)
end

local function SaveSetting(key, value)
    SAVE[key] = value
    DoSave()
end

local function LoadSetting(key, defaultValue)
    if SAVE[key] ~= nil then return SAVE[key] end
    return defaultValue
end

-- ════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════
local LH = {
    -- Combat
    KillAura = LoadSetting("KillAura", true),
    KillAuraRange = LoadSetting("KillAuraRange", 50),
    AttacksPerSecond = LoadSetting("AttacksPerSecond", 10000),
    Hitbox = LoadSetting("Hitbox", false),
    HitboxSize = LoadSetting("HitboxSize", 10),
    HitboxVis = LoadSetting("HitboxVis", false),
    BypassRange = LoadSetting("BypassRange", true),
    SilentTPHit = LoadSetting("SilentTPHit", false),
    GrabSpamNoTP = LoadSetting("GrabSpamNoTP", false),
    grabTargetName = LoadSetting("grabTargetName", ""),
    AutoFarm = LoadSetting("AutoFarm", false),
    RapidHit = LoadSetting("RapidHit", false),
    PunchSpam = LoadSetting("PunchSpam", false),
    FakeJitter = LoadSetting("FakeJitter", false),
    AutoStomp = LoadSetting("AutoStomp", false),
    
    -- Target
    Strafe = LoadSetting("Strafe", false),
    StrafeRadius = LoadSetting("StrafeRadius", 10),
    StrafeSpeed = LoadSetting("StrafeSpeed", 4),
    StrafeOffset = LoadSetting("StrafeOffset", -2),
    Backstab = LoadSetting("Backstab", false),
    strafeName = LoadSetting("strafeName", ""),
    Orbit = LoadSetting("Orbit", false),
    orbRadius = LoadSetting("orbRadius", 10),
    orbSpeed = LoadSetting("orbSpeed", 5),
    orbHeight = LoadSetting("orbHeight", 2),
    orbitName = LoadSetting("orbitName", ""),
    HeadSit = LoadSetting("HeadSit", false),
    headSitName = LoadSetting("headSitName", ""),
    
    -- Movement
    TPWalk = LoadSetting("TPWalk", false),
    tpSpeed = LoadSetting("tpSpeed", 50),
    Fly = LoadSetting("Fly", false),
    flySpeed = LoadSetting("flySpeed", 80),
    Noclip = LoadSetting("Noclip", false),
    InfJump = LoadSetting("InfJump", false),
    Spin = LoadSetting("Spin", false),
    spinSpeed = LoadSetting("spinSpeed", 60),
    Glitch = LoadSetting("Glitch", false),
    glitchInt = LoadSetting("glitchInt", 4),
    glitchName = LoadSetting("glitchName", ""),
    DeathTP = LoadSetting("DeathTP", false),
    
    -- Visual
    Invisible = LoadSetting("Invisible", false),
    RainbowTag = LoadSetting("RainbowTag", false),
    RainbowSpeed = LoadSetting("RainbowSpeed", 8),
    rpMode = LoadSetting("rpMode", "rainbow"),
    NameTypewriter = LoadSetting("NameTypewriter", false),
    BioPhrases = LoadSetting("BioPhrases", false),
    userPhrases = LoadSetting("userPhrases", {"LEGEND ON TOP!"}),
    BioTypeSpeed = LoadSetting("BioTypeSpeed", 15),
    
    -- Defense
    AutoBlock = LoadSetting("AutoBlock", false),
    AutoParry = LoadSetting("AutoParry", false),
    parryRange = LoadSetting("parryRange", 12),
    AntiRag = LoadSetting("AntiRag", true),
    AntiRagCombo = LoadSetting("AntiRagCombo", false),
    Invincible = LoadSetting("Invincible", false),
    AntiFling = LoadSetting("AntiFling", false),
    DodgeGrab = LoadSetting("DodgeGrab", false),
    SafeSpot = LoadSetting("SafeSpot", false),
    AntiAFK = LoadSetting("AntiAFK", true),
    
    -- Ghost
    Ghost = LoadSetting("Ghost", false),
    
    -- Environment
    -- (no persistent env settings)
    
    -- Util
    AutoRespawn = LoadSetting("AutoRespawn", false),
    
    -- ESP
    EspBox = LoadSetting("EspBox", false),
    
    -- Other
    currentTheme = LoadSetting("currentTheme", "legend"),
}

-- ════════════════════════════════════════
-- UTILITIES
-- ════════════════════════════════════════
local function parseList(str)
    local t = {}
    if str == "" then return t end
    for w in str:gmatch("%S+") do table.insert(t, w:lower()) end
    return t
end

local function matchAny(arr, name)
    local ln = name:lower()
    for _, k in ipairs(arr) do
        if ln:find(k, 1, true) then return true end
    end
    return false
end

local function isFriend(n)
    if isImmune(n) then return true end
    return matchAny(LH.friendList, n)
end

local function isTarget(n)
    if isImmune(n) then return false end
    if #LH.targetList == 0 then return true end
    return matchAny(LH.targetList, n)
end

local function findPlayer(name)
    if name == "" then return nil end
    local s = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and (p.Name:lower():find(s) or (p.DisplayName and p.DisplayName:lower():find(s))) then
            if not isImmune(p.Name) then return p end
        end
    end
    return nil
end

local function findNearest(range)
    local ch = lp.Character
    if not ch then return nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local mp = hrp.Position
    local best, bd = nil, range
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp or not p.Character then continue end
        if isImmune(p.Name) then continue end
        if isFriend(p.Name) or isFriend(p.DisplayName) then continue end
        if not isTarget(p.Name) and not isTarget(p.DisplayName) then continue end
        local h = p.Character:FindFirstChild("HumanoidRootPart")
        local hu = p.Character:FindFirstChildOfClass("Humanoid")
        if h and hu and hu.Health > 0 then
            local d = (h.Position - mp).Magnitude
            if d <= range and d < bd then
                bd = d
                best = p
            end
        end
    end
    return best
end

-- ════════════════════════════════════════
-- REMOTES
-- ════════════════════════════════════════
local HitRF, PunchRF, BlockRF, GrabRF, BioColR, RPColR, NameR, BioR

local function GetRemote(...)
    local cur = ReplicatedStorage
    for _, n in ipairs({...}) do
        if cur then
            cur = cur:FindFirstChild(n)
            if not cur then
                pcall(function() cur = cur:WaitForChild(n, 2) end)
            end
            if not cur then return nil end
        else
            return nil
        end
    end
    return cur
end

HitRF = GetRemote("Packages", "Knit", "Services", "CombatService", "RF", "Hit")
PunchRF = GetRemote("Packages", "Knit", "Services", "CombatService", "RF", "PunchDo")
BlockRF = GetRemote("Packages", "Knit", "Services", "CombatService", "RF", "Block")
GrabRF = GetRemote("Packages", "Knit", "Services", "CombatService", "RF", "Grab")

local rem = ReplicatedStorage:FindFirstChild("Remotes")
if rem then
    BioR = rem:FindFirstChild("UpdateBio")
    BioColR = rem:FindFirstChild("UpdateBioColor")
    RPColR = rem:FindFirstChild("UpdateRPColor")
    NameR = rem:FindFirstChild("UpdateRPName")
end

-- ════════════════════════════════════════
-- COMBAT FUNCTIONS
-- ════════════════════════════════════════
local function doHit(hum, myhrp)
    if not hum or not hum.Parent then return end
    if hum.Parent and hum.Parent.Name and isImmune(hum.Parent.Name) then return end
    task.spawn(function()
        if HitRF then
            pcall(function()
                HitRF:InvokeServer(hum, vector.create(myhrp.Position.X, myhrp.Position.Y, myhrp.Position.Z))
            end)
        end
    end)
end

local function doGrab(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    if isImmune(targetPlayer.Name) then return end
    task.spawn(function()
        local myChar = lp.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP and GrabRF then
            local orig = myHRP.CFrame
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 2)
            myHRP.AssemblyLinearVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
            pcall(function() GrabRF:InvokeServer(targetPlayer) end)
            myHRP.CFrame = orig
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function doRawGrab(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    if isImmune(targetPlayer.Name) then return end
    task.spawn(function()
        if GrabRF then pcall(function() GrabRF:InvokeServer(targetPlayer) end) end
    end)
end

local function cleanRag(ch)
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if hu then
        for _, st in ipairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding}) do
            pcall(function() hu:SetStateEnabled(st, false) end)
        end
        hu.PlatformStand = false
    end
    for _, o in ipairs(ch:GetDescendants()) do
        if (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
            o:Destroy()
        elseif o:IsA("Motor6D") then
            o.Enabled = true
        end
    end
end

-- Anti-rag combo (arc system)
local arc = {conn = nil, platConn = nil, origCF = nil, cleaned = false, inRet = false, grabbed = false, plat = nil, retTask = nil}
local ARC_SAFE = CFrame.new(0, 100, 0)

local function arcRemPlat()
    if arc.platConn then arc.platConn:Disconnect() end
    if arc.plat then pcall(function() arc.plat:Destroy() end) end
end

local function arcSpawnPlat(pos)
    arcRemPlat()
    local p = Instance.new("Part")
    p.Size = Vector3.new(12,1,12)
    p.CFrame = CFrame.new(pos.X, pos.Y-3.5, pos.Z)
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 0.4
    p.Parent = workspace
    arc.plat = p
    local topY = p.Position.Y + 0.5
    arc.platConn = RunService.Heartbeat:Connect(function()
        if not arc.plat or not arc.plat.Parent then arcRemPlat(); return end
        local ch = lp.Character
        local h = ch and ch:FindFirstChild("HumanoidRootPart")
        if h and h.Position.Y < topY then
            h.CFrame = CFrame.new(pos.X, topY+3.5, pos.Z)
            h.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function arcForceEnd(ch)
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if hu then
        for _, st in ipairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding}) do
            pcall(function() hu:SetStateEnabled(st, false) end)
        end
        hu.PlatformStand = false
        hu:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    for _, o in ipairs(ch:GetDescendants()) do
        if o:IsA("Motor6D") then o.Enabled = true
        elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy()
        end
    end
end

local function arcDoReturn(hrp, saved)
    if hrp and hrp.Parent then
        arcSpawnPlat(ARC_SAFE.Position)
        hrp.CFrame = CFrame.new(ARC_SAFE.Position)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    arc.retTask = task.delay(3.5, function()
        arcRemPlat()
        if hrp and hrp.Parent and saved then hrp.CFrame = saved end
        arc.origCF = nil
        arc.retTask = nil
        arc.cleaned = false
        arc.inRet = false
        arc.grabbed = false
    end)
end

local function arcOnChar(ch)
    local hrp = ch:WaitForChild("HumanoidRootPart", 10)
    local hu = ch:WaitForChild("Humanoid", 10)
    if arc.conn then arc.conn:Disconnect() end
    if arc.platConn then arc.platConn:Disconnect() end
    arc.origCF = nil
    arc.cleaned = false
    arc.inRet = false
    arc.grabbed = false
    if arc.retTask then task.cancel(arc.retTask) end
    task.wait(2.5)
    if not LH.AntiRagCombo then return end
    arc.platConn = hu:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not LH.AntiRagCombo or arc.inRet then return end
        if hu.PlatformStand then
            arc.grabbed = true
            if not arc.origCF then arc.origCF = hrp.CFrame end
        end
    end)
    arc.conn = RunService.Heartbeat:Connect(function()
        if not LH.AntiRagCombo or not ch.Parent then return end
        if arc.inRet then return end
        local tot, dis = 0, 0
        for _, o in ipairs(ch:GetDescendants()) do
            if o:IsA("Motor6D") then
                tot = tot + 1
                if not o.Enabled then dis = dis + 1 end
            end
        end
        local isRag = tot >= 12 and (dis/tot) >= 0.9
        if isRag then
            if not arc.origCF then arc.origCF = hrp.CFrame end
            if arc.grabbed then
                if not arc.cleaned then arcForceEnd(ch); arc.cleaned = true end
                if not arc.retTask then arc.inRet = true; arcDoReturn(hrp, arc.origCF) end
            else
                hrp.CFrame = ARC_SAFE
                if not arc.cleaned then arcForceEnd(ch); arc.cleaned = true end
            end
        else
            if not arc.grabbed and arc.origCF and not arc.retTask then
                arc.inRet = true
                local sv = arc.origCF
                arc.retTask = task.delay(0.1, function()
                    if hrp and hrp.Parent and sv then hrp.CFrame = sv end
                    arc.origCF = nil
                    arc.retTask = nil
                    arc.cleaned = false
                    arc.inRet = false
                    arc.grabbed = false
                end)
            end
        end
    end)
end

-- ════════════════════════════════════════
-- KILL AURA
-- ════════════════════════════════════════
local kaLast = 0
local kaConn

local function StartKA()
    if kaConn then kaConn:Disconnect() end
    kaConn = RunService.Heartbeat:Connect(function()
        if not LH.KillAura then return end
        local ch = lp.Character
        local myHRP = ch and ch:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        
        local now = tick()
        if now - kaLast < 1 / LH.AttacksPerSecond then return end
        
        local best, bd = nil, LH.KillAuraRange
        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end
            if isImmune(p.Name) then continue end
            if isFriend(p.Name) or isFriend(p.DisplayName) then continue end
            if not isTarget(p.Name) and not isTarget(p.DisplayName) then continue end
            
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            local hu = p.Character:FindFirstChildOfClass("Humanoid")
            if h and hu and hu.Health > 0 then
                local d = (h.Position - myHRP.Position).Magnitude
                if d <= LH.KillAuraRange and d < bd then
                    bd = d
                    best = hu
                end
            end
        end
        
        if best then
            task.spawn(function() doHit(best, myHRP) end)
            kaLast = now
        end
    end)
end

-- ════════════════════════════════════════
-- OTHER COMBAT FEATURES
-- ════════════════════════════════════════
-- AutoBlock
RunService.Heartbeat:Connect(function()
    if LH.AutoBlock and BlockRF then
        pcall(function() BlockRF:InvokeServer(true) end)
    end
end)

-- AutoFarm
RunService.Heartbeat:Connect(function()
    if not LH.AutoFarm then return end
    local ch = lp.Character
    if not ch then return end
    local myHRP = ch:FindFirstChild("HumanoidRootPart")
    local myHu = ch:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHu or myHu.Health <= 0 then return end
    local tgt = findNearest(LH.KillAuraRange * 3)
    if tgt and tgt.Character then
        local tHRP = tgt.Character:FindFirstChild("HumanoidRootPart")
        local tHu = tgt.Character:FindFirstChildOfClass("Humanoid")
        if tHRP and tHu and tHu.Health > 0 then
            myHRP.CFrame = CFrame.new(tHRP.Position - tHRP.CFrame.LookVector*3 + Vector3.new(0,2,0), tHRP.Position)
            if PunchRF then pcall(function() PunchRF:InvokeServer() end) end
            doHit(tHu, myHRP)
        end
    end
end)

-- Rapid Hit
local lastRapidHit = 0
local rhConn
local function startRapidHit()
    if rhConn then rhConn:Disconnect() end
    rhConn = RunService.Heartbeat:Connect(function()
        if not LH.RapidHit then
            if rhConn then rhConn:Disconnect(); rhConn = nil end
            return
        end
        local now = tick()
        if now - lastRapidHit < 0.1 then return end
        lastRapidHit = now
        local ch = lp.Character
        local myHRP = ch and ch:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end
            if isImmune(p.Name) then continue end
            if isFriend(p.Name) or isFriend(p.DisplayName) then continue end
            if not isTarget(p.Name) and not isTarget(p.DisplayName) then continue end
            local hu = p.Character:FindFirstChildOfClass("Humanoid")
            if hu and hu.Health > 0 then
                pcall(function()
                    if HitRF then HitRF:InvokeServer(hu, vector.create(myHRP.Position.X, myHRP.Position.Y, myHRP.Position.Z)) end
                end)
            end
        end
    end)
end

-- Punch Spam
local psConn
local function startPunchSpam()
    if psConn then psConn:Disconnect() end
    psConn = RunService.Heartbeat:Connect(function()
        if not LH.PunchSpam then
            if psConn then psConn:Disconnect(); psConn = nil end
            return
        end
        if PunchRF then pcall(function() PunchRF:InvokeServer() end) end
    end)
end

-- Jitter
local flJitterConn
local function startJitter()
    if flJitterConn then flJitterConn:Disconnect() end
    flJitterConn = RunService.Heartbeat:Connect(function()
        if not LH.FakeJitter then return end
        local ch = lp.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = hrp.CFrame * CFrame.new((math.random()-.5)*1.2, (math.random()-.5)*.5, (math.random()-.5)*1.2)
    end)
end

-- Auto Stomp
RunService.Heartbeat:Connect(function()
    if not LH.AutoStomp then return end
    local ch = lp.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and not isFriend(p.Name) and not isImmune(p.Name) then
            local tHu = p.Character:FindFirstChildOfClass("Humanoid")
            local tH = p.Character:FindFirstChild("HumanoidRootPart")
            if tHu and tH and tHu.Health > 0 and (tHu.PlatformStand or tHu.Sit) then
                task.spawn(function()
                    local orig = hrp.CFrame
                    hrp.CFrame = tH.CFrame * CFrame.new(0,0,-2)
                    doHit(tHu, hrp)
                    task.wait(0.05)
                    if hrp and hrp.Parent then hrp.CFrame = orig end
                end)
            end
        end
    end
end)

-- Grab Spam
local lastGrabSpam = 0
RunService.Heartbeat:Connect(function()
    if not LH.GrabSpamNoTP then return end
    local now = tick()
    if now - lastGrabSpam < 0.35 then return end
    lastGrabSpam = now
    local ch = lp.Character
    if not ch then return end
    local myHRP = ch:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp or not p.Character then continue end
        if isImmune(p.Name) then continue end
        if isFriend(p.Name) or isFriend(p.DisplayName) then continue end
        if not isTarget(p.Name) and not isTarget(p.DisplayName) then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local hu = p.Character:FindFirstChildOfClass("Humanoid")
        if hrp and hu and hu.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= LH.KillAuraRange then
            doRawGrab(p)
        end
    end
end)

-- ════════════════════════════════════════
-- TARGET & STRAFE / ORBIT / HEAD SIT
-- ════════════════════════════════════════
local strafeAngle = 0
local orbitAngle = 0

RunService.Heartbeat:Connect(function(dt)
    local ch = lp.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Strafe
    if LH.Strafe and LH.strafeName ~= "" then
        local tgt = findPlayer(LH.strafeName)
        if tgt and tgt.Character then
            local tH = tgt.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                local tp = tH.Position
                local np
                if LH.Backstab then
                    np = tp + (-tH.CFrame.LookVector * LH.StrafeRadius) + Vector3.new(0, LH.StrafeOffset, 0)
                else
                    strafeAngle = strafeAngle + LH.StrafeSpeed * dt
                    np = Vector3.new(
                        tp.X + math.cos(strafeAngle)*LH.StrafeRadius,
                        tp.Y + LH.StrafeOffset,
                        tp.Z + math.sin(strafeAngle)*LH.StrafeRadius
                    )
                end
                hrp.CFrame = CFrame.new(np, Vector3.new(tp.X, hrp.Position.Y, tp.Z))
            end
        end
    end
    
    -- Orbit
    if LH.Orbit and LH.orbitName ~= "" then
        local tgt = findPlayer(LH.orbitName)
        if tgt and tgt.Character then
            local tH = tgt.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                orbitAngle = orbitAngle + LH.orbSpeed * dt
                local tp = tH.Position
                hrp.CFrame = CFrame.new(
                    tp + Vector3.new(math.cos(orbitAngle)*LH.orbRadius, LH.orbHeight, math.sin(orbitAngle)*LH.orbRadius),
                    tp
                )
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
    
    -- Head Sit
    if LH.HeadSit and LH.headSitName ~= "" then
        local tgt = findPlayer(LH.headSitName)
        if tgt and tgt.Character then
            local hd = tgt.Character:FindFirstChild("Head")
            if hd and (hd.Position - hrp.Position).Magnitude <= LH.KillAuraRange * 2 then
                hrp.CFrame = CFrame.new(hd.Position + Vector3.new(0,3,0))
            end
        end
    end
end)

-- ════════════════════════════════════════
-- MOVEMENT
-- ════════════════════════════════════════
-- TP Walk
RunService.Heartbeat:Connect(function(dt)
    if not LH.TPWalk then return end
    local ch = lp.Character
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hu and hrp and hu.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + hu.MoveDirection * LH.tpSpeed * dt
    end
end)

-- Fly
local flyBV, flyBG, flyConn
local function startFly()
    local ch = lp.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if hu then hu.PlatformStand = true end
    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.D = 150
    LH.Fly = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not LH.Fly then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v = v - Vector3.new(0,1,0) end
        if v.Magnitude > 0 then v = v.Unit * LH.flySpeed end
        if flyBV and flyBV.Parent then flyBV.Velocity = v end
        if flyBG and flyBG.Parent then flyBG.CFrame = cam.CFrame end
    end)
end

local function stopFly()
    LH.Fly = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    pcall(function() if flyBV then flyBV:Destroy(); flyBV = nil end end)
    pcall(function() if flyBG then flyBG:Destroy(); flyBG = nil end end)
    pcall(function() lp.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false end)
end

-- Noclip
RunService.Stepped:Connect(function()
    if not LH.Noclip then return end
    local ch = lp.Character
    if not ch then return end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.CanCollide = false end)
        end
    end
end)

-- Inf Jump
UserInputService.JumpRequest:Connect(function()
    if not LH.InfJump then return end
    local ch = lp.Character
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if hu then pcall(function() hu:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

-- Spin
local spConn, spAng = nil, 0
local function startSpin()
    pcall(function()
        local ch = lp.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        spConn = RunService.Heartbeat:Connect(function(dt)
            if not LH.Spin then return end
            spAng = spAng + LH.spinSpeed * dt
            pcall(function() hrp.AssemblyAngularVelocity = Vector3.new(0, LH.spinSpeed, 0) end)
        end)
    end)
end

local function stopSpin()
    pcall(function()
        if spConn then spConn:Disconnect(); spConn = nil end
        local ch = lp.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyAngularVelocity = Vector3.zero end
    end)
end

-- Glitch
local glConn
local function startGlitch()
    if glConn then glConn:Disconnect() end
    glConn = RunService.RenderStepped:Connect(function()
        if not LH.Glitch then return end
        local tgt = findPlayer(LH.glitchName) or findNearest(9999)
        if not tgt or not tgt.Character then return end
        if isImmune(tgt.Name) then return end
        local tH = tgt.Character:FindFirstChild("HumanoidRootPart")
        if not tH then return end
        local ch = lp.Character
        if not ch then return end
        local mH = ch:FindFirstChild("HumanoidRootPart")
        if not mH then return end
        mH.AssemblyLinearVelocity = Vector3.zero
        local r = LH.glitchInt
        for _ = 1, 8 do
            mH.CFrame = tH.CFrame * CFrame.new(math.random(-r,r), math.random(-2,2), math.random(-r,r)) * CFrame.Angles(math.rad(math.random(-360,360)), math.rad(math.random(-360,360)), math.rad(math.random(-360,360)))
        end
    end)
end

-- DeathTP
lp.CharacterAdded:Connect(function(ch)
    local hrp = ch:WaitForChild("HumanoidRootPart", 8)
    if LH.DeathTP and LH.deathCF then
        task.wait(0.1)
        hrp.CFrame = LH.deathCF
    end
    local hu = ch:WaitForChild("Humanoid", 8)
    hu.Died:Connect(function()
        if hrp and hrp.Parent then LH.deathCF = hrp.CFrame end
    end)
end)

-- ════════════════════════════════════════
-- VISUAL (Invisible, RP Color, etc.)
-- ════════════════════════════════════════
-- Invisible
RunService.RenderStepped:Connect(function()
    if not LH.Invisible then return end
    local ch = lp.Character
    if not ch then return end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.LocalTransparencyModifier = 1
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
end)

-- RP Color
local rpConn
local rpHue = 0
local rpPhase = 0
local rpNameIdx = 1
local bioTask
local currentPhrase = ""

local function startPhrases()
    if bioTask then task.cancel(bioTask) end
    bioTask = task.spawn(function()
        while LH.BioPhrases do
            local s = LH.userPhrases[math.random(1, #LH.userPhrases)]
            local t = ""
            local dl = 1 / (LH.BioTypeSpeed or 10)
            for u = 1, #s do
                if not LH.BioPhrases then break end
                t = string.sub(s, 1, u)
                currentPhrase = t
                task.wait(dl)
            end
            task.wait(0.05)
            currentPhrase = ""
        end
    end)
end

local function startRP()
    if rpConn then return end
    local aB, aR, bT, rT, nT = 0, 0, 0, 0, 0
    rpConn = RunService.RenderStepped:Connect(function(dt)
        if not LH.RainbowTag then return end
        local spd = LH.RainbowSpeed * 0.05
        aB = aB + dt * spd
        aR = aR + dt * spd
        bT = bT + dt
        rT = rT + dt
        nT = nT + dt
        
        if bT >= 0.06 and LH.BioPhrases and currentPhrase ~= "" then
            bT = 0
            if BioR then pcall(function() BioR:FireServer(currentPhrase) end) end
        end
        
        if LH.NameTypewriter and nT >= 0.1 then
            nT = 0
            local fn = lp.DisplayName
            if NameR then
                pcall(function() NameR:FireServer(string.sub(fn, 1, rpNameIdx)) end)
            end
            rpNameIdx = rpNameIdx >= #fn and 1 or rpNameIdx + 1
        end
        
        if rT >= 0.04 then
            rT = 0
            local cB, cR
            local m = LH.rpMode
            -- Expanded color presets
            if m == "rainbow" then
                cB = Color3.fromHSV((aB+0.22)%1,0.65,0.98)
                cR = Color3.fromHSV(aR%1,0.65,0.98)
            elseif m == "neon" then
                cB = Color3.fromHSV((aB+0.22)%1,1,1)
                cR = Color3.fromHSV(aR%1,1,1)
            elseif m == "pastel" then
                cB = Color3.fromHSV((aB+0.22)%1,0.35,0.99)
                cR = Color3.fromHSV(aR%1,0.35,0.99)
            elseif m == "fire" then
                cB = Color3.fromHSV((aB*0.1)%0.15,0.9,1)
                cR = Color3.fromHSV((aR*0.1)%0.15,0.9,1)
            elseif m == "ice" then
                cB = Color3.fromHSV(0.55+(aB*0.05)%0.1,0.7,0.95)
                cR = Color3.fromHSV(0.55+(aR*0.05)%0.1,0.7,0.95)
            elseif m == "galaxy" then
                cB = Color3.fromHSV((aB*0.2)%1,0.8,0.9)
                cR = Color3.fromHSV((aR*0.2)%1,0.8,0.9)
            elseif m == "toxic" then
                cB = Color3.fromHSV(0.3+(aB*0.08)%0.15,0.85,0.95)
                cR = Color3.fromHSV(0.3+(aR*0.08)%0.15,0.85,0.95)
            elseif m == "blood" then
                cB = Color3.fromHSV(0, 1, 0.35 + math.abs(math.sin(aB * 2)) * 0.65)
                cR = Color3.fromHSV(0.01, 1, 0.4 + math.abs(math.cos(aR * 2)) * 0.6)
            elseif m == "dark" then
                cB = Color3.fromHSV((aB+0.22)%1, 0.9, 0.25)
                cR = Color3.fromHSV(aR%1, 0.9, 0.25)
            elseif m == "light" then
                cB = Color3.fromHSV((aB+0.22)%1, 0.25, 0.95)
                cR = Color3.fromHSV(aR%1, 0.25, 0.95)
            elseif m == "deep" then
                cB = Color3.fromHSV((aB+0.22)%1, 0.95, 0.55)
                cR = Color3.fromHSV(aR%1, 0.95, 0.55)
            elseif m == "soft" then
                cB = Color3.fromHSV((aB+0.22)%1, 0.4, 0.85)
                cR = Color3.fromHSV(aR%1, 0.4, 0.85)
            elseif m == "vivid" then
                cB = Color3.fromHSV((aB+0.22)%1, 1, 0.95)
                cR = Color3.fromHSV(aR%1, 1, 0.95)
            elseif m == "muted" then
                cB = Color3.fromHSV((aB+0.22)%1, 0.5, 0.6)
                cR = Color3.fromHSV(aR%1, 0.5, 0.6)
            else
                cB = Color3.fromHSV(aB%1,0.8,0.9)
                cR = Color3.fromHSV(aR%1,0.8,0.9)
            end
            if cB and BioColR then pcall(function() BioColR:FireServer(cB) end) end
            if cR and RPColR then pcall(function() RPColR:FireServer(cR) end) end
        end
    end)
end

local function stopRP()
    if rpConn then rpConn:Disconnect(); rpConn = nil end
end

-- ════════════════════════════════════════
-- DEFENSE
-- ════════════════════════════════════════
-- Anti-Rag
RunService.Heartbeat:Connect(function()
    if LH.AntiRag then
        local ch = lp.Character
        if ch then cleanRag(ch) end
    end
end)

lp.CharacterAdded:Connect(function(ch)
    ch.DescendantAdded:Connect(function()
        if LH.AntiRag then task.wait(); cleanRag(ch) end
    end)
    if LH.AntiRagCombo then task.spawn(arcOnChar, ch) end
end)

-- Invincible, Anti-Fling, AutoParry, DodgeGrab
RunService.Heartbeat:Connect(function()
    local ch = lp.Character
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    
    if LH.Invincible and hu then
        if hu.Health <= 0 then hu.Health = hu.MaxHealth end
        if hu.PlatformStand then hu.PlatformStand = false end
        if hu.Sit then hu.Sit = false end
        for _, st in ipairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding}) do
            pcall(function() hu:SetStateEnabled(st, false) end)
        end
        for _, o in ipairs(ch:GetDescendants()) do
            if o:IsA("Motor6D") then o.Enabled = true
            elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy()
            end
        end
    end
    
    if LH.AntiFling and hrp then
        if hrp.AssemblyAngularVelocity.Magnitude > 15 then hrp.AssemblyAngularVelocity = Vector3.zero end
        if hrp.AssemblyLinearVelocity.Magnitude > 150 then hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * 0.75 end
    end
    
    if LH.AutoParry and hrp and BlockRF then
        for _, p in ipairs(Players:GetPlayers()) do
            if p == lp or isFriend(p.Name) or isImmune(p.Name) or not p.Character then continue end
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if not h then continue end
            if (h.Position - hrp.Position).Magnitude < LH.parryRange then
                pcall(function() BlockRF:InvokeServer(true) end)
                break
            end
        end
    end
    
    if LH.DodgeGrab and hu and hrp and hu.PlatformStand then
        hu.PlatformStand = false
        hu:ChangeState(Enum.HumanoidStateType.GettingUp)
        hrp.CFrame = CFrame.new(0, 100, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        for _, o in ipairs(ch:GetDescendants()) do
            if o:IsA("Motor6D") then o.Enabled = true
            elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy()
            end
        end
    end
end)

-- Safe Spot
local safeOrig, safeConn = nil, nil
local SAFE_CF = CFrame.new(0, 100, 0)
local function goSafe()
    local ch = lp.Character
    local h = ch and ch:FindFirstChild("HumanoidRootPart")
    if not h then return end
    safeOrig = h.CFrame
    h.CFrame = SAFE_CF
    h.AssemblyLinearVelocity = Vector3.zero
    pcall(function() ch:FindFirstChildOfClass("Humanoid").PlatformStand = true end)
    if safeConn then safeConn:Disconnect() end
    safeConn = RunService.Heartbeat:Connect(function()
        if not LH.SafeSpot then return end
        local c = lp.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if hr then
            hr.CFrame = SAFE_CF
            hr.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end
local function endSafe()
    if safeConn then safeConn:Disconnect(); safeConn = nil end
    local ch = lp.Character
    local h = ch and ch:FindFirstChild("HumanoidRootPart")
    if h then
        pcall(function()
            local hu = ch:FindFirstChildOfClass("Humanoid")
            if hu then hu.PlatformStand = false; hu.Sit = false; hu:ChangeState(Enum.HumanoidStateType.GettingUp) end
        end)
        h.AssemblyLinearVelocity = Vector3.zero
        if safeOrig then h.CFrame = safeOrig; safeOrig = nil end
    end
end

-- Anti-AFK
lp.Idled:Connect(function()
    if LH.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ════════════════════════════════════════
-- GHOST
-- ════════════════════════════════════════
local ghost = {decoy = nil, conn = nil, died = nil}
local GHOST_POS = Vector3.new(0, 10000, 0)

do
    local gp = Instance.new("Part")
    gp.Size = Vector3.new(750,1,750)
    gp.Anchored = true
    gp.CanCollide = true
    gp.Transparency = 1
    gp.Parent = workspace
    gp.CFrame = CFrame.new(GHOST_POS)
end

local function stopGhost(noTP)
    if not LH.Ghost then return end
    LH.Ghost = false
    if ghost.conn then ghost.conn:Disconnect(); ghost.conn = nil end
    if ghost.died then ghost.died:Disconnect(); ghost.died = nil end
    local ch = lp.Character
    if ch then
        for _, v in ipairs(ch:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 0
            end
        end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        local hu = ch:FindFirstChildOfClass("Humanoid")
        if hu then hu.PlatformStand = false; hu.AutoRotate = true end
        if hrp and ghost.decoy and ghost.decoy.Parent and not noTP then
            local dHRP = ghost.decoy:FindFirstChild("HumanoidRootPart")
            if dHRP then
                task.wait()
                hrp.CFrame = dHRP.CFrame + Vector3.new(0,2,0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
        workspace.CurrentCamera.CameraSubject = hu or ch
    end
    if ghost.decoy then ghost.decoy:Destroy(); ghost.decoy = nil end
end

local function startGhost()
    if LH.Ghost then return end
    local ch = lp.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hu then return end
    ch.Archivable = true
    local cl = ch:Clone()
    ch.Archivable = false
    cl.Name = "Ghost"
    for _, v in ipairs(cl:GetDescendants()) do
        if v:IsA("BaseScript") then v:Destroy() end
    end
    for _, v in ipairs(cl:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
            v.Massless = false
            v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0.5
        elseif v:IsA("Accessory") then
            for _, p in ipairs(v:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = 0.5
                    p.CanCollide = false
                end
            end
        end
    end
    local clHu = cl:FindFirstChildOfClass("Humanoid")
    local dHRP = cl:FindFirstChild("HumanoidRootPart")
    if not clHu or not dHRP then cl:Destroy(); return end
    clHu.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local ani = clHu:FindFirstChildOfClass("Animator")
    if ani then ani:Destroy() end
    dHRP.CFrame = hrp.CFrame
    cl.Parent = workspace
    ghost.decoy = cl
    LH.Ghost = true
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 1
            if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
    hrp.CFrame = CFrame.new(GHOST_POS + Vector3.new(0,5,0))
    hrp.AssemblyLinearVelocity = Vector3.zero
    workspace.CurrentCamera.CameraSubject = dHRP
    ghost.died = hu.Died:Connect(function() stopGhost(true) end)
    local rJ = {}
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("Motor6D") then rJ[v.Name] = v end
    end
    local fJ = {}
    for _, v in ipairs(cl:GetDescendants()) do
        if v:IsA("Motor6D") then fJ[v.Name] = v end
    end
    ghost.conn = RunService.Heartbeat:Connect(function()
        if not LH.Ghost or not ghost.decoy or not ghost.decoy.Parent then
            stopGhost(); return
        end
        hrp.CFrame = CFrame.new(GHOST_POS + Vector3.new(0,5,0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        local mv = Vector3.zero
        local cam = workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
        local md = Vector3.new(mv.X, 0, mv.Z)
        if md.Magnitude > 0 then md = md.Unit end
        hu:Move(md, false)
        clHu:Move(md, false)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hu.Jump = true
            clHu.Jump = true
        end
        for n, r in pairs(rJ) do
            local f = fJ[n]
            if f then f.Transform = r.Transform end
        end
    end)
end

local function headless()
    pcall(function()
        local args = {{["Property"] = "Head", ["AssetId"] = 15093053680}}
        local remote = ReplicatedStorage:FindFirstChild("CatalogOnApplyToRealHumanoid", true)
        if remote then remote:FireServer(unpack(args)) end
    end)
end

-- ════════════════════════════════════════
-- ENVIRONMENT
-- ════════════════════════════════════════
-- (Buttons for Night, Day, Fullbright are in GUI)

-- ════════════════════════════════════════
-- UTIL (Server controls, Auto Respawn)
-- ════════════════════════════════════════
lp.CharacterAdded:Connect(function(ch)
    local hu = ch:WaitForChild("Humanoid", 8)
    if LH.AutoRespawn then
        hu.Died:Connect(function()
            if LH.AutoRespawn then
                task.wait(0.5)
                pcall(function() lp:LoadCharacter() end)
            end
        end)
    end
end)

-- ════════════════════════════════════════
-- ESP (Highlight)
-- ════════════════════════════════════════
local espObjects = {}
local espConn

local function createEsp(p)
    if espObjects[p] then return end
    if isImmune(p.Name) then return end
    local h = Instance.new("Highlight")
    h.FillTransparency = 0.7
    h.OutlineTransparency = 0.3
    h.FillColor = Color3.fromRGB(255,50,50)
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.Parent = p.Character
    espObjects[p] = h
end

local function destroyEsp(p)
    if espObjects[p] then
        pcall(function() espObjects[p]:Destroy() end)
        espObjects[p] = nil
    end
end

local function updateEsp()
    if not LH.EspBox then
        for p in pairs(espObjects) do destroyEsp(p) end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp or not p.Character then
            destroyEsp(p)
            continue
        end
        if isImmune(p.Name) then
            destroyEsp(p)
            continue
        end
        if isFriend(p.Name) or isFriend(p.DisplayName) then
            destroyEsp(p)
            continue
        end
        if not isTarget(p.Name) and not isTarget(p.DisplayName) then
            destroyEsp(p)
            continue
        end
        local hu = p.Character:FindFirstChildOfClass("Humanoid")
        if not hu or hu.Health <= 0 then
            destroyEsp(p)
            continue
        end
        if not espObjects[p] then createEsp(p) end
    end
end

local function startEsp()
    if espConn then espConn:Disconnect() end
    espConn = RunService.RenderStepped:Connect(updateEsp)
end

local function stopEsp()
    if espConn then espConn:Disconnect(); espConn = nil end
    for p in pairs(espObjects) do destroyEsp(p) end
end

-- ════════════════════════════════════════
-- KEYBINDS
-- ════════════════════════════════════════
local KEYS = {
    KillAura = Enum.KeyCode.U,
    Fly = Enum.KeyCode.F,
    Ghost = Enum.KeyCode.G,
    TpGrab = Enum.KeyCode.Q,
    TPWalk = Enum.KeyCode.X,
    Invis = Enum.KeyCode.I,
    Reset = Enum.KeyCode.T,
    GrabSpam = Enum.KeyCode.H,
}

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    
    if i.KeyCode == KEYS.TpGrab then
        local t = nil
        if LH.grabTargetName ~= "" then t = findPlayer(LH.grabTargetName) end
        if not t then t = findNearest(9999) end
        if t then doGrab(t) end
    elseif i.KeyCode == KEYS.GrabSpam then
        LH.GrabSpamNoTP = not LH.GrabSpamNoTP
        SaveSetting("GrabSpamNoTP", LH.GrabSpamNoTP)
    elseif i.KeyCode == KEYS.KillAura then
        LH.KillAura = not LH.KillAura
        SaveSetting("KillAura", LH.KillAura)
        if LH.KillAura then StartKA() else if kaConn then kaConn:Disconnect(); kaConn = nil end end
    elseif i.KeyCode == KEYS.Fly then
        LH.Fly = not LH.Fly
        SaveSetting("Fly", LH.Fly)
        if LH.Fly then startFly() else stopFly() end
    elseif i.KeyCode == KEYS.Ghost then
        LH.Ghost = not LH.Ghost
        SaveSetting("Ghost", LH.Ghost)
        if LH.Ghost then startGhost() else stopGhost() end
    elseif i.KeyCode == KEYS.TPWalk then
        LH.TPWalk = not LH.TPWalk
        SaveSetting("TPWalk", LH.TPWalk)
    elseif i.KeyCode == KEYS.Invis then
        LH.Invisible = not LH.Invisible
        SaveSetting("Invisible", LH.Invisible)
    elseif i.KeyCode == KEYS.Reset then
        pcall(function()
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                lp.Character.Humanoid.Health = 0
            end
        end)
    end
end)

-- ════════════════════════════════════════
-- NOTIFICATION
-- ════════════════════════════════════════
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 280, 1, 0)
NotifHolder.Position = UDim2.new(1, -294, 0, 12)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 9000

local _notifs = {}

local function Notif(title, body, ntype)
    local acc = (ntype == "ok" and Color3.fromRGB(100,255,150)) or
                (ntype == "warn" and Color3.fromRGB(200,185,120)) or
                (ntype == "err" and Color3.fromRGB(200,80,80)) or
                Color3.fromRGB(200,200,220)
    local y = #_notifs * (60 + 5)
    local f = Instance.new("Frame", NotifHolder)
    f.Size = UDim2.new(1, 0, 0, 60)
    f.Position = UDim2.new(1, 20, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(20,20,25)
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.ZIndex = 9001
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    
    local acbar = Instance.new("Frame", f)
    acbar.Size = UDim2.new(0, 4, 0, 40)
    acbar.Position = UDim2.new(0, 0, 0.5, -20)
    acbar.BackgroundColor3 = acc
    acbar.BorderSizePixel = 0
    Instance.new("UICorner", acbar).CornerRadius = UDim.new(0, 2)
    
    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(1, -20, 0, 18)
    tl.Position = UDim2.new(0, 12, 0, 8)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 11
    tl.TextColor3 = Color3.new(1,1,1)
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 9002
    
    local bl = Instance.new("TextLabel", f)
    bl.Size = UDim2.new(1, -20, 0, 30)
    bl.Position = UDim2.new(0, 12, 0, 26)
    bl.BackgroundTransparency = 1
    bl.Text = body or ""
    bl.Font = Enum.Font.Gotham
    bl.TextSize = 9
    bl.TextColor3 = Color3.fromRGB(150,150,160)
    bl.TextXAlignment = Enum.TextXAlignment.Left
    bl.TextWrapped = true
    bl.ZIndex = 9002
    
    table.insert(_notifs, f)
    TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, y)
    }):Play()
    
    task.delay(4.5, function()
        if f and f.Parent then
            local idx = table.find(_notifs, f)
            if idx then table.remove(_notifs, idx) end
            TweenService:Create(f, TweenInfo.new(0.2), {
                Position = UDim2.new(1, 20, 0, f.Position.Y.Offset),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.22, function()
                pcall(function() f:Destroy() end)
            end)
            task.delay(0.05, function()
                local y2 = 0
                for _, f2 in ipairs(_notifs) do
                    if f2 and f2.Parent then
                        TweenService:Create(f2, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            Position = UDim2.new(0, 0, 0, y2)
                        }):Play()
                        y2 = y2 + 60 + 5
                    end
                end
            end)
        end
    end)
end

-- ════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════
pcall(function()
    local o = CoreGui:FindFirstChild("LH8")
    if o then o:Destroy() end
end)

local GUI = Instance.new("ScreenGui")
GUI.Name = "LH8"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true
GUI.Parent = CoreGui
NotifHolder.Parent = GUI

-- ===== THEME SYSTEM =====
local THEMES = {
    legend = {
        name = "Legend",
        title = "LEGEND HUB V2",
        colors = {
            bg = Color3.fromRGB(8, 5, 20),
            glass = Color3.fromRGB(15, 10, 30),
            accent = Color3.fromRGB(200, 180, 255),
            accentDark = Color3.fromRGB(50, 40, 70),
            text = Color3.fromRGB(235, 230, 245),
            muted = Color3.fromRGB(160, 150, 180),
            border = Color3.fromRGB(50, 40, 70),
        },
        bgText = "LEGEND",
        glowColor = Color3.fromRGB(255, 0, 255),
        headerBg = Color3.fromRGB(20, 20, 40),
        subTitle = "Made by LEGEND",
    },
    zico = {
        name = "Zico",
        title = "ZICO HUB V2",
        colors = {
            bg = Color3.fromRGB(10, 10, 10),
            glass = Color3.fromRGB(18, 18, 18),
            accent = Color3.fromRGB(200, 200, 200),
            accentDark = Color3.fromRGB(60, 60, 60),
            text = Color3.fromRGB(240, 240, 240),
            muted = Color3.fromRGB(130, 130, 130),
            border = Color3.fromRGB(60, 60, 60),
        },
        bgText = "ZICO",
        glowColor = Color3.fromRGB(0, 200, 255),
        headerBg = Color3.fromRGB(30, 30, 35),
        subTitle = "Made by ZICO",
    }
}

local currentTheme = THEMES[LH.currentTheme] or THEMES.legend

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 440)
Main.Position = UDim2.new(0.5, -190, 0.5, -220)
Main.BackgroundColor3 = currentTheme.colors.bg
Main.BackgroundTransparency = 0.9
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = GUI
local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 16)

local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 6, 1, 6)
Glow.Position = UDim2.new(0, -3, 0, -3)
Glow.BackgroundColor3 = currentTheme.glowColor
Glow.BackgroundTransparency = 0.7
Glow.BorderSizePixel = 0
Glow.Parent = Main
local glowCorner = Instance.new("UICorner", Glow)
glowCorner.CornerRadius = UDim.new(0, 18)

local BgText = Instance.new("TextLabel")
BgText.Size = UDim2.new(1, 0, 1, 0)
BgText.BackgroundTransparency = 1
BgText.Text = currentTheme.bgText
BgText.TextColor3 = Color3.fromRGB(255, 255, 255)
BgText.TextTransparency = 0.92
BgText.Font = Enum.Font.GothamBlack
BgText.TextSize = 60
BgText.TextScaled = true
BgText.ZIndex = 0
BgText.Parent = Main
local bgGrad = Instance.new("UIGradient", BgText)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = currentTheme.headerBg
TitleBar.BackgroundTransparency = 0.5
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Main
local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 16)

local dragObj = {dragging = false, dragStart = nil, startPos = nil}
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragObj.dragging = true
        dragObj.dragStart = input.Position
        dragObj.startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragObj.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragObj.dragStart
        Main.Position = UDim2.new(
            dragObj.startPos.X.Scale, dragObj.startPos.X.Offset + d.X,
            dragObj.startPos.Y.Scale, dragObj.startPos.Y.Offset + d.Y
        )
        Glow.Position = UDim2.new(
            dragObj.startPos.X.Scale, dragObj.startPos.X.Offset + d.X + 3,
            dragObj.startPos.Y.Scale, dragObj.startPos.Y.Offset + d.Y + 3
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragObj.dragging = false
    end
end)

local CenterTitle = Instance.new("TextLabel")
CenterTitle.Size = UDim2.new(1, -90, 0, 22)
CenterTitle.Position = UDim2.new(0, 10, 0, 4)
CenterTitle.BackgroundTransparency = 1
CenterTitle.Text = currentTheme.title
CenterTitle.TextColor3 = Color3.new(1,1,1)
CenterTitle.Font = Enum.Font.GothamBlack
CenterTitle.TextSize = 18
CenterTitle.TextXAlignment = Enum.TextXAlignment.Left
CenterTitle.Parent = TitleBar
local cGrad = Instance.new("UIGradient", CenterTitle)
cGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -90, 0, 10)
SubTitle.Position = UDim2.new(0, 12, 0, 28)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = currentTheme.subTitle
SubTitle.TextColor3 = currentTheme.colors.muted
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 7
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

local CB = Instance.new("TextButton")
CB.Size = UDim2.new(0, 24, 0, 22)
CB.Position = UDim2.new(1, -30, 0.5, -11)
CB.Text = "X"
CB.BackgroundColor3 = Color3.fromRGB(100, 30, 40)
CB.BackgroundTransparency = 0.3
CB.TextColor3 = Color3.fromRGB(255,200,200)
CB.Font = Enum.Font.GothamBold
CB.TextSize = 12
CB.BorderSizePixel = 0
CB.Parent = TitleBar
local cbCorner = Instance.new("UICorner", CB)
cbCorner.CornerRadius = UDim.new(0, 6)
CB.MouseButton1Click:Connect(function()
    DoSave()
    GUI:Destroy()
end)

local MB = Instance.new("TextButton")
MB.Size = UDim2.new(0, 24, 0, 22)
MB.Position = UDim2.new(1, -58, 0.5, -11)
MB.Text = "-"
MB.BackgroundColor3 = Color3.fromRGB(40, 35, 50)
MB.BackgroundTransparency = 0.3
MB.TextColor3 = Color3.fromRGB(160, 150, 180)
MB.Font = Enum.Font.GothamBold
MB.TextSize = 14
MB.BorderSizePixel = 0
MB.Parent = TitleBar
local mbCorner = Instance.new("UICorner", MB)
mbCorner.CornerRadius = UDim.new(0, 6)

local isMin = false
MB.MouseButton1Click:Connect(function()
    isMin = not isMin
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = isMin and UDim2.new(0, 380, 0, 40) or UDim2.new(0, 380, 0, 440)
    }):Play()
    MB.Text = isMin and "+" or "-"
    for _, child in pairs(Main:GetChildren()) do
        if child ~= TitleBar and child ~= BgText then
            child.Visible = not isMin
        end
    end
    Glow.Visible = not isMin
end)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -6, 0, 30)
TabBar.Position = UDim2.new(0, 3, 0, 44)
TabBar.BackgroundColor3 = currentTheme.colors.glass
TabBar.BackgroundTransparency = 0.5
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = true
TabBar.Parent = Main
local tabCorner = Instance.new("UICorner", TabBar)
tabCorner.CornerRadius = UDim.new(0, 8)

local TabScr = Instance.new("ScrollingFrame", TabBar)
TabScr.Size = UDim2.new(1, -4, 1, 0)
TabScr.Position = UDim2.new(0, 2, 0, 0)
TabScr.BackgroundTransparency = 1
TabScr.BorderSizePixel = 0
TabScr.ScrollBarThickness = 0
TabScr.AutomaticCanvasSize = Enum.AutomaticSize.X
TabScr.CanvasSize = UDim2.new(0, 0, 0, 0)

local TabLay = Instance.new("UIListLayout", TabScr)
TabLay.FillDirection = Enum.FillDirection.Horizontal
TabLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLay.Padding = UDim.new(0, 2)

local PC = Instance.new("ScrollingFrame")
PC.Size = UDim2.new(1, -6, 1, -80)
PC.Position = UDim2.new(0, 3, 0, 76)
PC.BackgroundTransparency = 1
PC.ScrollBarThickness = 2
PC.ScrollBarImageColor3 = currentTheme.colors.accent
PC.ScrollBarImageTransparency = 0.3
PC.AutomaticCanvasSize = Enum.AutomaticSize.Y
PC.CanvasSize = UDim2.new(0, 0, 0, 0)
PC.Active = true
PC.BorderSizePixel = 0
PC.Parent = Main
Instance.new("UIPadding", PC).PaddingTop = UDim.new(0, 2)

local function mkPage()
    local p = Instance.new("Frame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = PC
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 3)
    return p
end

local P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12, P13, P14 = 
    mkPage(), mkPage(), mkPage(), mkPage(), mkPage(), mkPage(), mkPage(),
    mkPage(), mkPage(), mkPage(), mkPage(), mkPage(), mkPage(), mkPage()

local tabInfo = {}

local function mkTab(name, page)
    local t = Instance.new("TextButton")
    t.AutomaticSize = Enum.AutomaticSize.X
    t.Size = UDim2.new(0, 0, 1, 0)
    t.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    t.BackgroundTransparency = 0.5
    t.Text = name
    t.TextColor3 = Color3.fromRGB(100, 90, 120)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 7
    t.BorderSizePixel = 0
    t.Parent = TabScr
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
    table.insert(tabInfo, {t, page})
    t.MouseButton1Click:Connect(function()
        for _, ti in ipairs(tabInfo) do
            ti[1].BackgroundColor3 = Color3.fromRGB(15, 10, 25)
            ti[1].TextColor3 = Color3.fromRGB(100, 90, 120)
            ti[2].Visible = false
        end
        t.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
        t.TextColor3 = Color3.fromRGB(230, 210, 255)
        page.Visible = true
        PC.CanvasPosition = Vector2.new(0, 0)
    end)
end

mkTab("Combat", P1)
mkTab("Target", P2)
mkTab("Move", P3)
mkTab("Visual", P4)
mkTab("Defense", P5)
mkTab("Ghost", P6)
mkTab("Env", P7)
mkTab("Util", P8)
mkTab("ESP", P9)
mkTab("Home", P10)
mkTab("Adv", P11)
mkTab("Data", P12)
mkTab("Theme", P13)
mkTab("Keys", P14)

tabInfo[1][1].BackgroundColor3 = Color3.fromRGB(45, 35, 65)
tabInfo[1][1].TextColor3 = Color3.fromRGB(230, 210, 255)
P1.Visible = true

-- UI Components
local function Sec(p, t)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 16)
    f.BackgroundColor3 = currentTheme.colors.glass
    f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0
    f.Parent = p
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 6, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = t:upper()
    l.TextColor3 = currentTheme.colors.accent
    l.Font = Enum.Font.GothamBold
    l.TextSize = 6
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
end

local function Tog(p, t, cb, d)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 24)
    c.BackgroundColor3 = currentTheme.colors.glass
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    local st = Instance.new("UIStroke", c)
    st.Color = currentTheme.colors.border
    st.Thickness = 1
    st.Transparency = 0.6
    
    local lb = Instance.new("TextLabel", c)
    lb.Size = UDim2.new(0.7, 0, 1, 0)
    lb.Position = UDim2.new(0, 8, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = t
    lb.TextColor3 = currentTheme.colors.text
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 8
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 28, 0, 14)
    bg.Position = UDim2.new(1, -36, 0.5, -7)
    bg.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
    bg.BorderSizePixel = 0
    bg.Parent = c
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 10, 0, 10)
    kn.Position = UDim2.new(0, 2, 0.5, -5)
    kn.BackgroundColor3 = Color3.fromRGB(120, 110, 140)
    kn.BorderSizePixel = 0
    kn.Parent = bg
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1, 0)
    
    local bt = Instance.new("TextButton")
    bt.Size = UDim2.new(1, 0, 1, 0)
    bt.BackgroundTransparency = 1
    bt.Text = ""
    bt.ZIndex = 10
    bt.Parent = c
    
    local en = d or false
    if en then
        kn.Position = UDim2.new(1, -12, 0.5, -5)
        kn.BackgroundColor3 = currentTheme.colors.accent
        bg.BackgroundColor3 = currentTheme.colors.accentDark
        st.Color = currentTheme.colors.accent
        st.Transparency = 0.1
    end
    
    bt.MouseButton1Click:Connect(function()
        en = not en
        TweenService:Create(kn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = en and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            BackgroundColor3 = en and currentTheme.colors.accent or Color3.fromRGB(120, 110, 140)
        }):Play()
        TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = en and currentTheme.colors.accentDark or Color3.fromRGB(30, 25, 40)
        }):Play()
        TweenService:Create(st, TweenInfo.new(0.18), {
            Color = en and currentTheme.colors.accent or currentTheme.colors.border,
            Transparency = en and 0.1 or 0.6
        }):Play()
        cb(en)
        SaveSetting(t, en)
    end)
end

local function Sld(p, t, mn, mx, df, cb)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 32)
    c.BackgroundColor3 = currentTheme.colors.glass
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", c).Color = currentTheme.colors.border
    c:FindFirstChildOfClass("UIStroke").Thickness = 1
    c:FindFirstChildOfClass("UIStroke").Transparency = 0.6
    
    local lb = Instance.new("TextLabel", c)
    lb.Size = UDim2.new(0.55, 0, 0, 14)
    lb.Position = UDim2.new(0, 8, 0, 1)
    lb.BackgroundTransparency = 1
    lb.Text = t
    lb.TextColor3 = currentTheme.colors.muted
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 7
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.38, 0, 0, 14)
    vl.Position = UDim2.new(0.6, 0, 0, 1)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(df)
    vl.TextColor3 = currentTheme.colors.accent
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 7
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = c
    
    local tk = Instance.new("Frame")
    tk.Size = UDim2.new(1, -16, 0, 3)
    tk.Position = UDim2.new(0, 8, 0, 20)
    tk.BackgroundColor3 = Color3.fromRGB(8, 5, 15)
    tk.BorderSizePixel = 0
    tk.ZIndex = 4
    tk.Parent = c
    Instance.new("UICorner", tk).CornerRadius = UDim.new(1, 0)
    
    local fl = Instance.new("Frame")
    fl.Size = UDim2.new((df-mn)/(mx-mn), 0, 1, 0)
    fl.BackgroundColor3 = currentTheme.colors.accent
    fl.BorderSizePixel = 0
    fl.ZIndex = 5
    fl.Parent = tk
    Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
    
    local th = Instance.new("Frame")
    th.Size = UDim2.new(0, 8, 0, 8)
    th.Position = UDim2.new((df-mn)/(mx-mn), -4, 0.5, -4)
    th.BackgroundColor3 = Color3.fromRGB(240,240,245)
    th.BorderSizePixel = 0
    th.ZIndex = 6
    th.Parent = tk
    Instance.new("UICorner", th).CornerRadius = UDim.new(1, 0)
    
    local dr = false
    local function upd(ip)
        local rx = ip.X - tk.AbsolutePosition.X
        local pct = math.clamp(rx / tk.AbsoluteSize.X, 0, 1)
        fl.Size = UDim2.new(pct, 0, 1, 0)
        th.Position = UDim2.new(pct, -4, 0.5, -4)
        local v = math.floor(mn + pct * (mx - mn))
        vl.Text = tostring(v)
        cb(v)
        SaveSetting(t, v)
    end
    
    tk.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true
            PC.ScrollingEnabled = false
            upd(i.Position)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = false
            PC.ScrollingEnabled = true
        end
    end)
end

local function Txt(p, ph, cb)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 22)
    c.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    local st = Instance.new("UIStroke", c)
    st.Color = currentTheme.colors.border
    st.Thickness = 1
    st.Transparency = 0.5
    
    local t = Instance.new("TextBox")
    t.Size = UDim2.new(1, -12, 1, 0)
    t.Position = UDim2.new(0, 6, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = ""
    t.PlaceholderText = ph
    t.PlaceholderColor3 = currentTheme.colors.muted
    t.TextColor3 = currentTheme.colors.text
    t.Font = Enum.Font.Gotham
    t.TextSize = 8
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ClearTextOnFocus = false
    t.ZIndex = 3
    t.Parent = c
    t.FocusLost:Connect(function()
        cb(t.Text)
        SaveSetting(ph, t.Text)
    end)
    return t
end

local function Btn(p, t, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 24)
    b.BackgroundColor3 = currentTheme.colors.accentDark
    b.BackgroundTransparency = 0.4
    b.BorderSizePixel = 0
    b.Text = t
    b.TextColor3 = currentTheme.colors.accent
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", b).Color = currentTheme.colors.border
    b:FindFirstChildOfClass("UIStroke").Thickness = 1
    b:FindFirstChildOfClass("UIStroke").Transparency = 0.3
    b.MouseButton1Click:Connect(function() cb() end)
end

local function KeyBind(p, t, defaultKey, keyName)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 24)
    c.BackgroundColor3 = currentTheme.colors.glass
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", c).Color = currentTheme.colors.border
    Instance.new("UIStroke", c).Thickness = 1
    Instance.new("UIStroke", c).Transparency = 0.6
    
    local lb = Instance.new("TextLabel", c)
    lb.Size = UDim2.new(0.7, 0, 1, 0)
    lb.Position = UDim2.new(0, 8, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = t
    lb.TextColor3 = currentTheme.colors.text
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 8
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyLbl = Instance.new("TextLabel", c)
    keyLbl.Size = UDim2.new(0.25, 0, 1, 0)
    keyLbl.Position = UDim2.new(0.73, 0, 0, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = tostring(defaultKey):gsub("Enum.KeyCode.", "")
    keyLbl.TextColor3 = currentTheme.colors.accent
    keyLbl.Font = Enum.Font.GothamBold
    keyLbl.TextSize = 8
    
    local bt = Instance.new("TextButton")
    bt.Size = UDim2.new(1, 0, 1, 0)
    bt.BackgroundTransparency = 1
    bt.Text = ""
    bt.ZIndex = 10
    bt.Parent = c
    
    bt.MouseButton1Click:Connect(function()
        keyLbl.Text = "..."
        activeKeyBind = {name = keyName, label = keyLbl}
    end)
end

-- Active keybind listener
local activeKeyBind = nil
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if activeKeyBind then
        KEYS[activeKeyBind.name] = i.KeyCode
        activeKeyBind.label.Text = tostring(i.KeyCode):gsub("Enum.KeyCode.", "")
        activeKeyBind = nil
    end
end)

-- =============================================
-- BUILD PAGES
-- =============================================

-- Page 1: Combat
Sec(P1, "KILL AURA")
Tog(P1, "KillAura", function(v) LH.KillAura = v; if v then StartKA() else if kaConn then kaConn:Disconnect(); kaConn = nil end end end, LH.KillAura)
Sld(P1, "Aura Range", 5, 250, LH.KillAuraRange, function(v) LH.KillAuraRange = v end)
Sld(P1, "Attacks/Sec", 1, 10000, LH.AttacksPerSecond, function(v) LH.AttacksPerSecond = v end)
Tog(P1, "Bypass Range", function(v) LH.BypassRange = v end, LH.BypassRange)
Tog(P1, "Silent TP Hit", function(v) LH.SilentTPHit = v end, LH.SilentTPHit)

Sec(P1, "HITBOX")
Tog(P1, "Hitbox", function(v) LH.Hitbox = v end, LH.Hitbox)
Tog(P1, "Hitbox Vis", function(v) LH.HitboxVis = v end, LH.HitboxVis)
Sld(P1, "Hitbox Size", 1, 50, LH.HitboxSize, function(v) LH.HitboxSize = v end)

Sec(P1, "GRAB")
Tog(P1, "Grab Spam [H]", function(v) LH.GrabSpamNoTP = v end, LH.GrabSpamNoTP)
Txt(P1, "Grab Target (blank=nearest)", function(t) LH.grabTargetName = t end)
Btn(P1, "TP + Grab [Q]", function()
    local t = nil
    if LH.grabTargetName ~= "" then t = findPlayer(LH.grabTargetName) end
    if not t then t = findNearest(9999) end
    if t then doGrab(t) end
end)

Sec(P1, "FARM AND SPAM")
Tog(P1, "Auto Farm", function(v) LH.AutoFarm = v end, LH.AutoFarm)
Tog(P1, "Rapid Hit", function(v) LH.RapidHit = v; if v then startRapidHit() end end, LH.RapidHit)
Tog(P1, "Punch Spam", function(v) LH.PunchSpam = v; if v then startPunchSpam() end end, LH.PunchSpam)
Tog(P1, "Jitter", function(v) LH.FakeJitter = v; if v then startJitter() end end, LH.FakeJitter)
Tog(P1, "Auto Stomp", function(v) LH.AutoStomp = v end, LH.AutoStomp)

-- Page 2: Target
Sec(P2, "TARGETING")
Txt(P2, "Target Players", function(t)
    SAVE.kaTargets = t
    LH.targetList = parseList(t)
    DoSave()
end)
Txt(P2, "Friend List", function(t)
    SAVE.kaFriends = t
    LH.friendList = parseList(t)
    DoSave()
end)

Sec(P2, "STRAFE")
Tog(P2, "Strafe", function(v) LH.Strafe = v; strafeAngle = 0 end, LH.Strafe)
Tog(P2, "Backstab", function(v) LH.Backstab = v end, LH.Backstab)
Txt(P2, "Strafe Target", function(t) LH.strafeName = t end)
Sld(P2, "Radius", 2, 30, LH.StrafeRadius, function(v) LH.StrafeRadius = v end)
Sld(P2, "Speed", 1, 20, LH.StrafeSpeed, function(v) LH.StrafeSpeed = v end)
Sld(P2, "Offset", -15, 10, LH.StrafeOffset, function(v) LH.StrafeOffset = v end)

Sec(P2, "ORBIT")
Tog(P2, "Orbit", function(v) LH.Orbit = v; orbitAngle = 0 end, LH.Orbit)
Txt(P2, "Orbit Target", function(t) LH.orbitName = t end)
Sld(P2, "Orb Radius", 2, 50, LH.orbRadius, function(v) LH.orbRadius = v end)
Sld(P2, "Orb Speed", 1, 1000, LH.orbSpeed, function(v) LH.orbSpeed = v end)
Sld(P2, "Orb Height", -10, 10, LH.orbHeight, function(v) LH.orbHeight = v end)

Sec(P2, "HEAD SIT")
Tog(P2, "Head Sit", function(v) LH.HeadSit = v end, LH.HeadSit)
Txt(P2, "Head Sit Target", function(t) LH.headSitName = t end)

-- Page 3: Move
Sec(P3, "MOVEMENT")
Tog(P3, "TP Walk [X]", function(v) LH.TPWalk = v end, LH.TPWalk)
Sld(P3, "TP Speed", 16, 200, LH.tpSpeed, function(v) LH.tpSpeed = v end)
Tog(P3, "Fly [F]", function(v) if v then startFly() else stopFly() end end, LH.Fly)
Sld(P3, "Fly Speed", 1, 300, LH.flySpeed, function(v) LH.flySpeed = v end)
Tog(P3, "Noclip", function(v) LH.Noclip = v end, LH.Noclip)
Tog(P3, "Inf Jump", function(v) LH.InfJump = v end, LH.InfJump)
Sld(P3, "Walk Speed", 1, 500, 16, function(v) pcall(function() lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end) end)
Sld(P3, "Jump Power", 1, 500, 50, function(v) pcall(function() local h = lp.Character:FindFirstChildOfClass("Humanoid"); h.UseJumpPower = true; h.JumpPower = v end) end)
Sld(P3, "Gravity", 1, 600, 196, function(v) workspace.Gravity = v end)
Tog(P3, "Death TP", function(v) LH.DeathTP = v; if not v then LH.deathCF = nil end end, LH.DeathTP)

Sec(P3, "LAG AND SPIN")
Tog(P3, "Spin", function(v) LH.Spin = v; if v then startSpin() else stopSpin() end end, LH.Spin)
Sld(P3, "Spin Speed", 1, 500, LH.spinSpeed, function(v) LH.spinSpeed = v end)
Tog(P3, "Glitch", function(v) LH.Glitch = v; if v then startGlitch() end end, LH.Glitch)
Txt(P3, "Glitch Target", function(t) LH.glitchName = t end)
Sld(P3, "Glitch Power", 1, 20, LH.glitchInt, function(v) LH.glitchInt = v end)

-- Page 4: Visual
Sec(P4, "RP COLOR")
Tog(P4, "Rainbow Tag", function(v) LH.RainbowTag = v; if v then startRP() else stopRP() end end, LH.RainbowTag)
Sld(P4, "Rainbow Speed", 1, 100, LH.RainbowSpeed, function(v) LH.RainbowSpeed = v end)

local mc = Instance.new("Frame")
mc.Size = UDim2.new(1, 0, 0, 80)
mc.BackgroundColor3 = currentTheme.colors.glass
mc.BackgroundTransparency = 0.4
mc.BorderSizePixel = 0
mc.Parent = P4
Instance.new("UICorner", mc).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", mc).Color = currentTheme.colors.border
mc:FindFirstChildOfClass("UIStroke").Thickness = 1
mc:FindFirstChildOfClass("UIStroke").Transparency = 0.6

local mg = Instance.new("Frame", mc)
mg.Size = UDim2.new(1, -10, 0, 76)
mg.Position = UDim2.new(0, 5, 0, 2)
mg.BackgroundTransparency = 1

local mgl = Instance.new("UIGridLayout", mg)
mgl.CellSize = UDim2.new(0.23, -2, 0, 16)
mgl.CellPadding = UDim2.new(0, 2, 0, 2)

local colorModes = {
    "rainbow", "neon", "pastel", "fire", "ice", "galaxy", "toxic", "blood",
    "dark", "light", "deep", "soft", "vivid", "muted"
}
local colorLabels = {
    "Rainbow", "Neon", "Pastel", "Fire", "Ice", "Galaxy", "Toxic", "Blood",
    "Dark", "Light", "Deep", "Soft", "Vivid", "Muted"
}

for i, k in ipairs(colorModes) do
    local b = Instance.new("TextButton", mg)
    b.Text = colorLabels[i]
    b.Font = Enum.Font.GothamBold
    b.TextSize = 5
    b.BackgroundColor3 = k == LH.rpMode and currentTheme.colors.accent or Color3.fromRGB(30, 25, 40)
    b.TextColor3 = k == LH.rpMode and Color3.fromRGB(0,0,0) or currentTheme.colors.muted
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    b.MouseButton1Click:Connect(function()
        LH.rpMode = k
        for _, bt in ipairs(mg:GetChildren()) do
            if bt:IsA("TextButton") then
                bt.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
                bt.TextColor3 = currentTheme.colors.muted
            end
        end
        b.BackgroundColor3 = currentTheme.colors.accent
        b.TextColor3 = Color3.fromRGB(0,0,0)
        SaveSetting("rpMode", k)
    end)
end

Tog(P4, "Name Typer", function(v) LH.NameTypewriter = v; if not v then pcall(function() if NameR then NameR:FireServer(lp.DisplayName) end end) end end, LH.NameTypewriter)
Tog(P4, "Bio Phrases", function(v) LH.BioPhrases = v; if v then startPhrases() end end, LH.BioPhrases)
Sld(P4, "Type Speed", 1, 250, LH.BioTypeSpeed, function(v) LH.BioTypeSpeed = v end)
Txt(P4, "Phrases", function(t)
    LH.userPhrases = {}
    for w in t:gmatch("%S+") do table.insert(LH.userPhrases, w) end
    if #LH.userPhrases == 0 then LH.userPhrases = {"LEGEND!"} end
end)

Sec(P4, "INVISIBLE")
Tog(P4, "Invisible [I]", function(v) LH.Invisible = v end, LH.Invisible)

-- Page 5: Defense
Sec(P5, "BLOCK AND PARRY")
Tog(P5, "Auto Block", function(v) LH.AutoBlock = v end, LH.AutoBlock)
Tog(P5, "Auto Parry", function(v) LH.AutoParry = v end, LH.AutoParry)
Sld(P5, "Parry Range", 5, 20, LH.parryRange, function(v) LH.parryRange = v end)

Sec(P5, "ANTI RAGDOLL")
Tog(P5, "Anti Ragdoll", function(v) LH.AntiRag = v; if v and lp.Character then cleanRag(lp.Character) end end, LH.AntiRag)
Tog(P5, "Anti Rag Combo", function(v)
    LH.AntiRagCombo = v
    if v then
        if lp.Character then task.spawn(arcOnChar, lp.Character) end
    else
        if arc.conn then arc.conn:Disconnect() end
        arcRemPlat()
    end
end, LH.AntiRagCombo)

Sec(P5, "PROTECTION")
Tog(P5, "Invincible", function(v) LH.Invincible = v end, LH.Invincible)
Tog(P5, "Anti Fling", function(v) LH.AntiFling = v end, LH.AntiFling)
Tog(P5, "Dodge Grab", function(v) LH.DodgeGrab = v end, LH.DodgeGrab)
Tog(P5, "Safe Spot", function(v) LH.SafeSpot = v; if v then goSafe() else endSafe() end end, LH.SafeSpot)
Tog(P5, "Anti AFK", function(v) LH.AntiAFK = v end, LH.AntiAFK)

-- Page 6: Ghost
Sec(P6, "GHOST")
Tog(P6, "Ghost Mode [G]", function(v) if v then startGhost() else stopGhost() end end, LH.Ghost)
Btn(P6, "Headless", function() headless() end)

-- Page 7: Env
Sec(P7, "ENVIRONMENT")
Btn(P7, "Night", function()
    pcall(function()
        Lighting.ClockTime = 0
        Lighting.Brightness = 0
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(30,30,50)
        Lighting.Ambient = Color3.fromRGB(30,30,50)
        Lighting.FogEnd = 1000
    end)
end)
Btn(P7, "Day", function()
    pcall(function()
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.FogEnd = 100000
    end)
end)
Sld(P7, "Time of Day", 0, 24, 14, function(v) pcall(function() Lighting.ClockTime = v end) end)
Sld(P7, "Brightness", 0, 10, 2, function(v) pcall(function() Lighting.Brightness = v end) end)
Btn(P7, "Fullbright", function()
    pcall(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178,178,178)
    end)
end)

-- Page 8: Util
Sec(P8, "SERVER CONTROLS")
Btn(P8, "Rejoin", function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end)
end)
Btn(P8, "Server Hop", function()
    pcall(function()
        local srv = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if srv and srv.data then
            for _, s in ipairs(srv.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                    break
                end
            end
        end
    end)
end)
Btn(P8, "Force Reset", function()
    pcall(function()
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character.Humanoid.Health = 0
        end
    end)
end)
Btn(P8, "Unload", function()
    DoSave()
    GUI:Destroy()
end)

Sec(P8, "AUTO RESPAWN")
Tog(P8, "Auto Respawn", function(v) LH.AutoRespawn = v end, LH.AutoRespawn)

-- Page 9: ESP
Sec(P9, "ESP")
Tog(P9, "ESP", function(v) LH.EspBox = v; if v then startEsp() else stopEsp() end end, LH.EspBox)
Btn(P9, "Clear ESP", function()
    for p in pairs(espObjects) do destroyEsp(p) end
end)

-- Page 10: Home
Sec(P10, "LEGEND HUB")
local wc = Instance.new("Frame")
wc.Size = UDim2.new(1, 0, 0, 80)
wc.BackgroundColor3 = currentTheme.colors.glass
wc.BackgroundTransparency = 0.4
wc.BorderSizePixel = 0
wc.Parent = P10
Instance.new("UICorner", wc).CornerRadius = UDim.new(0, 5)

local wnL = Instance.new("TextLabel", wc)
wnL.Size = UDim2.new(1, -20, 0, 30)
wnL.Position = UDim2.new(0, 10, 0, 6)
wnL.BackgroundTransparency = 1
wnL.Text = currentTheme.title
wnL.TextColor3 = currentTheme.colors.text
wnL.Font = Enum.Font.GothamBlack
wnL.TextSize = 24
wnL.TextXAlignment = Enum.TextXAlignment.Left
local wnGrad = Instance.new("UIGradient", wnL)
wnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

local infoL = Instance.new("TextLabel", wc)
infoL.Size = UDim2.new(1, -20, 0, 14)
infoL.Position = UDim2.new(0, 10, 0, 38)
infoL.BackgroundTransparency = 1
infoL.Text = "Welcome "..lp.DisplayName
infoL.TextColor3 = currentTheme.colors.muted
infoL.Font = Enum.Font.Gotham
infoL.TextSize = 9
infoL.TextXAlignment = Enum.TextXAlignment.Left

local infoL2 = Instance.new("TextLabel", wc)
infoL2.Size = UDim2.new(1, -20, 0, 12)
infoL2.Position = UDim2.new(0, 10, 0, 54)
infoL2.BackgroundTransparency = 1
infoL2.Text = "Q=TP+Grab | H=Grab Spam | Data auto-saves"
infoL2.TextColor3 = currentTheme.colors.accent
infoL2.Font = Enum.Font.Gotham
infoL2.TextSize = 7
infoL2.TextXAlignment = Enum.TextXAlignment.Left

local crL = Instance.new("TextLabel", P10)
crL.Size = UDim2.new(1, 0, 0, 18)
crL.BackgroundTransparency = 1
crL.Text = "Made by LEGEND"
crL.TextColor3 = currentTheme.colors.accent
crL.Font = Enum.Font.GothamBold
crL.TextSize = 8
crL.Parent = P10

-- Page 11: Adv
Sec(P11, "ADV COMBAT")
Tog(P11, "Auto Combo", function(v) LH.AutoCombo = v end, false)
Tog(P11, "Speed Boost", function(v)
    LH.SpeedBoost = v
    if v then
        pcall(function() lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed * 1.5 end)
    else
        pcall(function() lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end)
    end
end, false)

-- Page 12: Data
Sec(P12, "DATA")
local dataInfo = Instance.new("TextLabel")
dataInfo.Size = UDim2.new(1, 0, 0, 24)
dataInfo.BackgroundTransparency = 1
dataInfo.Text = "Data saves to: lh_data.json"
dataInfo.TextColor3 = currentTheme.colors.muted
dataInfo.TextSize = 7
dataInfo.Font = Enum.Font.Gotham
dataInfo.TextWrapped = true
dataInfo.Parent = P12

Btn(P12, "Save All", function()
    DoSave()
    Notif("Saved", "All settings saved to lh_data.json", "ok")
end)

Btn(P12, "Load All", function()
    pcall(function()
        if readfile then
            local ok, d = pcall(function() return HttpService:JSONDecode(readfile("lh_data.json")) end)
            if ok and type(d) == "table" then
                for k, v in pairs(d) do SAVE[k] = v end
                -- Reload all
                LH.KillAura = LoadSetting("KillAura", true)
                LH.KillAuraRange = LoadSetting("KillAuraRange", 50)
                LH.AttacksPerSecond = LoadSetting("AttacksPerSecond", 10000)
                LH.Hitbox = LoadSetting("Hitbox", false)
                LH.HitboxSize = LoadSetting("HitboxSize", 10)
                LH.HitboxVis = LoadSetting("HitboxVis", false)
                LH.BypassRange = LoadSetting("BypassRange", true)
                LH.SilentTPHit = LoadSetting("SilentTPHit", false)
                LH.GrabSpamNoTP = LoadSetting("GrabSpamNoTP", false)
                LH.grabTargetName = LoadSetting("grabTargetName", "")
                LH.AutoFarm = LoadSetting("AutoFarm", false)
                LH.RapidHit = LoadSetting("RapidHit", false)
                LH.PunchSpam = LoadSetting("PunchSpam", false)
                LH.FakeJitter = LoadSetting("FakeJitter", false)
                LH.AutoStomp = LoadSetting("AutoStomp", false)
                LH.Strafe = LoadSetting("Strafe", false)
                LH.StrafeRadius = LoadSetting("StrafeRadius", 10)
                LH.StrafeSpeed = LoadSetting("StrafeSpeed", 4)
                LH.StrafeOffset = LoadSetting("StrafeOffset", -2)
                LH.Backstab = LoadSetting("Backstab", false)
                LH.strafeName = LoadSetting("strafeName", "")
                LH.Orbit = LoadSetting("Orbit", false)
                LH.orbRadius = LoadSetting("orbRadius", 10)
                LH.orbSpeed = LoadSetting("orbSpeed", 5)
                LH.orbHeight = LoadSetting("orbHeight", 2)
                LH.orbitName = LoadSetting("orbitName", "")
                LH.HeadSit = LoadSetting("HeadSit", false)
                LH.headSitName = LoadSetting("headSitName", "")
                LH.TPWalk = LoadSetting("TPWalk", false)
                LH.tpSpeed = LoadSetting("tpSpeed", 50)
                LH.Fly = LoadSetting("Fly", false)
                LH.flySpeed = LoadSetting("flySpeed", 80)
                LH.Noclip = LoadSetting("Noclip", false)
                LH.InfJump = LoadSetting("InfJump", false)
                LH.Spin = LoadSetting("Spin", false)
                LH.spinSpeed = LoadSetting("spinSpeed", 60)
                LH.Glitch = LoadSetting("Glitch", false)
                LH.glitchInt = LoadSetting("glitchInt", 4)
                LH.glitchName = LoadSetting("glitchName", "")
                LH.DeathTP = LoadSetting("DeathTP", false)
                LH.Invisible = LoadSetting("Invisible", false)
                LH.RainbowTag = LoadSetting("RainbowTag", false)
                LH.RainbowSpeed = LoadSetting("RainbowSpeed", 8)
                LH.rpMode = LoadSetting("rpMode", "rainbow")
                LH.NameTypewriter = LoadSetting("NameTypewriter", false)
                LH.BioPhrases = LoadSetting("BioPhrases", false)
                LH.BioTypeSpeed = LoadSetting("BioTypeSpeed", 15)
                LH.AutoBlock = LoadSetting("AutoBlock", false)
                LH.AutoParry = LoadSetting("AutoParry", false)
                LH.parryRange = LoadSetting("parryRange", 12)
                LH.AntiRag = LoadSetting("AntiRag", true)
                LH.AntiRagCombo = LoadSetting("AntiRagCombo", false)
                LH.Invincible = LoadSetting("Invincible", false)
                LH.AntiFling = LoadSetting("AntiFling", false)
                LH.DodgeGrab = LoadSetting("DodgeGrab", false)
                LH.SafeSpot = LoadSetting("SafeSpot", false)
                LH.AntiAFK = LoadSetting("AntiAFK", true)
                LH.Ghost = LoadSetting("Ghost", false)
                LH.AutoRespawn = LoadSetting("AutoRespawn", false)
                LH.EspBox = LoadSetting("EspBox", false)
                LH.currentTheme = LoadSetting("currentTheme", "legend")
                -- Re-apply states
                if LH.KillAura then StartKA() else if kaConn then kaConn:Disconnect(); kaConn = nil end end
                if LH.EspBox then startEsp() else stopEsp() end
                if LH.Fly then startFly() else stopFly() end
                if LH.Spin then startSpin() else stopSpin() end
                if LH.Glitch then startGlitch() else if glConn then glConn:Disconnect(); glConn = nil end end
                if LH.RainbowTag then startRP() else stopRP() end
                if LH.BioPhrases then startPhrases() end
                if LH.SafeSpot then goSafe() else endSafe() end
                if LH.Ghost then startGhost() else stopGhost() end
                Notif("Loaded", "Settings restored from lh_data.json", "ok")
            else
                Notif("No Data", "No saved data found", "err")
            end
        end
    end)
end)

Btn(P12, "Delete Data", function()
    pcall(function()
        if isfile("lh_data.json") then
            delfile("lh_data.json")
            SAVE = {}
            _G.LH_Saves = SAVE
            Notif("Deleted", "Data file removed", "warn")
        end
    end)
end)

-- Page 13: Theme
Sec(P13, "THEMES")
local function applyTheme(name)
    local theme = THEMES[name]
    if not theme then return end
    currentTheme = theme
    LH.currentTheme = name
    SaveSetting("currentTheme", name)
    
    -- Apply colors
    Main.BackgroundColor3 = theme.colors.bg
    Glow.BackgroundColor3 = theme.glowColor
    BgText.Text = theme.bgText
    TitleBar.BackgroundColor3 = theme.headerBg
    CenterTitle.Text = theme.title
    SubTitle.Text = theme.subTitle
    SubTitle.TextColor3 = theme.colors.muted
    -- Update all UI elements with new colors
    for _, child in pairs(PC:GetDescendants()) do
        if child:IsA("Frame") and child.BackgroundColor3 == Color3.fromRGB(20,15,30) then
            child.BackgroundColor3 = theme.colors.glass
        end
        if child:IsA("TextLabel") then
            if child.TextColor3 == Color3.fromRGB(200,180,255) then
                child.TextColor3 = theme.colors.accent
            elseif child.TextColor3 == Color3.fromRGB(160,150,180) then
                child.TextColor3 = theme.colors.muted
            elseif child.TextColor3 == Color3.fromRGB(235,230,245) then
                child.TextColor3 = theme.colors.text
            end
        end
        if child:IsA("TextButton") and child.BackgroundColor3 == Color3.fromRGB(45,35,65) then
            child.BackgroundColor3 = theme.colors.accentDark
            child.TextColor3 = theme.colors.accent
        end
    end
    Notif("Theme", theme.name .. " Theme Applied", "ok")
end

local legendBtn = Instance.new("TextButton")
legendBtn.Size = UDim2.new(1, 0, 0, 32)
legendBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
legendBtn.BorderSizePixel = 0
legendBtn.Text = "LEGEND"
legendBtn.TextColor3 = currentTheme.colors.accent
legendBtn.Font = Enum.Font.GothamBold
legendBtn.TextSize = 10
legendBtn.Parent = P13
Instance.new("UICorner", legendBtn).CornerRadius = UDim.new(0, 5)
legendBtn.MouseButton1Click:Connect(function() applyTheme("legend") end)

local zicoBtn = Instance.new("TextButton")
zicoBtn.Size = UDim2.new(1, 0, 0, 32)
zicoBtn.Position = UDim2.new(0, 0, 0, 36)
zicoBtn.BackgroundColor3 = Color3.fromRGB(10, 20, 30)
zicoBtn.BorderSizePixel = 0
zicoBtn.Text = "ZICO"
zicoBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
zicoBtn.Font = Enum.Font.GothamBold
zicoBtn.TextSize = 10
zicoBtn.Parent = P13
Instance.new("UICorner", zicoBtn).CornerRadius = UDim.new(0, 5)
zicoBtn.MouseButton1Click:Connect(function() applyTheme("zico") end)

-- Page 14: Keys
Sec(P14, "SHORTCUT KEYS")
KeyBind(P14, "KillAura", KEYS.KillAura, "KillAura")
KeyBind(P14, "Fly", KEYS.Fly, "Fly")
KeyBind(P14, "Ghost", KEYS.Ghost, "Ghost")
KeyBind(P14, "TP+Grab", KEYS.TpGrab, "TpGrab")
KeyBind(P14, "Grab Spam", KEYS.GrabSpam, "GrabSpam")
KeyBind(P14, "TP Walk", KEYS.TPWalk, "TPWalk")
KeyBind(P14, "Invis", KEYS.Invis, "Invis")
KeyBind(P14, "Reset", KEYS.Reset, "Reset")

-- =============================================
-- MOBILE TOGGLE
-- =============================================
local isMobile = (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) or
                 (UserInputService.TouchEnabled and UserInputService.MouseEnabled == false)

local MobileToggle = Instance.new("TextButton", GUI)
MobileToggle.Size = UDim2.new(0, 56, 0, 56)
MobileToggle.Position = UDim2.new(0, 16, 1, -72)
MobileToggle.BackgroundColor3 = currentTheme.colors.accent
MobileToggle.BackgroundTransparency = 0.15
MobileToggle.Text = "⚡"
MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.TextSize = 26
MobileToggle.BorderSizePixel = 0
MobileToggle.ZIndex = 9999
local mtCorner = Instance.new("UICorner", MobileToggle)
mtCorner.CornerRadius = UDim.new(1, 0)
local mtStroke = Instance.new("UIStroke", MobileToggle)
mtStroke.Color = currentTheme.colors.accent
mtStroke.Thickness = 2
mtStroke.Transparency = 0.3

if isMobile then
    MobileToggle.Visible = true
else
    MobileToggle.Visible = false
end

local guiVisible = false

-- PC toggle (Insert key)
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if not isMobile and i.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible
        Main.Visible = guiVisible
        if guiVisible then
            TweenService:Create(MobileToggle, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        else
            TweenService:Create(MobileToggle, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.15
            }):Play()
        end
    end
end)

-- Mobile toggle
MobileToggle.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    Main.Visible = guiVisible
    if guiVisible then
        TweenService:Create(MobileToggle, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    else
        TweenService:Create(MobileToggle, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.15
        }):Play()
    end
end)

-- =============================================
-- INIT
-- =============================================
-- Load targets and friends
LH.targetList = parseList(SAVE.kaTargets)
LH.friendList = parseList(SAVE.kaFriends)

-- Start features
if LH.KillAura then StartKA() end
if LH.EspBox then startEsp() end
if LH.Fly then startFly() end
if LH.Spin then startSpin() end
if LH.Glitch then startGlitch() end
if LH.RainbowTag then startRP() end
if LH.BioPhrases then startPhrases() end
if LH.SafeSpot then goSafe() end
if LH.Ghost then startGhost() end

if lp.Character and LH.AntiRag then
    task.spawn(cleanRag, lp.Character)
end

Notif("LEGEND HUB V2", "Loaded! Made by LEGEND", "ok")

print("LEGEND HUB V2 LOADED")
print("Immune: Villain63935, Zicooooi, lilufxc")
print("Data auto-saves to: lh_data.json")
