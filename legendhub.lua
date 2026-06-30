local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Http = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local wait = task.wait
local spawn = task.spawn
local insert = table.insert
local random = math.random
local rad = math.rad
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local WHITELIST = {
    ["Villain63935"] = true,
    ["Zicooooi"] = true,
}

local SEVEN_DAY_KEYS = {}
for i = 1, 10 do
    SEVEN_DAY_KEYS["free7daykey" .. i] = 604800
end

local LIFETIME_KEYS = {
    "free_vip_key",
}

local keyData = {}
pcall(function()
    if readfile then
        local data = readfile("lh_keydata.json")
        if data then
            keyData = Http:JSONDecode(data)
        end
    end
end)

local function saveKeyData()
    pcall(function()
        if writefile then
            writefile("lh_keydata.json", Http:JSONEncode(keyData))
        end
    end)
end

local function isWhitelisted()
    return WHITELIST[player.Name] == true
end

local function generateKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local key = "free24h_"
    for i = 1, 8 do
        key = key .. string.sub(chars, random(1, #chars), random(1, #chars))
    end
    return key
end

local function checkKey(inputKey)
    for _, k in ipairs(LIFETIME_KEYS) do
        if inputKey == k then
            return true, "lifetime"
        end
    end
    
    if SEVEN_DAY_KEYS[inputKey] then
        if keyData[inputKey] then
            local elapsed = os.time() - keyData[inputKey].activated
            local remaining = SEVEN_DAY_KEYS[inputKey] - elapsed
            if remaining > 0 then
                return true, "active", remaining
            else
                keyData[inputKey].expired = true
                saveKeyData()
                return false, "expired"
            end
        else
            keyData[inputKey] = {
                activated = os.time(),
                user = player.Name,
                expired = false
            }
            saveKeyData()
            return true, "active", SEVEN_DAY_KEYS[inputKey]
        end
    end
    
    if inputKey:match("^free24h_") then
        if keyData[inputKey] then
            local elapsed = os.time() - keyData[inputKey].activated
            local remaining = 86400 - elapsed
            if remaining > 0 then
                return true, "active", remaining
            else
                keyData[inputKey].expired = true
                saveKeyData()
                return false, "expired"
            end
        else
            keyData[inputKey] = {
                activated = os.time(),
                user = player.Name,
                expired = false,
                generated = true
            }
            saveKeyData()
            return true, "active", 86400
        end
    end
    
    if keyData[inputKey] and keyData[inputKey].expired then
        return false, "burned"
    end
    
    return false, "invalid"
end

if isWhitelisted() then
    print("✅ Whitelisted user:", player.Name)
else
    local function createKeyUI()
        local sg = Instance.new("ScreenGui")
        sg.Name = "KeySystem"
        sg.ResetOnSpawn = false
        sg.Parent = player:WaitForChild("PlayerGui")
        
        local blur = Instance.new("BlurEffect")
        blur.Size = 10
        blur.Parent = game.Lighting
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 340)
        frame.Position = UDim2.new(0.5, -175, 0.5, -170)
        frame.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = sg
        
        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(1, 6, 1, 6)
        glow.Position = UDim2.new(0, -3, 0, -3)
        glow.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
        glow.BackgroundTransparency = 0.6
        glow.BorderSizePixel = 0
        glow.Parent = frame
        local glowCorner = Instance.new("UICorner", glow)
        glowCorner.CornerRadius = UDim.new(0, 18)
        
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 14)
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.Position = UDim2.new(0, 0, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = "✦ LEGEND HUB ✦"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextScaled = true
        title.Font = Enum.Font.GothamBlack
        title.Parent = frame
        
        local grad = Instance.new("UIGradient", title)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 255)),
        })
        
        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.new(1, 0, 0, 18)
        subtitle.Position = UDim2.new(0, 0, 0, 42)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = "Enter key or generate one"
        subtitle.TextColor3 = Color3.fromRGB(160, 150, 190)
        subtitle.TextScaled = true
        subtitle.Font = Enum.Font.Gotham
        subtitle.Parent = frame
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.8, 0, 0, 32)
        box.Position = UDim2.new(0.1, 0, 0, 68)
        box.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
        box.BackgroundTransparency = 0.3
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.PlaceholderText = "🔑 Paste key here..."
        box.PlaceholderColor3 = Color3.fromRGB(100, 90, 130)
        box.Font = Enum.Font.Gotham
        box.TextScaled = true
        box.BorderSizePixel = 0
        box.ClipsDescendants = true
        box.Parent = frame
        local boxCorner = Instance.new("UICorner", box)
        boxCorner.CornerRadius = UDim.new(0, 8)
        
        local boxGlow = Instance.new("Frame")
        boxGlow.Size = UDim2.new(1, 2, 1, 2)
        boxGlow.Position = UDim2.new(0, -1, 0, -1)
        boxGlow.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
        boxGlow.BackgroundTransparency = 0.8
        boxGlow.BorderSizePixel = 0
        boxGlow.Parent = box
        local boxGlowCorner = Instance.new("UICorner", boxGlow)
        boxGlowCorner.CornerRadius = UDim.new(0, 9)
        
        local genBox = Instance.new("TextBox")
        genBox.Size = UDim2.new(0.8, 0, 0, 32)
        genBox.Position = UDim2.new(0.1, 0, 0, 108)
        genBox.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
        genBox.BackgroundTransparency = 0.3
        genBox.TextColor3 = Color3.fromRGB(100, 200, 255)
        genBox.PlaceholderText = "🔄 Generated key..."
        genBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 80)
        genBox.Font = Enum.Font.Gotham
        genBox.TextScaled = true
        genBox.BorderSizePixel = 0
        genBox.ClipsDescendants = true
        genBox.Active = false
        genBox.Parent = frame
        local genCorner = Instance.new("UICorner", genBox)
        genCorner.CornerRadius = UDim.new(0, 8)
        
        local genGlow = Instance.new("Frame")
        genGlow.Size = UDim2.new(1, 2, 1, 2)
        genGlow.Position = UDim2.new(0, -1, 0, -1)
        genGlow.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        genGlow.BackgroundTransparency = 0.8
        genGlow.BorderSizePixel = 0
        genGlow.Parent = genBox
        local genGlowCorner = Instance.new("UICorner", genGlow)
        genGlowCorner.CornerRadius = UDim.new(0, 9)
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0.25, 0, 0, 22)
        copyBtn.Position = UDim2.new(0.37, 0, 0, 148)
        copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        copyBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        copyBtn.Text = "📋 COPY"
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextScaled = true
        copyBtn.BorderSizePixel = 0
        copyBtn.Visible = false
        copyBtn.Parent = frame
        local copyCorner = Instance.new("UICorner", copyBtn)
        copyCorner.CornerRadius = UDim.new(0, 6)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 0, 32)
        btn.Position = UDim2.new(0.05, 0, 0, 185)
        btn.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = "▶ UNLOCK"
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.BorderSizePixel = 0
        btn.Parent = frame
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 10)
        
        local genBtn = Instance.new("TextButton")
        genBtn.Size = UDim2.new(0.4, 0, 0, 32)
        genBtn.Position = UDim2.new(0.55, 0, 0, 185)
        genBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
        genBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        genBtn.Text = "🎲 GENERATE"
        genBtn.Font = Enum.Font.GothamBold
        genBtn.TextScaled = true
        genBtn.BorderSizePixel = 0
        genBtn.Parent = frame
        local genBtnCorner = Instance.new("UICorner", genBtn)
        genBtnCorner.CornerRadius = UDim.new(0, 10)
        
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1, 0, 0, 25)
        timerLabel.Position = UDim2.new(0, 0, 0, 228)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = ""
        timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        timerLabel.TextScaled = true
        timerLabel.Font = Enum.Font.Gotham
        timerLabel.Parent = frame
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1, 0, 0, 22)
        status.Position = UDim2.new(0, 0, 0, 255)
        status.BackgroundTransparency = 1
        status.Text = ""
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        status.TextScaled = true
        status.Font = Enum.Font.Gotham
        status.Parent = frame
        
        local timeRemain = Instance.new("TextLabel")
        timeRemain.Size = UDim2.new(1, 0, 0, 20)
        timeRemain.Position = UDim2.new(0, 0, 0, 280)
        timeRemain.BackgroundTransparency = 1
        timeRemain.Text = ""
        timeRemain.TextColor3 = Color3.fromRGB(100, 200, 255)
        timeRemain.TextScaled = true
        timeRemain.Font = Enum.Font.Gotham
        timeRemain.Parent = frame
        
        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 24, 0, 24)
        close.Position = UDim2.new(1, -34, 0, 8)
        close.BackgroundColor3 = Color3.fromRGB(100, 30, 40)
        close.BackgroundTransparency = 0.5
        close.Text = "✕"
        close.TextColor3 = Color3.fromRGB(255, 200, 200)
        close.Font = Enum.Font.GothamBold
        close.TextSize = 12
        close.BorderSizePixel = 0
        close.Parent = frame
        local closeCorner = Instance.new("UICorner", close)
        closeCorner.CornerRadius = UDim.new(0, 6)
        close.MouseButton1Click:Connect(function()
            sg:Destroy()
            blur:Destroy()
        end)
        
        local function updateTimer(remaining)
            if remaining then
                local hours = math.floor(remaining / 3600)
                local mins = math.floor((remaining % 3600) / 60)
                local secs = math.floor(remaining % 60)
                if hours > 0 then
                    timeRemain.Text = string.format("⏰ %dh %dm %ds", hours, mins, secs)
                elseif mins > 0 then
                    timeRemain.Text = string.format("⏰ %dm %ds", mins, secs)
                else
                    timeRemain.Text = string.format("⏰ %ds", secs)
                end
                timeRemain.TextColor3 = Color3.fromRGB(100, 200, 255)
            else
                timeRemain.Text = ""
            end
        end
        
        local timerThread
        local function startTimer(remaining)
            if timerThread then task.cancel(timerThread) end
            timerThread = spawn(function()
                while remaining > 0 do
                    updateTimer(remaining)
                    wait(1)
                    remaining = remaining - 1
                end
                updateTimer(nil)
            end)
        end
        
        local generatedKey = ""
        local function startKeyGeneration()
            generatedKey = generateKey()
            genBox.Text = generatedKey
            genBox.PlaceholderText = ""
            copyBtn.Visible = true
            
            genBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
            genBtn.Text = "⏳ 60s"
            genBtn.TextColor3 = Color3.fromRGB(200, 150, 150)
            genBtn.Active = false
            
            timerLabel.Text = "⏳ Generating... 60s"
            timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            status.Text = ""
            copyBtn.Visible = false
            
            local genThread = spawn(function()
                for i = 60, 0, -1 do
                    if i > 0 then
                        genBtn.Text = string.format("⏳ %ds", i)
                        timerLabel.Text = string.format("⏳ Please wait %ds...", i)
                    else
                        timerLabel.Text = "✅ Key generated! Click UNLOCK."
                        timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                        genBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
                        genBtn.Text = "🎲 GENERATE"
                        genBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
                        genBtn.Active = true
                        status.Text = "✅ Key generated! Click UNLOCK."
                        status.TextColor3 = Color3.fromRGB(100, 255, 100)
                        copyBtn.Visible = true
                    end
                    wait(1)
                end
            end)
        end
        
        copyBtn.MouseButton1Click:Connect(function()
            if generatedKey ~= "" and genBox.Text ~= "" then
                setclipboard(generatedKey)
                status.Text = "📋 Key copied!"
                status.TextColor3 = Color3.fromRGB(100, 200, 255)
                timerLabel.Text = "📋 Copied! Paste in the box above."
                timerLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            end
        end)
        
        genBtn.MouseButton1Click:Connect(function()
            if genBtn.Active == false then return end
            startKeyGeneration()
        end)
        
        btn.MouseButton1Click:Connect(function()
            local entered = box.Text
            if entered == "" then
                status.Text = "❌ Please enter a key!"
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
                return
            end
            
            local valid, keyType, remaining = checkKey(entered)
            
            if valid then
                if keyType == "lifetime" then
                    status.Text = "✅ PERMANENT ACCESS!"
                    status.TextColor3 = Color3.fromRGB(100, 255, 100)
                    timeRemain.Text = "👑 VIP - Never Expires!"
                    timeRemain.TextColor3 = Color3.fromRGB(255, 215, 0)
                else
                    status.Text = "✅ ACCESS GRANTED!"
                    status.TextColor3 = Color3.fromRGB(100, 255, 100)
                    startTimer(remaining)
                end
                
                for i = 1, 3 do
                    btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                    wait(0.1)
                    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
                    wait(0.1)
                end
                
                wait(0.5)
                sg:Destroy()
                blur:Destroy()
            else
                if keyType == "expired" or keyType == "burned" then
                    status.Text = "❌ Key EXPIRED! Generate a new one."
                    status.TextColor3 = Color3.fromRGB(255, 50, 50)
                    timeRemain.Text = "💀 Key is BURNED"
                    timeRemain.TextColor3 = Color3.fromRGB(255, 50, 50)
                else
                    status.Text = "❌ Invalid key! Try again."
                    status.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
                box.Text = ""
                box.PlaceholderText = "Try again..."
                
                local origPos = frame.Position
                for i = 1, 5 do
                    frame.Position = UDim2.new(0.5, -175 + (i%2 == 0 and 8 or -8), 0.5, -170)
                    wait(0.05)
                end
                frame.Position = origPos
            end
        end)
        
        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                btn.MouseButton1Click:Fire()
            end
        end)
        
        return sg
    end
    
    createKeyUI()
    return
