local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local isActive = true
local currentColorMode = "all"
local customPhrases = {}

local defaultNameLines = {
    "LEGEND on top",
}

local nameLines = {}
local currentPhraseIndex = 1
local isTyping = false

local speedValue = 0.5
local totalTimePerPhrase = 0.5
local colorChangeSpeed = 0.5
local pauseBetweenPhrases = 0.5

local function updateSpeed()
    totalTimePerPhrase = speedValue
    colorChangeSpeed = speedValue
    pauseBetweenPhrases = speedValue
end

local function getLetterSpeed(phrase)
    local length = #phrase
    if length == 0 then return 0.001 end
    return totalTimePerPhrase / length
end

local colorLoopRunning = true
local nameLoopRunning = true
local colorThread = nil
local nameThread = nil

local skyColors = {
    Color3.fromRGB(135, 206, 235), Color3.fromRGB(0, 191, 255), Color3.fromRGB(135, 206, 250),
    Color3.fromRGB(70, 130, 180), Color3.fromRGB(176, 224, 230), Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(127, 255, 212), Color3.fromRGB(175, 238, 238), Color3.fromRGB(0, 206, 209),
    Color3.fromRGB(72, 209, 204),
}

local darkColors = {
    Color3.fromRGB(25, 25, 25), Color3.fromRGB(30, 30, 30), Color3.fromRGB(40, 40, 40),
    Color3.fromRGB(50, 50, 50), Color3.fromRGB(60, 60, 70), Color3.fromRGB(70, 70, 90),
    Color3.fromRGB(80, 50, 60), Color3.fromRGB(60, 40, 50), Color3.fromRGB(40, 60, 50),
    Color3.fromRGB(50, 40, 30),
}

local neonColors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 100, 255),
    Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 0, 150), Color3.fromRGB(150, 0, 255),
    Color3.fromRGB(0, 255, 150),
}

local pastelColors = {
    Color3.fromRGB(255, 200, 200), Color3.fromRGB(255, 220, 180), Color3.fromRGB(255, 255, 200),
    Color3.fromRGB(200, 255, 200), Color3.fromRGB(200, 220, 255), Color3.fromRGB(220, 200, 255),
    Color3.fromRGB(255, 200, 240), Color3.fromRGB(200, 255, 240), Color3.fromRGB(255, 220, 200),
    Color3.fromRGB(220, 220, 255),
}

local rainbowColors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211),
}

local warmColors = {
    Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 120, 60), Color3.fromRGB(255, 160, 60),
    Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 220, 100), Color3.fromRGB(255, 180, 120),
    Color3.fromRGB(255, 140, 100), Color3.fromRGB(255, 100, 80),
}

local coolColors = {
    Color3.fromRGB(100, 200, 255), Color3.fromRGB(80, 180, 255), Color3.fromRGB(60, 160, 255),
    Color3.fromRGB(100, 180, 220), Color3.fromRGB(120, 200, 210), Color3.fromRGB(100, 220, 200),
    Color3.fromRGB(80, 200, 180), Color3.fromRGB(140, 180, 255),
}

local metallicColors = {
    Color3.fromRGB(192, 192, 192), Color3.fromRGB(212, 175, 55), Color3.fromRGB(205, 127, 50),
    Color3.fromRGB(176, 224, 230), Color3.fromRGB(165, 42, 42), Color3.fromRGB(128, 128, 128),
    Color3.fromRGB(169, 169, 169), Color3.fromRGB(220, 220, 220),
}

local earthColors = {
    Color3.fromRGB(139, 69, 19), Color3.fromRGB(160, 82, 45), Color3.fromRGB(210, 105, 30),
    Color3.fromRGB(205, 133, 63), Color3.fromRGB(244, 164, 96), Color3.fromRGB(238, 232, 170),
    Color3.fromRGB(107, 142, 35), Color3.fromRGB(85, 107, 47),
}

local gemColors = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 20, 147), Color3.fromRGB(148, 0, 211),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 165, 0),
}

