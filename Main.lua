-- ═══════════════════════════════════════
-- 🔥 LGNG HUB — TRIÁNGULO ENCIMA DEL MONO + LÍNEA + AIMBOT + ESP 🔥
-- ═══════════════════════════════════════

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait(0.1) until LocalPlayer and LocalPlayer.Character

-- ========== VARIABLES ==========
local AimOn = false
local EspOn = false
local SkeletonColor = Color3.fromRGB(255, 0, 0)
local WhiteESP = Color3.fromRGB(255, 255, 255)
local ArmaTextoTamano = 14

-- ========== 🔋 ESTAMINA INFINITA ==========
local function SetMaxStamina()
    local function Apply()
        LocalPlayer.CharacterAdded:Connect(function() task.wait(0.2) Apply() end)
        local Char = LocalPlayer.Character
        if not Char then return end
        task.spawn(function()
            while Char and Char:FindFirstChild("Humanoid") do
                local Hum = Char.Humanoid
                if Hum and Hum.Health > 0 then
                    local Stamina = Char:FindFirstChild("Stamina") or LocalPlayer:FindFirstChild("Stamina")
                    if Stamina and Stamina:IsA("NumberValue") then Stamina.Value = Stamina.MaxValue or 100 end
                    Char:SetAttribute("Stamina", 100)
                    Char:SetAttribute("StaminaDrain", 0)
                end
                task.wait(0.05)
            end
        end)
    end
    Apply()
end

-- ========== 🖥️ ELEMENTOS VISUALES ==========
-- 🔺 TRIÁNGULO BLANCO ENCIMA DEL PERSONAJE
local Triangle = Drawing.new("Triangle")
Triangle.Visible = false
Triangle.Thickness = 2
Triangle.Color = Color3.fromRGB(255, 255, 255)
Triangle.Filled = false

-- 🟥 LÍNEA ROJA DESDE TU CABEZA AL PERSONAJE
local LineToTarget = Drawing.new("Line")
LineToTarget.Visible = false
LineToTarget.Thickness = 3
LineToTarget.Color = Color3.fromRGB(255, 0, 0)

-- ========== 🔥 INTERFAZ ==========
local Gui = Instance.new("ScreenGui")
Gui.Name = "LGNG_HUB"
Gui.Parent = game.CoreGui

local MainBox = Instance.new("Frame")
MainBox.Size = UDim2.new(0, 360, 0, 130)
MainBox.Position = UDim2.new(0.5, -180, 0.02, 0)
MainBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainBox.BorderSizePixel = 3
MainBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainBox.Active = true
MainBox.Draggable = true
MainBox.Parent = Gui

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 35)
MainTitle.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
MainTitle.Text = "🔥 TRIÁNGULO ENCIMA DEL MONO 🔥"
MainTitle.TextColor3 = Color3.fromRGB(255, 255, 0)
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextScaled = true
MainTitle.Parent = MainBox
Instance.new("UICorner", MainTitle).CornerRadius = UDim.new(0, 8)

-- BOTÓN AIMBOT
local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(0, 150, 0, 45)
AimBtn.Position = UDim2.new(0.03, 0, 0.38, 0)
AimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AimBtn.BorderSizePixel = 2
AimBtn.BorderColor3 = Color3.fromRGB(255, 55, 95)
AimBtn.Text = "❌ AIMBOT [Z]"
AimBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
AimBtn.Font = Enum.Font.GothamBold
AimBtn.TextScaled = true
AimBtn.Parent = MainBox
Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 6)

-- BOTÓN ESP
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0, 150, 0, 45)
EspBtn.Position = UDim2.new(0.55, 0, 0.38, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
EspBtn.BorderSizePixel = 2
EspBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
EspBtn.Text = "❌ ESP [X]"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.TextScaled = true
EspBtn.Parent = MainBox
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

-- ========== FUNCIONES BOTONES ==========
local function SwitchAim()
    AimOn = not AimOn
    AimBtn.Text = AimOn and "✅ AIMBOT [Z]" or "❌ AIMBOT [Z]"
    AimBtn.BackgroundColor3 = AimOn and Color3.fromRGB(25, 100, 55) or Color3.fromRGB(50, 50, 60)
    AimBtn.TextColor3 = AimOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 90, 90)