end

local SAVE = _G.LH_Saves or {}
_G.LH_Saves = SAVE
SAVE.kaTargets = SAVE.kaTargets or ""
SAVE.kaFriends = SAVE.kaFriends or ""
SAVE.headSit = SAVE.headSit or ""
SAVE.curTheme = SAVE.curTheme or "legend"
SAVE.keybinds = SAVE.keybinds or {}

pcall(function()
    if readfile then
        local ok, d = pcall(function() return Http:JSONDecode(readfile("lh_data.json")) end)
        if ok and type(d) == "table" then
            for k, v in pairs(d) do SAVE[k] = v end
        end
    end
end)

local function DoSave()
    pcall(function()
        if writefile then
            writefile("lh_data.json", Http:JSONEncode({
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

local S = {}
setmetatable(S, {__index = function(t,k) return false end})

local function loadAllSettings()
    S.KillAuraRange = LoadSetting("KillAuraRange", 50)
    S.AttacksPerSecond = LoadSetting("AttacksPerSecond", 10000)
    S.HitboxSize = LoadSetting("HitboxSize", 10)
    S.StrafeRadius = LoadSetting("StrafeRadius", 10)
    S.StrafeSpeed = LoadSetting("StrafeSpeed", 4)
    S.StrafeOffset = LoadSetting("StrafeOffset", -2)
    S.RainbowSpeed = LoadSetting("RainbowSpeed", 8)
    S.tpSpeed = LoadSetting("tpSpeed", 50)
    S.flySpeed = LoadSetting("flySpeed", 80)
    S.tpHitRange = LoadSetting("tpHitRange", 35)
    S.glitchInt = LoadSetting("glitchInt", 4)
    S.spinSpeed = LoadSetting("spinSpeed", 60)
    S.parryRange = LoadSetting("parryRange", 12)
    S.bioTypeSpeed = LoadSetting("bioTypeSpeed", 15)
    S.orbRadius = LoadSetting("orbRadius", 10)
    S.orbSpeed = LoadSetting("orbSpeed", 5)
    S.orbHeight = LoadSetting("orbHeight", 2)
    S.rpMode = LoadSetting("rpMode", "rainbow")
    S.targetNames = LoadSetting("targetNames", "")
    S.friendNames = LoadSetting("friendNames", "")
    S.userPhrases = LoadSetting("userPhrases", {"LEGEND ON TOP!"})
    S.KillAura = LoadSetting("KillAura", true)
    S.AntiRag = LoadSetting("AntiRag", true)
    S.BypassRange = LoadSetting("BypassRange", true)
    S.AntiAFK = LoadSetting("AntiAFK", true)
    S.Invincible = LoadSetting("Invincible", false)
    S.Noclip = LoadSetting("Noclip", false)
    S.AutoBlock = LoadSetting("AutoBlock", false)
    S.AutoParry = LoadSetting("AutoParry", false)
    S.AutoStomp = LoadSetting("AutoStomp", false)
    S.GrabSpamNoTP = LoadSetting("GrabSpamNoTP", false)
    S.Spin = LoadSetting("Spin", false)
    S.RainbowTag = LoadSetting("RainbowTag", false)
    S.BioPhrases = LoadSetting("BioPhrases", false)
    S.EspBox = LoadSetting("EspBox", false)
    S.Invisible = LoadSetting("Invisible", false)
    S.AutoFarm = LoadSetting("AutoFarm", false)
    S.RapidHit = LoadSetting("RapidHit", false)
    S.PunchSpam = LoadSetting("PunchSpam", false)
    S.FakeJitter = LoadSetting("FakeJitter", false)
    S.Strafe = LoadSetting("Strafe", false)
    S.Backstab = LoadSetting("Backstab", false)
    S.Orbit = LoadSetting("Orbit", false)
    S.HeadSit = LoadSetting("HeadSit", false)
    S.Glitch = LoadSetting("Glitch", false)
    S.Hitbox = LoadSetting("Hitbox", false)
    S.HitboxVis = LoadSetting("HitboxVis", false)
    S.Fly = LoadSetting("Fly", false)
    S.TPWalk = LoadSetting("TPWalk", false)
    S.DeathTP = LoadSetting("DeathTP", false)
    S.AutoRespawn = LoadSetting("AutoRespawn", false)
    S.SafeSpot = LoadSetting("SafeSpot", false)
    S.DodgeGrab = LoadSetting("DodgeGrab", false)
    S.AntiFling = LoadSetting("AntiFling", false)
    S.InfJump = LoadSetting("InfJump", false)
    S.NameTypewriter = LoadSetting("NameTypewriter", false)
    S.Ghost = LoadSetting("Ghost", false)
    S.currentTheme = LoadSetting("currentTheme", "legend")
end

loadAllSettings()

S.strafeAngle = 0
S.orbitAngle = 0
S.rpNameIdx = 1
S.deathCF = nil
S.grabGlitchName = ""
S.strafeName = ""
S.headSitName = ""
S.tpHitName = ""
S.autoGrabName = ""
S.orbitName = ""
S.glitchName = ""
S.targetList = {}
S.friendList = {}
S.currentPhrase = ""
S.AuraTurbo = true
S.AuraBurst = true
S.EspTeamCheck = true
S.CtrlClickTP = false
S.grabTargetName = ""

S.Keys = { 
    KillAura = Enum.KeyCode.U, 
    Fly = Enum.KeyCode.F, 
    Ghost = Enum.KeyCode.G, 
    TpGrab = Enum.KeyCode.Q, 
    TPWalk = Enum.KeyCode.X, 
    Invis = Enum.KeyCode.I, 
    Reset = Enum.KeyCode.T, 
    GrabSpam = Enum.KeyCode.H 
}
local activeKeyBind = nil

local Conns = {}
local function TC(sig, func) 
    if typeof(sig) ~= "RBXScriptSignal" then return nil end
    local c = sig:Connect(func)
    insert(Conns, c)
    return c 
end

player.Idled:Connect(function()
    if S.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

mouse.Button1Down:Connect(function()
    if S.CtrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local ch = player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp and mouse.Hit then
            hrp.CFrame = mouse.Hit * CFrame.new(0, 3, 0)
        end
    end
end)

local HitR, PunchR, BlockR, GrabR, BioR, BioColR, RPColR, NameR
do 
    local function gr(...) 
        local cur = RS
        for _, n in ipairs({...}) do 
            if cur then cur = cur:FindFirstChild(n) else return nil end 
        end
        return cur 
    end
    HitR = gr("Packages","Knit","Services","CombatService","RF","Hit")
    PunchR = gr("Packages","Knit","Services","CombatService","RF","PunchDo")
    BlockR = gr("Packages","Knit","Services","CombatService","RF","Block")
    GrabR = gr("Packages","Knit","Services","CombatService","RF","Grab")
    local rem = RS:FindFirstChild("Remotes")
    if rem then 
        BioR = rem:FindFirstChild("UpdateBio")
        BioColR = rem:FindFirstChild("UpdateBioColor")
        RPColR = rem:FindFirstChild("UpdateRPColor")
        NameR = rem:FindFirstChild("UpdateRPName")
    end 
end

local function parseList(str) 
    local t = {}; 
    if str == "" then return t end
    for w in str:gmatch("%S+") do 
        insert(t, w:lower()) 
    end
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
    if matchAny(S.friendList, n) then return true end 
    return false 
end

local function isTarget(n) 
    if #S.targetList == 0 then return true end
    return matchAny(S.targetList, n) 
end

local function findPlayer(name)
    if name == "" then return nil end
    local s = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= player and (p.Name:lower():find(s) or (p.DisplayName and p.DisplayName:lower():find(s))) then 
            return p
        end
    end
    return nil 
end

local function findNearest(range)
    local ch = player.Character
    if not ch then return nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local mp = hrp.Position
    local best, bd = nil, range
    for _, p in ipairs(Players:GetPlayers()) do 
        if p == player or not p.Character then continue end
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

local function isSelfHit(hum) 
    local myChar = player.Character
    if not myChar then return false end
    if hum.Parent == myChar then return true end
    return false 
end

local function doHit(hum, thrp, myhrp)
    if not hum or not hum.Parent then return end
    if isSelfHit(hum) then return end
    spawn(function()
        local pos = myhrp.Position
        if S.BypassRange and thrp then 
            pos = thrp.Position + thrp.CFrame.LookVector * 2 
        end
        pcall(function() 
            HitR:InvokeServer(hum, vector.create(pos.X, pos.Y, pos.Z)) 
        end)
    end)
end

local function doGrab(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    spawn(function()
        local myChar = player.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then
            local origCF = myHRP.CFrame
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 2)
            myHRP.AssemblyLinearVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
            pcall(function() GrabR:InvokeServer(targetPlayer) end)
            myHRP.CFrame = origCF
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function doRawGrab(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    spawn(function() 
        pcall(function() 
            GrabR:InvokeServer(targetPlayer) 
        end) 
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
        local ch = player.Character
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
        elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy() end
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
    wait(2.5)
    if not S.AntiRagCombo then return end
    arc.platConn = hu:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not S.AntiRagCombo or arc.inRet then return end
        if hu.PlatformStand then
            arc.grabbed = true
            if not arc.origCF then arc.origCF = hrp.CFrame end
        end
    end)
    arc.conn = RunService.Heartbeat:Connect(function()
        if not S.AntiRagCombo or not ch.Parent then return end
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

local targetCache, cacheTime = {}, 0
local auraThread

local function startAura()
    if auraThread then return end
    cacheTime = 0
    auraThread = spawn(function()
        while S.KillAura do 
            pcall(function()
                local ch = player.Character
                if not ch then return end
                local myHRP = ch:FindFirstChild("HumanoidRootPart")
                if not myHRP then return end
                local now = tick()
                if now - cacheTime > 0.1 then
                    targetCache = {}
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl == player or not pl.Character then continue end
                        if isFriend(pl.Name) or isFriend(pl.DisplayName) then continue end
                        if not isTarget(pl.Name) and not isTarget(pl.DisplayName) then continue end
                        local h = pl.Character:FindFirstChild("HumanoidRootPart")
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if h and hu and hu.Health > 0 then
                            targetCache[pl] = {hu, h}
                        end
                    end
                    cacheTime = now
                end
                local hits = {}
                local cls, md = nil, math.huge
                for p, d in pairs(targetCache) do
                    local dist = (d[2].Position - myHRP.Position).Magnitude
                    if dist <= S.KillAuraRange and dist < md then
                        md = dist
                        cls = d
                    end
                end
                if cls then insert(hits, cls) end
                if #hits > 0 then
                    spawn(function()
                        for _, hd in ipairs(hits) do
                            doHit(hd[1], hd[2], myHRP)
                        end
                    end)
                end
            end)
            wait(1/S.AttacksPerSecond)
        end
        auraThread = nil
    end)
end

local function stopAura()
    S.KillAura = false
end

TC(RunService.Heartbeat, function()
    if S.AutoBlock then
        pcall(function() BlockR:InvokeServer(true) end)
    end
end)

TC(RunService.Heartbeat, function()
    if not S.AutoFarm then return end
    local ch = player.Character
    if not ch then return end
    local myHRP = ch:FindFirstChild("HumanoidRootPart")
    local myHu = ch:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHu or myHu.Health <= 0 then return end
    local tgt = findNearest(S.KillAuraRange * 3)
    if tgt and tgt.Character then
        local tHRP = tgt.Character:FindFirstChild("HumanoidRootPart")
        local tHu = tgt.Character:FindFirstChildOfClass("Humanoid")
        if tHRP and tHu and tHu.Health > 0 then
            myHRP.CFrame = CFrame.new(tHRP.Position - tHRP.CFrame.LookVector*3 + Vector3.new(0,2,0), tHRP.Position)
            pcall(function() PunchR:InvokeServer() end)
            doHit(tHu, tHRP, myHRP)
        end
    end
end)

local lastRawGrabSpam = 0
TC(RunService.Heartbeat, function()
    if not S.GrabSpamNoTP then return end
    local now = tick()
    if now - lastRawGrabSpam < 0.35 then return end
    lastRawGrabSpam = now
    local ch = player.Character
    if not ch then return end
    local myHRP = ch:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player or not p.Character then continue end
        if isFriend(p.Name) or isFriend(p.DisplayName) then continue end
        if not isTarget(p.Name) and not isTarget(p.DisplayName) then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local hu = p.Character:FindFirstChildOfClass("Humanoid")
        if hrp and hu and hu.Health > 0 and (hrp.Position - myHRP.Position).Magnitude <= S.KillAuraRange then
            doRawGrab(p)
        end
    end
end)

TC(RunService.Heartbeat, function(dt)
    if not S.TPWalk then return end
    local ch = player.Character
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hu and hrp and hu.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + hu.MoveDirection * S.tpSpeed * dt
    end
end)

TC(RunService.Heartbeat, function()
    if not S.AntiRag then return end
    local ch = player.Character
    if ch then cleanRag(ch) end
end)

TC(player.CharacterAdded, function(ch)
    ch.DescendantAdded:Connect(function()
        if S.AntiRag then wait(); cleanRag(ch) end
    end)
end)

TC(RunService.RenderStepped, function()
    if not S.Invisible then return end
    local ch = player.Character
    if not ch then return end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.LocalTransparencyModifier = 1
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
end)

local lastRapidHit = 0
local rhConn
local function startRapidHit()
    if rhConn then rhConn:Disconnect() end
    rhConn = RunService.Heartbeat:Connect(function()
        if not S.RapidHit then
            if rhConn then rhConn:Disconnect(); rhConn = nil end
            return
        end
        local now = tick()
        if now - lastRapidHit < 0.1 then return end
        lastRapidHit = now
        local ch = player.Character
        local myHRP = ch and ch:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player or not p.Character or isFriend(p.Name) or not isTarget(p.Name) then continue end
            local hu = p.Character:FindFirstChildOfClass("Humanoid")
            if hu and hu.Health > 0 then
                pcall(function()
                    HitR:InvokeServer(hu, vector.create(myHRP.Position.X, myHRP.Position.Y, myHRP.Position.Z))
                end)
            end
        end
    end)
end

local psConn
local function startPunchSpam()
    if psConn then psConn:Disconnect() end
    psConn = RunService.Heartbeat:Connect(function()
        if not S.PunchSpam then
            if psConn then psConn:Disconnect(); psConn = nil end
            return
        end
        pcall(function() PunchR:InvokeServer() end)
    end)
end

local flyBV, flyBG, flyConn
local function startFly()
    local ch = player.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if hu then hu.PlatformStand = true end
    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    flyBV.Velocity = Vector3.zero
    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    flyBG.D = 150
    S.Fly = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not S.Fly then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v = v - Vector3.new(0,1,0) end
        if v.Magnitude > 0 then v = v.Unit * S.flySpeed end
        if flyBV and flyBV.Parent then flyBV.Velocity = v end
        if flyBG and flyBG.Parent then flyBG.CFrame = cam.CFrame end
    end)
end

local function stopFly()
    S.Fly = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    pcall(function() if flyBV then flyBV:Destroy(); flyBV = nil end end)
    pcall(function() if flyBG then flyBG:Destroy(); flyBG = nil end end)
    pcall(function() player.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false end)
end

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
    if not S.Ghost then return end
    S.Ghost = false
    if ghost.conn then ghost.conn:Disconnect(); ghost.conn = nil end
    if ghost.died then ghost.died:Disconnect(); ghost.died = nil end
    local ch = player.Character
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
                wait()
                hrp.CFrame = dHRP.CFrame + Vector3.new(0,2,0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
        workspace.CurrentCamera.CameraSubject = hu or ch
    end
    if ghost.decoy then ghost.decoy:Destroy(); ghost.decoy = nil end
end

local function startGhost()
    if S.Ghost then return end
    local ch = player.Character
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
    S.Ghost = true
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
        if not S.Ghost or not ghost.decoy or not ghost.decoy.Parent then
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
        local remote = RS:FindFirstChild("CatalogOnApplyToRealHumanoid", true)
        if remote then
            remote:FireServer(unpack(args))
        end
    end)
end

local glConn
local function startGlitch()
    if glConn then glConn:Disconnect() end
    glConn = RunService.RenderStepped:Connect(function()
        if not S.Glitch then return end
        local tgt = findPlayer(S.glitchName) or findNearest(9999)
        if not tgt or not tgt.Character then return end
        local tH = tgt.Character:FindFirstChild("HumanoidRootPart")
        if not tH then return end
        local ch = player.Character
        if not ch then return end
        local mH = ch:FindFirstChild("HumanoidRootPart")
        if not mH then return end
        mH.AssemblyLinearVelocity = Vector3.zero
        for _ = 1, 8 do
            mH.CFrame = tH.CFrame * CFrame.new(random(-S.glitchInt,S.glitchInt), random(-2,2), random(-S.glitchInt,S.glitchInt)) * CFrame.Angles(rad(random(-360,360)), rad(random(-360,360)), rad(random(-360,360)))
        end
    end)
end

local sAt, sAO, sBV, spConn, spAng = nil, nil, nil, nil, 0

local function startSpin()
    pcall(function()
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if sAt then sAt:Destroy() end
        if sAO then sAO:Destroy() end
        if sBV then sBV:Destroy() end
        sAt = Instance.new("Attachment", hrp)
        sAO = Instance.new("AlignOrientation")
        sAO.Attachment0 = sAt
        sAO.MaxTorque = math.huge
        sAO.Responsiveness = 200
        sAO.Mode = Enum.OrientationAlignmentMode.OneAttachment
        sAO.Parent = hrp
        sBV = Instance.new("BodyVelocity", hrp)
        sBV.MaxForce = Vector3.zero
        sBV.Velocity = Vector3.zero
        sBV.P = 1e4
        spConn = RunService.Heartbeat:Connect(function(dt)
            if not S.Spin then return end
            spAng = spAng + S.spinSpeed * dt
            sAO.CFrame = CFrame.Angles(0, spAng, 0)
            pcall(function()
                hrp.AssemblyAngularVelocity = Vector3.new(0, S.spinSpeed, 0)
            end)
        end)
    end)
end

local function stopSpin()
    pcall(function() if spConn then spConn:Disconnect(); spConn = nil end end)
    pcall(function() if sAt then sAt:Destroy(); sAt = nil end end)
    pcall(function() if sAO then sAO:Destroy(); sAO = nil end end)
    pcall(function() if sBV then sBV:Destroy(); sBV = nil end end)
end

local rpConn, bioSet = nil, false
local bioTask = nil

local function startPhrases()
    if bioTask then task.cancel(bioTask) end
    bioTask = spawn(function()
        while S.BioPhrases do
            local s = S.userPhrases[random(1, #S.userPhrases)]
            local t = ""
            local dl = 1 / (S.bioTypeSpeed or 10)
            for u = 1, #s do
                if not S.BioPhrases then break end
                t = string.sub(s, 1, u)
                S.currentPhrase = t
                wait(dl)
            end
            wait(0.05)
            S.currentPhrase = ""
        end
    end)
end

local function startRP()
    if rpConn then return end
    if not bioSet then
        pcall(function() BioR:FireServer("") end)
        bioSet = true
    end
    local aB, aR, bT, rT, nT = 0, 0, 0, 0, 0
    rpConn = RunService.RenderStepped:Connect(function(dt)
        if not S.RainbowTag then return end
        local spd = S.RainbowSpeed * 0.05
        aB = aB + dt * spd
        aR = aR + dt * spd
        bT = bT + dt
        rT = rT + dt
        nT = nT + dt
        if bT >= 0.06 and S.BioPhrases and S.currentPhrase ~= "" then
            bT = 0
            pcall(function() BioR:FireServer(S.currentPhrase) end)
        end
        if S.NameTypewriter and nT >= 0.1 then
            nT = 0
            local fn = player.DisplayName
            pcall(function() NameR:FireServer(string.sub(fn, 1, S.rpNameIdx)) end)
            S.rpNameIdx = S.rpNameIdx >= #fn and 1 or S.rpNameIdx + 1
        end
        if rT >= 0.04 then
            rT = 0
            local cB, cR
            local m = S.rpMode
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
            else
                cB = Color3.fromHSV(aB%1,0.8,0.9)
                cR = Color3.fromHSV(aR%1,0.8,0.9)
            end
            if cB then pcall(function() BioColR:FireServer(cB) end) end
            if cR then pcall(function() RPColR:FireServer(cR) end) end
        end
    end)
end

local function stopRP()
    if rpConn then rpConn:Disconnect(); rpConn = nil end
end

local SAFE_CF = CFrame.new(0, 100, 0)
local safeOrig, safeConn = nil, nil

local function goSafe()
    local ch = player.Character
    local h = ch and ch:FindFirstChild("HumanoidRootPart")
    if not h then return end
    safeOrig = h.CFrame
    h.CFrame = SAFE_CF
    h.AssemblyLinearVelocity = Vector3.zero
    pcall(function() ch:FindFirstChildOfClass("Humanoid").PlatformStand = true end)
    if safeConn then safeConn:Disconnect() end
    safeConn = RunService.Heartbeat:Connect(function()
        if not S.SafeSpot then return end
        local c = player.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if hr then
            hr.CFrame = SAFE_CF
            hr.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function endSafe()
    if safeConn then safeConn:Disconnect(); safeConn = nil end
    local ch = player.Character
    local h = ch and ch:FindFirstChild("HumanoidRootPart")
    if h then
        pcall(function()
            local hu = ch:FindFirstChildOfClass("Humanoid")
            if hu then
                hu.PlatformStand = false
                hu.Sit = false
                hu:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
        h.AssemblyLinearVelocity = Vector3.zero
        if safeOrig then
            h.CFrame = safeOrig
            safeOrig = nil
        end
    end
end

TC(RunService.Heartbeat, function(dt)
    local ch = player.Character
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    
    if hu and S.Invincible then
        if hu.Health <= 0 then hu.Health = 100 end
        if hu.PlatformStand then hu.PlatformStand = false end
        if hu.Sit then hu.Sit = false end
        for _, st in ipairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding}) do
            pcall(function() hu:SetStateEnabled(st, false) end)
        end
        for _, o in ipairs(ch:GetDescendants()) do
            if o:IsA("Motor6D") then o.Enabled = true
            elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy() end
        end
    end
    
    if hrp and S.AntiFling then
        if hrp.AssemblyAngularVelocity.Magnitude > 15 then hrp.AssemblyAngularVelocity = Vector3.zero end
        if hrp.AssemblyLinearVelocity.Magnitude > 150 then hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * 0.75 end
    end
    
    if S.HeadSit and hrp then
        local tgt = findPlayer(S.headSitName)
        if tgt and tgt.Character then
            local hd = tgt.Character:FindFirstChild("Head")
            if hd and (hd.Position - hrp.Position).Magnitude <= S.KillAuraRange * 2 then
                hrp.CFrame = CFrame.new(hd.Position + Vector3.new(0,3,0))
            end
        end
    end
    
    if S.Strafe and hrp then
        local tgt = findPlayer(S.strafeName)
        if tgt and tgt.Character then
            local tH = tgt.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                local tp = tH.Position
                local np
                if S.Backstab then
                    np = tp + (-tH.CFrame.LookVector * S.StrafeRadius) + Vector3.new(0, S.StrafeOffset, 0)
                else
                    S.strafeAngle = S.strafeAngle + S.StrafeSpeed * dt
                    np = Vector3.new(
                        tp.X + math.cos(S.strafeAngle)*S.StrafeRadius,
                        tp.Y + S.StrafeOffset,
                        tp.Z + math.sin(S.strafeAngle)*S.StrafeRadius
                    )
                end
                hrp.CFrame = CFrame.new(np, Vector3.new(tp.X, hrp.Position.Y, tp.Z))
            end
        end
    end
    
    if S.Orbit and hrp then
        local tgt = findPlayer(S.orbitName)
        if tgt and tgt.Character then
            local tH = tgt.Character:FindFirstChild("HumanoidRootPart")
            if tH then
                S.orbitAngle = S.orbitAngle + S.orbSpeed * dt
                local tp = tH.Position
                hrp.CFrame = CFrame.new(
                    tp + Vector3.new(
                        math.cos(S.orbitAngle)*S.orbRadius,
                        S.orbHeight,
                        math.sin(S.orbitAngle)*S.orbRadius
                    ),
                    tp
                )
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
    
    if S.DodgeGrab and hu and hrp and hu.PlatformStand then
        hu.PlatformStand = false
        hu:ChangeState(Enum.HumanoidStateType.GettingUp)
        hrp.CFrame = SAFE_CF
        hrp.AssemblyLinearVelocity = Vector3.zero
        for _, o in ipairs(ch:GetDescendants()) do
            if o:IsA("Motor6D") then o.Enabled = true
            elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy() end
        end
    end
    
    if S.AutoParry and hrp then
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player or isFriend(p.Name) or not p.Character then continue end
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if not h then continue end
            if (h.Position - hrp.Position).Magnitude < S.parryRange then
                pcall(function() BlockR:InvokeServer(true) end)
                break
            end
        end
    end
    
    if S.AutoStomp and hrp then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and not isFriend(p.Name) then
                local tHu = p.Character:FindFirstChildOfClass("Humanoid")
                local tH = p.Character:FindFirstChild("HumanoidRootPart")
                if tHu and tH and tHu.Health > 0 and (tHu.PlatformStand or tHu.Sit) then
                    spawn(function()
                        local orig = hrp.CFrame
                        hrp.CFrame = tH.CFrame * CFrame.new(0,0,-2)
                        doHit(tHu, tH, hrp)
                        wait(0.05)
                        if hrp and hrp.Parent then hrp.CFrame = orig end
                    end)
                end
            end
        end
    end
end)

TC(RunService.RenderStepped, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player or not p.Character then continue end
        pcall(function()
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if S.Hitbox and isTarget(p.Name) and not isFriend(p.Name) then
                hrp.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                hrp.CanCollide = false
                if S.HitboxVis then
                    hrp.Transparency = 0.7
                    hrp.Material = Enum.Material.Neon
                else
                    hrp.Transparency = 1
                    hrp.Material = Enum.Material.Plastic
                end
            else
                hrp.Size = Vector3.new(2,2,1)
                hrp.Transparency = 1
                hrp.Material = Enum.Material.Plastic
                hrp.CanCollide = false
            end
        end)
    end
end)

TC(RunService.Stepped, function()
    if not S.Noclip then return end
    local ch = player.Character
    if not ch then return end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.CanCollide = false end)
        end
    end
end)

TC(UserInputService.JumpRequest, function()
    if not S.InfJump then return end
    local ch = player.Character
    if not ch then return end
    local hu = ch:FindFirstChildOfClass("Humanoid")
    if hu then
        pcall(function() hu:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

TC(player.CharacterAdded, function(ch)
    local hu = ch:WaitForChild("Humanoid", 8)
    local hrp = ch:WaitForChild("HumanoidRootPart", 8)
    if S.DeathTP and S.deathCF then
        wait(0.1)
        hrp.CFrame = S.deathCF
    end
    hu.Died:Connect(function()
        if hrp and hrp.Parent then S.deathCF = hrp.CFrame end
    end)
    ch.DescendantAdded:Connect(function()
        if S.AntiRag then wait(); cleanRag(ch) end
    end)
    if S.AntiRag then spawn(cleanRag, ch) end
    if S.AntiRagCombo then spawn(arcOnChar, ch) end
    if S.Spin then wait(1); startSpin() end
    if S.AutoRespawn then
        hu.Died:Connect(function()
            if S.AutoRespawn then
                wait(0.5)
                pcall(function() player:LoadCharacter() end)
            end
        end)
    end
end)

local flJitterConn
local function startJitter()
    if flJitterConn then flJitterConn:Disconnect() end
    flJitterConn = RunService.Heartbeat:Connect(function()
        if not S.FakeJitter then return end
        local ch = player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = hrp.CFrame * CFrame.new((random()-.5)*1.2, (random()-.5)*.5, (random()-.5)*1.2)
    end)
end

local espObjects = setmetatable({}, {__mode = "kv"})
local espConn

local function createEsp(p)
    if espObjects[p] then return end
    local obj = {}
    obj.Highlight = Instance.new("Highlight")
    obj.Highlight.Name = "EspChams"
    obj.Highlight.FillTransparency = 0.7
    obj.Highlight.OutlineTransparency = 0.3
    obj.Highlight.FillColor = Color3.fromRGB(255,50,50)
    obj.Highlight.OutlineColor = Color3.fromRGB(255,255,255)
    obj.Billboard = Instance.new("BillboardGui")
    obj.Billboard.Size = UDim2.new(0,100,0,20)
    obj.Billboard.StudsOffset = Vector3.new(0,3,0)
    obj.Billboard.AlwaysOnTop = true
    obj.TextLabel = Instance.new("TextLabel", obj.Billboard)
    obj.TextLabel.Size = UDim2.new(1,0,1,0)
    obj.TextLabel.BackgroundTransparency = 1
    obj.TextLabel.TextColor3 = Color3.new(1,1,1)
    obj.TextLabel.TextStrokeTransparency = 0.5
    obj.TextLabel.Font = Enum.Font.GothamBold
    obj.TextLabel.TextSize = 14
    obj.TextLabel.Text = p.Name
    espObjects[p] = obj
end

local function destroyEsp(p)
    local obj = espObjects[p]
    if obj then
        pcall(function() obj.Highlight:Destroy() end)
        pcall(function() obj.Billboard:Destroy() end)
        espObjects[p] = nil
    end
end

local function updateEsp()
    if not S.EspBox then
        for p in pairs(espObjects) do destroyEsp(p) end
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player or not p.Character then
            destroyEsp(p)
            continue
        end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local head = p.Character:FindFirstChild("Head")
        if not hrp or not hum or hum.Health <= 0 then
            destroyEsp(p)
            continue
        end
        if isFriend(p.Name) or isFriend(p.DisplayName) then
            destroyEsp(p)
            continue
        end
        if not espObjects[p] then createEsp(p) end
        local obj = espObjects[p]
        obj.Highlight.Parent = p.Character
        obj.Billboard.Parent = head
    end
end

local function startEsp()
    if espConn then return end
    espConn = RunService.RenderStepped:Connect(updateEsp)
end

local function stopEsp()
    if espConn then espConn:Disconnect(); espConn = nil end
    for p in pairs(espObjects) do destroyEsp(p) end
end

local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 280, 1, 0)
NotifHolder.Position = UDim2.new(1, -294, 0, 12)
NotifHolder.BackgroundTransparency = 1
NotifHolder.ZIndex = 9000
NotifHolder.Parent = CoreGui

local _notifs = {}

local function _restack()
    local y = 0
    for _, f in ipairs(_notifs) do
        if f and f.Parent then
            TweenService:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 0, 0, y)
            }):Play()
            y = y + 60 + 5
        end
    end
end

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
    
    insert(_notifs, f)
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
            task.delay(0.05, _restack)
        end
    end)
end

local Col = {
    bg = Color3.fromRGB(8, 5, 15),
    glass = Color3.fromRGB(15, 10, 25),
    gl = Color3.fromRGB(20, 15, 30),
    acc = Color3.fromRGB(200, 180, 255),
    accB = Color3.fromRGB(230, 210, 255),
    accD = Color3.fromRGB(50, 40, 65),
    txt = Color3.fromRGB(235, 230, 245),
    dim = Color3.fromRGB(160, 150, 180),
    mut = Color3.fromRGB(100, 90, 120),
    tOff = Color3.fromRGB(30, 25, 40),
    tOn = Color3.fromRGB(70, 60, 90),
    kOff = Color3.fromRGB(120, 110, 140),
    kOn = Color3.fromRGB(220, 200, 255),
    stk = Color3.fromRGB(50, 40, 60),
    stkL = Color3.fromRGB(70, 60, 85),
    cls = Color3.fromRGB(100, 30, 40),
    mn = Color3.fromRGB(40, 35, 50),
    inp = Color3.fromRGB(12, 8, 20),
    tabBg = Color3.fromRGB(15, 10, 25),
    tabAc = Color3.fromRGB(45, 35, 65),
    trk = Color3.fromRGB(8, 5, 15),
    sec = Color3.fromRGB(20, 15, 30)
}

local SG = Instance.new("ScreenGui")
SG.Name = "LEGEND_HUB"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 420)
Main.Position = UDim2.new(0.5, -180, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 0.85
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = SG
local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 16)

local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 6, 1, 6)
Glow.Position = UDim2.new(0, -3, 0, -3)
Glow.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
Glow.BackgroundTransparency = 0.7
Glow.BorderSizePixel = 0
Glow.Parent = Main
local glowCorner = Instance.new("UICorner", Glow)
glowCorner.CornerRadius = UDim.new(0, 18)

local BgText = Instance.new("TextLabel")
BgText.Size = UDim2.new(1, 0, 1, 0)
BgText.Position = UDim2.new(0, 0, 0, 0)
BgText.BackgroundTransparency = 1
BgText.Text = "LEGEND"
BgText.TextColor3 = Color3.fromRGB(255, 255, 255)
BgText.TextTransparency = 0.92
BgText.Font = Enum.Font.GothamBlack
BgText.TextSize = 60
BgText.TextScaled = true
BgText.ZIndex = 0
BgText.Parent = Main

local BgGradient = Instance.new("UIGradient", BgText)
BgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BackgroundTransparency = 0.5
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Main
local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 16)

local dragObj = {dragging = false, dragStart = nil, startPos = nil, glowStart = nil}

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragObj.dragging = true
        dragObj.dragStart = input.Position
        dragObj.startPos = Main.Position
        dragObj.glowStart = Glow.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragObj.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragObj.dragStart
        Main.Position = UDim2.new(
            dragObj.startPos.X.Scale, 
            dragObj.startPos.X.Offset + d.X, 
            dragObj.startPos.Y.Scale, 
            dragObj.startPos.Y.Offset + d.Y
        )
        Glow.Position = UDim2.new(
            dragObj.startPos.X.Scale, 
            dragObj.startPos.X.Offset + d.X + 3, 
            dragObj.startPos.Y.Scale, 
            dragObj.startPos.Y.Offset + d.Y + 3
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
CenterTitle.Text = "LEGEND HUB"
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
SubTitle.Text = "Made by LEGEND"
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
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
    for _, c in ipairs(Conns) do
        pcall(function() c:Disconnect() end)
    end
    DoSave()
    SG:Destroy()
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
        Size = isMin and UDim2.new(0, 360, 0, 40) or UDim2.new(0, 360, 0, 420)
    }):Play()
    MB.Text = isMin and "+" or "-"
    for _, child in pairs(Main:GetChildren()) do
        if child ~= TitleBar and child ~= BgText then
            child.Visible = not isMin
        end
    end
    Glow.Visible = not isMin
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -6, 0, 28)
TabBar.Position = UDim2.new(0, 3, 0, 44)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
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
PC.Size = UDim2.new(1, -6, 1, -78)
PC.Position = UDim2.new(0, 3, 0, 74)
PC.BackgroundTransparency = 1
PC.ScrollBarThickness = 2
PC.ScrollBarImageColor3 = Color3.fromRGB(200, 180, 255)
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
    insert(tabInfo, {t, page})
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

