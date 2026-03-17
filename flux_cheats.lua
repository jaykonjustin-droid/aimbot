-- Flux Cheats v1.3 - Aimbot MÁS FUERTE (75% smooth + prediction) + FOV 220 + Menú con X/Y
-- Repo: https://github.com/jaykonjustin-droid/aimbot
-- Loadstring:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/jaykonjustin-droid/aimbot/main/flux_cheats.lua"))()

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local Camera        = workspace.CurrentCamera
local LocalPlayer   = Players.LocalPlayer

-- Configuración (más agresivo)
local Settings = {
    Enabled     = false,
    FOV         = 220,           -- Más grande para jalar desde lejos
    Smoothness  = 0.75,          -- 75% → se pega más rápido
    AimPart     = "Head",        -- Solo cabeza para precisión
    TeamCheck   = true,
    Prediction  = 0.135,         -- Predicción básica (adelanta movimiento)
}

-- FOV Circle más visible
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness    = 2.5
fovCircle.Color        = Color3.fromRGB(255, 80, 80)
fovCircle.Transparency = 0.45
fovCircle.NumSides     = 100
fovCircle.Radius       = Settings.FOV
fovCircle.Filled       = false
fovCircle.Visible      = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluxCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Menú principal (oculto al inicio)
local MainFrame = Instance.new("Frame")
MainFrame.Size             = UDim2.new(0, 260, 0, 180)
MainFrame.Position         = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel  = 0
MainFrame.Visible          = false
MainFrame.Parent           = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size                 = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text                 = "Flux Cheats v1.3"
Title.TextColor3           = Color3.fromRGB(0, 255, 130)
Title.Font                 = Enum.Font.GothamBlack
Title.TextSize             = 22
Title.Parent               = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size             = UDim2.new(0.88, 0, 0, 40)
ToggleBtn.Position         = UDim2.new(0.06, 0, 0.28, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text             = "Aimbot: OFF"
ToggleBtn.TextColor3       = Color3.new(1,1,1)
ToggleBtn.Font             = Enum.Font.GothamBold
ToggleBtn.TextSize         = 18
ToggleBtn.Parent           = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    ToggleBtn.Text = "Aimbot: " .. (Settings.Enabled and "ON" or "OFF")
    ToggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 40)
    fovCircle.Visible = Settings.Enabled
end)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size                 = UDim2.new(0.88, 0, 0, 25)
InfoLabel.Position             = UDim2.new(0.06, 0, 0.58, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text                 = "FOV: 220 | Smooth: 75% | Prediction ON"
InfoLabel.TextColor3           = Color3.fromRGB(170, 170, 170)
InfoLabel.Font                 = Enum.Font.Gotham
InfoLabel.TextSize             = 14
InfoLabel.Parent               = MainFrame

-- Botón flotante "F"
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size             = UDim2.new(0, 55, 0, 55)
FloatBtn.Position         = UDim2.new(1, -75, 1, -85)
FloatBtn.BackgroundColor3 = Color3.fromRGB(0, 210, 100)
FloatBtn.Text             = "F"
FloatBtn.TextColor3       = Color3.new(0,0,0)
FloatBtn.Font             = Enum.Font.GothamBlack
FloatBtn.TextSize         = 30
FloatBtn.Parent           = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", FloatBtn)
stroke.Color      = Color3.fromRGB(0, 255, 150)
stroke.Thickness  = 2.5
stroke.Transparency = 0.3

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Drag menú
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Teclas
UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        local show = not (MainFrame.Visible or FloatBtn.Visible)
        MainFrame.Visible = show
        FloatBtn.Visible  = show
    end
    if input.KeyCode == Enum.KeyCode.Y then
        Settings.Enabled = not Settings.Enabled
        ToggleBtn.Text = "Aimbot: " .. (Settings.Enabled and "ON" or "OFF")
        ToggleBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(40, 40, 40)
        fovCircle.Visible = Settings.Enabled
    end
end)

-- Aimbot más fuerte con prediction
RunService.RenderStepped:Connect(function(delta)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius   = Settings.FOV

    if not Settings.Enabled then return end

    local closest, minDist = nil, math.huge
    local cameraPos = Camera.CFrame.Position

    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or not plr.Character then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local humanoid = plr.Character:FindFirstChild("Humanoid")
        local part = plr.Character:FindFirstChild(Settings.AimPart)
        if not part or not humanoid then continue end

        local velocity = part.Velocity or Vector3.new()
        local predictedPos = part.Position + (velocity * Settings.Prediction)

        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < Settings.FOV and dist < minDist then
            minDist = dist
            closest = predictedPos
        end
    end

    if closest then
        local targetCFrame = CFrame.new(cameraPos, closest)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
    end
end)

print("Flux Cheats v1.3 cargado! MÁS FUERTE 🔥 | X = ocultar todo | Y = toggle aimbot | Toca 'F' para menú")