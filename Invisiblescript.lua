if _G.a then
    for _, v in pairs(_G.a) do
        v:Disconnect()
    end;
    _G.a = nil
end;

repeat task.wait() until game.Players.LocalPlayer;
local player = game.Players.LocalPlayer;
local character, humanoid, rootPart;
local isEnabled = false;
local parts = {}

local function updateCharacterData()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    parts = {}
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency == 0 then
            table.insert(parts, v)
        end
    end
end;

local function createStyledGui()
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    sg.Name = "InvisibleGuiSystem"
    sg.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 130, 0, 45)
    btn.Position = UDim2.new(0.5, -65, 0.1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "Invisible"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Active = true

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2

    -- Flowers in corners
    local flowers = {
        {text = "🌸", pos = UDim2.new(0, 4, 0, 4)},
        {text = "🌸", pos = UDim2.new(1, -20, 0, 4)},
        {text = "🌷", pos = UDim2.new(0, 4, 1, -20)},
        {text = "🌷", pos = UDim2.new(1, -20, 1, -20)}
    }
    
    for _, f in pairs(flowers) do
        local fl = Instance.new("TextLabel", btn)
        fl.Size = UDim2.new(0, 16, 0, 16)
        fl.Position = f.pos
        fl.BackgroundTransparency = 1
        fl.Text = f.text
        fl.TextSize = 12
        fl.TextColor3 = Color3.fromRGB(255, 150, 200)
        fl.Font = Enum.Font.Gotham
        fl.TextXAlignment = Enum.TextXAlignment.Center
        fl.TextYAlignment = Enum.TextYAlignment.Center
    end

    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local function toggle()
        isEnabled = not isEnabled;
        stroke.Color = isEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        btn.TextColor3 = isEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
        btn.Text = isEnabled and "👻 Invisible" or "Invisible"
        for _, v in pairs(parts) do
            v.Transparency = isEnabled and 0.5 or 0
        end
    end

    btn.MouseButton1Click:Connect(toggle)
    return toggle
end;

updateCharacterData()
local toggleFunc = createStyledGui()

local h = {}
h[1] = player:GetMouse().KeyDown:Connect(function(key)
    if key == "g" then
        toggleFunc()
    end
end)

h[2] = game:GetService("RunService").Heartbeat:Connect(function()
    if isEnabled and rootPart and humanoid then
        local oldCF = rootPart.CFrame;
        local oldOffset = humanoid.CameraOffset;
        local hideCF = oldCF * CFrame.new(0, -200000, 0)
        
        rootPart.CFrame = hideCF;
        humanoid.CameraOffset = hideCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position;
        game:GetService("RunService").RenderStepped:Wait()
        rootPart.CFrame = oldCF;
        humanoid.CameraOffset = oldOffset;
    end
end)

player.CharacterAdded:Connect(function()
    isEnabled = false;
    task.wait(1)
    updateCharacterData()
end)

_G.a = h