local oceanColors = {
    Color3.fromRGB(0, 105, 148), Color3.fromRGB(0, 119, 190), Color3.fromRGB(0, 150, 199),
    Color3.fromRGB(0, 180, 216), Color3.fromRGB(72, 202, 228), Color3.fromRGB(144, 224, 239),
    Color3.fromRGB(202, 240, 248), Color3.fromRGB(0, 85, 120),
}

local iceColors = {
    Color3.fromRGB(173, 216, 230), Color3.fromRGB(176, 224, 230), Color3.fromRGB(224, 255, 255),
    Color3.fromRGB(240, 248, 255), Color3.fromRGB(230, 255, 255), Color3.fromRGB(200, 240, 255),
    Color3.fromRGB(150, 220, 255), Color3.fromRGB(100, 200, 255),
}

local blackWhiteColors = {Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255)}
local lightColors = {Color3.fromRGB(240,248,255), Color3.fromRGB(245,245,245), Color3.fromRGB(255,250,240), Color3.fromRGB(255,255,240)}

local allColors = {}
for _, color in pairs(skyColors) do table.insert(allColors, color) end
for _, color in pairs(darkColors) do table.insert(allColors, color) end
for _, color in pairs(neonColors) do table.insert(allColors, color) end
for _, color in pairs(pastelColors) do table.insert(allColors, color) end
for _, color in pairs(rainbowColors) do table.insert(allColors, color) end
for _, color in pairs(warmColors) do table.insert(allColors, color) end
for _, color in pairs(coolColors) do table.insert(allColors, color) end
for _, color in pairs(metallicColors) do table.insert(allColors, color) end
for _, color in pairs(earthColors) do table.insert(allColors, color) end
for _, color in pairs(gemColors) do table.insert(allColors, color) end
for _, color in pairs(oceanColors) do table.insert(allColors, color) end
for _, color in pairs(iceColors) do table.insert(allColors, color) end
for _, color in pairs(blackWhiteColors) do table.insert(allColors, color) end
for _, color in pairs(lightColors) do table.insert(allColors, color) end

local colorModes = {
    all = allColors,
    rainbow = rainbowColors,
    pastel = pastelColors,
    neon = neonColors,
    ocean = oceanColors,
    ice = iceColors,
    bw = blackWhiteColors,
    dark = darkColors,
    light = lightColors,
    warm = warmColors,
    cool = coolColors,
    metallic = metallicColors,
    earth = earthColors,
    gem = gemColors,
    sky = skyColors,
}

local colorRemote = nil
local nameRemote = nil

local function findRemotes()
    local colorNames = {"UpdateBioColor", "UpdateNameColor", "SetNameColor", "ChangeNameColor", "SetColor", "UpdateColor"}
    local nameNames = {"UpdateName", "SetName", "ChangeName", "UpdateDisplayName", "SetDisplayName", "ChangeBio", "UpdateBio"}
    
    local function search(obj, names)
        for _, child in pairs(obj:GetChildren()) do
            for _, rName in pairs(names) do
                if child.Name == rName then
                    return child
                end
            end
            if child:IsA("Folder") or child:IsA("Model") then
                local found = search(child, names)
                if found then return found end
            end
        end
        return nil
    end
    
    colorRemote = search(ReplicatedStorage, colorNames)
    nameRemote = search(ReplicatedStorage, nameNames)
end

findRemotes()

local function applyColor(color)
    if not isActive then return end
    if colorRemote then
        pcall(function()
            if colorRemote:IsA("RemoteEvent") then
                colorRemote:FireServer(color)
            elseif colorRemote:IsA("RemoteFunction") then
                colorRemote:InvokeServer(color)
            end
        end)
    end
end

local function applyName(text)
    if not isActive then return end
    if nameRemote then
        pcall(function()
            if nameRemote:IsA("RemoteEvent") then
                nameRemote:FireServer(text)
            elseif nameRemote:IsA("RemoteFunction") then
                nameRemote:InvokeServer(text)
            end
        end)
    end
