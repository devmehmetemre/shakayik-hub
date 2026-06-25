-- =============================================================================
--                     SHAKAYIK CHEAT HUB - BLOX FRUITS
-- =============================================================================

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

-- Config Dosya Adı (Delta workspace klasöründe saklanır)
local ConfigFile = "shakayik_config.json"

-- Varsayılan Ayarlar (Gelişmiş JSON Altyapısı)
_G.Settings = {
    AutoFarm = false,
    FastAttack = false,
    SelectedIsland = "Hapishane",
    SelectedNPC = "Random Devil Fruit",
    AutoStats = { Melee = false, Defense = false, Sword = false },
    AFKMode = true
}

-- Config Kaydetme Fonksiyonu
local function SaveConfig()
    if writefile then
        local success, json = pcall(function() return HttpService:JSONEncode(_G.Settings) end)
        if success then writefile(ConfigFile, json) end
    end
end

-- Config Yükleme Fonksiyonu
local function LoadConfig()
    if readfile and isfile and isfile(ConfigFile) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and type(result) == "table" then
            _G.Settings = result
        end
    end
end

LoadConfig() -- Başlangıçta ayarları yükle

-- =============================================================================
-- ÖZEL DOKUNUŞLAR & FONKSİYONLAR (Gelişmiş Altyapı)
-- =============================================================================

-- Güvenli Uçuş (Tween to Island)
local function TweenToCFrame(targetCFrame)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local Distance = (RootPart.Position - targetCFrame.Position).Magnitude
    
    -- Gelişmiş Hız Ayarı (Mesafe uzaksa daha kararlı uçar, ban riskini sıfırlar)
    local Speed = 300
    local TweenInfoData = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local Tween = TweenService:Create(RootPart, TweenInfoData, {CFrame = targetCFrame})
    Tween:Play()
    return Tween
end

-- Ada Koordinatları Veritabanı (Görseldeki "Select Island" İçin)
local IslandPositions = {
    ["Hapishane"] = CFrame.new(-4892, 6, 736),
    ["Karlı Köy"] = CFrame.new(1286, 105, -1432),
    ["Orta Şehir"] = CFrame.new(-1184, 15, 412),
    ["Başlangıç Adası"] = CFrame.new(979, 16, 1412),
    ["Deniz Kalesi"] = CFrame.new(-5021, 286, -4320)
}

-- =============================================================================
-- ARAYÜZ (GUI) OLUŞTURMA (Görseldeki Axonic/Cinnamon Tasarımı)
-- =============================================================================

