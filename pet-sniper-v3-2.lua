-- ============================================
-- GROW A GARDEN - PET SNIPER v3.2 (CLEAN)
-- UNTUK DELTA EXECUTOR
-- ============================================

-- Anti-Double Load
if _G.PetSniperV32 then
    warn("⚠️ Pet Sniper v3.2 sudah aktif!")
    return
end
_G.PetSniperV32 = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    -- Target Pet
    targetPets = {"Spring bee", "Jerboa", "Nyala"},
    targetPrice = 20,
    priceRange = 2, -- ±2
    
    -- Timing
    scanInterval = 1,
    buyDelay = 0.5,
    hopDelay = 3,
    
    -- Features
    autoClick = true,
    soundAlert = true,
    autoHop = true,
    maxAttempts = 50
}

-- ============================================
-- STATE
-- ============================================

local State = {
    isRunning = false,
    found = 0,
    bought = 0,
    spent = 0,
    hopped = 0,
    attempts = 0,
    startTime = 0
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function log(msg)
    local time = os.date("%H:%M:%S")
    print("[" .. time .. "] " .. msg)
end

local function playSound()
    if not Config.soundAlert then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://12221967"
        sound.Volume = 0.5
        sound.Parent = workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

local function getPetInfo(element)
    if not element then return nil, nil end
    
    local name = nil
    local price = nil
    
    -- Cari nama pet
    pcall(function()
        local nameLabel = element:FindFirstChild("PetName") or 
                         element:FindFirstChild("Name") or
                         element:FindFirstChildOfClass("TextLabel")
        if nameLabel then
            name = nameLabel.Text
        end
    end)
    
    -- Cari harga
    pcall(function()
        local priceLabel = element:FindFirstChild("Price") or
                          element:FindFirstChild("Cost")
        if priceLabel then
            local priceText = priceLabel.Text
            price = tonumber(priceText:match("%d+"))
        end
    end)
    
    return name, price
end

local function isTargetPet(name, price)
    if not name or not price then return false, nil end
    
    for _, target in ipairs(Config.targetPets) do
        local targetLower = string.lower(target)
        local nameLower = string.lower(name)
        
        if string.find(nameLower, targetLower) then
            local minPrice = Config.targetPrice - Config.priceRange
            local maxPrice = Config.targetPrice + Config.priceRange
            
            if price >= minPrice and price <= maxPrice then
                return true, target
            end
        end
    end
    
    return false, nil
end

local function scanMarket()
    log("🔍 Scanning market...")
    
    local marketGui = nil
    
    -- Cari market GUI
    pcall(function()
        marketGui = playerGui:FindFirstChild("MarketGui") or
                   playerGui:FindFirstChild("ShopGui") or
                   playerGui:FindFirstChild("Store")
    end)
    
    if not marketGui then
        log("⚠️ Market GUI tidak ditemukan!")
        return false
    end
    
    -- Scan semua button/frame
    local found = false
    pcall(function()
        for _, item in ipairs(marketGui:GetDescendants()) do
            if item:IsA("GuiButton") or (item:IsA("Frame") and item:FindFirstChildOfClass("TextLabel")) then
                local petName, petPrice = getPetInfo(item)
                
                if petName and petPrice then
                    local isTarget, targetName = isTargetPet(petName, petPrice)
                    
                    if isTarget then
                        log("✅ FOUND: " .. targetName .. " @ " .. petPrice .. " token!")
                        State.found = State.found + 1
                        playSound()
                        
                        if Config.autoClick then
                            log("💰 Buying " .. targetName .. "...")
                            wait(Config.buyDelay)
                            
                            -- Click pet
                            pcall(function()
                                item:FireSignal(item.Activated)
                                item.MouseButton1Click:Fire()
                            end)
                            
                            State.bought = State.bought + 1
                            State.spent = State.spent + petPrice
                            log("✨ SUCCESS! Bought " .. targetName)
                        end
                        
                        found = true
                        break
                    end
                end
            end
        end
    end)
    
    if not found then
        log("❌ Pet tidak ditemukan")
    end
    
    return found
end

local function hopServer()
    if not Config.autoHop then return end
    
    State.hopped = State.hopped + 1
    log("🌐 Server hop #" .. State.hopped .. "...")
    
    wait(Config.hopDelay)
    
    pcall(function()
        local placeId = game.PlaceId
        TeleportService:Teleport(placeId, player)
    end)
end

-- ============================================
-- UI FUNCTIONS
-- ============================================

local function createUI()
    -- Cleanup UI lama
    pcall(function()
        playerGui:FindFirstChild("PetSniperUI"):Destroy()
    end)
    
    -- Main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetSniperUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Background
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(0, 320, 0, 420)
    bg.Position = UDim2.new(0.5, -160, 0.5, -210)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bg.BorderSizePixel = 2
    bg.BorderColor3 = Color3.fromRGB(0, 120, 215)
    bg.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "🎯 PET SNIPER v3.2"
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.BorderSizePixel = 0
    title.Parent = bg
    
    -- Info Box
    local infoBox = Instance.new("TextLabel")
    infoBox.Name = "InfoBox"
    infoBox.Size = UDim2.new(1, -20, 0, 80)
    infoBox.Position = UDim2.new(0, 10, 0, 60)
    infoBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    infoBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoBox.Text = "🎯 Target: Spring bee, Jerboa, Nyala\n💵 Harga: 20±2 token\n🌐 Auto Hop: " .. (Config.autoHop and "✅" or "❌")
    infoBox.TextSize = 12
    infoBox.Font = Enum.Font.Gotham
    infoBox.TextWrapped = true
    infoBox.BorderSizePixel = 0
    infoBox.Parent = bg
    
    -- Start Button
    local startBtn = Instance.new("TextButton")
    startBtn.Name = "StartBtn"
    startBtn.Size = UDim2.new(0.45, 0, 0, 45)
    startBtn.Position = UDim2.new(0, 10, 0, 150)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.Text = "▶️ START"
    startBtn.TextSize = 14
    startBtn.Font = Enum.Font.GothamBold
    startBtn.BorderSizePixel = 0
    startBtn.Parent = bg
    
    -- Stop Button
    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "StopBtn"
    stopBtn.Size = UDim2.new(0.45, 0, 0, 45)
    stopBtn.Position = UDim2.new(0.55, 0, 0, 150)
    stopBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.Text = "⏹️ STOP"
    stopBtn.TextSize = 14
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.BorderSizePixel = 0
    stopBtn.Parent = bg
    
    -- Stats Box
    local statsBox = Instance.new("TextLabel")
    statsBox.Name = "StatsBox"
    statsBox.Size = UDim2.new(1, -20, 0, 120)
    statsBox.Position = UDim2.new(0, 10, 0, 210)
    statsBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statsBox.TextColor3 = Color3.fromRGB(100, 200, 100)
    statsBox.Text = "📊 STATISTICS\n\n✅ Found: 0\n💳 Bought: 0\n💰 Spent: 0\n🌐 Hopped: 0x"
    statsBox.TextSize = 12
    statsBox.Font = Enum.Font.Gotham
    statsBox.TextWrapped = true
    statsBox.BorderSizePixel = 0
    statsBox.Parent = bg
    
    -- Status Label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 340)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    statusLabel.Text = "⏸️ Idle"
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.BorderSizePixel = 0
    statusLabel.Parent = bg
    
    -- Button Events
    startBtn.MouseButton1Click:Connect(function()
        if not State.isRunning then
            State.isRunning = true
            State.startTime = os.time()
            State.attempts = 0
            startBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
            startBtn.Text = "⏳ RUNNING..."
            statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
            statusLabel.Text = "🟢 Running..."
        end
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        State.isRunning = false
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        startBtn.Text = "▶️ START"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
        statusLabel.Text = "🟠 Stopped"
    end)
    
    -- Update Stats Loop
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        statsBox.Text = "📊 STATISTICS\n\n✅ Found: " .. State.found ..
                       "\n💳 Bought: " .. State.bought ..
                       "\n💰 Spent: " .. State.spent ..
                       "\n🌐 Hopped: " .. State.hopped .. "x"
    end)
    
    return screenGui
