-- ============================================
-- GROW A GARDEN - PET SNIPER v3.0
-- GitHub: https://github.com/[USERNAME]/pet-sniper-v3
-- ============================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local PetSniper = {
    settings = {
        targetPets = {"Spring bee", "Jerboa", "Nyala"},
        targetPrice = 20,
        priceRange = 2,
        checkInterval = 0.6,
        buyDelay = 0.4,
        serverHopDelay = 2.5,
        scanDuration = 5,
        autoClick = true,
        soundAlert = true,
        autoServerHop = true,
        maxAttempts = 100,
        stopAfterBuy = true
    },
    stats = {
        found = 0,
        bought = 0,
        totalSpent = 0,
        serverHops = 0,
        attempts = 0,
        currentServer = 1
    },
    isRunning = false,
    scanStartTime = 0,
    logs = {}
}

-- ============================================
-- CREATE UI
-- ============================================

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetSniperGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 900)
    mainFrame.Position = UDim2.new(1, -470, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(102, 126, 234)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(102, 126, 234)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Text = "🎯 PET SNIPER v3.0"
    title.BorderSizePixel = 0
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundColor3 = Color3.fromRGB(102, 126, 234)
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "Auto Server Hop + Multi-Pet Search"
    subtitle.BorderSizePixel = 0
    subtitle.Parent = mainFrame
    
    -- Scroll Frame untuk konten
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -150)
    scrollFrame.Position = UDim2.new(0, 10, 0, 80)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(102, 126, 234)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mainFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = scrollFrame
    
    -- TARGET PETS SECTION
    local petLabel = Instance.new("TextLabel")
    petLabel.Name = "PetLabel"
    petLabel.Size = UDim2.new(1, -20, 0, 25)
    petLabel.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
    petLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    petLabel.TextSize = 12
    petLabel.Font = Enum.Font.GothamBold
    petLabel.Text = "🐝 TARGET PETS"
    petLabel.BorderSizePixel = 0
    petLabel.Parent = scrollFrame
    
    local petCorner = Instance.new("UICorner")
    petCorner.CornerRadius = UDim.new(0, 8)
    petCorner.Parent = petLabel
    
    local petInput = Instance.new("TextBox")
    petInput.Name = "PetInput"
    petInput.Size = UDim2.new(1, -20, 0, 35)
    petInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    petInput.TextColor3 = Color3.fromRGB(51, 51, 51)
    petInput.TextSize = 12
    petInput.Font = Enum.Font.Gotham
    petInput.Text = "Spring bee,Jerboa,Nyala"
    petInput.PlaceholderText = "Pisahkan dengan koma"
    petInput.BorderSizePixel = 0
    petInput.Parent = scrollFrame
    
    local petInputCorner = Instance.new("UICorner")
    petInputCorner.CornerRadius = UDim.new(0, 5)
    petInputCorner.Parent = petInput
    
    -- PRICE SECTION
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "PriceLabel"
    priceLabel.Size = UDim2.new(1, -20, 0, 25)
    priceLabel.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
    priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    priceLabel.TextSize = 12
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.Text = "💰 HARGA TARGET"
    priceLabel.BorderSizePixel = 0
    priceLabel.Parent = scrollFrame
    
    local priceCorner = Instance.new("UICorner")
    priceCorner.CornerRadius = UDim.new(0, 8)
    priceCorner.Parent = priceLabel
    
    -- Price Container
    local priceContainer = Instance.new("Frame")
    priceContainer.Name = "PriceContainer"
    priceContainer.Size = UDim2.new(1, -20, 0, 40)
    priceContainer.BackgroundTransparency = 1
    priceContainer.Parent = scrollFrame
    
    local priceGridLayout = Instance.new("UIGridLayout")
    priceGridLayout.CellSize = UDim2.new(0.5, -5, 0, 40)
    priceGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    priceGridLayout.Parent = priceContainer
    
    local targetPriceInput = Instance.new("TextBox")
    targetPriceInput.Name = "TargetPrice"
    targetPriceInput.Size = UDim2.new(1, 0, 1, 0)
    targetPriceInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    targetPriceInput.TextColor3 = Color3.fromRGB(51, 51, 51)
    targetPriceInput.TextSize = 12
    targetPriceInput.Font = Enum.Font.Gotham
    targetPriceInput.Text = "20"
    targetPriceInput.BorderSizePixel = 0
    targetPriceInput.Parent = priceContainer
    
    local targetPriceCorner = Instance.new("UICorner")
    targetPriceCorner.CornerRadius = UDim.new(0, 5)
    targetPriceCorner.Parent = targetPriceInput
    
    local priceRangeInput = Instance.new("TextBox")
    priceRangeInput.Name = "PriceRange"
    priceRangeInput.Size = UDim2.new(1, 0, 1, 0)
    priceRangeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    priceRangeInput.TextColor3 = Color3.fromRGB(51, 51, 51)
    priceRangeInput.TextSize = 12
    priceRangeInput.Font = Enum.Font.Gotham
    priceRangeInput.Text = "2"
    priceRangeInput.BorderSizePixel = 0
    priceRangeInput.Parent = priceContainer
    
    local priceRangeCorner = Instance.new("UICorner")
    priceRangeCorner.CornerRadius = UDim.new(0, 5)
    priceRangeCorner.Parent = priceRangeInput
    
    -- Price Info
    local priceInfo = Instance.new("TextLabel")
    priceInfo.Name = "PriceInfo"
    priceInfo.Size = UDim2.new(1, -20, 0, 25)
    priceInfo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    priceInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    priceInfo.TextSize = 12
    priceInfo.Font = Enum.Font.Gotham
    priceInfo.Text = "Mencari harga: 18-22 token"
    priceInfo.BorderSizePixel = 0
    priceInfo.Parent = scrollFrame
    
    local priceInfoCorner = Instance.new("UICorner")
    priceInfoCorner.CornerRadius = UDim.new(0, 5)
    priceInfoCorner.Parent = priceInfo
    
    -- TIMING SECTION
    local timingLabel = Instance.new("TextLabel")
    timingLabel.Name = "TimingLabel"
    timingLabel.Size = UDim2.new(1, -20, 0, 25)
    timingLabel.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
    timingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timingLabel.TextSize = 12
    timingLabel.Font = Enum.Font.GothamBold
    timingLabel.Text = "⏱️ TIMING (detik)"
    timingLabel.BorderSizePixel = 0
    timingLabel.Parent = scrollFrame
    
    local timingCorner = Instance.new("UICorner")
    timingCorner.CornerRadius = UDim.new(0, 8)
    timingCorner.Parent = timingLabel
    
    -- Timing inputs
    local timingInputs = {}
    local timingData = {
        {label = "Check Interval", value = "0.6"},
        {label = "Scan Duration", value = "5"},
        {label = "Server Hop Delay", value = "2.5"},
        {label = "Buy Delay", value = "0.4"}
    }
    
    for _, data in ipairs(timingData) do
        local container = Instance.new("Frame")
        container.Name = data.label
        container.Size = UDim2.new(1, -20, 0, 35)
        container.BackgroundTransparency = 1
        container.Parent = scrollFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.Text = data.label
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local input = Instance.new("TextBox")
        input.Name = data.label
        input.Size = UDim2.new(0.6, -5, 1, 0)
        input.Position = UDim2.new(0.4, 5, 0, 0)
        input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        input.TextColor3 = Color3.fromRGB(51, 51, 51)
        input.TextSize = 12
        input.Font = Enum.Font.Gotham
        input.Text = data.value
        input.BorderSizePixel = 0
        input.Parent = container
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = input
        
        table.insert(timingInputs, input)
    end
    
    -- OPTIONS SECTION
    local optionsLabel = Instance.new("TextLabel")
    optionsLabel.Name = "OptionsLabel"
    optionsLabel.Size = UDim2.new(1, -20, 0, 25)
    optionsLabel.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
    optionsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionsLabel.TextSize = 12
    optionsLabel.Font = Enum.Font.GothamBold
    optionsLabel.Text = "⚙️ OPTIONS"
    optionsLabel.BorderSizePixel = 0
    optionsLabel.Parent = scrollFrame
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 8)
    optionsCorner.Parent = optionsLabel
    
    local options = {
        {name = "autoClick", label = "🖱️ Auto Click"},
        {name = "soundAlert", label = "🔊 Sound Alert"},
        {name = "autoServerHop", label = "🌐 Auto Server Hop"}
    }
    
    local checkboxes = {}
    
    for _, opt in ipairs(options) do
        local checkboxFrame = Instance.new("Frame")
        checkboxFrame.Name = opt.name
        checkboxFrame.Size = UDim2.new(1, -20, 0, 30)
        checkboxFrame.BackgroundTransparency = 1
        checkboxFrame.Parent = scrollFrame
        
        local checkbox = Instance.new("TextButton")
        checkbox.Name = "Checkbox"
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.BackgroundColor3 = Color3.fromRGB(76, 200, 80)
        checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkbox.TextSize = 14
        checkbox.Font = Enum.Font.GothamBold
        checkbox.Text = "✓"
        checkbox.BorderSizePixel = 0
        checkbox.Parent = checkboxFrame
        
        local checkboxCorner = Instance.new("UICorner")
        checkboxCorner.CornerRadius = UDim.new(0, 4)
        checkboxCorner.Parent = checkbox
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -30, 1, 0)
        label.Position = UDim2.new(0, 30, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.Text = opt.label
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = checkboxFrame
        
        local isChecked = true
        checkbox.MouseButton1Click:Connect(function()
            isChecked = not isChecked
            checkbox.BackgroundColor3 = isChecked and Color3.fromRGB(76, 200, 80) or Color3.fromRGB(150, 150, 150)
            checkbox.Text = isChecked and "✓" or ""
        end)
        
        checkboxes[opt.name] = {
            button = checkbox,
            isChecked = function() return isChecked end
        }
    end
    
    -- STATS SECTION
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -20, 0, 25)
    statsLabel.BackgroundColor3 = Color3.fromRGB(76, 76, 76)
    statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsLabel.TextSize = 12
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.Text = "📊 STATS"
    statsLabel.BorderSizePixel = 0
    statsLabel.Parent = scrollFrame
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 8)
    statsCorner.Parent = statsLabel
    
    local statsFrame = Instance.new("TextLabel")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, -20, 0, 80)
    statsFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statsFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsFrame.TextSize = 12
    statsFrame.Font = Enum.Font.Gotham
    statsFrame.Text = "🔍 Found: 0 | ✅ Bought: 0\n💰 Spent: 0T | 🌐 Hops: 0\n📌 Attempts: 0/100 | Server: 1"
    statsFrame.TextWrapped = true
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = scrollFrame
    
    local statsFrameCorner = Instance.new("UICorner")
    statsFrameCorner.CornerRadius = UDim.new(0, 5)
    statsFrameCorner.Parent = statsFrame
    
    -- STATUS SECTION
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.BackgroundColor3 = Color3.fromRGB(76, 200, 80)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Text = "Status: Ready"
    statusLabel.BorderSizePixel = 0
    statusLabel.Parent = scrollFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusLabel
    
    -- BUTTONS
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 50)
    buttonContainer.Position = UDim2.new(0, 10, 1, -60)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    local buttonLayout = Instance.new("UIGridLayout")
    buttonLayout.CellSize = UDim2.new(0.5, -5, 1, 0)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    buttonLayout.Parent = buttonContainer
    
    local startBtn = Instance.new("TextButton")
    startBtn.Name = "StartBtn"
    startBtn.Size = UDim2.new(1, 0, 1, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(76, 200, 80)
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.TextSize = 14
    startBtn.Font = Enum.Font.GothamBold
    startBtn.Text = "▶️ START"
    startBtn.BorderSizePixel = 0
    startBtn.Parent = buttonContainer
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 8)
    startCorner.Parent = startBtn
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Name = "StopBtn"
    stopBtn.Size = UDim2.new(1, 0, 1, 0)
    stopBtn.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 14
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Text = "⏹️ STOP"
    stopBtn.BorderSizePixel = 0
    stopBtn.Parent = buttonContainer
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopBtn
    
    return {
        mainFrame = mainFrame,
        petInput = petInput,
        targetPriceInput = targetPriceInput,
        priceRangeInput = priceRangeInput,
        priceInfo = priceInfo,
        timingInputs = timingInputs,
        checkboxes = checkboxes,
        statsFrame = statsFrame,
        statusLabel = statusLabel,
        startBtn = startBtn,
        stopBtn = stopBtn,
        scrollFrame = scrollFrame
    }
