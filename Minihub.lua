local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

local isActive = true
local bioLines = {}
local blinkLines = {}
local colorLoopRunning = true
local bioLoopRunning = true
local nameLoopRunning = true
local blinkLoopRunning = true
local colorThread = nil
local bioThread = nil
local nameThread = nil
local blinkThread = nil
local colorPreset = 1

local DataFile = "MiniHub.json"
local SAVE = {}
local function LoadData()
    pcall(function()
        if writefile and isfile(DataFile) then
            local data = HttpService:JSONDecode(readfile(DataFile))
            if type(data) == "table" then
                for k, v in pairs(data) do SAVE[k] = v end
            end
        end
    end)
end
local function SaveData()
    pcall(function()
        if writefile then
            writefile(DataFile, HttpService:JSONEncode(SAVE))
        end
    end)
end
local function Get(k, d) return SAVE[k] ~= nil and SAVE[k] or d end
local function Set(k, v) SAVE[k] = v; SaveData() end
LoadData()

local colorPalettes = {
    {name="Rainbow", colors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,127,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,0,255),Color3.fromRGB(75,0,130),Color3.fromRGB(148,0,211)}},
    {name="Neon", colors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,50,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,100,255),Color3.fromRGB(255,0,255)}},
    {name="B&W Ultra", colors={Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),Color3.fromRGB(255,255,255)}},
    {name="Pastel", colors={Color3.fromRGB(255,200,200),Color3.fromRGB(255,220,180),Color3.fromRGB(255,255,200),Color3.fromRGB(200,255,200),Color3.fromRGB(200,220,255),Color3.fromRGB(220,200,255),Color3.fromRGB(255,200,240)}},
    {name="Red to White", colors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,50,50),Color3.fromRGB(255,100,100),Color3.fromRGB(255,150,150),Color3.fromRGB(255,200,200),Color3.fromRGB(255,220,220),Color3.fromRGB(255,240,240),Color3.fromRGB(255,255,255)}},
    {name="Sky", colors={Color3.fromRGB(135,206,235),Color3.fromRGB(0,191,255),Color3.fromRGB(135,206,250),Color3.fromRGB(70,130,180),Color3.fromRGB(176,224,230),Color3.fromRGB(0,255,255),Color3.fromRGB(127,255,212)}},
    {name="Dark", colors={Color3.fromRGB(25,25,25),Color3.fromRGB(40,40,40),Color3.fromRGB(60,60,70),Color3.fromRGB(80,80,90),Color3.fromRGB(30,30,40),Color3.fromRGB(50,50,60),Color3.fromRGB(20,20,30)}},
    {name="Light", colors={Color3.fromRGB(240,240,240),Color3.fromRGB(245,245,245),Color3.fromRGB(250,250,250),Color3.fromRGB(252,252,252),Color3.fromRGB(254,254,254),Color3.fromRGB(255,255,255)}},
    {name="Blood", colors={Color3.fromRGB(40,0,0),Color3.fromRGB(60,0,0),Color3.fromRGB(80,0,0),Color3.fromRGB(100,0,0),Color3.fromRGB(120,0,0),Color3.fromRGB(160,0,0),Color3.fromRGB(200,0,0)}},
    {name="Fire", colors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,50,0),Color3.fromRGB(255,100,0),Color3.fromRGB(255,150,0),Color3.fromRGB(255,200,0),Color3.fromRGB(255,100,50),Color3.fromRGB(200,50,0)}}
}

local bioRemote = nil
local colorRemote = nil
local bioColorRemote = nil
local nameRemote = nil
local HitRF = nil
local PunchRF = nil
local BlockRF = nil
local GrabRF = nil

local function findRemotes()
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local name = child.Name
            if name == "UpdateBio" or name == "SetBio" then
                bioRemote = child
            elseif name == "UpdateBioColor" or name == "SetBioColor" then
                bioColorRemote = child
            elseif name == "UpdateRPColor" or name == "SetNameColor" then
                colorRemote = child
            elseif name == "UpdateRPName" or name == "SetName" then
                nameRemote = child
            elseif name:lower() == "hit" or name:lower() == "punch" then
                HitRF = child
            elseif name:lower() == "punchdo" then
                PunchRF = child
            elseif name:lower() == "block" then
                BlockRF = child
            elseif name:lower() == "grab" then
                GrabRF = child
            end
        end
    end
