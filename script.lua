local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "popkacheats",
   LoadingTitle = "Загрузка оптимизации...",
   LoadingSubtitle = "by cyk3rka",
   ConfigurationSaving = { Enabled = true, FolderName = "popkacheats_cfg" }
})

-- СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ПЕРЕМЕННЫЕ
local StartMoney = LocalPlayer.leaderstats.Money.Value
local StartTime = os.time()
local ArrestsCount = 0

local Settings = {
    ESP_Enabled = false,
    ESP_Boxes = false,
    ESP_Tracers = false,
    ESP_Names = false,
    FullBright = false,
    NoClip = false,
    InfJump = false,
    WalkSpeed = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    -- Хитбоксы
    HitboxEnabled = false,
    HitboxSize = 2,
    HitboxTransparency = 0.5,
    -- Настройки Косметики
    TrailEnabled = false,
    TrailRainbow = false,
    TrailColor = Color3.fromRGB(255, 0, 0),
    ChinaHatEnabled = false,
    ChinaHatRainbow = false,
    ChinaHatColor = Color3.fromRGB(255, 255, 255),
    JumpCircleEnabled = false,
    JumpCircleRainbow = false,
    JumpCircleColor = Color3.fromRGB(0, 255, 255)
}

-- ВКЛАДКИ
local VisualsTab = Window:CreateTab("Визуальные", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)
local CosmeticTab = Window:CreateTab("Косметика", 4483362458)
local WorldTab = Window:CreateTab("Мир", 4483362458)
local GraphicsTab = Window:CreateTab("Графика", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)
local DiscordTab = Window:CreateTab("Discord", 4483362458)

--- ВКЛАДКА ВИЗУАЛЬНЫЕ (ESP + HITBOX) ---
VisualsTab:CreateSection("Hitbox Expander")

VisualsTab:CreateToggle({
   Name = "Включить Хитбоксы",
   CurrentValue = false,
   Callback = function(v) Settings.HitboxEnabled = v end,
})

VisualsTab:CreateSlider({
   Name = "Размер Хитбокса",
   Range = {2, 20},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) Settings.HitboxSize = v end,
})

VisualsTab:CreateSlider({
   Name = "Прозрачность",
   Range = {0, 100},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) Settings.HitboxTransparency = v / 100 end,
})

VisualsTab:CreateSection("FOV & Brightness")
VisualsTab:CreateSlider({
   Name = "Угол обзора (FOV)",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(v) Camera.FieldOfView = v end,
})
VisualsTab:CreateToggle({
   Name = "Яркий свет (FullBright)",
   CurrentValue = false,
   Callback = function(v)
       Settings.FullBright = v
       if v then Lighting.Ambient = Color3.new(1, 1, 1); Lighting.Brightness = 2
       else Lighting.Ambient = Color3.new(0.5, 0.5, 0.5); Lighting.Brightness = 1 end
   end,
})

VisualsTab:CreateSection("ESP Настройки")
VisualsTab:CreateToggle({Name = "ВКЛЮЧИТЬ ESP", CurrentValue = false, Callback = function(v) Settings.ESP_Enabled = v end})
VisualsTab:CreateToggle({Name = "Боксы", CurrentValue = false, Callback = function(v) Settings.ESP_Boxes = v end})
VisualsTab:CreateToggle({Name = "Трейсеры", CurrentValue = false, Callback = function(v) Settings.ESP_Tracers = v end})
VisualsTab:CreateToggle({Name = "Ники", CurrentValue = false, Callback = function(v) Settings.ESP_Names = v end})

-- Логика Хитбоксов (Работает в фоне)
task.spawn(function()
    while task.wait(0.5) do
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                if Settings.HitboxEnabled then
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.Transparency = Settings.HitboxTransparency
                    hrp.Color = Color3.fromRGB(255, 0, 0)
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                    hrp.Material = Enum.Material.Plastic
                end
            end
        end
    end
end)

-- Логика ESP
local function createESP(plr)
    local Box = Drawing.new("Square"); local Tracer = Drawing.new("Line"); local NameTag = Drawing.new("Text")
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if Settings.ESP_Enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr ~= LocalPlayer then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local color = (plr.TeamColor and plr.TeamColor.Color) or Color3.new(1,1,1)
                if Settings.ESP_Boxes then
                    Box.Visible = true; Box.Size = Vector2.new(2000 / pos.Z, 2500 / pos.Z)
                    Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2); Box.Color = color
                else Box.Visible = false end
                if Settings.ESP_Tracers then
                    Tracer.Visible = true; Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(pos.X, pos.Y); Tracer.Color = color
                else Tracer.Visible = false end
                if Settings.ESP_Names then
                    NameTag.Visible = true; NameTag.Text = plr.Name; NameTag.Position = Vector2.new(pos.X, pos.Y - (2500/pos.Z/2) - 15)
                    NameTag.Outline = true; NameTag.Center = true; NameTag.Size = 16
                else NameTag.Visible = false end
            else Box.Visible = false; Tracer.Visible = false; NameTag.Visible = false end
        else
            Box.Visible = false; Tracer.Visible = false; NameTag.Visible = false
            if not plr.Parent then Box:Remove(); Tracer:Remove(); NameTag:Remove(); connection:Disconnect() end
        end
    end)
