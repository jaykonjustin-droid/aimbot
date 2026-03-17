-- Flux Cheats v1.1 - Aimbot 60% + FOV Circle + Menú flotante + Teclas X/Y
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/jaykonjustin-droid/aimbot/main/flux_cheats.lua"))()

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Camera        = workspace.CurrentCamera
local LocalPlayer   = Players.LocalPlayer

-- Config
local Settings = {
    AimbotEnabled   = false,
    FOV             = 150,
    Smoothness      = 0.6,       -- 60%
    AimPart         = "Head",    -- o "HumanoidRootPart"
    TeamCheck       = true,      -- No apunta a teammates
    VisibleCheck    = true       -- Solo si está visible (no walls por ahora)
}

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness   = 2
fovCircle.Color       = Color3.fromRGB(255, 50, 50)
fovCircle.Transparency= 0.65
fovCircle.NumSides    = 100
fovCircle.Radius      = Settings.FOV
fovCircle.Filled      = false
fovCircle.Visible     = false

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluxCheatsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Menú principal (oculto al inicio)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 200)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Flux Cheats v1.1"
Title.TextColor3 = Color3.fromRGB(0, 255, 140)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.Parent = MainFrame

local ToggleAimbot = Instance.new("TextButton")
ToggleAimbot.Size = UDim2.new(0.85, 0, 0, 45)
ToggleAimbot.Position = UDim2.new(0.075, 0, 0.28, 0)
ToggleAimbot.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleAimbot.Text = "Aimbot: OFF"
ToggleAimbot.TextColor3 = Color3.new(1,1,1)
ToggleAimbot.Font = Enum.Font.GothamBold
ToggleAimbot.TextSize = 18
ToggleAimbot.Parent = MainFrame
Instance.new("UICorner", ToggleAimbot).CornerRadius = UDim.new(0, 10)

ToggleAimbot.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    ToggleAimbot.Text = "Aimbot: " .. (Settings.AimbotEnabled and "ON" or "OFF")
    ToggleAimbot.BackgroundColor3 = Settings.AimbotEnabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 35, 35)
    fovCircle.Visible = Settings.AimbotEnabled
end)

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.85, 0, 0, 30)
FOVLabel.Position = UDim2.new(0.075, 0, 0.55, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. Settings.FOV .. " | Smooth: 60%"
FOVLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 15
FOVLabel.Parent = MainFrame

-- Botón flotante circular (para abrir menú)
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 60, 0, 60)
FloatButton.Position = UDim2.new(1, -80, 1, -90)
FloatButton.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
FloatButton.Text = "F"
FloatButton.TextColor3 = Color3.new(0,0,0)
FloatButton.Font = Enum.Font.GothamBlack
FloatButton.TextSize = 32
FloatButton.AutoButtonColor = false
FloatButton.Parent = ScreenGui
local floatCorner = Instance.new("UICorner", FloatButton)
floatCorner.CornerRadius = UDim.new(1, 0)  -- círculo perfecto
local uiStroke = Instance.new("UIStroke", FloatButton)
uiStroke.Color = Color3.fromRGB(0, 255, 140)
uiStroke.Thickness = 2
uiStroke.Transparency = 0.4

FloatButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Drag para menú principal
local dragging, dragStart, startPos
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
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Teclas rápidas
UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        -- Ocultar / mostrar todo
        local visible = not MainFrame.Visible and not FloatButton.Visible
        MainFrame.Visible = visible
        FloatButton.Visible = visible
    end
    
    if input.KeyCode == Enum.KeyCode.Y then
        -- Toggle aimbot rápido
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        ToggleAimbot.Text = "Aimbot: " .. (Settings.AimbotEnabled and "ON" or "OFF")
        ToggleAimbot.BackgroundColor3 = Settings.AimbotEnabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(35, 35, 35)
        fovCircle.Visible = Settings.AimbotEnabled
    end
end)

-- ===================== AIMBOT LOGIC =====================
RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    fovCircle.Position = center
    fovCircle.Radius = Settings.FOV
    
    if not Settings.AimbotEnabled then return end
    
    local closest, minDist = nil, math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local char = player.Character
        local part = char:FindFirstChild(Settings.AimPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < Settings.FOV and dist < minDist then
            minDist = dist
            closest = part
        end
    end
    
    if closest then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
    end
end)

print("Flux Cheats v1.1 cargado!  X = ocultar/mostrar menú  |  Y = toggle aimbot rápido")
