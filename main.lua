-- ═══════════════════════════════════════
-- 🔥 LGNG HUB — RECOLECCIÓN QUE SÍ FUNCIONA + AIMBOT + ESP + ESTAMINA 🔥
-- ═══════════════════════════════════════

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

repeat task.wait(0.1) until LocalPlayer and LocalPlayer.Character

-- ========== ⚙️ CONFIGURACIÓN ==========
local Config = {
    AlcanceRecoleccion = 25,       -- 📏 Alcance de recolección
    RecogerCada = 0.03            -- ⚡ Qué tan rápido revisa
}

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

-- ========== 🧲 RECOLECCIÓN DE ARMAS QUE SÍ FUNCIONA ==========
local Recogidos = {}

local function RecoleccionFuncional()
    task.spawn(function()
        while task.wait(Config.RecogerCada) do
            local Char = LocalPlayer.Character
            local Backpack = LocalPlayer:FindFirstChild("Backpack")
            if not Char or not Backpack then continue end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            if not Root then continue end

            for _, v in ipairs(workspace:GetChildren()) do
                -- ✅ ARMAS / HERRAMIENTAS (LO PRINCIPAL)
                if v:IsA("Tool") then
                    local Handle = v:FindFirstChild("Handle")
                    if not Handle then continue end
                    
                    local Dist = (Root.Position - Handle.Position).Magnitude
                    
                    if Dist <= Config.AlcanceRecoleccion and not Recogidos[v] then
                        Recogidos[v] = true
                        
                        -- 🔥 MÉTODO CORRECTO: Tocar la arma como si el jugador la tocara
                        pcall(function()
                            -- Simular que el jugador tocó el objeto (activar el evento de recolección del juego)
                            local TouchPart = Instance.new("Part")
                            TouchPart.Size = Vector3.new(0.1, 0.1, 0.1)
                            TouchPart.Position = Handle.Position
                            TouchPart.CanCollide = false
                            TouchPart.Transparency = 1
                            TouchPart.Parent = Root
                            
                            -- Si la arma tiene TouchTransmitter (común en muchos juegos)
                            if Handle:FindFirstChild("TouchTransmitter") then
                                Handle.TouchTransmitter:Fire(Root)
                            end
                            
                            -- Método directo: mover al personaje (el servidor lo valida al tocar)
                            v.Parent = Char
                            
                            -- Si no se quedó, mandarlo a la mochila
                            task.wait(0.05)
                            if v.Parent ~= Char then
                                v.Parent = Backpack
                            end
                            
                            -- Intentar equiparla automáticamente
                            task.wait(0.05)
                            if v.Parent == Char or v.Parent == Backpack then
                                pcall(function() Char.Humanoid:EquipTool(v) end)
                            end
                            
                            TouchPart:Destroy()
                        end)
                    end
                end
                
                -- 💰 MONEDAS Y OTROS OBJETOS
                local Nombre = string.lower(v.Name)
                if Nombre:find("coin") or Nombre:find("moneda") or Nombre:find("item") or Nombre:find("drop") or Nombre:find("pickup") then
                    local Pos = v:IsA("BasePart") and v.Position or nil
                    if Pos and (Root.Position - Pos).Magnitude <= Config.AlcanceRecoleccion and not Recogidos[v] then
                        Recogidos[v] = true
                        pcall(function()
                            -- Mover el objeto hacia el jugador (imán)
                            local Tween = TweenService:Create(v, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = Root.Position})
                            Tween:Play()
                            -- Activar evento de recolección si existe
                            local Remote = v:FindFirstChildOfClass("RemoteEvent") or game.ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
                            if Remote then Remote:FireServer(v) end
                        end)
                    end
                end
            end
            
            -- Limpiar lista cada rato
            if #Recogidos > 200 then table.clear(Recogidos) end
        end
    end)
end