end

local function updateNameList()
    nameLines = {}
    
    if #customPhrases > 0 then
        for _, v in pairs(customPhrases) do
            if v ~= "" then
                table.insert(nameLines, v)
            end
        end
    else
        for _, v in pairs(defaultNameLines) do
            table.insert(nameLines, v)
        end
    end
end

local function addCustomPhrases(input)
    if input == "" then return false end
    
    local phrases = {}
    for phrase in input:gmatch("[^,]+") do
        local trimmed = phrase:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            table.insert(phrases, trimmed)
        end
    end
    
    if #phrases == 0 then return false end
    
    for _, p in pairs(phrases) do
        table.insert(customPhrases, p)
    end
    
    updateNameList()
    currentPhraseIndex = 1
    return true
end

local function clearCustomPhrases()
    customPhrases = {}
    updateNameList()
    currentPhraseIndex = 1
end

local function typewriter(text)
    if isTyping then return end
    isTyping = true
    
    local letterSpeed = getLetterSpeed(text)
    
    for i = 1, #text do
        if not isActive then break end
        applyName(text:sub(1, i))
        task.wait(letterSpeed)
    end
    
    isTyping = false
end

local function startNameCycle()
    nameLoopRunning = true
    
    while nameLoopRunning do
        if isActive then
            updateNameList()
            if #nameLines > 0 then
                local currentPhrase = nameLines[currentPhraseIndex]
                if currentPhrase then
                    typewriter(currentPhrase)
                end
                currentPhraseIndex = currentPhraseIndex % #nameLines + 1
                task.wait(pauseBetweenPhrases)
            end
        end
        task.wait(0.001)
    end
end

local function startColorCycle()
    colorLoopRunning = true
    local lastColorTime = tick()
    local localColorIndex = 1
    local bwIndex = 1
    
    while colorLoopRunning do
        if isActive then
            local now = tick()
            if now - lastColorTime >= colorChangeSpeed then
                lastColorTime = now
                
                local colors = colorModes[currentColorMode]
                if colors then
                    if currentColorMode == "bw" then
                        bwIndex = bwIndex % 2 + 1
                        applyColor(colors[bwIndex])
                    else
                        localColorIndex = localColorIndex % #colors + 1
                        applyColor(colors[localColorIndex])
                    end
                end
            end
        end
        task.wait(0.001)
    end
end

local function startAll()
    if colorThread and coroutine.status(colorThread) ~= "dead" then
        colorLoopRunning = false
        task.wait(0.05)
    end
    if nameThread and coroutine.status(nameThread) ~= "dead" then
        nameLoopRunning = false
        task.wait(0.05)
    end
    
    colorLoopRunning = true
    nameLoopRunning = true
    
    colorThread = coroutine.create(startColorCycle)
    nameThread = coroutine.create(startNameCycle)
    
    coroutine.resume(colorThread)
    coroutine.resume(nameThread)
end

local function stopAll()
    colorLoopRunning = false
    nameLoopRunning = false
end

local phraseSelectorGui = Instance.new("ScreenGui")
phraseSelectorGui.Name = "PhraseSelector"
phraseSelectorGui.Parent = CoreGui
phraseSelectorGui.Enabled = false

local phraseFrame = Instance.new("Frame")
phraseFrame.Size = UDim2.new(0, 400, 0, 350)
phraseFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
phraseFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
phraseFrame.BackgroundTransparency = 0.05
phraseFrame.BorderSizePixel = 0
phraseFrame.Parent = phraseSelectorGui

local phraseCorner = Instance.new("UICorner")
phraseCorner.CornerRadius = UDim.new(0, 20)
phraseCorner.Parent = phraseFrame

local phraseTitle = Instance.new("Frame")
phraseTitle.Size = UDim2.new(1, 0, 0, 45)
phraseTitle.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
phraseTitle.BorderSizePixel = 0
phraseTitle.Parent = phraseFrame

