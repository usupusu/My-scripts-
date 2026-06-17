local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local isActive = true
local currentColorMode = "all"
local customPhrases = {}
local customName = ""
local useCustomName = false

local defaultBioLines = {
    "LEGEND on top"
}

local bioLines = {}
local currentPhraseIndex = 1

-- ULTRA FAST FLICKER (0.001s = 1ms!)
local flickerSpeed = 0.001
local colorChangeSpeed = 0.001
local nameTypeSpeed = 0.01

local colorLoopRunning = true
local bioLoopRunning = true
local nameLoopRunning = true
local colorThread = nil
local bioThread = nil
local nameThread = nil

-- ============================================
-- COMPLETE COLOR SYSTEM
-- ============================================

-- REDS
local darkRed = {Color3.fromRGB(40,0,0), Color3.fromRGB(60,0,0), Color3.fromRGB(80,0,0), Color3.fromRGB(100,0,0), Color3.fromRGB(120,0,0)}
local lightRed = {Color3.fromRGB(255,100,100), Color3.fromRGB(255,120,120), Color3.fromRGB(255,140,140), Color3.fromRGB(255,160,160), Color3.fromRGB(255,180,180)}
local skyRed = {Color3.fromRGB(255,200,200), Color3.fromRGB(255,210,210), Color3.fromRGB(255,220,220), Color3.fromRGB(255,230,230), Color3.fromRGB(255,240,240)}

-- ORANGES
local darkOrange = {Color3.fromRGB(60,30,0), Color3.fromRGB(80,40,0), Color3.fromRGB(100,50,0), Color3.fromRGB(120,60,0), Color3.fromRGB(140,70,0)}
local lightOrange = {Color3.fromRGB(255,180,100), Color3.fromRGB(255,190,120), Color3.fromRGB(255,200,140), Color3.fromRGB(255,210,160), Color3.fromRGB(255,220,180)}
local skyOrange = {Color3.fromRGB(255,230,200), Color3.fromRGB(255,235,210), Color3.fromRGB(255,240,220), Color3.fromRGB(255,245,230), Color3.fromRGB(255,250,240)}

-- YELLOWS
local darkYellow = {Color3.fromRGB(60,60,0), Color3.fromRGB(80,80,0), Color3.fromRGB(100,100,0), Color3.fromRGB(120,120,0), Color3.fromRGB(140,140,0)}
local lightYellow = {Color3.fromRGB(255,255,150), Color3.fromRGB(255,255,170), Color3.fromRGB(255,255,190), Color3.fromRGB(255,255,210), Color3.fromRGB(255,255,230)}
local skyYellow = {Color3.fromRGB(255,255,240), Color3.fromRGB(255,255,245), Color3.fromRGB(255,255,250), Color3.fromRGB(255,255,252), Color3.fromRGB(255,255,255)}

-- GREENS
local darkGreen = {Color3.fromRGB(0,40,0), Color3.fromRGB(0,60,0), Color3.fromRGB(0,80,0), Color3.fromRGB(0,100,0), Color3.fromRGB(0,120,0)}
local lightGreen = {Color3.fromRGB(100,255,100), Color3.fromRGB(120,255,120), Color3.fromRGB(140,255,140), Color3.fromRGB(160,255,160), Color3.fromRGB(180,255,180)}
local skyGreen = {Color3.fromRGB(200,255,200), Color3.fromRGB(210,255,210), Color3.fromRGB(220,255,220), Color3.fromRGB(230,255,230), Color3.fromRGB(240,255,240)}

-- BLUES
local darkBlue = {Color3.fromRGB(0,0,40), Color3.fromRGB(0,0,60), Color3.fromRGB(0,0,80), Color3.fromRGB(0,0,100), Color3.fromRGB(0,0,120)}
local lightBlue = {Color3.fromRGB(100,100,255), Color3.fromRGB(120,120,255), Color3.fromRGB(140,140,255), Color3.fromRGB(160,160,255), Color3.fromRGB(180,180,255)}
local skyBlue = {Color3.fromRGB(200,200,255), Color3.fromRGB(210,210,255), Color3.fromRGB(220,220,255), Color3.fromRGB(230,230,255), Color3.fromRGB(240,240,255)}

-- INDIGOS
local darkIndigo = {Color3.fromRGB(20,0,40), Color3.fromRGB(30,0,60), Color3.fromRGB(40,0,80), Color3.fromRGB(50,0,100), Color3.fromRGB(60,0,120)}
local lightIndigo = {Color3.fromRGB(150,100,255), Color3.fromRGB(170,120,255), Color3.fromRGB(190,140,255), Color3.fromRGB(210,160,255), Color3.fromRGB(230,180,255)}
local skyIndigo = {Color3.fromRGB(230,200,255), Color3.fromRGB(235,210,255), Color3.fromRGB(240,220,255), Color3.fromRGB(245,230,255), Color3.fromRGB(250,240,255)}