local function Sec(p, t)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 16)
    f.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0
    f.Parent = p
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 6, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = t:upper()
    l.TextColor3 = Color3.fromRGB(200, 180, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 6
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
end

local function Tog(p, t, cb, d)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 24)
    c.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    local st = Instance.new("UIStroke", c)
    st.Color = Color3.fromRGB(50, 40, 60)
    st.Thickness = 1
    st.Transparency = 0.6
    
    local lb = Instance.new("TextLabel", c)
    lb.Size = UDim2.new(0.7, 0, 1, 0)
    lb.Position = UDim2.new(0, 8, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = t
    lb.TextColor3 = Color3.fromRGB(235, 230, 245)
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
        kn.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
        bg.BackgroundColor3 = Color3.fromRGB(70, 60, 90)
        st.Color = Color3.fromRGB(200, 180, 255)
        st.Transparency = 0.1
    end
    
    bt.MouseButton1Click:Connect(function()
        en = not en
        TweenService:Create(kn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = en and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            BackgroundColor3 = en and Color3.fromRGB(220, 200, 255) or Color3.fromRGB(120, 110, 140)
        }):Play()
        TweenService:Create(bg, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = en and Color3.fromRGB(70, 60, 90) or Color3.fromRGB(30, 25, 40)
        }):Play()
        TweenService:Create(st, TweenInfo.new(0.18), {
            Color = en and Color3.fromRGB(200, 180, 255) or Color3.fromRGB(50, 40, 60),
            Transparency = en and 0.1 or 0.6
        }):Play()
        cb(en)
        SaveSetting(t, en)
    end)