end
findRemotes()

local function applyColor(color)
    if not isActive then return end
    if colorRemote then pcall(function() colorRemote:FireServer(color) end) end
    if bioColorRemote then pcall(function() bioColorRemote:FireServer(color) end) end
end

local function applyBio(text)
    if not isActive or not bioRemote then return end
    pcall(function() bioRemote:FireServer(text) end)
end

local function applyName(text)
    if not isActive or not nameRemote then return end
    pcall(function() nameRemote:FireServer(text) end)
end

local function parsePhrases(input)
    local result = {}
    if input == "" then return result end
    for phrase in input:gmatch("[^,]+") do
        local trimmed = phrase:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            table.insert(result, trimmed)
        end
    end
    return result
end

local function updateBioList()
    bioLines = {}
    local phrases = Get("BioPhrases", "")
    if phrases ~= "" then
        bioLines = parsePhrases(phrases)
    end
end

local function updateBlinkList()
    blinkLines = {}
    local phrases = Get("BlinkPhrases", "")
    if phrases ~= "" then
        blinkLines = parsePhrases(phrases)
    end
end

local function startBioType()
    bioLoopRunning = true
    while bioLoopRunning do
        if isActive then
            updateBioList()
            if #bioLines > 0 then
                for _, phrase in ipairs(bioLines) do
                    if not bioLoopRunning or not isActive then break end
                    local speed = Get("BioSpeed", 15)
                    local delay = 1 / speed
                    for i = 1, #phrase do
                        if not bioLoopRunning or not isActive then break end
                        applyBio(phrase:sub(1, i))
                        task.wait(delay)
                    end
                    applyBio(phrase)
                    task.wait(0.05)
                end
            end
        end
        task.wait(0.01)
    end
end

local function startBioBlink()
    blinkLoopRunning = true
    local visible = true
    while blinkLoopRunning do
        if isActive then
            updateBlinkList()
            if #blinkLines > 0 then
                local speed = Get("BlinkSpeed", 5) / 10
                for _, phrase in ipairs(blinkLines) do
                    if not blinkLoopRunning or not isActive then break end
                    if visible then
                        applyBio(phrase)
                    else
                        applyBio("")
                    end
                    visible = not visible
                    task.wait(speed)
                end
            end
        end
        task.wait(0.01)
    end
end

local function startNameType()
    nameLoopRunning = true
    while nameLoopRunning do
        if isActive and nameRemote then
            local targetName = player.DisplayName or player.Name
            local speed = Get("NameSpeed", 5) / 10
            for i = 1, #targetName do
                if not nameLoopRunning or not isActive then break end
                applyName(targetName:sub(1, i))
                task.wait(speed)
            end
            applyName(targetName)
            task.wait(0.05)
        end
        task.wait(0.01)
    end
end

local function startColorCycle()
    colorLoopRunning = true
    local index = 1
    while colorLoopRunning do
        if isActive then
            local preset = colorPalettes[colorPreset] or colorPalettes[1]
            if preset and #preset.colors > 0 then
                index = index % #preset.colors + 1
                applyColor(preset.colors[index])
            end
        end
        local speed = Get("ColorSpeed", 20)
        task.wait(1 / speed)
    end
end

-- KILL AURA LOGIC
local kaOn = false
local kaConn = nil
local kaLast = 0
local hitCounter = 0

local function parseList(str)
    local t = {}
    if str == "" then return t end
    for w in str:gmatch("%S+") do table.insert(t, w:lower()) end
    return t
end

local function isTarget(n, targetList)
    if #targetList == 0 then return true end
    local ln = n:lower()
    for _, v in ipairs(targetList) do
        if ln:find(v, 1, true) then return true end
    end
    return false
end

local function isSafe(n, safeList)
    local ln = n:lower()
    for _, v in ipairs(safeList) do
        if ln:find(v, 1, true) then return true end
    end
    return false