-- VIOLETS
local darkViolet = {Color3.fromRGB(40,0,40), Color3.fromRGB(60,0,60), Color3.fromRGB(80,0,80), Color3.fromRGB(100,0,100), Color3.fromRGB(120,0,120)}
local lightViolet = {Color3.fromRGB(255,100,255), Color3.fromRGB(255,120,255), Color3.fromRGB(255,140,255), Color3.fromRGB(255,160,255), Color3.fromRGB(255,180,255)}
local skyViolet = {Color3.fromRGB(255,200,255), Color3.fromRGB(255,210,255), Color3.fromRGB(255,220,255), Color3.fromRGB(255,230,255), Color3.fromRGB(255,240,255)}

-- PINKS
local darkPink = {Color3.fromRGB(40,0,20), Color3.fromRGB(60,0,30), Color3.fromRGB(80,0,40), Color3.fromRGB(100,0,50), Color3.fromRGB(120,0,60)}
local lightPink = {Color3.fromRGB(255,150,200), Color3.fromRGB(255,170,210), Color3.fromRGB(255,190,220), Color3.fromRGB(255,210,230), Color3.fromRGB(255,230,240)}
local skyPink = {Color3.fromRGB(255,240,245), Color3.fromRGB(255,242,247), Color3.fromRGB(255,245,249), Color3.fromRGB(255,248,251), Color3.fromRGB(255,250,253)}

-- BROWNS
local darkBrown = {Color3.fromRGB(40,20,0), Color3.fromRGB(60,30,0), Color3.fromRGB(80,40,0), Color3.fromRGB(100,50,0), Color3.fromRGB(120,60,0)}
local lightBrown = {Color3.fromRGB(200,150,100), Color3.fromRGB(210,160,110), Color3.fromRGB(220,170,120), Color3.fromRGB(230,180,130), Color3.fromRGB(240,190,140)}
local skyBrown = {Color3.fromRGB(250,220,190), Color3.fromRGB(252,225,195), Color3.fromRGB(254,230,200), Color3.fromRGB(255,235,205), Color3.fromRGB(255,240,210)}

-- BLACKS
local darkBlack = {Color3.fromRGB(0,0,0), Color3.fromRGB(5,5,5), Color3.fromRGB(10,10,10), Color3.fromRGB(15,15,15), Color3.fromRGB(20,20,20)}
local lightBlack = {Color3.fromRGB(80,80,80), Color3.fromRGB(100,100,100), Color3.fromRGB(120,120,120), Color3.fromRGB(140,140,140), Color3.fromRGB(160,160,160)}
local skyBlack = {Color3.fromRGB(200,200,200), Color3.fromRGB(210,210,210), Color3.fromRGB(220,220,220), Color3.fromRGB(230,230,230), Color3.fromRGB(240,240,240)}

-- WHITES
local darkWhite = {Color3.fromRGB(180,180,180), Color3.fromRGB(190,190,190), Color3.fromRGB(200,200,200), Color3.fromRGB(210,210,210), Color3.fromRGB(220,220,220)}
local lightWhite = {Color3.fromRGB(240,240,240), Color3.fromRGB(245,245,245), Color3.fromRGB(250,250,250), Color3.fromRGB(252,252,252), Color3.fromRGB(254,254,254)}
local skyWhite = {Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)}

-- GRAYS
local darkGray = {Color3.fromRGB(30,30,30), Color3.fromRGB(40,40,40), Color3.fromRGB(50,50,50), Color3.fromRGB(60,60,60), Color3.fromRGB(70,70,70)}
local lightGray = {Color3.fromRGB(170,170,170), Color3.fromRGB(180,180,180), Color3.fromRGB(190,190,190), Color3.fromRGB(200,200,200), Color3.fromRGB(210,210,210)}
local skyGray = {Color3.fromRGB(230,230,230), Color3.fromRGB(235,235,235), Color3.fromRGB(240,240,240), Color3.fromRGB(245,245,245), Color3.fromRGB(250,250,250)}

-- CYANS
local darkCyan = {Color3.fromRGB(0,40,40), Color3.fromRGB(0,60,60), Color3.fromRGB(0,80,80), Color3.fromRGB(0,100,100), Color3.fromRGB(0,120,120)}
local lightCyan = {Color3.fromRGB(100,255,255), Color3.fromRGB(120,255,255), Color3.fromRGB(140,255,255), Color3.fromRGB(160,255,255), Color3.fromRGB(180,255,255)}
local skyCyan = {Color3.fromRGB(200,255,255), Color3.fromRGB(210,255,255), Color3.fromRGB(220,255,255), Color3.fromRGB(230,255,255), Color3.fromRGB(240,255,255)}