end

-- ============================================
-- MAIN FUNCTIONS
-- ============================================

local ui = createUI()

local function updatePriceInfo()
    local target = tonumber(ui.targetPriceInput.Text) or 20
    local range = tonumber(ui.priceRangeInput.Text) or 2
    local min = target - range
    local max = target + range
    ui.priceInfo.Text = "Mencari harga: " .. min .. "-" .. max .. " token"
end

local function updateStats()
    ui.statsFrame.Text = string.format(
        "🔍 Found: %d | ✅ Bought: %d\n💰 Spent: %dT | 🌐 Hops: %d\n📌 Attempts: %d/100 | Server: %d",
        PetSniper.stats.found,
        PetSniper.stats.bought,
        PetSniper.stats.totalSpent,
        PetSniper.stats.serverHops,
        PetSniper.stats.attempts,
        PetSniper.stats.currentServer
    )
end

local function updateStatus(status, color)
    ui.statusLabel.Text = "Status: " .. status
    ui.statusLabel.BackgroundColor3 = color or Color3.fromRGB(76, 200, 80)
end

local function addLog(message)
    table.insert(PetSniper.logs, message)
    if #PetSniper.logs > 50 then
        table.remove(PetSniper.logs, 1)
    end
    print("[PET SNIPER] " .. message)