end

local function HitRemoteInvoke(hum, px, py, pz)
    task.spawn(function()
        pcall(function()
            if HitRF then
                if HitRF:IsA("RemoteFunction") then
                    HitRF:InvokeServer(unpack({hum, vector.create(px, py, pz)}))
                elseif HitRF:IsA("RemoteEvent") then
                    HitRF:FireServer(unpack({hum, vector.create(px, py, pz)}))
                end
            end
        end)
    end)
end

local function startKA()
    if kaConn then kaConn:Disconnect() end
    kaConn = RunService.Heartbeat:Connect(function()
        if not Get("KillAura", false) then return end
        local mc = player.Character
        local myHRP = mc and mc:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        
        local now = tick()
        local aps = Get("KAAttacks", 15000)
        local cd = 1 / aps
        if now - kaLast < cd then return end
        
        local range = Get("KARange", 50)
        local targetsStr = Get("KATargets", "")
        local safeStr = Get("KASafe", "")
        local targetList = parseList(targetsStr)
        local safeList = parseList(safeStr)
        
        local px, py, pz = myHRP.Position.X, myHRP.Position.Y, myHRP.Position.Z
        local hitList = {}
        
        for _, p in Players:GetPlayers() do
            if p == player then continue end
            if isSafe(p.Name, safeList) or isSafe(p.DisplayName, safeList) then continue end
            if not isTarget(p.Name, targetList) and not isTarget(p.DisplayName, targetList) then continue end
            
            local c = p.Character
            if not c then continue end
            local hu = c:FindFirstChild("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hu and hrp and hu.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d <= range then
                    table.insert(hitList, {hu = hu, dist = d})
                end
            end
        end
        
        if #hitList > 0 then
            table.sort(hitList, function(a, b) return a.dist < b.dist end)
            for _, h in ipairs(hitList) do
                HitRemoteInvoke(h.hu, px, py, pz)
            end
            kaLast = now
            hitCounter = hitCounter + 1
        end
    end)
end

local function stopKA()
    if kaConn then kaConn:Disconnect(); kaConn = nil end
end

-- SPAM GRAB LOGIC
local grabConn = nil

local function startGrab()
    if grabConn then grabConn:Disconnect() end
    grabConn = RunService.Heartbeat:Connect(function()
        if not Get("SpamGrab", false) then return end
        if not GrabRF then return end
        local targetsStr = Get("KATargets", "")
        local safeStr = Get("KASafe", "")
        local targetList = parseList(targetsStr)
        local safeList = parseList(safeStr)
        
        for _, p in Players:GetPlayers() do
            if p == player then continue end
            if isSafe(p.Name, safeList) or isSafe(p.DisplayName, safeList) then continue end
            if not isTarget(p.Name, targetList) and not isTarget(p.DisplayName, targetList) then continue end
            if p.Character then
                pcall(function()
                    if GrabRF:IsA("RemoteFunction") then
                        GrabRF:InvokeServer(p)
                    elseif GrabRF:IsA("RemoteEvent") then
                        GrabRF:FireServer(p)
                    end
                end)
                break
            end
        end
        task.wait(0.001)
    end)
end

local function stopGrab()
    if grabConn then grabConn:Disconnect(); grabConn = nil end
end

-- HITBOX LOGIC
local hitboxConn = nil

local function startHitbox()
    if hitboxConn then hitboxConn:Disconnect() end
    hitboxConn = RunService.Heartbeat:Connect(function()
        if not Get("Hitbox", false) then return end
        local mc = player.Character
        if not mc then return end
        local size = Get("HitboxSize", 10)
        for _, v in mc:GetDescendants() do
            if v:IsA("BasePart") then
                pcall(function() v.Size = Vector3.new(size, size, size) end)
            end
        end
    end)
end

local function stopHitbox()
    if hitboxConn then hitboxConn:Disconnect(); hitboxConn = nil end
end

local function startAll()
    if colorThread then colorLoopRunning = false end
    if bioThread then bioLoopRunning = false end
    if nameThread then nameLoopRunning = false end
    if blinkThread then blinkLoopRunning = false end
    task.wait(0.05)
    
    if Get("RainbowSys", false) then
        colorLoopRunning = true
        colorThread = coroutine.create(startColorCycle)
        coroutine.resume(colorThread)
    end
    
    if Get("BioType", false) then
        bioLoopRunning = true
        bioThread = coroutine.create(startBioType)
        coroutine.resume(bioThread)
    end
    
    if Get("BioBlink", false) then
        blinkLoopRunning = true
        blinkThread = coroutine.create(startBioBlink)
        coroutine.resume(blinkThread)
    end
    
    if Get("NameType", false) then
        nameLoopRunning = true
        nameThread = coroutine.create(startNameType)
        coroutine.resume(nameThread)
    end
    
    if Get("KillAura", false) then
        startKA()
    else
        stopKA()
    end
    
    if Get("SpamGrab", false) then
        startGrab()
    else
        stopGrab()
    end
    
    if Get("Hitbox", false) then
        startHitbox()
    else
        stopHitbox()
    end
end

local function stopAll()
    colorLoopRunning = false
    bioLoopRunning = false
    nameLoopRunning = false
    blinkLoopRunning = false
    stopKA()
    stopGrab()
    stopHitbox()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiniHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local glowBorder = Instance.new("Frame")
glowBorder.Size = UDim2.new(1, 6, 1, 6)
glowBorder.Position = UDim2.new(0, -3, 0, -3)
glowBorder.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
glowBorder.BackgroundTransparency = 0.6
glowBorder.BorderSizePixel = 0
glowBorder.ZIndex = 0
glowBorder.Parent = mainFrame
Instance.new("UICorner", glowBorder).CornerRadius = UDim.new(0, 14)

coroutine.wrap(function()
    local colors = {Color3.fromRGB(200, 200, 255), Color3.fromRGB(255, 200, 255), Color3.fromRGB(200, 255, 255)}
    local idx = 1
    while glowBorder and glowBorder.Parent do
        glowBorder.BackgroundColor3 = colors[idx]
        idx = idx % #colors + 1
        task.wait(0.15)
    end
end)()

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12, 0, 0)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.Position = UDim2.new(0, 8, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ MINI HUB"
titleText.TextColor3 = Color3.fromRGB(0, 0, 0)
titleText.TextSize = 12
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -54, 0.5, -12)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.TextSize = 12
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 11
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 160, 0, 32)
        minimizeBtn.Text = "+"
        for _, child in pairs(mainFrame:GetChildren()) do
            if child ~= titleBar and child ~= glowBorder then
                child.Visible = false
            end
        end
    else
        mainFrame.Size = UDim2.new(0, 280, 0, 350)
        minimizeBtn.Text = "−"
        for _, child in pairs(mainFrame:GetChildren()) do
            if child ~= titleBar and child ~= glowBorder then
                child.Visible = true
            end
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local tabs = {"Home", "Combat", "Visual", "Defense", "Ghost"}
local tabButtons = {}
local tabPanels = {}

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, 65, 1, -38)
tabBar.Position = UDim2.new(0, 0, 0, 36)
tabBar.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 26)
    btn.Position = UDim2.new(0, 2, 0, (i - 1) * 28 + 4)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(180, 180, 220) or Color3.fromRGB(240, 240, 250)
    btn.BackgroundTransparency = (i == 1) and 0.2 or 0.5
    btn.Text = name
    btn.TextColor3 = (i == 1) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(100, 100, 120)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    tabButtons[i] = btn
    
    local panel = Instance.new("ScrollingFrame")
    panel.Size = UDim2.new(1, -70, 1, -38)
    panel.Position = UDim2.new(0, 68, 0, 36)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ScrollBarThickness = 2
    panel.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 220)
    panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.Visible = (i == 1)
    panel.Parent = mainFrame
    Instance.new("UIListLayout", panel).Padding = UDim.new(0, 3)
    Instance.new("UIPadding", panel).PaddingLeft = UDim.new(0, 3)
    Instance.new("UIPadding", panel).PaddingRight = UDim.new(0, 3)
    Instance.new("UIPadding", panel).PaddingTop = UDim.new(0, 3)
    tabPanels[i] = panel
    
    btn.MouseButton1Click:Connect(function()
        for j, b in ipairs(tabButtons) do
            b.BackgroundColor3 = (j == i) and Color3.fromRGB(180, 180, 220) or Color3.fromRGB(240, 240, 250)
            b.BackgroundTransparency = (j == i) and 0.2 or 0.5
            b.TextColor3 = (j == i) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(100, 100, 120)
            tabPanels[j].Visible = (j == i)
        end
        panel.CanvasPosition = Vector2.new(0, 0)
    end)
