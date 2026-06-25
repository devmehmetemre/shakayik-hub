-- =============================================================================
--                 SHAKAYIK CHEAT HUB (DELTA STABLE VERSION)
-- =============================================================================

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local ConfigFile = "shakayik_config.json"

_G.Settings = {
    AutoFarm = false,
    FastAttack = false,
    SelectedIsland = "Hapishane",
    SelectedNPC = "Random Devil Fruit",
    AutoStats = { Melee = false, Defense = false }
}

-- Config Altyapısı
local function SaveConfig()
    if writefile then
        pcall(function() writefile(ConfigFile, HttpService:JSONEncode(_G.Settings)) end)
    end
end

-- Güvenli Uçuş (Tween)
local function TweenToCFrame(targetCFrame)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local Distance = (RootPart.Position - targetCFrame.Position).Magnitude
    local TweenInfoData = TweenInfo.new(Distance / 250, Enum.EasingStyle.Linear)
    local Tween = TweenService:Create(RootPart, TweenInfoData, {CFrame = targetCFrame})
    Tween:Play()
    return Tween
end

local IslandPositions = {
    ["Hapishane"] = CFrame.new(-4892, 6, 736),
    ["Karlı Köy"] = CFrame.new(1286, 105, -1432),
    ["Orta Şehir"] = CFrame.new(-1184, 15, 412),
    ["Başlangıç Adası"] = CFrame.new(979, 16, 1412)
}

-- KAVO UI KÜTÜPHANESİ (Delta için En Kararlı Arayüz)
local KavoUi = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = KavoUi.CreateLib("Shakayik Cheat Hub", "DarkTheme")

-- Görseldeki Menü Düzeni (Sol Sekmeler)
local UtilsTab = Window:NewTab("Utils")
local FarmingTab = Window:NewTab("Farming")
local TeleportTab = Window:NewTab("İşınlanma")
local StatsTab = Window:NewTab("Skill Points")

-- SEKMELERİN İÇERİĞİ
local UtilsSection = UtilsTab:NewSection("Genel Ayarlar")
UtilsSection:NewToggle("AFK Mode", "Oyundan atılmanı engeller", function(state)
    _G.Settings.AFKMode = state
    SaveConfig()
end)

local FarmSection = FarmingTab:NewSection("Otomatik Kasılma")
FarmSection:NewToggle("Otomatik Çiftlik (Auto Farm)", "Otomatik seviye kasar", function(state)
    _G.Settings.AutoFarm = state
    SaveConfig()
end)

local TeleportSection = TeleportTab:NewSection("Teleport to Sea")
TeleportSection:NewButton("Ada İşınlanma (Sea 2)", "700 Level iseniz kaptana uçurur", function()
    if Player.Data.Level.Value >= 700 then
        TweenToCFrame(IslandPositions["Orta Şehir"])
    end
end)

TeleportSection:NewSection("Select Island")
TeleportSection:NewDropdown("Ada Seçin", "Işınlanılacak ada", {"Hapishane", "Karlı Köy", "Orta Şehir", "Başlangıç Adası"}, function(currentOption)
    _G.Settings.SelectedIsland = currentOption
    SaveConfig()
end)

TeleportSection:NewToggle("Tween to Island", "Seçili adaya güvenli uçar", function(state)
    if state then
        local target = IslandPositions[_G.Settings.SelectedIsland]
        if target then TweenToCFrame(target) end
    end
end)

TeleportSection:NewSection("Shop NPCs")
TeleportSection:NewDropdown("Choose NPC", "NPC Seçimi", {"Random Devil Fruit", "Ability Teacher"}, function(currentOption)
    _G.Settings.SelectedNPC = currentOption
    SaveConfig()
end)

local StatsSection = StatsTab:NewSection("Stat Dağıtıcı")
StatsSection:NewToggle("Yumruk Geliştir (Melee)", "Otomatik puan verir", function(state)
    _G.Settings.AutoStats.Melee = state
    SaveConfig()
end)

-- Anti AFK Aktif Etme
pcall(function()
    Player.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
    end)
end)
