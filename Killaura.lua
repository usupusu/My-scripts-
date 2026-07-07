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
    AttacksPerSecond = 15000,
    targetList = {},
    friendList = {},
    MultiTarget = true,
    MaxTargets = 10,
}

local contentVisible = false

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
local kaAPS = 15000
local kaCD = 1 / kaAPS
local kaRange = 50
local kaLast = 0
local kaConn = nil
local hitCounter = 0

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
        
        local targets = {}
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
                if d <= kaRange then
                    table.insert(targets, {hu = hu, hrp = hrp, dist = d})
                end
            end
        end
        
        if #targets > 0 then
            table.sort(targets, function(a, b) return a.dist < b.dist end)
            local maxTargets = math.min(S.MaxTargets or 10, #targets)
            for i = 1, maxTargets do
                task.spawn(function()
                    HitRemoteInvoke(targets[i].hu, px, py, pz)
                end)
            end
            kaLast = now
            hitCounter = hitCounter + 1
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
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 45)
mainFrame.Position = UDim2.new(0.5, -160, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local border = Instance.new("Frame")
border.Size = UDim2.new(1, 8, 1, 8)
border.Position = UDim2.new(-0.01, 0, -0.01, 0)
border.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
border.BackgroundTransparency = 0
border.BorderSizePixel = 0
border.ZIndex = 0
border.Parent = mainFrame

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 18)
borderCorner.Parent = border

local innerFrame = Instance.new("Frame")
innerFrame.Size = UDim2.new(1, -4, 1, -4)
innerFrame.Position = UDim2.new(0, 2, 0, 2)
innerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
innerFrame.BackgroundTransparency = 0
innerFrame.BorderSizePixel = 0
innerFrame.ZIndex = 1
innerFrame.Parent = mainFrame

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, 15)
innerCorner.Parent = innerFrame

coroutine.wrap(function()
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(75, 0, 130),
        Color3.fromRGB(148, 0, 211)
    }
    local index = 1
    while border and border.Parent do
        border.BackgroundColor3 = colors[index]
        index = index % #colors + 1
        task.wait(0.1)
    end
end)()

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleBar.BackgroundTransparency = 0
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = innerFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -130, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "☠️ KILL AURA"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 60, 1, 0)
statusText.Position = UDim2.new(0, 150, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "🔴 OFF"
statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
statusText.TextSize = 12
statusText.Font = Enum.Font.GothamBold
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = titleBar

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 12, 0, 12)
statusDot.Position = UDim2.new(1, -100, 0.5, -6)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
statusDot.BorderSizePixel = 2
statusDot.BorderColor3 = Color3.fromRGB(255, 255, 255)
statusDot.Parent = titleBar

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(0, 6)
dotCorner.Parent = statusDot

local expandBtn = Instance.new("TextButton")
expandBtn.Size = UDim2.new(0, 30, 0, 30)
expandBtn.Position = UDim2.new(1, -68, 0.5, -15)
expandBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
expandBtn.Text = "▼"
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.TextSize = 14
expandBtn.Font = Enum.Font.GothamBold
expandBtn.BorderSizePixel = 0
expandBtn.ZIndex = 3
expandBtn.Parent = titleBar

local expandCorner = Instance.new("UICorner")
expandCorner.CornerRadius = UDim.new(0, 8)
expandCorner.Parent = expandBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 3
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 0, 350)
contentFrame.Position = UDim2.new(0, 0, 0, 45)
contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
contentFrame.BackgroundTransparency = 0
contentFrame.BorderSizePixel = 0
contentFrame.Visible = false
contentFrame.ZIndex = 2
contentFrame.Parent = innerFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 0, 0, 15)
contentCorner.Parent = contentFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.4, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.3, 0, 0.02, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "ACTIVATE"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.ZIndex = 3
toggleBtn.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.5, 0, 0, 20)
rangeLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📡 Range: " .. kaRange
rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rangeLabel.TextSize = 11
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.ZIndex = 3
rangeLabel.Parent = contentFrame

local rangeSliderBg = Instance.new("Frame")
rangeSliderBg.Size = UDim2.new(0.8, 0, 0, 6)
rangeSliderBg.Position = UDim2.new(0.05, 0, 0.18, 0)
rangeSliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
rangeSliderBg.BorderSizePixel = 0
rangeSliderBg.ZIndex = 3
rangeSliderBg.Parent = contentFrame

