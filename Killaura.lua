local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local insert = table.insert

local S = {
    KillAura = false,
    KillAuraRange = 50,
    AttacksPerSecond = 10000,
    targetList = {},
    friendList = {},
}

local contentVisible = false
local guiClosed = false

local function parseList(str)
    local t = {}
    if str == "" then return t end
    for w in str:gmatch("%S+") do insert(t, w:lower()) end
    return t
end

local function isTarget(n)
    if #S.targetList == 0 then return true end
    local ln = n:lower()
    for i = 1, #S.targetList do
        if ln:find(S.targetList[i], 1, true) then return true end
    end
    return false
end

local function isFriend(n)
    local ln = n:lower()
    for i = 1, #S.friendList do
        if ln:find(S.friendList[i], 1, true) then return true end
    end
    return false
end

local HitRF = nil

local function findHitRemote()
    local combatService = RS:FindFirstChild("Packages")
    if combatService then
        combatService = combatService:FindFirstChild("Knit")
        if combatService then
            combatService = combatService:FindFirstChild("Services")
            if combatService then
                combatService = combatService:FindFirstChild("CombatService")
                if combatService then
                    local rf = combatService:FindFirstChild("RF")
                    if rf then
                        HitRF = rf:FindFirstChild("Hit")
                    end
                end
            end
        end
    end
end

findHitRemote()

local function HitRemoteInvoke(hum, px, py, pz)
    task.spawn(function()
        pcall(function()
            if HitRF then
                HitRF:InvokeServer(unpack({hum, vector.create(px, py, pz)}))
            end
        end)
    end)
end

local kaOn = false
local kaAPS = 10000
local kaCD = 1 / kaAPS
local kaRange = 50
local kaLast = 0
local kaConn = nil

local function StartKA()
    if kaConn then kaConn:Disconnect() end
    kaConn = RunService.Heartbeat:Connect(function()
        if not kaOn then return end
        local mc = lp.Character
        local myHRP = mc and mc:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        
        local now = tick()
        if now - kaLast < kaCD then return end
        
        local px, py, pz = myHRP.Position.X, myHRP.Position.Y, myHRP.Position.Z
        
        local cls, mind = nil, math.huge
        for _, p in Players:GetPlayers() do
            if p == lp then continue end
            if isFriend(p.Name) or isFriend(p.DisplayName) then continue end
            if not isTarget(p.Name) and not isTarget(p.DisplayName) then continue end
            
            local c = p.Character
            if not c then continue end
            local hu = c:FindFirstChild("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hu and hrp and hu.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d <= kaRange and d < mind then
                    mind = d
                    cls = {hu, hrp}
                end
            end
        end
        
        if cls then
            HitRemoteInvoke(cls[1], px, py, pz)
            kaLast = now
        end
    end)
end

local function StopKA()
    kaOn = false
    if kaConn then kaConn:Disconnect(); kaConn = nil end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillAura"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 40)
mainFrame.Position = UDim2.new(0.5, -140, 0, 2)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 0, 1, 0)
glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
glow.BackgroundTransparency = 0.85
glow.BorderSizePixel = 0
glow.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 16)
glowCorner.Parent = glow

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -110, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "☠️ KILL AURA"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 50, 1, 0)
statusText.Position = UDim2.new(0, 135, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "🔴 OFF"
statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
statusText.TextSize = 12
statusText.Font = Enum.Font.GothamBold
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = titleBar

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(1, -85, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
statusDot.BorderSizePixel = 2
statusDot.BorderColor3 = Color3.fromRGB(255, 255, 255)
statusDot.Parent = titleBar

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(0, 5)
dotCorner.Parent = statusDot

local expandBtn = Instance.new("TextButton")
expandBtn.Size = UDim2.new(0, 25, 0, 25)
expandBtn.Position = UDim2.new(1, -55, 0.5, -12)
expandBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
expandBtn.Text = "▼"
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.TextSize = 14
expandBtn.Font = Enum.Font.GothamBold
expandBtn.BorderSizePixel = 0
expandBtn.Parent = titleBar

local expandCorner = Instance.new("UICorner")
expandCorner.CornerRadius = UDim.new(0, 8)
expandCorner.Parent = expandBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 0, 200)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
contentFrame.BackgroundTransparency = 0.05
contentFrame.BorderSizePixel = 0
contentFrame.Visible = false
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 0, 0, 16)
contentCorner.Parent = contentFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.35, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.32, 0, 0.05, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "ACTIVATE"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.5, 0, 0, 18)
rangeLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📡 Range: " .. kaRange
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 10
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = contentFrame