-- MAGENTAS
local darkMagenta = {Color3.fromRGB(40,0,40), Color3.fromRGB(60,0,60), Color3.fromRGB(80,0,80), Color3.fromRGB(100,0,100), Color3.fromRGB(120,0,120)}
local lightMagenta = {Color3.fromRGB(255,100,255), Color3.fromRGB(255,120,255), Color3.fromRGB(255,140,255), Color3.fromRGB(255,160,255), Color3.fromRGB(255,180,255)}
local skyMagenta = {Color3.fromRGB(255,200,255), Color3.fromRGB(255,210,255), Color3.fromRGB(255,220,255), Color3.fromRGB(255,230,255), Color3.fromRGB(255,240,255)}

-- TURQUOISES
local darkTurquoise = {Color3.fromRGB(0,40,30), Color3.fromRGB(0,60,50), Color3.fromRGB(0,80,70), Color3.fromRGB(0,100,90), Color3.fromRGB(0,120,110)}
local lightTurquoise = {Color3.fromRGB(100,255,220), Color3.fromRGB(120,255,230), Color3.fromRGB(140,255,240), Color3.fromRGB(160,255,245), Color3.fromRGB(180,255,250)}
local skyTurquoise = {Color3.fromRGB(200,255,245), Color3.fromRGB(210,255,248), Color3.fromRGB(220,255,250), Color3.fromRGB(230,255,252), Color3.fromRGB(240,255,254)}

-- LIMES
local darkLime = {Color3.fromRGB(20,40,0), Color3.fromRGB(30,60,0), Color3.fromRGB(40,80,0), Color3.fromRGB(50,100,0), Color3.fromRGB(60,120,0)}
local lightLime = {Color3.fromRGB(150,255,100), Color3.fromRGB(170,255,120), Color3.fromRGB(190,255,140), Color3.fromRGB(210,255,160), Color3.fromRGB(230,255,180)}
local skyLime = {Color3.fromRGB(240,255,200), Color3.fromRGB(242,255,210), Color3.fromRGB(245,255,220), Color3.fromRGB(248,255,230), Color3.fromRGB(250,255,240)}

-- NAVY
local darkNavy = {Color3.fromRGB(0,0,30), Color3.fromRGB(0,0,50), Color3.fromRGB(0,0,70), Color3.fromRGB(0,0,90), Color3.fromRGB(0,0,110)}
local lightNavy = {Color3.fromRGB(100,100,200), Color3.fromRGB(120,120,220), Color3.fromRGB(140,140,240), Color3.fromRGB(160,160,250), Color3.fromRGB(180,180,255)}
local skyNavy = {Color3.fromRGB(200,200,255), Color3.fromRGB(210,210,255), Color3.fromRGB(220,220,255), Color3.fromRGB(230,230,255), Color3.fromRGB(240,240,255)}

-- MAROON
local darkMaroon = {Color3.fromRGB(40,0,0), Color3.fromRGB(60,0,0), Color3.fromRGB(80,0,0), Color3.fromRGB(100,0,0), Color3.fromRGB(120,0,0)}
local lightMaroon = {Color3.fromRGB(200,100,100), Color3.fromRGB(220,120,120), Color3.fromRGB(240,140,140), Color3.fromRGB(250,160,160), Color3.fromRGB(255,180,180)}
local skyMaroon = {Color3.fromRGB(255,200,200), Color3.fromRGB(255,210,210), Color3.fromRGB(255,220,220), Color3.fromRGB(255,230,230), Color3.fromRGB(255,240,240)}

-- TEAL
local darkTeal = {Color3.fromRGB(0,30,30), Color3.fromRGB(0,50,50), Color3.fromRGB(0,70,70), Color3.fromRGB(0,90,90), Color3.fromRGB(0,110,110)}
local lightTeal = {Color3.fromRGB(100,220,220), Color3.fromRGB(120,240,240), Color3.fromRGB(140,250,250), Color3.fromRGB(160,255,255), Color3.fromRGB(180,255,255)}
local skyTeal = {Color3.fromRGB(200,255,255), Color3.fromRGB(210,255,255), Color3.fromRGB(220,255,255), Color3.fromRGB(230,255,255), Color3.fromRGB(240,255,255)}

-- GOLD
local darkGold = {Color3.fromRGB(60,50,0), Color3.fromRGB(80,70,0), Color3.fromRGB(100,90,0), Color3.fromRGB(120,110,0), Color3.fromRGB(140,130,0)}
local lightGold = {Color3.fromRGB(255,220,100), Color3.fromRGB(255,230,120), Color3.fromRGB(255,240,140), Color3.fromRGB(255,245,160), Color3.fromRGB(255,250,180)}
local skyGold = {Color3.fromRGB(255,250,200), Color3.fromRGB(255,252,210), Color3.fromRGB(255,254,220), Color3.fromRGB(255,255,230), Color3.fromRGB(255,255,240)}