end

local function playSound(success)
    local sound = Instance.new("Sound")
    sound.Volume = 0.5
    sound.Parent = workspace
    
    if success then
        sound.SoundId = "rbxassetid://12221967"
    else
        sound.SoundId = "rbxassetid://4363899"
    end
    
    game:GetService("Debris"):AddItem(sound, 2)
    sound:Play()
end

local function searchPets()
    local foundPets = {}
    local allObjects = game:GetDescendants()
    
    for _, obj in ipairs(allObjects) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = obj.Text or ""
            
            for _, petName in ipairs(PetSniper.settings.targetPets) do
                if string.find(text:lower(), petName:lower()) then
                    local priceMatch = string.match(text, "(%d+)%s*(?:token|t|coins?|💰)")
                    if priceMatch then
                        local price = tonumber(priceMatch)
                        local minPrice = PetSniper.settings.targetPrice - PetSniper.settings.priceRange
                        local maxPrice = PetSniper.settings.targetPrice + PetSniper.settings.priceRange
                        
                        if price >= minPrice and price <= maxPrice then
                            table.insert(foundPets, {
                                name = petName,
                                price = price,
                                element = obj
                            })
                        end
                    end
                end
            end
        end
    end
    
    return foundPets
end

local function buyPet(petInfo)
    if PetSniper.settings.autoClick then
        petInfo.element:FireEvent("MouseButton1Click")
        wait(PetSniper.settings.buyDelay)
        
        PetSniper.stats.bought = PetSniper.stats.bought + 1
        PetSniper.stats.totalSpent = PetSniper.stats.totalSpent + petInfo.price
        updateStats()
        
        addLog("✅ BOUGHT: " .. petInfo.name .. " - " .. petInfo.price .. " token")
        
        if PetSniper.settings.soundAlert then
            playSound(true)
        end
    end
end

local function hopServer()
    if not PetSniper.settings.autoServerHop then return end
    
    PetSniper.stats.serverHops = PetSniper.stats.serverHops + 1
    PetSniper.stats.currentServer = PetSniper.stats.currentServer + 1
    PetSniper.stats.found = 0
    
    updateStats()
    addLog("🌐 Hop #" .. PetSniper.stats.serverHops .. " → Server " .. PetSniper.stats.currentServer)
    updateStatus("Hopping Server...", Color3.fromRGB(255, 152, 0))
    
    wait(PetSniper.settings.serverHopDelay)
    
    local teleportService
