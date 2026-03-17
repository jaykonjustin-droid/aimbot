-- Flux Cheats v1.0 - Aimbot 60% con FOV básico y menú GUI
-- Uso: pega en executor (Fluxus, Solara, Delta, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AIMBOT_ENABLED = false
local FOV = 150
local SMOOTHNESS = 0.6

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.NumSides = 64
fovCircle.Radius = FOV
fovCircle.Visible = true

-- GUI Flux Cheats
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluxCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Flux Cheats"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 26
Title.Parent = MainFrame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.8, 0, 0, 45)
Toggle.Position = UDim2.new(0.1, 0, 0.25, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Toggle.Text = "Aimbot: OFF"
Toggle.TextColor3 = Color3.white
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 20
Toggle.Parent = MainFrame
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

Toggle.MouseButton1Click:Connect(function()
    AIMBOT_ENABLED = not AIMBOT_ENABLED
    Toggle.Text = "Aimbot: " .. (AIMBOT_ENABLED and "ON" or "OFF")
    Toggle.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 45)
end)

-- Labels info
local Info1 = Instance.new("TextLabel")
Info1.Size = UDim2.new(0.8, 0, 0, 25)
Info1.Position = UDim2.new(0.1, 0, 0.48, 0)
Info1.BackgroundTransparency = 1
Info1.Text = "FOV: 150 px | Smooth: 60%"
Info1.TextColor3 = Color3.fromRGB(180, 180, 180)
Info1.Font = Enum.Font.Gotham
Info1.TextSize = 15
Info1.Parent = MainFrame

-- Close button
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -38, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
Close.Text = "X"
Close.TextColor3 = Color3.white
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.Parent = MainFrame
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    fovCircle:Remove()
end)

-- Drag
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Aimbot logic
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius = FOV

    if not AIMBOT_ENABLED then return end

    local closest, distMin = nil, math.huge

    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, visible = Camera:WorldToViewportPoint(root.Position)
                if visible then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance < FOV and distance < distMin then
                        distMin = distance
                        closest = player
                    end
                end
            end
        end
    end

    if closest and closest.Character then
        local head = closest.Character:FindFirstChild("Head") or closest.Character.HumanoidRootPart
        if head then
            local targetCF = CFrame.new(Camera.CFrame.Position, head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, SMOOTHNESS)
        end
    end
end)

print("Flux Cheats cargado! Toggle con el menú.")