local rangeSliderBg = Instance.new("Frame")
rangeSliderBg.Size = UDim2.new(0.7, 0, 0, 4)
rangeSliderBg.Position = UDim2.new(0.05, 0, 0.5, 0)
rangeSliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
rangeSliderBg.BorderSizePixel = 0
rangeSliderBg.Parent = contentFrame

local rangeSliderFill = Instance.new("Frame")
local rangePct = (kaRange - 5) / (250 - 5)
rangeSliderFill.Size = UDim2.new(rangePct, 0, 1, 0)
rangeSliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
rangeSliderFill.BorderSizePixel = 0
rangeSliderFill.Parent = rangeSliderBg

local rangeKnob = Instance.new("Frame")
rangeKnob.Size = UDim2.new(0, 12, 0, 12)
rangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
rangeKnob.Position = UDim2.new(rangePct, 0, 0.5, 0)
rangeKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rangeKnob.BorderSizePixel = 0
rangeKnob.Parent = rangeSliderBg

local apsLabel = Instance.new("TextLabel")
apsLabel.Size = UDim2.new(0.5, 0, 0, 18)
apsLabel.Position = UDim2.new(0.05, 0, 0.68, 0)
apsLabel.BackgroundTransparency = 1
apsLabel.Text = "⚡ APS: " .. kaAPS
apsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
apsLabel.TextSize = 10
apsLabel.Font = Enum.Font.Gotham
apsLabel.TextXAlignment = Enum.TextXAlignment.Left
apsLabel.Parent = contentFrame

local apsSliderBg = Instance.new("Frame")
apsSliderBg.Size = UDim2.new(0.7, 0, 0, 4)
apsSliderBg.Position = UDim2.new(0.05, 0, 0.83, 0)
apsSliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
apsSliderBg.BorderSizePixel = 0
apsSliderBg.Parent = contentFrame

local apsSliderFill = Instance.new("Frame")
local apsPct = (kaAPS - 1) / (10000 - 1)
apsSliderFill.Size = UDim2.new(apsPct, 0, 1, 0)
apsSliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
apsSliderFill.BorderSizePixel = 0
apsSliderFill.Parent = apsSliderBg

local apsKnob = Instance.new("Frame")
apsKnob.Size = UDim2.new(0, 12, 0, 12)
apsKnob.AnchorPoint = Vector2.new(0.5, 0.5)
apsKnob.Position = UDim2.new(apsPct, 0, 0.5, 0)
apsKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
apsKnob.BorderSizePixel = 0
apsKnob.Parent = apsSliderBg

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, 0, 0, 14)
targetLabel.Position = UDim2.new(0, 10, 0, 105)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "🎯 TARGET LIST (space separated)"
targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
targetLabel.TextSize = 8
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = contentFrame

local targetInput = Instance.new("TextBox")
targetInput.Size = UDim2.new(0.85, 0, 0, 22)
targetInput.Position = UDim2.new(0.08, 0, 0, 122)
targetInput.PlaceholderText = ""
targetInput.Text = ""
targetInput.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
targetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
targetInput.TextSize = 10
targetInput.Font = Enum.Font.Gotham
targetInput.ClearTextOnFocus = false
targetInput.Parent = contentFrame

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 6)
targetCorner.Parent = targetInput

targetInput.FocusLost:Connect(function()
    S.targetList = parseList(targetInput.Text)
end)

local friendLabel = Instance.new("TextLabel")
friendLabel.Size = UDim2.new(1, 0, 0, 14)
friendLabel.Position = UDim2.new(0, 10, 0, 158)
friendLabel.BackgroundTransparency = 1
friendLabel.Text = "🛡️ SAFE LIST (space separated)"
friendLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
friendLabel.TextSize = 8
friendLabel.Font = Enum.Font.GothamBold
friendLabel.TextXAlignment = Enum.TextXAlignment.Left
friendLabel.Parent = contentFrame