-- ========== 🎯 AIMBOT ==========
local AimOn = false
local function Aimbot()
    RunService.RenderStepped:Connect(function()
        if not AimOn then return end
        local Char = LocalPlayer.Character
        if not Char then return end
        local Target, MinDist = nil, math.huge
        local Centro = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local Head = p.Character:FindFirstChild("Head")
                if Head then
                    local Pos, Vis = Camera:WorldToViewportPoint(Head.Position)
                    if Vis then
                        local Dist = (Vector2.new(Pos.X, Pos.Y) - Centro).Magnitude
                        if Dist < MinDist then MinDist = Dist Target = Head end
                    end
                end
            end
        end
        if Target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position) end
    end)
end

-- ========== 👁️ ESP COMPLETO ==========
local EspOn = false
local SkeletonObjects = {}
local ESPObjects = {}
local Bones = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local function CrearESP(p)
    if ESPObjects[p] then return end
    local Gui = Instance.new("BillboardGui")
    Gui.Name = "ESP_Info"
    Gui.AlwaysOnTop = true
    Gui.Size = UDim2.new(0, 150, 0, 80)
    Gui.StudsOffset = Vector3.new(0, 3, 0)
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

local function ActualizarESP()
    RunService.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local Char = p.Character
            if not Char or not Char:FindFirstChild("Humanoid") or Char.Humanoid.Health <= 0 then
                if SkeletonObjects[p] then SkeletonObjects[p].Gui.Enabled = false for _, L in ipairs(SkeletonObjects[p].Lines) do L.Visible = false end end
                continue
            end
            if not EspOn then
                if SkeletonObjects[p] then SkeletonObjects[p].Gui.Enabled = false for _, L in ipairs(SkeletonObjects[p].Lines) do L.Visible = false end end
                continue
            end
            CrearESP(p)
            SkeletonObjects[p].Gui.Enabled = true

            local Dist = (Char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            SkeletonObjects[p].Text.Text = p.Name .. "\n❤️ "..math.floor(Char.Humanoid.Health).." HP\n📏 "..math.floor(Dist).."m"

            local i = 1
            for _, Par in ipairs(Bones) do
                local P1 = Char:FindFirstChild(Par[1])
                local P2 = Char:FindFirstChild(Par[2])
                local L = SkeletonObjects[p].Lines[i]
                i += 1
                if P1 and P2 and L then
                    local Pos1, Vis1 = Camera:WorldToViewportPoint(P1.Position)
                    local Pos2, Vis2 = Camera:WorldToViewportPoint(P2.Position)
                    if Vis1 and Vis2 then L.From = Vector2.new(Pos1.X, Pos1.Y) L.To = Vector2.new(Pos2.X, Pos2.Y) L.Visible = true else L.Visible = false end
                elseif L then L.Visible = false end
            end
        end
    end)
end

-- ========== 🖥️ INTERFAZ LGNG HUB ==========
local Gui = Instance.new("ScreenGui")
Gui.Name = "LGNG_HUB"
Gui.Parent = game.CoreGui

local MainBox = Instance.new("Frame")
MainBox.Size = UDim2.new(0, 340, 0, 130)
MainBox.Position = UDim2.new(0.5, -170, 0.02, 0)
MainBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainBox.BorderSizePixel = 3
MainBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainBox.Active = true
MainBox.Draggable = true
MainBox.Parent = Gui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
Title.Text = "🔥 LGNG HUB — RECOGE ARMAS 🔥"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = MainBox
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- BOTÓN AIMBOT
local AimBtn = Instance.new("TextButton")
AimBtn.Size = UDim2.new(0, 145, 0, 40)
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
EspBtn.Size = UDim2.new(0, 145, 0, 40)
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

-- FUNCIONES BOTONES
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

-- TECLAS RÁPIDAS
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Z then SwitchAim() end
    if i.KeyCode == Enum.KeyCode.X then SwitchEsp() end
end)

Players.PlayerRemoving:Connect(EliminarESP)

-- ========== 🚀 INICIAR TODO ==========
SetMaxStamina()
RecoleccionFuncional()
Aimbot()
ActualizarESP()