end
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--- ВКЛАДКА КОСМЕТИКА ---
CosmeticTab:CreateSection("Шлейф (Trail)")
local trailObj = nil
local function createTrail()
    if trailObj then trailObj:Destroy() end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local att0, att1 = Instance.new("Attachment", hrp), Instance.new("Attachment", hrp)
    att0.Position, att1.Position = Vector3.new(0, 0.5, 0), Vector3.new(0, -0.5, 0)
    local trail = Instance.new("Trail")
    trail.Attachment0, trail.Attachment1 = att0, att1
    trail.Color = ColorSequence.new(Settings.TrailColor)
    trail.Lifetime, trail.Enabled, trail.Parent = 0.6, Settings.TrailEnabled, hrp
    trailObj = trail
end

CosmeticTab:CreateToggle({
   Name = "Включить Трейл",
   CurrentValue = false,
   Callback = function(v) Settings.TrailEnabled = v; if v then createTrail() elseif trailObj then trailObj.Enabled = false end end,
})
CosmeticTab:CreateToggle({Name = "Радужный Трейл", CurrentValue = false, Callback = function(v) Settings.TrailRainbow = v end})
CosmeticTab:CreateColorPicker({Name = "Цвет Трейла", Color = Settings.TrailColor, Callback = function(v) Settings.TrailColor = v end})

CosmeticTab:CreateSection("Китайская Шляпа (China Hat)")
local hatPart = nil
local function createChinaHat()
    if hatPart then hatPart:Destroy() end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return end
    hatPart = Instance.new("Part", LocalPlayer.Character)
    hatPart.Name = "ChinaHat"; hatPart.Anchored = false; hatPart.CanCollide = false
    hatPart.Transparency = 0.3; hatPart.Material = Enum.Material.Neon; hatPart.Size = Vector3.new(2, 0.5, 2)
    local mesh = Instance.new("SpecialMesh", hatPart)
    mesh.MeshType, mesh.MeshId = Enum.MeshType.FileMesh, "rbxassetid://1778999"
    mesh.Scale = Vector3.new(2.2, 0.8, 2.2)
    local weld = Instance.new("Weld", hatPart)
    weld.Part0, weld.Part1, weld.C0 = LocalPlayer.Character.Head, hatPart, CFrame.new(0, 0.8, 0)
end

CosmeticTab:CreateToggle({
   Name = "Включить Шляпу",
   CurrentValue = false,
   Callback = function(v) Settings.ChinaHatEnabled = v; if v then createChinaHat() elseif hatPart then hatPart:Destroy(); hatPart = nil end end,
})
CosmeticTab:CreateToggle({Name = "Радужная Шляпа", CurrentValue = false, Callback = function(v) Settings.ChinaHatRainbow = v end})
CosmeticTab:CreateColorPicker({Name = "Цвет Шляпы", Color = Settings.ChinaHatColor, Callback = function(v) Settings.ChinaHatColor = v end})

CosmeticTab:CreateSection("Кольца Прыжка (Jump Circle)")
CosmeticTab:CreateToggle({Name = "Неоновые кольца", CurrentValue = false, Callback = function(v) Settings.JumpCircleEnabled = v end})
CosmeticTab:CreateToggle({Name = "Радужные Кольца", CurrentValue = false, Callback = function(v) Settings.JumpCircleRainbow = v end})
CosmeticTab:CreateColorPicker({Name = "Цвет Колец", Color = Settings.JumpCircleColor, Callback = function(v) Settings.JumpCircleColor = v end})

local function createJumpCircle()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local p = Instance.new("Part", workspace)
    p.Anchored, p.CanCollide, p.Transparency, p.Material = true, false, 0.2, Enum.Material.Neon
    p.Size, p.CFrame, p.CastShadow = Vector3.new(0.5, 0.05, 0.5), CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2.9, 0)), false
    local mesh = Instance.new("SpecialMesh", p)
    mesh.MeshType, mesh.MeshId, mesh.Scale = Enum.MeshType.FileMesh, "rbxassetid://20329976", Vector3.new(0.5, 0.05, 0.5)
    p.Color = Settings.JumpCircleRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.JumpCircleColor
    task.spawn(function()
        for i = 1, 15 do task.wait(0.01); mesh.Scale = mesh.Scale + Vector3.new(0.6, 0, 0.6); p.Transparency = p.Transparency + 0.06 end
        p:Destroy()
    end)
end

--- ВКЛАДКА ГРАФИКА (FPS BOOST) ---
GraphicsTab:CreateSection("Оптимизация FPS")