local allColors = {}
local colorCategories = {
    darkRed, lightRed, skyRed,
    darkOrange, lightOrange, skyOrange,
    darkYellow, lightYellow, skyYellow,
    darkGreen, lightGreen, skyGreen,
    darkBlue, lightBlue, skyBlue,
    darkIndigo, lightIndigo, skyIndigo,
    darkViolet, lightViolet, skyViolet,
    darkPink, lightPink, skyPink,
    darkBrown, lightBrown, skyBrown,
    darkBlack, lightBlack, skyBlack,
    darkWhite, lightWhite, skyWhite,
    darkGray, lightGray, skyGray,
    darkCyan, lightCyan, skyCyan,
    darkMagenta, lightMagenta, skyMagenta,
    darkTurquoise, lightTurquoise, skyTurquoise,
    darkLime, lightLime, skyLime,
    darkNavy, lightNavy, skyNavy,
    darkMaroon, lightMaroon, skyMaroon,
    darkTeal, lightTeal, skyTeal,
    darkGold, lightGold, skyGold,
}

for _, category in pairs(colorCategories) do
    for _, color in pairs(category) do
        table.insert(allColors, color)
    end
end

local colorModes = {
    all = allColors,
    dark = {
        darkRed, darkOrange, darkYellow, darkGreen, darkBlue,
        darkIndigo, darkViolet, darkPink, darkBrown, darkBlack,
        darkGray, darkCyan, darkMagenta, darkTurquoise, darkLime,
        darkNavy, darkMaroon, darkTeal, darkGold
    },
    light = {
        lightRed, lightOrange, lightYellow, lightGreen, lightBlue,
        lightIndigo, lightViolet, lightPink, lightBrown, lightBlack,
        lightGray, lightCyan, lightMagenta, lightTurquoise, lightLime,
        lightNavy, lightMaroon, lightTeal, lightGold
    },
    sky = {
        skyRed, skyOrange, skyYellow, skyGreen, skyBlue,
        skyIndigo, skyViolet, skyPink, skyBrown, skyBlack,
        skyGray, skyCyan, skyMagenta, skyTurquoise, skyLime,
        skyNavy, skyMaroon, skyTeal, skyGold
    },
    bw = {Color3.fromRGB(0,0,0), Color3.fromRGB(255,255,255)},
}

local function flattenColors(colorTable)
    local result = {}
    for _, category in pairs(colorTable) do
        for _, color in pairs(category) do
            table.insert(result, color)
        end
    end
    return result
end

colorModes.dark = flattenColors(colorModes.dark)
colorModes.light = flattenColors(colorModes.light)
colorModes.sky = flattenColors(colorModes.sky)

local bioRemote = nil
local colorRemote = nil
local bioColorRemote = nil
local nameRemote = nil

local function findRemotes()
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local name = child.Name
            if name == "UpdateBio" then
                bioRemote = child
                print("✅ Found UpdateBio remote!")
            elseif name == "UpdateBioColor" then
                bioColorRemote = child
                print("✅ Found UpdateBioColor remote!")
            elseif name == "UpdateRPColor" then
                colorRemote = child
                print("✅ Found UpdateRPColor remote!")
            elseif name == "UpdateRPName" then
                nameRemote = child
                print("✅ Found UpdateRPName remote!")
            end
        end
    end
end
findRemotes()

local function applyColor(color)
    if not isActive then return end
    if colorRemote then
        pcall(function()
            colorRemote:FireServer(color)
        end)
    end
    if bioColorRemote then
        pcall(function()
            bioColorRemote:FireServer(color)
        end)
    end
end

local function applyBio(text)
    if not isActive or not bioRemote then return end
    pcall(function()
        bioRemote:FireServer(text)
    end)
end

local function applyName(text)
    if not isActive or not nameRemote then return end
    pcall(function()
        nameRemote:FireServer(text)
    end)
end

local function updateNameList()
    bioLines = {}
    if #customPhrases > 0 then
        for _, v in pairs(customPhrases) do
            if v ~= "" then table.insert(bioLines, v) end
        end
    else
        for _, v in pairs(defaultBioLines) do
            table.insert(bioLines, v)
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

local function setCustomName(name)
    if name ~= "" then
        customName = name
        useCustomName = true
    else
        customName = ""
        useCustomName = false
    end
end

local function startNameType()
    nameLoopRunning = true
    local charIndex = 1
    local currentName = ""
    
    while nameLoopRunning do
        if isActive and nameRemote then
            local targetName
            if useCustomName and customName ~= "" then
                targetName = customName
            else
                targetName = player.DisplayName or player.Name
            end
            
            if charIndex <= #targetName then
                currentName = currentName .. targetName:sub(charIndex, charIndex)
                applyName(currentName)
                charIndex = charIndex + 1
                task.wait(nameTypeSpeed)
            else
                currentName = ""
                charIndex = 1
                applyName("")
            end
        end
        task.wait()
    end
end