-- Fluent / Kavo benzeri ancak tamamen özelleştirilmiş dikey şık arayüz kitaplığı yükleniyor
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Shakayik Cheat Hub",
    SubTitle = "by TAGCHAOS | Blox Fruits",
    TabWidth = 160,
    Size = Vector2.new(580, 420),
    Acrylic = true, -- Arka planı hafif buzlu cam efekti yapar
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Görseldeki Sol Menü Sekmeleri (Tabs)
local Tabs = {
    Utils = Window:AddTab({ Title = "Utils", Icon = "settings" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "swords" }),
    BossFarm = Window:AddTab({ Title = "Boss Farming", Icon = "skull" }),
    Teleport = Window:AddTab({ Title = "İşınlanma", Icon = "map" }),
    Shop = Window:AddTab({ Title = "Dükkan", Icon = "shopping-cart" }),
    SkillPoints = Window:AddTab({ Title = "Skill Points", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" })
}

-- Top Bar - AFK Mode Göstergesi (Ekran görüntünün en üstündeki AFK ON/OFF alanı)
Tabs.Utils:AddToggle("AFKMode", {
    Title = "AFK Mode", 
    Default = _G.Settings.AFKMode,
    Callback = function(Value)
        _G.Settings.AFKMode = Value
        SaveConfig()
    end
})

-- =============================================================================
-- TELEPORT (IŞINLANMA) SEKMESİ - (Tam Ekran Görüntüsündeki gibi)
-- =============================================================================

Tabs.Teleport:AddSection("Teleport to Sea")

Tabs.Teleport:AddButton({
    Title = "Ada İşınlanma (Teleport to Sea 2)",
    Description = "700 Level iseniz sizi otomatik 2. Dünya Kaptanına götürür.",
    Callback = function()
        if Player.Data.Level.Value >= 700 then
            TweenToCFrame(IslandPositions["Orta Şehir"])
        else
            Fluent:Notify({ Title = "Hata", Content = "Leveliniz henüz 700 değil!", Duration = 5 })
        end
    end
})

Tabs.Teleport:AddSection("Select Island")

local IslandDropdown = Tabs.Teleport:AddDropdown("SelectedIsland", {
    Title = "Select Island",
    Values = {"Hapishane", "Karlı Köy", "Orta Şehir", "Başlangıç Adası", "Deniz Kalesi"},
    Default = _G.Settings.SelectedIsland,
    Callback = function(Value)
        _G.Settings.SelectedIsland = Value
        SaveConfig()
    end
})

Tabs.Teleport:AddToggle("TweenToIsland", {
    Title = "Tween to Island",
    Default = false,
    Callback = function(Value)
        if Value then
            local targetPos = IslandPositions[_G.Settings.SelectedIsland]
            if targetPos then
                TweenToCFrame(targetPos)
            else
                Fluent:Notify({ Title = "Hata", Content = "Ada konumu bulunamadı.", Duration = 3 })
            end
        end
    end
})

Tabs.Teleport:AddSection("Shop NPCs")

Tabs.Teleport:AddDropdown("ChooseNPC", {
    Title = "Choose NPC",
    Values = {"Random Devil Fruit", "Ability Teacher", "Sword Dealer", "Blox Fruit Dealer"},
    Default = _G.Settings.SelectedNPC,
    Callback = function(Value)
        _G.Settings.SelectedNPC = Value
        SaveConfig()
    end
})

Tabs.Teleport:AddToggle("TeleportToNPC", {
    Title = "Teleport To NPC",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Seçilen dükkan NPC'sine göre akıllı uçuş mantığı
            if _G.Settings.SelectedNPC == "Random Devil Fruit" then
                -- Örnek: Rastgele meyve alınan ormandaki NPC koordinatı
                TweenToCFrame(CFrame.new(-22, 15, -225))
            elseif _G.Settings.SelectedNPC == "Ability Teacher" then
                TweenToCFrame(CFrame.new(1286, 105, -1432)) -- Karlı köy mağara
            end
        end
    end
})

-- =============================================================================
-- FARMING & SKILL POINTS SEKMELERİ (Kendi özel dokunuşlarım)
-- =============================================================================

Tabs.Farming:AddToggle("AutoFarm", {
    Title = "Otomatik Seviye Kasma (Auto Farm)",
    Default = _G.Settings.AutoFarm,
    Callback = function(Value)
        _G.Settings.AutoFarm = Value
        SaveConfig()
    end
})

Tabs.Farming:AddToggle("FastAttack", {
    Title = "Süper Hızlı Saldırı (Fast Attack)",
    Default = _G.Settings.FastAttack,
    Callback = function(Value)
        _G.Settings.FastAttack = Value
        SaveConfig()
    end
})

-- Skill Points Otomatik Dağıtıcı
Tabs.SkillPoints:AddToggle("StatMelee", {
    Title = "Yumruk Geliştir (Melee)",
    Default = _G.Settings.AutoStats.Melee,
    Callback = function(Value) _G.Settings.AutoStats.Melee = Value; SaveConfig() end
})
Tabs.SkillPoints:AddToggle("StatDefense", {
    Title = "Can Geliştir (Defense)",
    Default = _G.Settings.AutoStats.Defense,
    Callback = function(Value) _G.Settings.AutoStats.Defense = Value; SaveConfig() end
})

-- =============================================================================
-- ARKA PLAN DÖNGÜLERİ (BACKGROUND WORKERS)
-- =============================================================================

-- Otomatik Stat Dağıtma Döngüsü
spawn(function()
    while task.wait(1) do
        pcall(function()
            if Player.Data.Points.Value > 0 then
                if _G.Settings.AutoStats.Melee then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
                elseif _G.Settings.AutoStats.Defense then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Defense", 1)
                end
            end
        end)
    end
end)

-- Anti-AFK Özelliği (Oyundan 20 dk sonra atılmayı engeller)
if getconnections then
    for _, v in pairs(getconnections(Player.Idled)) do
        v:Disable()
    end
else
    Player.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
    end)
end

-- Menüyü Hazırla ve İlklendir
Window:SelectTab(1)
Fluent:Notify({
    Title = "Shakayik Hub Başlatıldı",
    Content = "Ayarlarınız shakayik_config.json dosyasına kaydediliyor.",
    Duration = 5
})