local phraseTitleCorner = Instance.new("UICorner")
phraseTitleCorner.CornerRadius = UDim.new(0, 20)
phraseTitleCorner.Parent = phraseTitle

local phraseTitleText = Instance.new("TextLabel")
phraseTitleText.Size = UDim2.new(1, -60, 1, 0)
phraseTitleText.Position = UDim2.new(0, 20, 0, 0)
phraseTitleText.BackgroundTransparency = 1
phraseTitleText.Text = "📝 PHRASE SETTINGS"
phraseTitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
phraseTitleText.TextSize = 16
phraseTitleText.Font = Enum.Font.GothamBold
phraseTitleText.TextXAlignment = Enum.TextXAlignment.Left
phraseTitleText.Parent = phraseTitle

local phraseCloseBtn = Instance.new("TextButton")
phraseCloseBtn.Size = UDim2.new(0, 40, 0, 35)
phraseCloseBtn.Position = UDim2.new(1, -45, 0.5, -17)
phraseCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
phraseCloseBtn.Text = "✕"
phraseCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
phraseCloseBtn.TextSize = 16
phraseCloseBtn.Font = Enum.Font.GothamBold
phraseCloseBtn.BorderSizePixel = 0
phraseCloseBtn.Parent = phraseTitle

local phraseCloseCorner = Instance.new("UICorner")
phraseCloseCorner.CornerRadius = UDim.new(0, 10)
phraseCloseCorner.Parent = phraseCloseBtn

local instrLabel = Instance.new("TextLabel")
instrLabel.Size = UDim2.new(0.9, 0, 0, 25)
instrLabel.Position = UDim2.new(0.05, 0, 0, 55)
instrLabel.BackgroundTransparency = 1
instrLabel.Text = "Separate multiple phrases with commas"
instrLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
instrLabel.TextSize = 11
instrLabel.Font = Enum.Font.Gotham
instrLabel.TextXAlignment = Enum.TextXAlignment.Left
instrLabel.Parent = phraseFrame

local phraseInput = Instance.new("TextBox")
phraseInput.Size = UDim2.new(0.9, 0, 0, 60)
phraseInput.Position = UDim2.new(0.05, 0, 0, 85)
phraseInput.PlaceholderText = "Example: HELLO, WORLD, COOL"
phraseInput.Text = ""
phraseInput.BackgroundColor3 = Color3.fromRGB(255, 240, 240)
phraseInput.TextColor3 = Color3.fromRGB(0, 0, 0)
phraseInput.TextSize = 13
phraseInput.Font = Enum.Font.Gotham
phraseInput.ClearTextOnFocus = false
phraseInput.TextWrapped = true
phraseInput.Parent = phraseFrame

local phraseInputCorner = Instance.new("UICorner")
phraseInputCorner.CornerRadius = UDim.new(0, 10)
phraseInputCorner.Parent = phraseInput

local addPhraseBtn = Instance.new("TextButton")
addPhraseBtn.Size = UDim2.new(0.9, 0, 0, 40)
addPhraseBtn.Position = UDim2.new(0.05, 0, 0, 155)
addPhraseBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
addPhraseBtn.Text = "➕ ADD PHRASES"
addPhraseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
addPhraseBtn.TextSize = 15
addPhraseBtn.Font = Enum.Font.GothamBold
addPhraseBtn.Parent = phraseFrame

local addPhraseCorner = Instance.new("UICorner")
addPhraseCorner.CornerRadius = UDim.new(0, 10)
addPhraseCorner.Parent = addPhraseBtn

local clearPhraseBtn = Instance.new("TextButton")
clearPhraseBtn.Size = UDim2.new(0.9, 0, 0, 35)
clearPhraseBtn.Position = UDim2.new(0.05, 0, 0, 205)
clearPhraseBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 100)
clearPhraseBtn.Text = "🗑️ CLEAR ALL"
clearPhraseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
clearPhraseBtn.TextSize = 13
clearPhraseBtn.Font = Enum.Font.GothamBold
clearPhraseBtn.Parent = phraseFrame

