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
    FlySpeed = 50
}

-- ВКЛАДКИ
local VisualsTab = Window:CreateTab("Визуальные", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)
local WorldTab = Window:CreateTab("Мир", 4483362458)
local GraphicsTab = Window:CreateTab("Графика", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)
local DiscordTab = Window:CreateTab("Discord", 4483362458)

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

--- ВКЛАДКА ВИЗУАЛЬНЫЕ ---
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

-- Полет и статистика
RunService.RenderStepped:Connect(function()
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

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({Title = "popkacheats", Content = "FPS Boost готов!", Duration = 5})