local rangeSliderFill = Instance.new("Frame")
local rangePct = (kaRange - 1) / (250 - 1)
rangeSliderFill.Size = UDim2.new(rangePct, 0, 1, 0)
rangeSliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
rangeSliderFill.BorderSizePixel = 0
rangeSliderFill.ZIndex = 4
rangeSliderFill.Parent = rangeSliderBg

local rangeKnob = Instance.new("Frame")
rangeKnob.Size = UDim2.new(0, 16, 0, 16)
rangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
rangeKnob.Position = UDim2.new(rangePct, 0, 0.5, 0)
rangeKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rangeKnob.BorderSizePixel = 0
rangeKnob.ZIndex = 5
rangeKnob.Parent = rangeSliderBg

local rangeKnobCorner = Instance.new("UICorner")
rangeKnobCorner.CornerRadius = UDim.new(0, 8)
rangeKnobCorner.Parent = rangeKnob

local apsLabel = Instance.new("TextLabel")
apsLabel.Size = UDim2.new(0.5, 0, 0, 20)
apsLabel.Position = UDim2.new(0.05, 0, 0.30, 0)
apsLabel.BackgroundTransparency = 1
apsLabel.Text = "⚡ APS: " .. kaAPS
apsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
apsLabel.TextSize = 11
apsLabel.Font = Enum.Font.Gotham
apsLabel.TextXAlignment = Enum.TextXAlignment.Left
apsLabel.ZIndex = 3
apsLabel.Parent = contentFrame

local apsSliderBg = Instance.new("Frame")
apsSliderBg.Size = UDim2.new(0.8, 0, 0, 6)
apsSliderBg.Position = UDim2.new(0.05, 0, 0.36, 0)
apsSliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
apsSliderBg.BorderSizePixel = 0
apsSliderBg.ZIndex = 3
apsSliderBg.Parent = contentFrame

local apsSliderFill = Instance.new("Frame")
local apsPct = (kaAPS - 1) / (15000 - 1)
apsSliderFill.Size = UDim2.new(apsPct, 0, 1, 0)
apsSliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
apsSliderFill.BorderSizePixel = 0
apsSliderFill.ZIndex = 4
apsSliderFill.Parent = apsSliderBg

local apsKnob = Instance.new("Frame")
apsKnob.Size = UDim2.new(0, 16, 0, 16)
apsKnob.AnchorPoint = Vector2.new(0.5, 0.5)
apsKnob.Position = UDim2.new(apsPct, 0, 0.5, 0)
apsKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
apsKnob.BorderSizePixel = 0
apsKnob.ZIndex = 5
apsKnob.Parent = apsSliderBg