end

local function createSection(parent, title)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 15)
    f.BackgroundColor3 = Color3.fromRGB(220, 220, 240)
    f.BackgroundTransparency = 0.3
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 1, 0)
    l.Position = UDim2.new(0, 5, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = title:upper()
    l.TextColor3 = Color3.fromRGB(80, 80, 150)
    l.TextSize = 6
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function createToggle(parent, label, key, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local state = Get(key, default)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.6, 0, 1, 0)
    lb.Position = UDim2.new(0, 6, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = Color3.fromRGB(0, 0, 0)
    lb.TextSize = 8
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 16)
    btn.Position = UDim2.new(1, -42, 0.5, -8)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 200, 200)
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 7
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        Set(key, state)
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(200, 200, 200)
        btn.Text = state and "ON" or "OFF"
        if key == "RainbowSys" or key == "BioType" or key == "BioBlink" or key == "NameType" or key == "KillAura" or key == "SpamGrab" or key == "Hitbox" then
            startAll()
        end
    end)
    return frame
end

local function createSlider(parent, label, key, min, max, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local val = Get(key, default)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.5, 0, 0, 12)
    lb.Position = UDim2.new(0, 6, 0, 1)
    lb.BackgroundTransparency = 1
    lb.Text = label .. ": " .. tostring(val)
    lb.TextColor3 = Color3.fromRGB(80, 80, 100)
    lb.TextSize = 7
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = frame
    
    local tk = Instance.new("Frame")
    tk.Size = UDim2.new(0.7, 0, 0, 3)
    tk.Position = UDim2.new(0.1, 0, 0.7, 0)
    tk.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    tk.BorderSizePixel = 0
    tk.Parent = frame
    Instance.new("UICorner", tk).CornerRadius = UDim.new(0, 2)
    
    local pct = (val - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    fill.BorderSizePixel = 0
    fill.Parent = tk
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(pct, -5, 0.5, -5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = tk
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 5)
    
    local dragging = false
    local function update(pos)
        local aw = tk.AbsoluteSize.X
        if aw <= 0 then return end
        local p2 = math.clamp((pos.X - tk.AbsolutePosition.X) / aw, 0, 1)
        local v = math.floor(min + p2 * (max - min))
        fill.Size = UDim2.new(p2, 0, 1, 0)
        knob.Position = UDim2.new(p2, -5, 0.5, -5)
        lb.Text = label .. ": " .. tostring(v)
        Set(key, v)
    end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return frame
end

local function createTextBox(parent, label, key, placeholder)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.3, 0, 1, 0)
    lb.Position = UDim2.new(0, 6, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = Color3.fromRGB(80, 80, 100)
    lb.TextSize = 7
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.65, 0, 0.8, 0)
    box.Position = UDim2.new(0.33, 0, 0.1, 0)
    box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = Get(key, "")
    box.PlaceholderText = placeholder
    box.TextColor3 = Color3.fromRGB(0, 0, 0)
    box.TextSize = 8
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function()
        Set(key, box.Text)
        if key == "BioPhrases" then updateBioList() end
        if key == "BlinkPhrases" then updateBlinkList() end
        startAll()
    end)
    return frame
