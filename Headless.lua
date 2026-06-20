local function headless()
    pcall(function()
        local args = {{["Property"] = "Head", ["AssetId"] = 15093053680}}
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("CatalogOnApplyToRealHumanoid", true)
        if remote then
            remote:FireServer(unpack(args))
        else
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then
                    if v.Name:lower():find("catalog") or v.Name:lower():find("apply") or v.Name:lower():find("humanoid") then
                        pcall(function()
                            v:FireServer(unpack(args))
                        end)
                        break
                    end
                end
            end
        end
    end)
end

headless()
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    headless()
end)
