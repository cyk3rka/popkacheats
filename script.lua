local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "popkacheats",
   LoadingTitle = "Загрузка popkacheats...",
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

-- НАСТРОЙКИ
local Settings = {
    ESP_Enabled = false,
    ESP_Boxes = false,
    ESP_Tracers = false,
    ESP_Names = false,
    FullBright = false,
    NoClip = false,
    InfJump = false,
    PotatoMode = false
}

-- ВКЛАДКИ
local VisualsTab = Window:CreateTab("Визуальные", 4483362458)
local WorldTab = Window:CreateTab("Мир", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)
local GraphicsTab = Window:CreateTab("Графика", 4483362458)

--- ВКЛАДКА ГРАФИКА ---
GraphicsTab:CreateToggle({
   Name = "Картофельная графика",
   CurrentValue = false,
   Callback = function(Value)
       Settings.PotatoMode = Value
       if Value then
           for _, v in pairs(game:GetDescendants()) do
               if v:IsA("BasePart") and not v:IsA("MeshPart") then
                   v.Material = Enum.Material.SmoothPlastic
               end
               if v:IsA("Texture") or v:IsA("Decal") then
                   v.Transparency = 1
               end
           end
           Lighting.GlobalShadows = false
           Lighting.FogEnd = 9e9
           for _, effect in pairs(Lighting:GetChildren()) do
               if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
                   effect.Enabled = false
               end
           end
           Rayfield:Notify({Title="popkacheats", Content="Режим картошки активирован! FPS повышен."})
       else
           Rayfield:Notify({Title="popkacheats", Content="Для возврата графики нужно перезайти в игру."})
       end
   end,
})

--- ВКЛАДКА ВИЗУАЛЬНЫЕ ---
VisualsTab:CreateToggle({
   Name = "Яркий свет (FullBright)",
   CurrentValue = false,
   Callback = function(v)
       Settings.FullBright = v
       if v then
           Lighting.Ambient = Color3.new(1, 1, 1)
           Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
           Lighting.Brightness = 2
       else
           Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
           Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
           Lighting.Brightness = 1
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ВКЛЮЧИТЬ ESP",
   CurrentValue = false,
   Callback = function(v) Settings.ESP_Enabled = v end,
})

VisualsTab:CreateToggle({
   Name = "Боксы",
   CurrentValue = false,
   Callback = function(v) Settings.ESP_Boxes = v end,
})

VisualsTab:CreateToggle({
   Name = "Трейсеры",
   CurrentValue = false,
   Callback = function(v) Settings.ESP_Tracers = v end,
})

VisualsTab:CreateToggle({
   Name = "Ники игроков",
   CurrentValue = false,
   Callback = function(v) Settings.ESP_Names = v end,
})

-- ЛОГИКА ESP (ФИНАЛЬНАЯ ВЕРСИЯ)
local function createESP(plr)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local NameTag = Drawing.new("Text")

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if Settings.ESP_Enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr ~= LocalPlayer then
            
            local head = plr.Character.Head
            local hrp = plr.Character.HumanoidRootPart
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local hrpPos, _ = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local color = (plr.TeamColor and plr.TeamColor.Color) or Color3.new(1,1,1)

                if Settings.ESP_Boxes then
                    Box.Visible = true
                    Box.Size = Vector2.new(2000 / headPos.Z, 2500 / headPos.Z)
                    Box.Position = Vector2.new(hrpPos.X - Box.Size.X / 2, hrpPos.Y - Box.Size.Y / 2)
                    Box.Color = color
                    Box.Thickness = 1
                else Box.Visible = false end

                if Settings.ESP_Tracers then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    Tracer.Color = color
                else Tracer.Visible = false end

                if Settings.ESP_Names then
                    NameTag.Visible = true
                    NameTag.Text = plr.Name
                    NameTag.Position = Vector2.new(headPos.X, headPos.Y - 25) 
                    NameTag.Color = Color3.new(1, 1, 1)
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.Size = math.clamp(18 - (headPos.Z / 15), 12, 18)
                else NameTag.Visible = false end
            else
                Box.Visible = false; Tracer.Visible = false; NameTag.Visible = false
            end
        else
            Box.Visible = false; Tracer.Visible = false; NameTag.Visible = false
            if not plr.Parent then 
                Box:Remove(); Tracer:Remove(); NameTag:Remove(); connection:Disconnect() 
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--- ВКЛАДКА МИР ---
WorldTab:CreateButton({
   Name = "Убрать лазеры (Force)",
   Callback = function()
       for _, v in pairs(workspace:GetDescendants()) do
           if v:IsA("BasePart") and (v.Name:lower():find("laser") or v.Name:lower():find("touchkill") or v.Name == "Beam") then
               v.CanTouch = false; v.CanQuery = false; v.Transparency = 0.9; pcall(function() v:Destroy() end)
           end
       end
       Rayfield:Notify({Title="popkacheats", Content="Лазеры отключены!"})
   end,
})

WorldTab:CreateButton({
   Name = "Удалить двери и заборы",
   Callback = function()
       for _, v in pairs(workspace:GetDescendants()) do
           if v:IsA("BasePart") and (v.Name:find("Door") or v.Name:find("Gate") or v.Name:find("Cell") or v.Name:find("Fence")) then
               if v.Name ~= "Baseplate" then
                   v.CanCollide = false; v.Transparency = 0.7; pcall(function() v:Destroy() end)
               end
           end
       end
       Rayfield:Notify({Title="popkacheats", Content="Двери и преграды удалены!"})
   end,
})

--- ВКЛАДКА ИГРОК ---
PlayerTab:CreateToggle({
   Name = "Бесконечный прыжок",
   CurrentValue = false,
   Callback = function(v) Settings.InfJump = v end,
})

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

PlayerTab:CreateToggle({
   Name = "NoClip (Сквозь стены)",
   CurrentValue = false,
   Callback = function(v) Settings.NoClip = v end,
})

RunService.Stepped:Connect(function()
    if Settings.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

Rayfield:Notify({
   Title = "popkacheats",
   Content = "Приятной игры, cyk3rka!",
   Duration = 5
})