end

local function createButton(parent, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(180, 180, 220)
    btn.BackgroundTransparency = 0.3
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local homePanel = tabPanels[1]
local homeBg = Instance.new("Frame")
homeBg.Size = UDim2.new(1, 0, 0, 90)
homeBg.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
homeBg.BackgroundTransparency = 0.5
homeBg.BorderSizePixel = 0
homeBg.Parent = homePanel
Instance.new("UICorner", homeBg).CornerRadius = UDim.new(0, 8)

local homeTitle = Instance.new("TextLabel")
homeTitle.Size = UDim2.new(1, 0, 0, 30)
homeTitle.Position = UDim2.new(0, 0, 0, 8)
homeTitle.BackgroundTransparency = 1
homeTitle.Text = "✨ MINI HUB ✨"
homeTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
homeTitle.TextSize = 24
homeTitle.Font = Enum.Font.GothamBlack
homeTitle.TextScaled = true
homeTitle.Parent = homeBg

local homeSub = Instance.new("TextLabel")
homeSub.Size = UDim2.new(1, 0, 0, 16)
homeSub.Position = UDim2.new(0, 0, 0, 42)
homeSub.BackgroundTransparency = 1
homeSub.Text = "~ MADE BY LEGEND ~"
homeSub.TextColor3 = Color3.fromRGB(0, 0, 0)
homeSub.TextSize = 10
homeSub.Font = Enum.Font.GothamBold
homeSub.Parent = homeBg

local homeKey = Instance.new("TextLabel")
homeKey.Size = UDim2.new(1, 0, 0, 14)
homeKey.Position = UDim2.new(0, 0, 0, 62)
homeKey.BackgroundTransparency = 1
homeKey.Text = "🔑 L = Hide/Show GUI"
homeKey.TextColor3 = Color3.fromRGB(100, 100, 200)
homeKey.TextSize = 7
homeKey.Font = Enum.Font.Gotham
homeKey.Parent = homeBg

local combatPanel = tabPanels[2]
createSection(combatPanel, "KILL AURA")
createToggle(combatPanel, "Kill Aura", "KillAura", false)
createSlider(combatPanel, "Range", "KARange", 1, 50, 50)
createSlider(combatPanel, "Attacks/Sec", "KAAttacks", 1, 15000, 15000)
createTextBox(combatPanel, "Target List", "KATargets", "space separated")
createTextBox(combatPanel, "Safe List", "KASafe", "space separated")

createSection(combatPanel, "SPAM GRAB")
createToggle(combatPanel, "Spam Grab", "SpamGrab", false)

createSection(combatPanel, "HITBOX")
createToggle(combatPanel, "Hitbox", "Hitbox", false)
createSlider(combatPanel, "Hitbox Size", "HitboxSize", 1, 50, 10)

local visualPanel = tabPanels[3]
createSection(visualPanel, "RAINBOW SYSTEM")
createToggle(visualPanel, "Rainbow System", "RainbowSys", false)
createSlider(visualPanel, "Color Speed", "ColorSpeed", 1, 500, 20)

createSection(visualPanel, "COLOR PRESETS")
local colorFrame = Instance.new("Frame")
colorFrame.Size = UDim2.new(1, 0, 0, 60)
colorFrame.BackgroundTransparency = 1
colorFrame.Parent = visualPanel

for i = 1, #colorPalettes do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.23, 0, 0, 16)
    btn.Position = UDim2.new((i - 1) % 3 * 0.26, 0, math.floor((i - 1) / 3) * 20, 0)
    btn.BackgroundColor3 = colorPalettes[i].colors[1]
    btn.Text = colorPalettes[i].name
    btn.TextColor3 = (i == 1 or i == 4 or i == 7 or i == 9) and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
    btn.TextSize = 5
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = colorFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    btn.MouseButton1Click:Connect(function()
        colorPreset = i
        Set("ColorPreset", i)
    end)
end

createSection(visualPanel, "NAME TYPEWRITER")
createToggle(visualPanel, "Name Typewriter", "NameType", false)
createSlider(visualPanel, "Name Speed", "NameSpeed", 1, 10, 5)

createSection(visualPanel, "BIO TYPEWRITER")
createToggle(visualPanel, "Bio Typewriter", "BioType", false)
createSlider(visualPanel, "Bio Speed", "BioSpeed", 1, 500, 15)
createTextBox(visualPanel, "Bio Phrases", "BioPhrases", "HELLO, WORLD")

createSection(visualPanel, "BIO BLINKER")
createToggle(visualPanel, "Bio Blinker", "BioBlink", false)
createSlider(visualPanel, "Blink Speed", "BlinkSpeed", 1, 10, 5)
createTextBox(visualPanel, "Blink Phrases", "BlinkPhrases", "FLICKER, BLINK")

local defensePanel = tabPanels[4]
createSection(defensePanel, "DEFENSE")
createToggle(defensePanel, "Anti Ragdoll", "AntiRag", true)
createToggle(defensePanel, "Anti Fling", "AntiFling", false)
createToggle(defensePanel, "Safe Spot", "SafeSpot", false)
createToggle(defensePanel, "Anti AFK", "AntiAFK", true)

local ghostPanel = tabPanels[5]
createSection(ghostPanel, "GHOST MODE")
createToggle(ghostPanel, "Ghost Mode", "GhostMode", false)

local headlessBtn = createButton(ghostPanel, "Headless", function()
    pcall(function()
        local args = {{["Property"] = "Head", ["AssetId"] = 15093053680}}
        local remote = ReplicatedStorage:FindFirstChild("CatalogOnApplyToRealHumanoid", true)
        if remote then
            remote:FireServer(unpack(args))
        else
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then
                    if v.Name:lower():find("catalog") or v.Name:lower():find("apply") or v.Name:lower():find("humanoid") then
                        pcall(function() v:FireServer(unpack(args)) end)
                        break
                    end
                end
            end
        end
    end)
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    pcall(function()
        local args = {{["Property"] = "Head", ["AssetId"] = 15093053680}}
        local remote = ReplicatedStorage:FindFirstChild("CatalogOnApplyToRealHumanoid", true)
        if remote then
            remote:FireServer(unpack(args))
        end
    end)
end)

local safeOrig = nil
local safePos = nil
RunService.Heartbeat:Connect(function()
    if Get("SafeSpot", false) then
        local ch = player.Character
        if ch then
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not safePos then
                    safePos = hrp.Position
                    safeOrig = hrp.CFrame
                end
                hrp.CFrame = CFrame.new(safePos.X, 150, safePos.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    else
        if safePos and safeOrig then
            local ch = player.Character
            if ch then
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = safeOrig
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
            safePos = nil
            safeOrig = nil
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Get("AntiRag", true) then
        local ch = player.Character
        if ch then
            local hu = ch:FindFirstChildOfClass("Humanoid")
            if hu then
                for _, st in ipairs({Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding}) do
                    pcall(function() hu:SetStateEnabled(st, false) end)
                end
                hu.PlatformStand = false
            end
            for _, o in pairs(ch:GetDescendants()) do
                if (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
                    o:Destroy()
                elseif o:IsA("Motor6D") then
                    o.Enabled = true
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Get("AntiFling", false) then
        local ch = player.Character
        if ch then
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                if hrp.AssemblyAngularVelocity.Magnitude > 15 then
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                if hrp.AssemblyLinearVelocity.Magnitude > 150 then
                    hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * 0.75
                end
            end
        end
    end
end)

player.Idled:Connect(function()
    if Get("AntiAFK", true) then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

local ghostConn = nil
local function startGhost()
    if ghostConn then ghostConn:Disconnect() end
    ghostConn = RunService.Heartbeat:Connect(function()
        if not Get("GhostMode", false) then return end
        local ch = player.Character
        if not ch then return end
        for _, v in pairs(ch:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 1
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            end
        end
    end)
end

local function stopGhost()
    if ghostConn then ghostConn:Disconnect(); ghostConn = nil end
    local ch = player.Character
    if ch then
        for _, v in pairs(ch:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
                if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 0
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if Get("GhostMode", false) then
            startGhost()
        else
            stopGhost()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.L then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

updateBioList()
updateBlinkList()
startAll()

print("⚡ MINI HUB LOADED")
print("🔑 L = Hide/Show GUI")
print("👑 LEGEND ON TOP 👑")
print("❤️❤️❤️❤️❤️❤️❤️❤️❤️")