local function startBioBlink()
    bioLoopRunning = true
    local phraseIndex = 1
    
    while bioLoopRunning do
        if isActive then
            updateNameList()
            if #bioLines > 0 then
                local currentPhrase = bioLines[phraseIndex]
                if currentPhrase then
                    applyBio(currentPhrase)
                end
                task.wait(flickerSpeed)
                applyBio("")
                task.wait(flickerSpeed)
                phraseIndex = phraseIndex % #bioLines + 1
            end
        end
        task.wait()
    end
end

local function startColorCycle()
    colorLoopRunning = true
    local index = 1
    local colors = colorModes[currentColorMode]
    
    while colorLoopRunning do
        if isActive then
            colors = colorModes[currentColorMode]
            if colors then
                index = index % #colors + 1
                applyColor(colors[index])
            end
        end
        task.wait(colorChangeSpeed)
    end
end

local function startAll()
    if colorThread then colorLoopRunning = false end
    if bioThread then bioLoopRunning = false end
    if nameThread then nameLoopRunning = false end
    task.wait(0.1)
    
    colorLoopRunning = true
    bioLoopRunning = true
    nameLoopRunning = true
    
    colorThread = coroutine.create(startColorCycle)
    bioThread = coroutine.create(startBioBlink)
    nameThread = coroutine.create(startNameType)
    
    coroutine.resume(colorThread)
    coroutine.resume(bioThread)
    coroutine.resume(nameThread)
end

local function stopAll()
    colorLoopRunning = false
    bioLoopRunning = false
    nameLoopRunning = false
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlinkBio"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 45)
mainFrame.Position = UDim2.new(0, 10, 1, -55)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 22)
mainCorner.Parent = mainFrame

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 0, 1, 0)
glow.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
glow.BackgroundTransparency = 0.7
glow.BorderSizePixel = 0
glow.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 22)
glowCorner.Parent = glow

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 30, 1, 0)
icon.Position = UDim2.new(0, 5, 0, 0)
icon.BackgroundTransparency = 1
icon.Text = "⚡"
icon.TextColor3 = Color3.fromRGB(255, 255, 255)
icon.TextSize = 20
icon.Font = Enum.Font.GothamBold
icon.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 32)
toggleBtn.Position = UDim2.new(0.28, 0, 0.14, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 16)
toggleCorner.Parent = toggleBtn

local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0, 45, 0, 32)
colorBtn.Position = UDim2.new(0.56, 0, 0.14, 0)
colorBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
colorBtn.Text = "🎨"
colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
colorBtn.TextSize = 16
colorBtn.Font = Enum.Font.GothamBold
colorBtn.BorderSizePixel = 0
colorBtn.Parent = mainFrame

local colorCorner = Instance.new("UICorner")
colorCorner.CornerRadius = UDim.new(0, 16)
colorCorner.Parent = colorBtn

local phraseBtn = Instance.new("TextButton")
phraseBtn.Size = UDim2.new(0, 45, 0, 32)
phraseBtn.Position = UDim2.new(0.8, 0, 0.14, 0)
phraseBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
phraseBtn.Text = "📝"
phraseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
phraseBtn.TextSize = 16
phraseBtn.Font = Enum.Font.GothamBold
phraseBtn.BorderSizePixel = 0
phraseBtn.Parent = mainFrame

local phraseCornerBtn = Instance.new("UICorner")
phraseCornerBtn.CornerRadius = UDim.new(0, 16)
phraseCornerBtn.Parent = phraseBtn

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 12)
statusText.Position = UDim2.new(0, 0, 0.7, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "⚡ FAST"
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
statusText.TextSize = 7
statusText.Font = Enum.Font.Gotham
statusText.Parent = mainFrame

local phraseSelectorGui = Instance.new("ScreenGui")
phraseSelectorGui.Name = "PhraseSelector"
phraseSelectorGui.Parent = CoreGui
phraseSelectorGui.Enabled = false

local phraseFrame = Instance.new("Frame")
phraseFrame.Size = UDim2.new(0, 380, 0, 480)
phraseFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
phraseFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
phraseFrame.BackgroundTransparency = 0.05
phraseFrame.BorderSizePixel = 0
phraseFrame.Parent = phraseSelectorGui

local phraseCorner = Instance.new("UICorner")
phraseCorner.CornerRadius = UDim.new(0, 14)
phraseCorner.Parent = phraseFrame

local phraseTitle = Instance.new("Frame")
phraseTitle.Size = UDim2.new(1, 0, 0, 40)
phraseTitle.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
phraseTitle.BorderSizePixel = 0
phraseTitle.Parent = phraseFrame

local phraseTitleCorner = Instance.new("UICorner")
phraseTitleCorner.CornerRadius = UDim.new(0, 14)
phraseTitleCorner.Parent = phraseTitle

local phraseTitleText = Instance.new("TextLabel")
phraseTitleText.Size = UDim2.new(1, -50, 1, 0)
phraseTitleText.Position = UDim2.new(0, 15, 0, 0)
phraseTitleText.BackgroundTransparency = 1
phraseTitleText.Text = "⚡ PHRASES & SPEED"
phraseTitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
phraseTitleText.TextSize = 14
phraseTitleText.Font = Enum.Font.GothamBold
phraseTitleText.TextXAlignment = Enum.TextXAlignment.Left
phraseTitleText.Parent = phraseTitle

local phraseCloseBtn = Instance.new("TextButton")
phraseCloseBtn.Size = UDim2.new(0, 35, 0, 30)
phraseCloseBtn.Position = UDim2.new(1, -42, 0.5, -15)
phraseCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
phraseCloseBtn.Text = "✕"
phraseCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
phraseCloseBtn.TextSize = 14
phraseCloseBtn.Font = Enum.Font.GothamBold
phraseCloseBtn.BorderSizePixel = 0
phraseCloseBtn.Parent = phraseTitle

local phraseCloseCorner = Instance.new("UICorner")
phraseCloseCorner.CornerRadius = UDim.new(0, 8)
phraseCloseCorner.Parent = phraseCloseBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 18)
speedLabel.Position = UDim2.new(0.05, 0, 0, 48)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⚡ BLINK SPEED: 0.001s (LIGHTNING!)"
speedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = phraseFrame