end

local function Sld(p, t, mn, mx, df, cb)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 32)
    c.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", c).Color = Color3.fromRGB(50, 40, 60)
    c:FindFirstChildOfClass("UIStroke").Thickness = 1
    c:FindFirstChildOfClass("UIStroke").Transparency = 0.6
    
    local lb = Instance.new("TextLabel", c)
    lb.Size = UDim2.new(0.55, 0, 0, 14)
    lb.Position = UDim2.new(0, 8, 0, 1)
    lb.BackgroundTransparency = 1
    lb.Text = t
    lb.TextColor3 = Color3.fromRGB(160, 150, 180)
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 7
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.38, 0, 0, 14)
    vl.Position = UDim2.new(0.6, 0, 0, 1)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(df)
    vl.TextColor3 = Color3.fromRGB(230, 210, 255)
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
    fl.BackgroundColor3 = Color3.fromRGB(200, 180, 255)
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
    st.Color = Color3.fromRGB(50, 40, 60)
    st.Thickness = 1
    st.Transparency = 0.5
    
    local t = Instance.new("TextBox")
    t.Size = UDim2.new(1, -12, 1, 0)
    t.Position = UDim2.new(0, 6, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = ""
    t.PlaceholderText = ph
    t.PlaceholderColor3 = Color3.fromRGB(100, 90, 120)
    t.TextColor3 = Color3.fromRGB(220,220,230)
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
    b.BackgroundColor3 = Color3.fromRGB(50, 40, 65)
    b.BackgroundTransparency = 0.4
    b.BorderSizePixel = 0
    b.Text = t
    b.TextColor3 = Color3.fromRGB(230, 210, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.Parent = p
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(50, 40, 60)
    b:FindFirstChildOfClass("UIStroke").Thickness = 1
    b:FindFirstChildOfClass("UIStroke").Transparency = 0.3
    b.MouseButton1Click:Connect(function() cb() end)
end

local function KeyBind(p, t, defaultKey, keyName)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 24)
    c.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    c.BackgroundTransparency = 0.4
    c.BorderSizePixel = 0
    c.Parent = p
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", c).Color = Color3.fromRGB(50, 40, 60)
    Instance.new("UIStroke", c).Thickness = 1
    Instance.new("UIStroke", c).Transparency = 0.6
    
    local lb = Instance.new("TextLabel", c)
    lb.Size = UDim2.new(0.7, 0, 1, 0)
    lb.Position = UDim2.new(0, 8, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = t
    lb.TextColor3 = Color3.fromRGB(235, 230, 245)
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 8
    lb.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyLbl = Instance.new("TextLabel", c)
    keyLbl.Size = UDim2.new(0.25, 0, 1, 0)
    keyLbl.Position = UDim2.new(0.73, 0, 0, 0)
    keyLbl.BackgroundTransparency = 1
    keyLbl.Text = tostring(defaultKey):gsub("Enum.KeyCode.", "")
    keyLbl.TextColor3 = Color3.fromRGB(200, 180, 255)
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

TC(UserInputService.InputBegan, function(i, gp)
    if gp then return end
    if activeKeyBind then
        S.Keys[activeKeyBind.name] = i.KeyCode
        activeKeyBind.label.Text = tostring(i.KeyCode):gsub("Enum.KeyCode.", "")
        activeKeyBind = nil
        return
    end
    if i.KeyCode == S.Keys.TpGrab then
        local t = nil
        if S.grabTargetName ~= "" then t = findPlayer(S.grabTargetName) end
        if not t then
            if S.targetNames ~= "" then t = findPlayer(S.targetNames) end
        end
        if not t then t = findNearest(9999) end
        if t then doGrab(t) end
    elseif i.KeyCode == S.Keys.GrabSpam then
        S.GrabSpamNoTP = not S.GrabSpamNoTP
        Notif("Grab Spam", S.GrabSpamNoTP and "Enabled" or "Disabled", S.GrabSpamNoTP and "ok" or "warn")
    elseif i.KeyCode == S.Keys.KillAura then
        S.KillAura = not S.KillAura
        if S.KillAura then startAura() else stopAura() end
        SaveSetting("KillAura", S.KillAura)
    elseif i.KeyCode == S.Keys.Fly then
        S.Fly = not S.Fly
        if S.Fly then startFly() else stopFly() end
        SaveSetting("Fly", S.Fly)
    elseif i.KeyCode == S.Keys.Ghost then
        S.Ghost = not S.Ghost
        if S.Ghost then startGhost() else stopGhost() end
        SaveSetting("Ghost", S.Ghost)
    elseif i.KeyCode == S.Keys.TPWalk then
        S.TPWalk = not S.TPWalk
        SaveSetting("TPWalk", S.TPWalk)
    elseif i.KeyCode == S.Keys.Invis then
        S.Invisible = not S.Invisible
        SaveSetting("Invisible", S.Invisible)
    elseif i.KeyCode == S.Keys.Reset then
        pcall(function()
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end)
    end
end)

Sec(P1, "KILL AURA")
Tog(P1, "KillAura", function(v) S.KillAura = v; if v then startAura() else stopAura() end end, S.KillAura)
Sld(P1, "Aura Range", 5, 250, S.KillAuraRange, function(v) S.KillAuraRange = v end)
Sld(P1, "Attacks/Sec", 1, 10000, S.AttacksPerSecond, function(v) S.AttacksPerSecond = v end)
Tog(P1, "Bypass Range", function(v) S.BypassRange = v end, S.BypassRange)
Tog(P1, "Silent TP Hit", function(v) S.SilentTPHit = v end, false)

Sec(P1, "HITBOX")
Tog(P1, "Hitbox", function(v) S.Hitbox = v end, S.Hitbox)
Tog(P1, "Hitbox Vis", function(v) S.HitboxVis = v end, S.HitboxVis)
Sld(P1, "Hitbox Size", 1, 50, S.HitboxSize, function(v) S.HitboxSize = v end)

Sec(P1, "GRAB")
Tog(P1, "Grab Spam No TP", function(v) S.GrabSpamNoTP = v end, S.GrabSpamNoTP)
Txt(P1, "Grab Target", function(t) S.grabTargetName = t end)
Btn(P1, "TP + Grab Target", function()
    local t = nil
    if S.grabTargetName ~= "" then t = findPlayer(S.grabTargetName) end
    if not t then
        if S.targetNames ~= "" then t = findPlayer(S.targetNames) end
    end
    if not t then t = findNearest(9999) end
    if t then doGrab(t) end
end)

Sec(P1, "FARM AND SPAM")
Tog(P1, "Auto Farm", function(v) S.AutoFarm = v end, S.AutoFarm)
Tog(P1, "Rapid Hit", function(v) S.RapidHit = v; if v then startRapidHit() end end, S.RapidHit)
Tog(P1, "Punch Spam", function(v) S.PunchSpam = v; if v then startPunchSpam() end end, S.PunchSpam)
Tog(P1, "Jitter", function(v) S.FakeJitter = v; if v then startJitter() end end, S.FakeJitter)
Tog(P1, "Auto Stomp", function(v) S.AutoStomp = v end, S.AutoStomp)

Sec(P2, "TARGETING")
Txt(P2, "Target Players", function(t) S.targetNames = t; S.targetList = parseList(t) end)
Txt(P2, "Friend List", function(t) S.friendNames = t; S.friendList = parseList(t) end)

Sec(P2, "STRAFE")
Tog(P2, "Strafe", function(v) S.Strafe = v; S.strafeAngle = 0 end, S.Strafe)
Tog(P2, "Backstab", function(v) S.Backstab = v end, S.Backstab)
Txt(P2, "Strafe Target", function(t) S.strafeName = t end)
Sld(P2, "Radius", 2, 30, S.StrafeRadius, function(v) S.StrafeRadius = v end)
Sld(P2, "Speed", 1, 20, S.StrafeSpeed, function(v) S.StrafeSpeed = v end)
Sld(P2, "Offset", -15, 10, S.StrafeOffset, function(v) S.StrafeOffset = v end)

Sec(P2, "ORBIT")
Tog(P2, "Orbit", function(v) S.Orbit = v; S.orbitAngle = 0 end, S.Orbit)
Txt(P2, "Orbit Target", function(t) S.orbitName = t end)
Sld(P2, "Orb Radius", 2, 50, S.orbRadius, function(v) S.orbRadius = v end)
Sld(P2, "Orb Speed", 1, 1000, S.orbSpeed, function(v) S.orbSpeed = v end)
Sld(P2, "Orb Height", -10, 10, S.orbHeight, function(v) S.orbHeight = v end)

Sec(P2, "HEAD SIT")
Tog(P2, "Head Sit", function(v) S.HeadSit = v end, S.HeadSit)
Txt(P2, "Head Sit Target", function(t) S.headSitName = t end)

Sec(P3, "MOVEMENT")
Tog(P3, "TP Walk", function(v) S.TPWalk = v end, S.TPWalk)
Sld(P3, "TP Speed", 16, 200, S.tpSpeed, function(v) S.tpSpeed = v end)
Tog(P3, "Fly", function(v) if v then startFly() else stopFly() end end, S.Fly)
Sld(P3, "Fly Speed", 1, 300, S.flySpeed, function(v) S.flySpeed = v end)
Tog(P3, "Noclip", function(v) S.Noclip = v end, S.Noclip)
Tog(P3, "Inf Jump", function(v) S.InfJump = v end, S.InfJump)
Tog(P3, "Ctrl Click TP", function(v) S.CtrlClickTP = v end, false)
Sld(P3, "Walk Speed", 1, 500, 16, function(v) pcall(function() player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end) end)
Sld(P3, "Jump Power", 1, 500, 50, function(v) pcall(function() local h = player.Character:FindFirstChildOfClass("Humanoid"); h.UseJumpPower = true; h.JumpPower = v end) end)
Sld(P3, "Gravity", 1, 600, 196, function(v) workspace.Gravity = v end)
Tog(P3, "Death TP", function(v) S.DeathTP = v; if not v then S.deathCF = nil end end, S.DeathTP)

Sec(P3, "LAG AND SPIN")
Tog(P3, "Spin", function(v) S.Spin = v; if v then startSpin() else stopSpin() end end, S.Spin)
Sld(P3, "Spin Speed", 1, 500, S.spinSpeed, function(v) S.spinSpeed = v end)
Tog(P3, "Glitch", function(v) S.Glitch = v; if v then startGlitch() end end, S.Glitch)
Txt(P3, "Glitch Target", function(t) S.glitchName = t end)
Sld(P3, "Glitch Power", 1, 20, S.glitchInt, function(v) S.glitchInt = v end)

Sec(P4, "RP COLOR")
Tog(P4, "Rainbow Tag", function(v) S.RainbowTag = v; if v then startRP() else stopRP() end end, S.RainbowTag)
Sld(P4, "Rainbow Speed", 1, 100, S.RainbowSpeed, function(v) S.RainbowSpeed = v end)

local mc = Instance.new("Frame")
mc.Size = UDim2.new(1, 0, 0, 70)
mc.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
mc.BackgroundTransparency = 0.4
mc.BorderSizePixel = 0
mc.Parent = P4
Instance.new("UICorner", mc).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", mc).Color = Color3.fromRGB(50, 40, 60)
mc:FindFirstChildOfClass("UIStroke").Thickness = 1
mc:FindFirstChildOfClass("UIStroke").Transparency = 0.6

local mg = Instance.new("Frame", mc)
mg.Size = UDim2.new(1, -10, 0, 66)
mg.Position = UDim2.new(0, 5, 0, 2)
mg.BackgroundTransparency = 1

local mgl = Instance.new("UIGridLayout", mg)
mgl.CellSize = UDim2.new(0.23, -2, 0, 14)
mgl.CellPadding = UDim2.new(0, 2, 0, 2)

local mK = {"rainbow","neon","pastel","fire","ice","galaxy","toxic","blood"}
local mL = {"Rainbow","Neon","Pastel","Fire","Ice","Galaxy","Toxic","Blood"}

for i, k in ipairs(mK) do
    local b = Instance.new("TextButton", mg)
    b.Text = mL[i]
    b.Font = Enum.Font.GothamBold
    b.TextSize = 5
    b.BackgroundColor3 = k == S.rpMode and Color3.fromRGB(200, 180, 255) or Color3.fromRGB(30, 25, 40)
    b.TextColor3 = k == S.rpMode and Color3.fromRGB(0,0,0) or Color3.fromRGB(100, 90, 120)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    b.MouseButton1Click:Connect(function()
        S.rpMode = k
        for _, bt in ipairs(mg:GetChildren()) do
            if bt:IsA("TextButton") then
                bt.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
                bt.TextColor3 = Color3.fromRGB(100, 90, 120)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(200, 180, 255)
        b.TextColor3 = Color3.fromRGB(0,0,0)
        SaveSetting("rpMode", k)
    end)
end

Tog(P4, "Name Typer", function(v)
    S.NameTypewriter = v
    S.rpNameIdx = 1
    if not v then pcall(function() NameR:FireServer(player.DisplayName) end) end
end, S.NameTypewriter)

Tog(P4, "Bio Phrases", function(v)
    S.BioPhrases = v
    if v then startPhrases() end
end, S.BioPhrases)

Sld(P4, "Type Speed", 1, 250, S.bioTypeSpeed, function(v) S.bioTypeSpeed = v end)
Txt(P4, "Phrases", function(t)
    S.userPhrases = {}
    for w in t:gmatch("%S+") do insert(S.userPhrases, w) end
    if #S.userPhrases == 0 then S.userPhrases = {"LEGEND!"} end
end)

Sec(P4, "INVIS")
Tog(P4, "Invisible", function(v) S.Invisible = v end, S.Invisible)

Sec(P5, "BLOCK AND PARRY")
Tog(P5, "Auto Block", function(v) S.AutoBlock = v end, S.AutoBlock)
Tog(P5, "Auto Parry", function(v) S.AutoParry = v end, S.AutoParry)
Sld(P5, "Parry Range", 5, 20, S.parryRange, function(v) S.parryRange = v end)

Sec(P5, "ANTI RAGDOLL")
Tog(P5, "Anti Ragdoll", function(v) S.AntiRag = v; if v and player.Character then cleanRag(player.Character) end end, S.AntiRag)
Tog(P5, "Anti Rag Combo", function(v)
    S.AntiRagCombo = v
    if v then
        if player.Character then spawn(arcOnChar, player.Character) end
    else
        if arc.conn then arc.conn:Disconnect() end
        arcRemPlat()
    end
end, false)

Sec(P5, "PROTECTION")
Tog(P5, "Invincible", function(v) S.Invincible = v end, S.Invincible)
Tog(P5, "Anti Fling", function(v) S.AntiFling = v end, S.AntiFling)
Tog(P5, "Dodge Grab", function(v) S.DodgeGrab = v end, S.DodgeGrab)
Tog(P5, "Safe Spot", function(v) S.SafeSpot = v; if v then goSafe() else endSafe() end end, S.SafeSpot)
Tog(P5, "Anti AFK", function(v) S.AntiAFK = v end, S.AntiAFK)

Sec(P6, "GHOST")
Tog(P6, "Ghost Mode", function(v) if v then startGhost() else stopGhost() end end, S.Ghost)
Btn(P6, "Headless", function() headless() end)

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

Sec(P8, "SERVER")
Btn(P8, "Rejoin", function()
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end)
Btn(P8, "Server Hop", function()
    pcall(function()
        local srv = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if srv and srv.data then
            for _, s in ipairs(srv.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, player)
                    break
                end
            end
        end
    end)
end)
Btn(P8, "Unload", function()
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    stopAura(); stopFly(); stopSpin(); stopGhost(true); endSafe(); stopEsp()
    DoSave()
    wait(0.3)
    pcall(function() SG:Destroy() end)
end)
Btn(P8, "Force Reset", function()
    pcall(function()
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end)
end)

Sec(P8, "AUTO RESPAWN")
Tog(P8, "Auto Respawn", function(v) S.AutoRespawn = v end, S.AutoRespawn)

Sec(P9, "ESP")
Tog(P9, "ESP", function(v) S.EspBox = v; if v then startEsp() else stopEsp() end end, S.EspBox)
Btn(P9, "Clear ESP", function()
    for p in pairs(espObjects) do destroyEsp(p) end
end)

Sec(P10, "LEGEND HUB")
local wc = Instance.new("Frame")
wc.Size = UDim2.new(1, 0, 0, 80)
wc.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
wc.BackgroundTransparency = 0.4
wc.BorderSizePixel = 0
wc.Parent = P10
Instance.new("UICorner", wc).CornerRadius = UDim.new(0, 5)

local wnL = Instance.new("TextLabel", wc)
wnL.Size = UDim2.new(1, -20, 0, 30)
wnL.Position = UDim2.new(0, 10, 0, 6)
wnL.BackgroundTransparency = 1
wnL.Text = "LEGEND HUB"
wnL.TextColor3 = Color3.fromRGB(235, 230, 245)
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
infoL.Text = "Welcome "..player.DisplayName
infoL.TextColor3 = Color3.fromRGB(160, 150, 180)
infoL.Font = Enum.Font.Gotham
infoL.TextSize = 9
infoL.TextXAlignment = Enum.TextXAlignment.Left

local infoL2 = Instance.new("TextLabel", wc)
infoL2.Size = UDim2.new(1, -20, 0, 12)
infoL2.Position = UDim2.new(0, 10, 0, 54)
infoL2.BackgroundTransparency = 1
infoL2.Text = "Q=TP+Grab | H=Grab Spam | Data auto-saves"
infoL2.TextColor3 = Color3.fromRGB(200, 180, 255)
infoL2.Font = Enum.Font.Gotham
infoL2.TextSize = 7
infoL2.TextXAlignment = Enum.TextXAlignment.Left

Sec(P10, "MADE BY LEGEND")
local crL = Instance.new("TextLabel")
crL.Size = UDim2.new(1, 0, 0, 18)
crL.BackgroundTransparency = 1
crL.Text = "Made by LEGEND"
crL.TextColor3 = Color3.fromRGB(230, 210, 255)
crL.Font = Enum.Font.GothamBold
crL.TextSize = 8
crL.Parent = P10

Sec(P11, "ADV COMBAT")
Tog(P11, "Auto Combo", function(v) S.AutoCombo = v end, false)
Tog(P11, "Speed Boost", function(v)
    S.SpeedBoost = v
    if v then
        pcall(function() player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed * 1.5 end)
    else
        pcall(function() player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end)
    end
end, false)

Sec(P12, "DATA")
local dataInfo = Instance.new("TextLabel")
dataInfo.Size = UDim2.new(1, 0, 0, 24)
dataInfo.BackgroundTransparency = 1
dataInfo.Text = "Data saves to: lh_data.json"
dataInfo.TextColor3 = Color3.fromRGB(160, 150, 180)
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
            local ok, d = pcall(function() return Http:JSONDecode(readfile("lh_data.json")) end)
            if ok and type(d) == "table" then
                for k, v in pairs(d) do SAVE[k] = v end
                loadAllSettings()
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

Sec(P13, "THEMES")

local function applyLegendTheme()
    Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Main.BackgroundTransparency = 0.85
    Glow.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    Glow.BackgroundTransparency = 0.7
    BgText.Text = "LEGEND"
    BgText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BgText.TextTransparency = 0.92
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleBar.BackgroundTransparency = 0.5
    CenterTitle.Text = "LEGEND HUB"
    SubTitle.Text = "Made by LEGEND"
    SG.Name = "LEGEND_HUB"
    S.currentTheme = "legend"
    SaveSetting("currentTheme", "legend")
    Notif("Theme", "LEGEND Theme", "ok")
end

local function applyZicoTheme()
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 0.7
    Glow.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    Glow.BackgroundTransparency = 0.7
    BgText.Text = "ZICO"
    BgText.TextColor3 = Color3.fromRGB(100, 100, 150)
    BgText.TextTransparency = 0.9
    TitleBar.BackgroundColor3 = Color3.fromRGB(200, 220, 240)
    TitleBar.BackgroundTransparency = 0.4
    CenterTitle.Text = "ZICO HUB"
    SubTitle.Text = "Made by ZICO"
    SG.Name = "ZICO_HUB"
    S.currentTheme = "zico"
    SaveSetting("currentTheme", "zico")
    Notif("Theme", "ZICO Theme", "ok")
end

local legendBtn = Instance.new("TextButton")
legendBtn.Size = UDim2.new(1, 0, 0, 32)
legendBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
legendBtn.BorderSizePixel = 0
legendBtn.Text = "LEGEND"
legendBtn.TextColor3 = Color3.fromRGB(200, 180, 255)
legendBtn.Font = Enum.Font.GothamBold
legendBtn.TextSize = 10
legendBtn.Parent = P13
local ltCorner = Instance.new("UICorner", legendBtn)
ltCorner.CornerRadius = UDim.new(0, 5)
legendBtn.MouseButton1Click:Connect(applyLegendTheme)

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
local ztCorner = Instance.new("UICorner", zicoBtn)
ztCorner.CornerRadius = UDim.new(0, 5)
zicoBtn.MouseButton1Click:Connect(applyZicoTheme)

if S.currentTheme == "zico" then
    applyZicoTheme()
else
    applyLegendTheme()
end

Sec(P14, "SHORTCUT KEYS")
KeyBind(P14, "KillAura", S.Keys.KillAura, "KillAura")
KeyBind(P14, "Fly", S.Keys.Fly, "Fly")
KeyBind(P14, "Ghost", S.Keys.Ghost, "Ghost")
KeyBind(P14, "TP+Grab", S.Keys.TpGrab, "TpGrab")
KeyBind(P14, "Grab Spam", S.Keys.GrabSpam, "GrabSpam")
KeyBind(P14, "TP Walk", S.Keys.TPWalk, "TPWalk")
KeyBind(P14, "Invis", S.Keys.Invis, "Invis")
KeyBind(P14, "Reset", S.Keys.Reset, "Reset")

loadAllSettings()

if S.KillAura then startAura() end
if S.EspBox then startEsp() end
if S.Fly then startFly() end
if S.Ghost then startGhost() end
if S.Spin then startSpin() end
if S.Glitch then startGlitch() end
if S.RainbowTag then startRP() end
if S.BioPhrases then startPhrases() end
if S.RapidHit then startRapidHit() end
if S.PunchSpam then startPunchSpam() end
if S.FakeJitter then startJitter() end
if S.SafeSpot then goSafe() end

if player.Character and S.AntiRag then
    spawn(cleanRag, player.Character)
end

Notif("LEGEND HUB", "Loaded! Made by LEGEND", "ok")