end

local function SwitchEsp()
    EspOn = not EspOn
    EspBtn.Text = EspOn and "✅ ESP [X]" or "❌ ESP [X]"
    EspBtn.BackgroundColor3 = EspOn and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(50, 50, 60)
end

AimBtn.MouseButton1Click:Connect(SwitchAim)
EspBtn.MouseButton1Click:Connect(SwitchEsp)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Z then SwitchAim() end
    if i.KeyCode == Enum.KeyCode.X then SwitchEsp() end
end)

-- ========== 🎯 TRIÁNGULO ENCIMA DEL MONO + LÍNEA ROJA ==========
RunService.RenderStepped:Connect(function()
    local CenterX = Camera.ViewportSize.X / 2
    local CenterY = Camera.ViewportSize.Y / 2
    local CamPos = Camera.CFrame.Position
    local TargetHead = nil
    local MinDist = 120

    -- BUSCAR JUGADOR EN LA MIRA
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        for _, P in ipairs(Players:GetPlayers()) do
            if P ~= LocalPlayer and P.Character and P.Character:FindFirstChild("Head") then
                local Head = P.Character.Head
                local Pos, Vis = Camera:WorldToViewportPoint(Head.Position)
                if Vis then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(CenterX, CenterY)).Magnitude
                    if Dist < MinDist then
                        MinDist = Dist
                        TargetHead = Head
                    end
                end
            end
        end

        -- ✅ DIBUJAR TRIÁNGULO ENCIMA DEL PERSONAJE
        if TargetHead then
            local MyHead = LocalPlayer.Character.Head
            local MyPos, MyVis = Camera:WorldToViewportPoint(MyHead.Position)
            local TarPos, TarVis = Camera:WorldToViewportPoint(TargetHead.Position)

            if MyVis and TarVis then
                -- 🔺 TRIÁNGULO BLANCO ENCIMA DE LA CABEZA
                Triangle.Visible = true
                local triSize = 10
                local offsetY = 8 -- AQUI BAJAMOS EL TRIÁNGULO HACIA LA CABEZA

                Triangle.PointA = Vector2.new(TarPos.X, TarPos.Y - offsetY - triSize)
                Triangle.PointB = Vector2.new(TarPos.X - triSize, TarPos.Y - offsetY + triSize/2)
                Triangle.PointC = Vector2.new(TarPos.X + triSize, TarPos.Y - offsetY + triSize/2)

                -- 🟥 LÍNEA ROJA DESDE TU CABEZA
                LineToTarget.Visible = true
                LineToTarget.From = Vector2.new(MyPos.X, MyPos.Y)
                LineToTarget.To = Vector2.new(TarPos.X, TarPos.Y - offsetY)

                -- 🎯 AIMBOT
                if AimOn then
                    Camera.CFrame = CFrame.new(CamPos, TargetHead.Position)
                end
            end
        else
            -- ❌ OCULTAR SI NO MIRAS A NADIE
            Triangle.Visible = false
            LineToTarget.Visible = false
        end
    end
end)

-- ========== 👁️ ESP COMPLETO: ESQUELETO + NOMBRE + VIDA + ARMAS ==========
local SkeletonObjects = {}
local ESPObjects = {}
local WeaponRegistry = {}
local Items = ReplicatedStorage:WaitForChild("Items", 10) or nil

-- HUESOS DEL ESQUELETO
local Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

-- REGISTRAR ARMAS PARA ESP
if Items then
    local function registerItems(folder)
        for _, tool in ipairs(folder:GetChildren()) do
            if tool:IsA("Tool") then
                local displayName = tool:GetAttribute("DisplayName") or tool.Name
                WeaponRegistry[tool.Name] = displayName
            end
        end
        folder.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                WeaponRegistry[child.Name] = child:GetAttribute("DisplayName") or child.Name
            end
        end)
    end
    registerItems(Items)