local speedSliderBg = Instance.new("Frame")
speedSliderBg.Size = UDim2.new(0.85, 0, 0, 4)
speedSliderBg.Position = UDim2.new(0.08, 0, 0, 70)
speedSliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
speedSliderBg.BorderSizePixel = 0
speedSliderBg.Parent = phraseFrame

local speedSliderFill = Instance.new("Frame")
local speedPct = (flickerSpeed - 0.0005) / (0.50 - 0.0005)
speedSliderFill.Size = UDim2.new(speedPct, 0, 1, 0)
speedSliderFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
speedSliderFill.BorderSizePixel = 0
speedSliderFill.Parent = speedSliderBg

local speedKnob = Instance.new("Frame")
speedKnob.Size = UDim2.new(0, 14, 0, 14)
speedKnob.AnchorPoint = Vector2.new(0.5, 0.5)
speedKnob.Position = UDim2.new(speedPct, 0, 0.5, 0)
speedKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedKnob.BorderSizePixel = 0
speedKnob.Parent = speedSliderBg

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 7)
speedCorner.Parent = speedKnob

local speedValueText = Instance.new("TextLabel")
speedValueText.Size = UDim2.new(0.5, 0, 0, 16)
speedValueText.Position = UDim2.new(0.05, 0, 0, 78)
speedValueText.BackgroundTransparency = 1
speedValueText.Text = "0.0005s (⚡) | 0.50s (SLOW)"
speedValueText.TextColor3 = Color3.fromRGB(150, 150, 180)
speedValueText.TextSize = 8
speedValueText.Font = Enum.Font.Gotham
speedValueText.TextXAlignment = Enum.TextXAlignment.Left
speedValueText.Parent = phraseFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0.9, 0, 0, 16)
nameLabel.Position = UDim2.new(0.05, 0, 0, 102)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "✏️ CUSTOM NAME (leave empty for display name)"
nameLabel.TextColor3 = Color3.fromRGB(255, 200, 150)
nameLabel.TextSize = 9
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = phraseFrame

local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(0.9, 0, 0, 28)
nameInput.Position = UDim2.new(0.05, 0, 0, 122)
nameInput.PlaceholderText = player.DisplayName or player.Name
nameInput.Text = ""
nameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.TextSize = 11
nameInput.Font = Enum.Font.Gotham
nameInput.ClearTextOnFocus = false
nameInput.Parent = phraseFrame

local nameInputCorner = Instance.new("UICorner")
nameInputCorner.CornerRadius = UDim.new(0, 8)
nameInputCorner.Parent = nameInput

local setNameBtn = Instance.new("TextButton")
setNameBtn.Size = UDim2.new(0.4, 0, 0, 25)
setNameBtn.Position = UDim2.new(0.3, 0, 0, 155)
setNameBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
setNameBtn.Text = "✅ SET NAME"
setNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setNameBtn.TextSize = 10
setNameBtn.Font = Enum.Font.GothamBold
setNameBtn.Parent = phraseFrame

local setNameCorner = Instance.new("UICorner")
setNameCorner.CornerRadius = UDim.new(0, 8)
setNameCorner.Parent = setNameBtn

