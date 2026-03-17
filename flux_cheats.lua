-- Flux Cheats v1.7 FINAL - Aimbot + ESP + Chams + Tracers + Silent + Menu Tabs Rayo
-- Repo: https://github.com/jaykonjustin-droid/aimbot
-- Loadstring: loadstring(game:HttpGet("https://raw.githubusercontent.com/jaykonjustin-droid/aimbot/main/flux_cheats.lua"))()

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Camera        = workspace.CurrentCamera
local LocalPlayer   = Players.LocalPlayer
local Mouse         = LocalPlayer:GetMouse()

-- ==================== CONFIG ====================
local Settings = {
    AimbotEnabled   = false,
    SilentEnabled   = false,
    ESPEnabled      = false,
    ChamsEnabled    = false,
    TracersEnabled  = false,
    SpeedEnabled    = false,
    FPSUnlock       = false,
    MouseLocked     = false,
    StreamProof     = false,
    ForceLook       = false,
    FOV             = 220,
    Smoothness      = 0.75,
    Prediction      = 0.135,
    WalkSpeed       = 16,
    AimPart         = "Head",
    TeamCheck       = true,
    FOVColor        = Color3.fromRGB(255, 80, 80),
    Language        = "Español"
}

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2.5
fovCircle.Color = Settings.FOVColor
fovCircle.Transparency = 0.45
fovCircle.NumSides = 100
fovCircle.Radius = Settings.FOV
fovCircle.Filled = false
fovCircle.Visible = false

-- ESP Tables
local ESP_Objects = {}
local ChamsHighlights = {}
local Tracers = {}

-- ==================== CREATE ESP ====================
local function CreateESP(plr)
    if plr == LocalPlayer or ESP_Objects[plr] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 0.8
    Box.Color = Color3.fromRGB(255, 0, 0)

    local NameText = Drawing.new("Text")
    NameText.Size = 14
    NameText.Center = true
    NameText.Outline = true
    NameText.Color = Color3.fromRGB(255, 255, 255)
    NameText.Font = Drawing.Fonts.UI

    local HealthBar = Drawing.new("Line")
    HealthBar.Thickness = 3
    HealthBar.Color = Color3.fromRGB(0, 255, 0)
    HealthBar.Transparency = 0.7

    local SkeletonLines = {}
    for i = 1, 10 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Color3.fromRGB(0, 255, 255)
        line.Transparency = 0.6
        table.insert(SkeletonLines, line)
    end

    ESP_Objects[plr] = {Box = Box, Name = NameText, Health = HealthBar, Skeleton = SkeletonLines}
end

-- ==================== UPDATE ESP ====================
local function UpdateESP()
    if not Settings.ESPEnabled then
        for _, obj in pairs(ESP_Objects) do
            for k, v in pairs(obj) do
                if type(v) == "table" then
                    for _, l in ipairs(v) do l.Visible = false end
                else
                    v.Visible = false
                end
            end
        end
        return
    end

    for plr, drawings in pairs(ESP_Objects) do
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or not plr.Character:FindFirstChild("HumanoidRootPart") then
            for k, v in pairs(drawings) do
                if type(v) == "table" then for _, l in ipairs(v) do l.Visible = false end
                else v.Visible = false end
            end
            continue
        end

        local humanoid = plr.Character.Humanoid
        local root = plr.Character.HumanoidRootPart
        local head = plr.Character:FindFirstChild("Head")

        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
        local bottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local size = Vector2.new(math.abs(top.X - bottom.X) * 2, math.abs(top.Y - bottom.Y) * 1.5)
        local pos = Vector2.new(rootPos.X - size.X / 2, top.Y)

        drawings.Box.Size = size
        drawings.Box.Position = pos
        drawings.Box.Visible = true

        local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
        drawings.Name.Text = string.format("%s [%d HP] [%.0f studs]", plr.Name, math.floor(humanoid.Health), dist)
        drawings.Name.Position = Vector2.new(pos.X + size.X / 2, pos.Y - 20)
        drawings.Name.Visible = true

        local healthPct = humanoid.Health / humanoid.MaxHealth
        drawings.Health.From = Vector2.new(pos.X - 6, pos.Y + size.Y)
        drawings.Health.To = Vector2.new(pos.X - 6, pos.Y + size.Y * (1 - healthPct))
        drawings.Health.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
        drawings.Health.Visible = true

        local function WorldToScreen(pos)
            local v, vis = Camera:WorldToViewportPoint(pos)
            return Vector2.new(v.X, v.Y), vis
        end

        local skel = drawings.Skeleton
        local parts = {
            {head, root},
            {root, plr.Character:FindFirstChild("Left Arm") or root},
            {root, plr.Character:FindFirstChild("Right Arm") or root},
            {root, plr.Character:FindFirstChild("Left Leg") or root},
            {root, plr.Character:FindFirstChild("Right Leg") or root},
        }

        for i, pair in ipairs(parts) do
            if pair[1] and pair[2] then
                local p1, v1 = WorldToScreen(pair[1].Position)
                local p2, v2 = WorldToScreen(pair[2].Position)
                if v1 and v2 then
                    skel[i].From = p1
                    skel[i].To = p2
                    skel[i].Visible = true
                else
                    skel[i].Visible = false
                end
            end
        end
    end
