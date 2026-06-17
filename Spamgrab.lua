local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local grabEnabled = false
local grabConn = nil
local GrabR = nil

pcall(function()
    GrabR = RS:FindFirstChild("Packages"):FindFirstChild("Knit"):FindFirstChild("Services"):FindFirstChild("CombatService"):FindFirstChild("RF"):FindFirstChild("Grab")
end)

if not GrabR then
    pcall(function()
        local rem = RS:FindFirstChild("Remotes")
        if rem then
            GrabR = rem:FindFirstChild("Grab")
        end
    end)
end

if not GrabR then
    pcall(function()
        for _, child in pairs(RS:GetDescendants()) do
            if child:IsA("RemoteEvent") and (child.Name:lower():find("grab") or child.Name:lower():find("grabspam") or child.Name:lower():find("ragdoll")) then
                GrabR = child
                break
            end
        end
    end)
end

local function doGrab()
    if not GrabR then return end
    local char = player.Character
    if not char then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local closest, closestDist = nil, math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not p.Character then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local hu = p.Character:FindFirstChildOfClass("Humanoid")
        if hrp and hu and hu.Health > 0 then
            local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = p
            end
        end
    end
    
    if closest then
        pcall(function()
            GrabR:InvokeServer(closest)
        end)
    end
end

local function toggleGrab()
    grabEnabled = not grabEnabled
    
    if grabEnabled then
        if grabConn then grabConn:Disconnect() end
        grabConn = RunService.Heartbeat:Connect(function()
            if grabEnabled then
                doGrab()
            end
        end)
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        glow.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        glow.BackgroundTransparency = 0.5
    else
        if grabConn then
            grabConn:Disconnect()
            grabConn = nil
        end
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        glow.BackgroundTransparency = 0.85
    end
end

local sg = Instance.new("ScreenGui")
sg.Name = "SpamGrab"
sg.ResetOnSpawn = false
sg.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 100, 0, 50)
main.Position = UDim2.new(1, -120, 0.5, -25)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = sg
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 16)

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 4, 1, 4)
glow.Position = UDim2.new(0, -2, 0, -2)
glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
glow.BackgroundTransparency = 0.85
glow.BorderSizePixel = 0
glow.Parent = main
local glowCorner = Instance.new("UICorner", glow)
glowCorner.CornerRadius = UDim.new(0, 18)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -30, 0.5, -15)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = main
local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 10)

toggleBtn.MouseButton1Click:Connect(function()
    toggleGrab()
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.G then
        toggleGrab()
    end
end)

local drag = {dragging = false, start = nil, pos = nil}
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag.dragging = true
        drag.start = i.Position
        drag.pos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if drag.dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - drag.start
        main.Position = UDim2.new(
            drag.pos.X.Scale,
            drag.pos.X.Offset + d.X,
            drag.pos.Y.Scale,
            drag.pos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag.dragging = false
    end
end)

print("⚡ Spam Grab Loaded!")
print("📌 Click button or press G to toggle")
print("🎯 Grabs closest player every 0.1s")