local clearPhraseCorner = Instance.new("UICorner")
clearPhraseCorner.CornerRadius = UDim.new(0, 10)
clearPhraseCorner.Parent = clearPhraseBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0, 250)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed (1-500):"
speedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = phraseFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.3, 0, 0, 35)
speedInput.Position = UDim2.new(0.35, 0, 0, 247)
speedInput.BackgroundColor3 = Color3.fromRGB(255, 240, 240)
speedInput.TextColor3 = Color3.fromRGB(0, 0, 0)
speedInput.Text = "500"
speedInput.TextSize = 14
speedInput.Font = Enum.Font.GothamBold
speedInput.PlaceholderText = "1-500"
speedInput.ClearTextOnFocus = false
speedInput.Parent = phraseFrame

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 8)
speedInputCorner.Parent = speedInput

local applySpeedBtn = Instance.new("TextButton")
applySpeedBtn.Size = UDim2.new(0.25, 0, 0, 35)
applySpeedBtn.Position = UDim2.new(0.68, 0, 0, 247)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
applySpeedBtn.Text = "APPLY"
applySpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
applySpeedBtn.TextSize = 13
applySpeedBtn.Font = Enum.Font.GothamBold
applySpeedBtn.Parent = phraseFrame

local applySpeedCorner = Instance.new("UICorner")
applySpeedCorner.CornerRadius = UDim.new(0, 8)
applySpeedCorner.Parent = applySpeedBtn

local currentSpeedLabel = Instance.new("TextLabel")
currentSpeedLabel.Size = UDim2.new(0.9, 0, 0, 25)
currentSpeedLabel.Position = UDim2.new(0.05, 0, 0, 290)
currentSpeedLabel.BackgroundTransparency = 1
currentSpeedLabel.Text = "Current: 500 (Fastest)"
currentSpeedLabel.TextColor3 = Color3.fromRGB(0, 0, 200)
currentSpeedLabel.TextSize = 13
currentSpeedLabel.Font = Enum.Font.Gotham
currentSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
currentSpeedLabel.Parent = phraseFrame

local function setSpeedFromInput()
    local val = tonumber(speedInput.Text)
    if val then
        val = math.floor(math.clamp(val, 1, 500))
        speedInput.Text = tostring(val)
        speedValue = (501 - val) / 1000
        updateSpeed()
        if val == 500 then
            currentSpeedLabel.Text = "Current: 500 (Fastest)"
        elseif val == 1 then
            currentSpeedLabel.Text = "Current: 1 (Slowest)"
        else
            currentSpeedLabel.Text = "Current: " .. tostring(val) .. " (" .. string.format("%.3f", speedValue) .. "s)"
        end
        statusText.Text = "✅ Speed: " .. tostring(val)
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(1.5, function()
            if isActive then
                statusText.Text = "ACTIVE"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    end
end

applySpeedBtn.MouseButton1Click:Connect(setSpeedFromInput)

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        setSpeedFromInput()
    end
end)

addPhraseBtn.MouseButton1Click:Connect(function()
    local input = phraseInput.Text
    if input ~= "" then
        addCustomPhrases(input)
        phraseInput.Text = ""
        statusText.Text = "✅ Added!"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(1, function()
            if isActive then
                statusText.Text = "ACTIVE"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    end
end)

clearPhraseBtn.MouseButton1Click:Connect(function()
    clearCustomPhrases()
    statusText.Text = "🗑️ Cleared!"
    statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
    task.delay(1, function()
        if isActive then
            statusText.Text = "ACTIVE"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFastNameChanger"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 55)
mainFrame.Position = UDim2.new(0, 10, 1, -65)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 25)
mainCorner.Parent = mainFrame

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 0, 1, 0)
glow.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
glow.BackgroundTransparency = 0.5
glow.BorderSizePixel = 0
glow.Parent = mainFrame
glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 25)
glowCorner.Parent = glow

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 35, 1, 0)
icon.Position = UDim2.new(0, 5, 0, 0)
icon.BackgroundTransparency = 1
icon.Text = "⚡"
icon.TextColor3 = Color3.fromRGB(0, 0, 0)
icon.TextSize = 24
icon.Font = Enum.Font.GothamBold
icon.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 38)
toggleBtn.Position = UDim2.new(0.24, 0, 0.15, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "ON"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 20)
toggleCorner.Parent = toggleBtn