end

-- OBTENER ARMAS DEL JUGADOR
local function getWeapons(player)
    local weapons = {}
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    if bp then for _, v in ipairs(bp:GetChildren()) do if v:IsA("Tool") then table.insert(weapons, WeaponRegistry[v.Name] or v.Name) end end end
    if char then for _, v in ipairs(char:GetChildren()) do if v:IsA("Tool") then table.insert(weapons, WeaponRegistry[v.Name] or v.Name) end end end
    return weapons
end

-- CREAR ESP POR JUGADOR
local function CrearESP(p)
    if ESPObjects[p] then return end
    local Gui = Instance.new("BillboardGui")
    Gui.Name = "ESP_Info"
    Gui.AlwaysOnTop = true
    Gui.Size = UDim2.new(0, 200, 0, 100)
    Gui.StudsOffset = Vector3.new(0, 4, 0)
    Gui.Parent = p:FindFirstChild("Head")

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.Font = Enum.Font.GothamBold
    Text.TextColor3 = Color3.fromRGB(255, 0, 0)
    Text.TextScaled = true
    Text.Parent = Gui

    SkeletonObjects[p] = { Gui = Gui, Text = Text, Lines = {} }
    for _ in ipairs(Bones) do
        local Line = Drawing.new("Line")
        Line.Thickness = 2.5
        Line.Color = Color3.fromRGB(255, 0, 0)
        Line.Visible = false
        table.insert(SkeletonObjects[p].Lines, Line)
    end
    ESPObjects[p] = true
end

-- ELIMINAR ESP AL SALIR
local function EliminarESP(p)
    if ESPObjects[p] then
        if SkeletonObjects[p] then
            SkeletonObjects[p].Gui:Destroy()
            for _, L in ipairs(SkeletonObjects[p].Lines) do L:Destroy() end
        end
        ESPObjects[p] = nil
        SkeletonObjects[p] = nil
    end
end

-- ACTUALIZAR ESP CADA FRAME
RunService.RenderStepped:Connect(function()
    if not EspOn then
        for _, p in pairs(ESPObjects) do
            if SkeletonObjects[p] then
                SkeletonObjects[p].Gui.Enabled = false
                for _, L in ipairs(SkeletonObjects[p].Lines) do L.Visible = false end
            end
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local Char = p.Character
        if not Char or not Char:FindFirstChild("Humanoid") or Char.Humanoid.Health <= 0 then
            if SkeletonObjects[p] then
                SkeletonObjects[p].Gui.Enabled = false
                for _, L in ipairs(SkeletonObjects[p].Lines) do L.Visible = false end
            end
            continue
        end

        CrearESP(p)
        SkeletonObjects[p].Gui.Enabled = true

        -- 📋 TEXTO: NOMBRE + VIDA + DISTANCIA + ARMAS
        local Dist = (Char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        local armas = getWeapons(p)
        local armaTexto = #armas > 0 and "\n🔫 " .. table.concat(armas, " | ") or ""
        SkeletonObjects[p].Text.Text = p.Name .. "\n❤️ "..math.floor(Char.Humanoid.Health).." HP\n📏 "..math.floor(Dist).."m"..armaTexto

        -- 🦴 ESQUELETO ROJO
        local i = 1
        for _, Par in ipairs(Bones) do
            local P1 = Char:FindFirstChild(Par[1])
            local P2 = Char:FindFirstChild(Par[2])
            local L = SkeletonObjects[p].Lines[i]
            i += 1
            if P1 and P2 and L then
                local Pos1, Vis1 = Camera:WorldToViewportPoint(P1.Position)
                local Pos2, Vis2 = Camera:WorldToViewportPoint(P2.Position)
                if Vis1 and Vis2 then
                    L.From = Vector2.new(Pos1.X, Pos1.Y)
                    L.To = Vector2.new(Pos2.X, Pos2.Y)
                    L.Visible = true
                else
                    L.Visible = false
                end
            elseif L then
                L.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(EliminarESP)

-- ========== 🚀 INICIAR TODO ==========
SetMaxStamina()