end

-- ==================== CHAMS ====================
local function CreateChams(plr)
    if plr == LocalPlayer or ChamsHighlights[plr] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0.05
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = plr.Character
    highlight.Parent = plr.Character
    highlight.Enabled = false
    ChamsHighlights[plr] = highlight
end

local function UpdateChams()
    if not Settings.ChamsEnabled then
        for _, hl in pairs(ChamsHighlights) do hl.Enabled = false end
        return
    end
    for plr, hl in pairs(ChamsHighlights) do
        if not plr.Character then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
            hl.Enabled = false
            continue
        end
        hl.Adornee = plr.Character
        hl.Enabled = true
    end
end

-- ==================== TRACERS ====================
local function CreateTracer(plr)
    if Tracers[plr] then return end
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Transparency = 0.5
    Tracers[plr] = line
end

local function UpdateTracers()
    if not Settings.TracersEnabled then
        for _, line in pairs(Tracers) do line.Visible = false end
        return
    end
    for plr, line in pairs(Tracers) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            line.Visible = false
            continue
        end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
            line.Visible = false
            continue
        end
        local root = plr.Character.HumanoidRootPart
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            line.Visible = false
            continue
        end
        line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
        line.To = Vector2.new(rootPos.X, rootPos.Y)
        line.Visible = true
    end
end

-- ==================== SILENT AIM ====================
local function SilentAim()
    if not Settings.SilentEnabled then return end
    local target = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or not plr.Character then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local part = plr.Character:FindFirstChild(Settings.AimPart)
        if not part then continue end
        local pos, vis = Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < Settings.FOV and dist < minDist then
            minDist = dist
            target = part
        end
    end

    if target then
        Mouse.Hit = CFrame.new(target.Position)
    end
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluxCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 460)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local glow = Instance.new("UIStroke", MainFrame)
glow.Color = Color3.fromRGB(0, 255, 180)
glow.Thickness = 2
glow.Transparency = 0.6

local function OpenMenu()
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -230 + 80)
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -170, 0.5, -230)}):Play()
end

local function CloseMenu()
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -170, 0.5, -230 - 80)}):Play()
    task.delay(0.4, function() MainFrame.Visible = false end)
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "FLUX CHEATS v1.7"
Title.TextColor3 = Color3.fromRGB(0, 255, 140)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 28
Title.Parent = MainFrame

-- Tabs
local TabAimbot = Instance.new("TextButton")
TabAimbot.Size = UDim2.new(0.25, 0, 0, 40)
TabAimbot.Position = UDim2.new(0, 0, 0.12, 0)
TabAimbot.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
TabAimbot.Text = "Aimbot"
TabAimbot.TextColor3 = Color3.new(1,1,1)
TabAimbot.Font = Enum.Font.GothamBold
TabAimbot.TextSize = 18
TabAimbot.Parent = MainFrame
Instance.new("UICorner", TabAimbot).CornerRadius = UDim.new(0, 10)

local TabVisual = Instance.new("TextButton")
TabVisual.Size = UDim2.new(0.25, 0, 0, 40)
TabVisual.Position = UDim2.new(0.25, 0, 0.12, 0)
TabVisual.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabVisual.Text = "Visual"
TabVisual.TextColor3 = Color3.new(1,1,1)
TabVisual.Font = Enum.Font.GothamBold
TabVisual.TextSize = 18
TabVisual.Parent = MainFrame
Instance.new("UICorner", TabVisual).CornerRadius = UDim.new(0, 10)

local TabMisc = Instance.new("TextButton")
TabMisc.Size = UDim2.new(0.25, 0, 0, 40)
TabMisc.Position = UDim2.new(0.5, 0, 0.12, 0)
TabMisc.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabMisc.Text = "Misc"
TabMisc.TextColor3 = Color3.new(1,1,1)
TabMisc.Font = Enum.Font.GothamBold
TabMisc.TextSize = 18
TabMisc.Parent = MainFrame
Instance.new("UICorner", TabMisc).CornerRadius = UDim.new(0, 10)