setNameBtn.MouseButton1Click:Connect(function()
    local input = nameInput.Text
    if input ~= "" then
        setCustomName(input)
        statusText.Text = "✅ Custom name set!"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(1, function()
            if isActive then
                statusText.Text = "⚡ FAST"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    else
        setCustomName("")
        statusText.Text = "✅ Using display name!"
        statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        task.delay(1, function()
            if isActive then
                statusText.Text = "⚡ FAST"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    end
end)

local instrLabel = Instance.new("TextLabel")
instrLabel.Size = UDim2.new(0.9, 0, 0, 16)
instrLabel.Position = UDim2.new(0.05, 0, 0, 190)
instrLabel.BackgroundTransparency = 1
instrLabel.Text = "📝 BIO PHRASES (separate with commas)"
instrLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
instrLabel.TextSize = 9
instrLabel.Font = Enum.Font.Gotham
instrLabel.TextXAlignment = Enum.TextXAlignment.Left
instrLabel.Parent = phraseFrame

local phraseInput = Instance.new("TextBox")
phraseInput.Size = UDim2.new(0.9, 0, 0, 55)
phraseInput.Position = UDim2.new(0.05, 0, 0, 210)
phraseInput.PlaceholderText = "HELLO, WORLD, COOL"
phraseInput.Text = ""
phraseInput.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
phraseInput.TextColor3 = Color3.fromRGB(255, 255, 255)
phraseInput.TextSize = 11
phraseInput.Font = Enum.Font.Gotham
phraseInput.ClearTextOnFocus = false
phraseInput.TextWrapped = true
phraseInput.Parent = phraseFrame

local phraseInputCorner = Instance.new("UICorner")
phraseInputCorner.CornerRadius = UDim.new(0, 8)
phraseInputCorner.Parent = phraseInput

local addPhraseBtn = Instance.new("TextButton")
addPhraseBtn.Size = UDim2.new(0.9, 0, 0, 30)
addPhraseBtn.Position = UDim2.new(0.05, 0, 0, 272)
addPhraseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
addPhraseBtn.Text = "➕ ADD BIO PHRASES"
addPhraseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addPhraseBtn.TextSize = 11
addPhraseBtn.Font = Enum.Font.GothamBold
addPhraseBtn.Parent = phraseFrame

local addPhraseCorner = Instance.new("UICorner")
addPhraseCorner.CornerRadius = UDim.new(0, 8)
addPhraseCorner.Parent = addPhraseBtn

addPhraseBtn.MouseButton1Click:Connect(function()
    local input = phraseInput.Text
    if input ~= "" then
        addCustomPhrases(input)
        phraseInput.Text = ""
        statusText.Text = "✅ Phrases added!"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(1, function()
            if isActive then
                statusText.Text = "⚡ FAST"
                statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end)
    end
end)

local clearPhraseBtn = Instance.new("TextButton")
clearPhraseBtn.Size = UDim2.new(0.9, 0, 0, 28)
clearPhraseBtn.Position = UDim2.new(0.05, 0, 0, 308)
clearPhraseBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
clearPhraseBtn.Text = "🗑️ CLEAR BIO PHRASES"
clearPhraseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearPhraseBtn.TextSize = 10
clearPhraseBtn.Font = Enum.Font.GothamBold
clearPhraseBtn.Parent = phraseFrame

local clearPhraseCorner = Instance.new("UICorner")
clearPhraseCorner.CornerRadius = UDim.new(0, 8)
clearPhraseCorner.Parent = clearPhraseBtn

clearPhraseBtn.MouseButton1Click:Connect(function()
    clearCustomPhrases()
    statusText.Text = "🗑️ Cleared!"
    statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
    task.delay(1, function()
        if isActive then
            statusText.Text = "⚡ FAST"
            statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
end)

local currentPhrasesLabel = Instance.new("TextLabel")
currentPhrasesLabel.Size = UDim2.new(0.9, 0, 0, 25)
currentPhrasesLabel.Position = UDim2.new(0.05, 0, 0, 342)
currentPhrasesLabel.BackgroundTransparency = 1
currentPhrasesLabel.Text = "Current Bio: LEGEND on top"
currentPhrasesLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
currentPhrasesLabel.TextSize = 8
currentPhrasesLabel.Font = Enum.Font.Gotham
currentPhrasesLabel.TextWrapped = true
currentPhrasesLabel.Parent = phraseFrame

local speedDragging = false

local function updateSpeed(posX)
    if not speedSliderBg.AbsolutePosition then return end
    local pct = math.clamp((posX - speedSliderBg.AbsolutePosition.X) / speedSliderBg.AbsoluteSize.X, 0, 1)
    speedSliderFill.Size = UDim2.new(pct, 0, 1, 0)
    speedKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    flickerSpeed = math.floor((0.0005 + pct * (0.50 - 0.0005)) * 10000) / 10000
    speedLabel.Text = "⚡ BLINK SPEED: " .. string.format("%.4f", flickerSpeed) .. "s"
end

speedSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        speedDragging = true
        updateSpeed(i.Position.X)
    end
end)

speedKnob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        speedDragging = true
        updateSpeed(i.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if speedDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        updateSpeed(i.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        speedDragging = false
    end
end)

local colorSelectorGui = Instance.new("ScreenGui")
colorSelectorGui.Name = "ColorSelector"
colorSelectorGui.Parent = CoreGui
colorSelectorGui.Enabled = false

local selectorFrame = Instance.new("Frame")
selectorFrame.Size = UDim2.new(0, 320, 0, 350)
selectorFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
selectorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
selectorFrame.BackgroundTransparency = 0.05
selectorFrame.BorderSizePixel = 0
selectorFrame.Parent = colorSelectorGui

local selectorCorner = Instance.new("UICorner")
selectorCorner.CornerRadius = UDim.new(0, 14)
selectorCorner.Parent = selectorFrame

local selectorTitle = Instance.new("Frame")
selectorTitle.Size = UDim2.new(1, 0, 0, 40)
selectorTitle.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
selectorTitle.BorderSizePixel = 0
selectorTitle.Parent = selectorFrame

local selectorTitleCorner = Instance.new("UICorner")
selectorTitleCorner.CornerRadius = UDim.new(0, 14)
selectorTitleCorner.Parent = selectorTitle

local selectorTitleText = Instance.new("TextLabel")
selectorTitleText.Size = UDim2.new(1, -50, 1, 0)
selectorTitleText.Position = UDim2.new(0, 15, 0, 0)
selectorTitleText.BackgroundTransparency = 1
selectorTitleText.Text = "🎨 COLOR MODES"
selectorTitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
selectorTitleText.TextSize = 14
selectorTitleText.Font = Enum.Font.GothamBold
selectorTitleText.TextXAlignment = Enum.TextXAlignment.Left
selectorTitleText.Parent = selectorTitle

local closeSelectorBtn = Instance.new("TextButton")
closeSelectorBtn.Size = UDim2.new(0, 35, 0, 30)
closeSelectorBtn.Position = UDim2.new(1, -42, 0.5, -15)
closeSelectorBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeSelectorBtn.Text = "✕"
closeSelectorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeSelectorBtn.TextSize = 14
closeSelectorBtn.Font = Enum.Font.GothamBold
closeSelectorBtn.BorderSizePixel = 0
closeSelectorBtn.Parent = selectorTitle

local closeSelectorCorner = Instance.new("UICorner")
closeSelectorCorner.CornerRadius = UDim.new(0, 8)
closeSelectorCorner.Parent = closeSelectorBtn

local colorButtons = {
    {name = "🌈 ALL COLORS", mode = "all", color = Color3.fromRGB(255,100,150)},
    {name = "🌑 DARK COLORS", mode = "dark", color = Color3.fromRGB(30,30,30)},
    {name = "☀️ LIGHT COLORS", mode = "light", color = Color3.fromRGB(255,255,220)},
    {name = "☁️ SKY COLORS", mode = "sky", color = Color3.fromRGB(200,230,255)},
    {name = "⚫⚪ B&W", mode = "bw", color = Color3.fromRGB(100,100,100)},
}

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #colorButtons * 55 + 10)
scrollFrame.ScrollBarThickness = 3
scrollFrame.Parent = selectorFrame

local scrollList = Instance.new("UIListLayout")
scrollList.Padding = UDim.new(0, 8)
scrollList.Parent = scrollFrame

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingLeft = UDim.new(0, 10)
scrollPadding.PaddingRight = UDim.new(0, 10)
scrollPadding.PaddingTop = UDim.new(0, 10)
scrollPadding.Parent = scrollFrame

for _, btnData in pairs(colorButtons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = btnData.color
    btn.Text = btnData.name
    btn.TextColor3 = btnData.mode == "dark" and Color3.fromRGB(255,255,255) or Color3.fromRGB(255,255,255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentColorMode = btnData.mode
        colorSelectorGui.Enabled = false
        statusText.Text = btnData.name
        statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        task.delay(1.5, function()
            if isActive then
                statusText.Text = "⚡ FAST"
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
    local currentText = #customPhrases > 0 and table.concat(customPhrases, ", ") or "LEGEND on top"
    currentPhrasesLabel.Text = "Current Bio: " .. currentText
    nameInput.PlaceholderText = useCustomName and customName or (player.DisplayName or player.Name)
end)

phraseCloseBtn.MouseButton1Click:Connect(function()
    phraseSelectorGui.Enabled = false
end)

local function setActive(active)
    isActive = active
    
    if active then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        toggleBtn.Text = "ON"
        statusText.Text = "⚡ FAST"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        mainFrame.BackgroundTransparency = 0.1
        glow.BackgroundTransparency = 0.7
        startAll()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        toggleBtn.Text = "OFF"
        statusText.Text = "OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
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

print("⚡ ULTRA FAST BIO FLICKER LOADED!")
print("📝 Default Bio: LEGEND on top")
print("⚡ Speed: 0.001s (LIGHTNING FAST!)")
print("🎨 300+ Colors")
print("🔑 L = Hide/Show GUI")