local friendInput = Instance.new("TextBox")
friendInput.Size = UDim2.new(0.85, 0, 0, 22)
friendInput.Position = UDim2.new(0.08, 0, 0, 175)
friendInput.PlaceholderText = ""
friendInput.Text = ""
friendInput.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
friendInput.TextColor3 = Color3.fromRGB(255, 255, 255)
friendInput.TextSize = 10
friendInput.Font = Enum.Font.Gotham
friendInput.ClearTextOnFocus = false
friendInput.Parent = contentFrame

local friendCorner = Instance.new("UICorner")
friendCorner.CornerRadius = UDim.new(0, 6)
friendCorner.Parent = friendInput

friendInput.FocusLost:Connect(function()
    S.friendList = parseList(friendInput.Text)
end)

local function updateRange(posX)
    if not rangeSliderBg.AbsolutePosition then return end
    local pct = math.clamp((posX - rangeSliderBg.AbsolutePosition.X) / rangeSliderBg.AbsoluteSize.X, 0, 1)
    rangeSliderFill.Size = UDim2.new(pct, 0, 1, 0)
    rangeKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    kaRange = math.floor(5 + pct * (250 - 5))
    S.KillAuraRange = kaRange
    rangeLabel.Text = "📡 Range: " .. kaRange
end

local function updateAPS(posX)
    if not apsSliderBg.AbsolutePosition then return end
    local pct = math.clamp((posX - apsSliderBg.AbsolutePosition.X) / apsSliderBg.AbsoluteSize.X, 0, 1)
    apsSliderFill.Size = UDim2.new(pct, 0, 1, 0)
    apsKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    kaAPS = math.floor(1 + pct * (10000 - 1))
    S.AttacksPerSecond = kaAPS
    kaCD = 1 / kaAPS
    apsLabel.Text = "⚡ APS: " .. kaAPS
end

local rangeDragging = false
local apsDragging = false

rangeSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        rangeDragging = true
        updateRange(i.Position.X)
    end
end)
rangeKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        rangeDragging = true
        updateRange(i.Position.X)
    end
end)

apsSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        apsDragging = true
        updateAPS(i.Position.X)
    end
end)
apsKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        apsDragging = true
        updateAPS(i.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if rangeDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        updateRange(i.Position.X)
    end
    if apsDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        updateAPS(i.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        rangeDragging = false
        apsDragging = false
    end
end)

expandBtn.MouseButton1Click:Connect(function()
    contentVisible = not contentVisible
    contentFrame.Visible = contentVisible
    local targetHeight = contentVisible and 250 or 40
    expandBtn.Text = contentVisible and "▲" or "▼"
    TweenService:Create(mainFrame, TweenInfo.new(0.15), {
        Size = UDim2.new(0, 280, 0, targetHeight)
    }):Play()
end)

local function setActive(active)
    kaOn = active
    if active then
        toggleBtn.Text = "DEACTIVATE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusText.Text = "🟢 ON"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        glow.BackgroundTransparency = 0.7
        StartKA()
        print("☠️ KILL AURA ACTIVATED")
    else
        toggleBtn.Text = "ACTIVATE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        statusText.Text = "🔴 OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        glow.BackgroundTransparency = 0.85
        StopKA()
        print("☠️ KILL AURA DEACTIVATED")
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setActive(not kaOn)
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.U then
        setActive(not kaOn)
    end
    if i.KeyCode == Enum.KeyCode.L then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    kaOn = false
    StopKA()
    screenGui:Destroy()
end)

S.targetList = parseList(targetInput.Text)
S.friendList = parseList(friendInput.Text)

print("☠️ KILL AURA LOADED ☠️")
print("📡 Range: 5-250 | ⚡ APS: 1-10000")
print("🎯 Target List: Space separated names")
print("🛡️ Safe List: Space separated names")
print("🔑 U = Toggle | L = Hide/Show")