local apsKnobCorner = Instance.new("UICorner")
apsKnobCorner.CornerRadius = UDim.new(0, 8)
apsKnobCorner.Parent = apsKnob

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.4, 0, 0, 20)
targetLabel.Position = UDim2.new(0.05, 0, 0.47, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "🎯 Target List"
targetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
targetLabel.TextSize = 12
targetLabel.Font = Enum.Font.GothamBold
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.ZIndex = 3
targetLabel.Parent = contentFrame

local targetInput = Instance.new("TextBox")
targetInput.Size = UDim2.new(0.9, 0, 0, 25)
targetInput.Position = UDim2.new(0.05, 0, 0.51, 0)
targetInput.PlaceholderText = "Enter names separated by space"
targetInput.Text = ""
targetInput.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
targetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
targetInput.TextSize = 11
targetInput.Font = Enum.Font.Gotham
targetInput.ClearTextOnFocus = false
targetInput.ZIndex = 3
targetInput.Parent = contentFrame

local targetCorner = Instance.new("UICorner")
targetCorner.CornerRadius = UDim.new(0, 8)
targetCorner.Parent = targetInput

targetInput.FocusLost:Connect(function()
    S.targetList = parseList(targetInput.Text)
end)

local friendLabel = Instance.new("TextLabel")
friendLabel.Size = UDim2.new(0.4, 0, 0, 20)
friendLabel.Position = UDim2.new(0.05, 0, 0.64, 0)
friendLabel.BackgroundTransparency = 1
friendLabel.Text = "🛡️ Safe List"
friendLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
friendLabel.TextSize = 12
friendLabel.Font = Enum.Font.GothamBold
friendLabel.TextXAlignment = Enum.TextXAlignment.Left
friendLabel.ZIndex = 3
friendLabel.Parent = contentFrame

local friendInput = Instance.new("TextBox")
friendInput.Size = UDim2.new(0.9, 0, 0, 25)
friendInput.Position = UDim2.new(0.05, 0, 0.68, 0)
friendInput.PlaceholderText = "Enter names separated by space"
friendInput.Text = ""
friendInput.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
friendInput.TextColor3 = Color3.fromRGB(255, 255, 255)
friendInput.TextSize = 11
friendInput.Font = Enum.Font.Gotham
friendInput.ClearTextOnFocus = false
friendInput.ZIndex = 3
friendInput.Parent = contentFrame

local friendCorner = Instance.new("UICorner")
friendCorner.CornerRadius = UDim.new(0, 8)
friendCorner.Parent = friendInput

friendInput.FocusLost:Connect(function()
    S.friendList = parseList(friendInput.Text)
end)

local hitsLabel = Instance.new("TextLabel")
hitsLabel.Size = UDim2.new(0.5, 0, 0, 20)
hitsLabel.Position = UDim2.new(0.05, 0, 0.85, 0)
hitsLabel.BackgroundTransparency = 1
hitsLabel.Text = "💥 Hits: 0"
hitsLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
hitsLabel.TextSize = 11
hitsLabel.Font = Enum.Font.Gotham
hitsLabel.TextXAlignment = Enum.TextXAlignment.Left
hitsLabel.ZIndex = 3
hitsLabel.Parent = contentFrame

coroutine.wrap(function()
    while wait(0.5) do
        hitsLabel.Text = "💥 Hits: " .. hitCounter
    end
end)()

local function updateRange(posX)
    if not rangeSliderBg.AbsolutePosition then return end
    local pct = math.clamp((posX - rangeSliderBg.AbsolutePosition.X) / rangeSliderBg.AbsoluteSize.X, 0, 1)
    rangeSliderFill.Size = UDim2.new(pct, 0, 1, 0)
    rangeKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    kaRange = math.floor(1 + pct * (250 - 1))
    S.KillAuraRange = kaRange
    rangeLabel.Text = "📡 Range: " .. kaRange
end

local function updateAPS(posX)
    if not apsSliderBg.AbsolutePosition then return end
    local pct = math.clamp((posX - apsSliderBg.AbsolutePosition.X) / apsSliderBg.AbsoluteSize.X, 0, 1)
    apsSliderFill.Size = UDim2.new(pct, 0, 1, 0)
    apsKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    kaAPS = math.floor(1 + pct * (15000 - 1))
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
    local targetHeight = contentVisible and 395 or 45
    expandBtn.Text = contentVisible and "▲" or "▼"
    TweenService:Create(mainFrame, TweenInfo.new(0.15), {
        Size = UDim2.new(0, 320, 0, targetHeight)
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
        StartKA()
    else
        toggleBtn.Text = "ACTIVATE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        statusText.Text = "🔴 OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        StopKA()
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setActive(not kaOn)
end)

local function toggleGui()
    mainFrame.Visible = not mainFrame.Visible
end

local lastTap = 0
UserInputService.TouchEnabled = true
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.3 then
            toggleGui()
        end
        lastTap = now
    end
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.U then
        setActive(not kaOn)
    end
    if i.KeyCode == Enum.KeyCode.L then
        toggleGui()
    end
    if i.KeyCode == Enum.KeyCode.RightAlt then
        contentVisible = not contentVisible
        contentFrame.Visible = contentVisible
        local targetHeight = contentVisible and 395 or 45
        expandBtn.Text = contentVisible and "▲" or "▼"
        TweenService:Create(mainFrame, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 320, 0, targetHeight)
        }):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    kaOn = false
    StopKA()
    screenGui:Destroy()
end)

-- Drag functionality
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

S.targetList = parseList(targetInput.Text)
S.friendList = parseList(friendInput.Text)

print("☠️ KILL AURA LOADED")
print("📡 Range: 1-250 | ⚡ APS: 1-15000")
print("🎯 Target List: Space separated names")
print("🛡️ Safe List: Space separated names")
print("🔑 U = Toggle | L = Hide/Show | RightAlt = Expand")
print("📱 Double Tap = Toggle GUI")