end

-- ============================================
-- MAIN LOOP
-- ============================================

local function start()
    log("🚀 Pet Sniper v3.2 dimulai!")
    log("🎯 Target: " .. table.concat(Config.targetPets, ", "))
    log("💵 Harga: " .. Config.targetPrice .. "±" .. Config.priceRange .. " token")
    
    while State.isRunning and State.attempts < Config.maxAttempts do
        State.attempts = State.attempts + 1
        
        local found = scanMarket()
        
        if found then
            log("🎉 MISSION ACCOMPLISHED!")
            log("⏱️ Total waktu: " .. (os.time() - State.startTime) .. " detik")
            State.isRunning = false
            break
        end
        
        hopServer()
        wait(Config.scanInterval)
    end
    
    if State.attempts >= Config.maxAttempts then
        log("⚠️ Max attempts reached!")
        State.isRunning = false
    end
end

-- ============================================
-- INIT
-- ============================================

createUI()

-- Global Access
_G.PetSniper = {
    start = function()
        if not State.isRunning then
            State.isRunning = true
            State.startTime = os.time()
            State.attempts = 0
            task.spawn(start)
        end
    end,
    stop = function()
        State.isRunning = false
    end,
    stats = State,
    config = Config
}

log("✅ Pet Sniper v3.2 loaded!")
log("📌 Gunakan UI atau ketik: _G.PetSniper.start()")