GraphicsTab:CreateToggle({
   Name = "Отключить тени (Shadows)",
   CurrentValue = false,
   Callback = function(v)
       Lighting.GlobalShadows = not v
       Rayfield:Notify({Title="popkacheats", Content = v and "Тени отключены" or "Тени включены"})
   end,
})

GraphicsTab:CreateButton({
   Name = "Удалить все наклейки (Decals)",
   Callback = function()
       local count = 0
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("Decal") or v:IsA("Texture") then
               v:Destroy()
               count = count + 1
           end
       end
       Rayfield:Notify({Title="popkacheats", Content="Удалено " .. count .. " текстур!"})
   end,
})

GraphicsTab:CreateButton({
   Name = "Картофельный режим (Potato Mode)",
   Callback = function()
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("BasePart") or v:IsA("MeshPart") then
               v.Material = Enum.Material.SmoothPlastic
               v.Reflectance = 0
           end
       end
       Rayfield:Notify({Title="popkacheats", Content="Материалы упрощены"})
   end,
})

--- ВКЛАДКА ИГРОК ---
PlayerTab:CreateSection("Движение")
PlayerTab:CreateSlider({
   Name = "Скорость ходьбы",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) Settings.WalkSpeed = v end,
})
PlayerTab:CreateToggle({Name = "Бесконечный прыжок", CurrentValue = false, Callback = function(v) Settings.InfJump = v end})
PlayerTab:CreateToggle({Name = "NoClip (Сквозь стены)", CurrentValue = false, Callback = function(v) Settings.NoClip = v end})

PlayerTab:CreateSection("Полет (Fly)")
PlayerTab:CreateToggle({
   Name = "Включить Полет",
   CurrentValue = false,
   Callback = function(v) 
       Settings.FlyEnabled = v 
       if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
       end
   end,
})
PlayerTab:CreateSlider({
   Name = "Скорость полета",
   Range = {10, 300},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) Settings.FlySpeed = v end,
})

--- ВКЛАДКА МИР ---
WorldTab:CreateButton({
   Name = "Убрать лазеры и двери",
   Callback = function()
       for _, v in pairs(workspace:GetDescendants()) do
           if v:IsA("BasePart") and (v.Name:lower():find("laser") or v.Name:find("Door") or v.Name:find("Fence")) then
               v.CanCollide = false; v.CanTouch = false; v.Transparency = 0.8
           end
       end
   end,
})

--- ВКЛАДКА INFO ---
InfoTab:CreateSection("Credits")
InfoTab:CreateLabel("popkacheats - by cyk3rka")
InfoTab:CreateSection("Статистика сессии")
local MoneyLabel = InfoTab:CreateLabel("Заработано за сессию: 0 $")
local TimeLabel = InfoTab:CreateLabel("Время работы: 00:00:00")
local ArrestLabel = InfoTab:CreateLabel("Арестов за сессию: 0")

--- ВКЛАДКА DISCORD ---
DiscordTab:CreateButton({
   Name = "Скопировать Дискорд (RU/EN)",
   Callback = function() setclipboard("https://discord.gg/6wjpNCJdeJ"); Rayfield:Notify({Title="Discord", Content="Copied!"}) end,
})

-- ЦИКЛЫ ОБНОВЛЕНИЯ
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600); local minutes = math.floor((seconds % 3600) / 60); local seconds = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- Фикс скорости
spawn(function()
    while wait() do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and not Settings.FlyEnabled then
                LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
            end
        end)
    end
end)

-- РЕНДЕР ЦИКЛ
RunService.RenderStepped:Connect(function()
    if trailObj and Settings.TrailEnabled then
        trailObj.Color = ColorSequence.new(Settings.TrailRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.TrailColor)
    end
    if hatPart and Settings.ChinaHatEnabled then
        hatPart.Color = Settings.ChinaHatRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ChinaHatColor
    end

    MoneyLabel:Set("Заработано за сессию: " .. (LocalPlayer.leaderstats.Money.Value - StartMoney) .. " $")
    TimeLabel:Set("Время работы: " .. formatTime(os.time() - StartTime))

    if Settings.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local moveDir = Vector3.new(0,0,0)
        local lookVec = Camera.CFrame.LookVector
        local rightVec = Camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rightVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rightVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0,1,0) end
        
        if moveDir.Magnitude > 0 then
            hrp.Velocity = moveDir.Unit * Settings.FlySpeed
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end

    if LocalPlayer.Character and Settings.NoClip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ОБРАБОТКА ПРЫЖКОВ
UserInputService.JumpRequest:Connect(function()
    if Settings.JumpCircleEnabled then createJumpCircle() end
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- РЕСПАВН ЭФФЕКТОВ
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    if Settings.TrailEnabled then createTrail() end
    if Settings.ChinaHatEnabled then createChinaHat() end
end)

Rayfield:Notify({Title = "popkacheats", Content = "Скрипт полностью обновлен!", Duration = 5})