local TabConfig = Instance.new("TextButton")
TabConfig.Size = UDim2.new(0.25, 0, 0, 40)
TabConfig.Position = UDim2.new(0.75, 0, 0.12, 0)
TabConfig.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabConfig.Text = "Config"
TabConfig.TextColor3 = Color3.new(1,1,1)
TabConfig.Font = Enum.Font.GothamBold
TabConfig.TextSize = 18
TabConfig.Parent = MainFrame
Instance.new("UICorner", TabConfig).CornerRadius = UDim.new(0, 10)

-- Toggle Aimbot (ejemplo contenido)
local ToggleAimbot = Instance.new("TextButton")
ToggleAimbot.Size = UDim2.new(0.9, 0, 0, 45)
ToggleAimbot.Position = UDim2.new(0.05, 0, 0.20, 0)
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
    ToggleAimbot.BackgroundColor3 = Settings.AimbotEnabled and Color3.fromRGB(0, 190, 90) or Color3.fromRGB(35, 35, 35)
    fovCircle.Visible = Settings.AimbotEnabled
end)

-- (Aquí puedes agregar más toggles como ToggleESP, ToggleChams, ToggleSilent, etc. en las posiciones que quieras)

-- Botón flotante logo Flux
local FloatBtn = Instance.new("ImageButton")
FloatBtn.Size = UDim2.new(0, 70, 0, 70)
FloatBtn.Position = UDim2.new(1, -90, 1, -100)
FloatBtn.BackgroundTransparency = 1
FloatBtn.Image = "https://cdn.discordapp.com/avatars/1373412241227120792/6d5e593df0314df5e465f4e177c09be1.png?size=4096"
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local floatStroke = Instance.new("UIStroke", FloatBtn)
floatStroke.Color = Color3.fromRGB(0, 255, 150)
floatStroke.Thickness = 3
floatStroke.Transparency = 0.4

FloatBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then CloseMenu() else OpenMenu() end
end)

-- Botón Discord izquierda
local DiscordBtn = Instance.new("ImageButton")
DiscordBtn.Size = UDim2.new(0, 50, 0, 50)
DiscordBtn.Position = UDim2.new(0, 20, 1, -80)
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.Image = "https://cdn.discordapp.com/avatars/1373412241227120792/6d5e593df0314df5e465f4e177c09be1.png?size=4096"
DiscordBtn.Parent = ScreenGui
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(1, 0)
local discStroke = Instance.new("UIStroke", DiscordBtn)
discStroke.Color = Color3.fromRGB(88, 101, 242)
discStroke.Thickness = 2.5
discStroke.Transparency = 0.3

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/pG89JRy5pT")
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Flux Cheats", Text = "Discord copiado!", Duration = 5})
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

-- Teclas rápidas
UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if MainFrame.Visible then CloseMenu() else OpenMenu() end
    end
    if input.KeyCode == Enum.KeyCode.X then
        Settings.MouseLocked = not Settings.MouseLocked
        UserInput.MouseBehavior = Settings.MouseLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
    end
    if input.KeyCode == Enum.KeyCode.Y then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        fovCircle.Visible = Settings.AimbotEnabled
    end
end)

-- ==================== LOOPS ====================
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius = Settings.FOV
    fovCircle.Visible = Settings.AimbotEnabled

    if Settings.AimbotEnabled then
        local closest, minDist = nil, math.huge
        local cameraPos = Camera.CFrame.Position

        for _, plr in Players:GetPlayers() do
            if plr == LocalPlayer or not plr.Character then continue end
            if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local part = plr.Character:FindFirstChild(Settings.AimPart)
            if not part then continue end
            local velocity = part.Velocity or Vector3.new()
            local predicted = part.Position + velocity * Settings.Prediction
            local pos, vis = Camera:WorldToViewportPoint(predicted)
            if not vis then continue end
            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if dist < Settings.FOV and dist < minDist then
                minDist = dist
                closest = predicted
            end
        end

        if closest then
            local target = CFrame.new(cameraPos, closest)
            Camera.CFrame = Camera.CFrame:Lerp(target, Settings.Smoothness)
        end
    end

    UpdateESP()
    UpdateChams()
    UpdateTracers()
    SilentAim()
end)

print("Flux Cheats v1.7 FINAL cargado correctamente! 🔥 Menú abre con INSERT")