local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0, 55, 0, 38)
colorBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
colorBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 255)
colorBtn.Text = "🎨"
colorBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
colorBtn.TextSize = 20
colorBtn.Font = Enum.Font.GothamBold
colorBtn.BorderSizePixel = 0
colorBtn.Parent = mainFrame

local colorCorner = Instance.new("UICorner")
colorCorner.CornerRadius = UDim.new(0, 20)
colorCorner.Parent = colorBtn

local phraseBtn = Instance.new("TextButton")
phraseBtn.Size = UDim2.new(0, 55, 0, 38)
phraseBtn.Position = UDim2.new(0.78, 0, 0.15, 0)
phraseBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 150)
phraseBtn.Text = "📝"
phraseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
phraseBtn.TextSize = 20
phraseBtn.Font = Enum.Font.GothamBold
phraseBtn.BorderSizePixel = 0
phraseBtn.Parent = mainFrame

local phraseCornerBtn = Instance.new("UICorner")
phraseCornerBtn.CornerRadius = UDim.new(0, 20)
phraseCornerBtn.Parent = phraseBtn

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 15)
statusText.Position = UDim2.new(0, 0, 0.72, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "ACTIVE"
statusText.TextColor3 = Color3.fromRGB(0, 200, 0)
statusText.TextSize = 9
statusText.Font = Enum.Font.Gotham
statusText.Parent = mainFrame

local colorSelectorGui = Instance.new("ScreenGui")
colorSelectorGui.Name = "ColorSelector"
colorSelectorGui.Parent = CoreGui
colorSelectorGui.Enabled = false

local selectorFrame = Instance.new("Frame")
selectorFrame.Size = UDim2.new(0, 340, 0, 450)
selectorFrame.Position = UDim2.new(0.5, -170, 0.5, -225)
selectorFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
selectorFrame.BackgroundTransparency = 0.05
selectorFrame.BorderSizePixel = 0
selectorFrame.Parent = colorSelectorGui

local selectorCorner = Instance.new("UICorner")
selectorCorner.CornerRadius = UDim.new(0, 20)
selectorCorner.Parent = selectorFrame

local selectorTitle = Instance.new("Frame")
selectorTitle.Size = UDim2.new(1, 0, 0, 50)
selectorTitle.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
selectorTitle.BorderSizePixel = 0
selectorTitle.Parent = selectorFrame

local selectorTitleCorner = Instance.new("UICorner")
selectorTitleCorner.CornerRadius = UDim.new(0, 20)
selectorTitleCorner.Parent = selectorTitle

local selectorTitleText = Instance.new("TextLabel")
selectorTitleText.Size = UDim2.new(1, -60, 1, 0)
selectorTitleText.Position = UDim2.new(0, 20, 0, 0)
selectorTitleText.BackgroundTransparency = 1
selectorTitleText.Text = "🎨 SELECT COLOR MODE"
selectorTitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
selectorTitleText.TextSize = 16
selectorTitleText.Font = Enum.Font.GothamBold
selectorTitleText.TextXAlignment = Enum.TextXAlignment.Left
selectorTitleText.Parent = selectorTitle

local closeSelectorBtn = Instance.new("TextButton")
closeSelectorBtn.Size = UDim2.new(0, 40, 0, 35)
closeSelectorBtn.Position = UDim2.new(1, -45, 0.5, -17)
closeSelectorBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeSelectorBtn.Text = "✕"
closeSelectorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeSelectorBtn.TextSize = 16
closeSelectorBtn.Font = Enum.Font.GothamBold
closeSelectorBtn.BorderSizePixel = 0
closeSelectorBtn.Parent = selectorTitle

local closeSelectorCorner = Instance.new("UICorner")
closeSelectorCorner.CornerRadius = UDim.new(0, 10)
closeSelectorCorner.Parent = closeSelectorBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -60)
scrollFrame.Position = UDim2.new(0, 5, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
scrollFrame.ScrollBarThickness = 3
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = selectorFrame

local scrollList = Instance.new("UIListLayout")
scrollList.Padding = UDim.new(0, 10)
scrollList.Parent = scrollFrame

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingLeft = UDim.new(0, 10)
scrollPadding.PaddingRight = UDim.new(0, 10)
scrollPadding.PaddingTop = UDim.new(0, 10)
scrollPadding.Parent = scrollFrame

local colorModesList = {
    {name = "🌈 ALL", mode = "all", color = Color3.fromRGB(255, 100, 150)},
    {name = "🌈 RAINBOW", mode = "rainbow", color = Color3.fromRGB(255, 0, 0)},
    {name = "🎀 PASTEL", mode = "pastel", color = Color3.fromRGB(255, 200, 200)},
    {name = "⚡ NEON", mode = "neon", color = Color3.fromRGB(0, 255, 0)},
    {name = "🌊 OCEAN", mode = "ocean", color = Color3.fromRGB(0, 105, 148)},
    {name = "❄️ ICE", mode = "ice", color = Color3.fromRGB(173, 216, 230)},
    {name = "⚫⚪ B&W", mode = "bw", color = Color3.fromRGB(100, 100, 100)},
    {name = "🌑 DARK", mode = "dark", color = Color3.fromRGB(30, 30, 30)},
    {name = "☀️ LIGHT", mode = "light", color = Color3.fromRGB(255, 255, 255)},
    {name = "🔥 WARM", mode = "warm", color = Color3.fromRGB(255, 80, 80)},
    {name = "❄️ COOL", mode = "cool", color = Color3.fromRGB(100, 200, 255)},
    {name = "✨ METALLIC", mode = "metallic", color = Color3.fromRGB(192, 192, 192)},
    {name = "🌍 EARTH", mode = "earth", color = Color3.fromRGB(139, 69, 19)},
    {name = "💎 GEM", mode = "gem", color = Color3.fromRGB(255, 215, 0)},
    {name = "☁️ SKY", mode = "sky", color = Color3.fromRGB(135, 206, 235)},
}

for _, mode in pairs(colorModesList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = mode.color
    btn.Text = mode.name
    btn.TextColor3 = mode.mode == "bw" and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentColorMode = mode.mode
        colorSelectorGui.Enabled = false
        statusText.Text = mode.name
        statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        task.delay(1.5, function()
            if isActive then
                statusText.Text = "ACTIVE"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    end)
end

closeSelectorBtn.MouseButton1Click:Connect(function()
    colorSelectorGui.Enabled = false
end)

colorBtn.MouseButton1Click:Connect(function()
    colorSelectorGui.Enabled = true
end)

phraseBtn.MouseButton1Click:Connect(function()
    phraseSelectorGui.Enabled = true
end)

phraseCloseBtn.MouseButton1Click:Connect(function()
    phraseSelectorGui.Enabled = false
end)

local function setActive(active)
    isActive = active
    
    if active then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        toggleBtn.Text = "ON"
        statusText.Text = "ACTIVE"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        mainFrame.BackgroundTransparency = 0.1
        glow.BackgroundTransparency = 0.5
        startAll()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        toggleBtn.Text = "OFF"
        statusText.Text = "OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
        mainFrame.BackgroundTransparency = 0.5
        glow.BackgroundTransparency = 0.9
        stopAll()
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setActive(not isActive)
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.L then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

updateNameList()
startAll()
setActive(true)
