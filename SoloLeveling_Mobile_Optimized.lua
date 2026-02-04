--[[
═══════════════════════════════════════════════════════════════════════════
⚡ SOLO LEVELING SYSTEM - MOBILE OPTIMIZED
📱 Codex/Delta Compatible - Phone Optimized
🎮 The Strongest Battlegrounds Compatible
═══════════════════════════════════════════════════════════════════════════

✨ FEATURES:
- Mobile-friendly 3D UI (touch compatible)
- No animation dependencies (fixes asset errors)
- Lightweight for phone performance
- TSB speed system fixed
- No VFX/camera shake (performance optimized)

🎯 CONTROLS (MOBILE):
- Touch UI buttons for stats
- [E] - Shadow Step
- [R] - Rampage (NO EFFECTS)
- [F] - Behind You
- UI Toggle button on screen

═══════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════
-- 🔧 SERVICES & MOBILE DETECTION
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Mobile detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════
-- 📊 PLAYER DATA
-- ═══════════════════════════════════════════════════════════════

local PlayerData = {
    level = 1,
    exp = 0,
    expNeeded = 100,
    
    stats = {
        strength = 1,
        vitality = 1,
        agility = 1,
        intelligence = 1,
        sense = 1
    },
    
    statPoints = 5,
    
    abilities = {
        shadowStep = {cooldown = 5, lastUsed = 0},
        rampage = {cooldown = 15, lastUsed = 0, duration = 8, active = false},
        behindYou = {cooldown = 10, lastUsed = 0, range = 50}
    },
    
    baseWalkSpeed = 16,
    baseJumpPower = 50,
    baseHealth = 100
}

-- ═══════════════════════════════════════════════════════════════
-- 🎨 UI STORAGE
-- ═══════════════════════════════════════════════════════════════

local uiElements = {
    mainPart = nil,
    surfaceGui = nil,
    isVisible = false,
    statLabels = {},
    levelLabel = nil,
    expBar = nil,
    expText = nil,
    pointsLabel = nil,
    toggleButton = nil
}

local acceptedNotification = false

-- ═══════════════════════════════════════════════════════════════
-- 🎯 UI FOLLOW SYSTEM (Optimized for mobile)
-- ═══════════════════════════════════════════════════════════════

local FollowController = {
    enabled = false,
    distance = 5,
    height = 1.5,
    updateRate = 0.1,
    lastUpdate = 0
}

function FollowController:start()
    self.enabled = true
    
    RunService.Heartbeat:Connect(function()
        if not self.enabled or not uiElements.mainPart or not uiElements.mainPart.Parent then
            return
        end
        
        -- Throttle updates for mobile performance
        if tick() - self.lastUpdate < self.updateRate then
            return
        end
        self.lastUpdate = tick()
        
        if not character or not character.Parent then
            character = player.Character
            if not character then return end
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local lookVector = hrp.CFrame.LookVector
        local targetPosition = hrp.Position + (lookVector * self.distance) + Vector3.new(0, self.height, 0)
        local targetCFrame = CFrame.new(targetPosition, hrp.Position + Vector3.new(0, self.height, 0))
        
        uiElements.mainPart.CFrame = uiElements.mainPart.CFrame:Lerp(targetCFrame, 0.15)
    end)
end

function FollowController:stop()
    self.enabled = false
end

-- ═══════════════════════════════════════════════════════════════
-- 💻 UI MODULE
-- ═══════════════════════════════════════════════════════════════

local UIModule = {}

-- Create ability button
function UIModule.createAbilityButton(parent, name, key, order, color)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, 0, 0, 60)
    button.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.LayoutOrder = order
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    nameLabel.TextSize = 20
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 45, 0, 30)
    keyLabel.Position = UDim2.new(1, -55, 0.5, -15)
    keyLabel.BackgroundColor3 = color
    keyLabel.BackgroundTransparency = 0.3
    keyLabel.BorderSizePixel = 0
    keyLabel.Text = key
    keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.TextSize = 18
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.Parent = button
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyLabel
    
    return button
end

-- ═══════════════════════════════════════════════════════════════
-- ⭐ NOTIFICATION (Mobile Optimized)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createInitialNotification()
    if acceptedNotification then return end
    
    local notifPart = Instance.new("Part")
    notifPart.Name = "NotificationPanel"
    notifPart.Size = Vector3.new(10, 6, 0.1)
    notifPart.Anchored = true
    notifPart.CanCollide = false
    notifPart.Material = Enum.Material.ForceField
    notifPart.Transparency = 1
    notifPart.Parent = workspace
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local lookVector = hrp.CFrame.LookVector
        notifPart.CFrame = CFrame.new(hrp.Position + (lookVector * 7) + Vector3.new(0, 2, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1000, 600)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = notifPart
    
    local mainBg = Instance.new("Frame")
    mainBg.Size = UDim2.new(1, 0, 1, 0)
    mainBg.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    mainBg.BackgroundTransparency = 0.1
    mainBg.BorderSizePixel = 0
    mainBg.Parent = surfaceGui
    
    -- Borders
    local function createBorder(position, size, rotation)
        local border = Instance.new("Frame")
        border.Size = size
        border.Position = position
        border.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        border.BorderSizePixel = 0
        border.Parent = mainBg
        
        local grad = Instance.new("UIGradient")
        grad.Rotation = rotation or 0
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.3)
        })
        grad.Parent = border
        return border
    end
    
    createBorder(UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 6), 0)
    createBorder(UDim2.new(0, 0, 1, -6), UDim2.new(1, 0, 0, 6), 0)
    createBorder(UDim2.new(0, 0, 0, 0), UDim2.new(0, 6, 1, 0), 90)
    createBorder(UDim2.new(1, -6, 0, 0), UDim2.new(0, 6, 1, 0), 90)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -30, 0, 80)
    header.Position = UDim2.new(0, 15, 0, 20)
    header.BackgroundTransparency = 1
    header.Parent = mainBg
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 60, 0, 60)
    iconFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = header
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0.15, 0)
    iconCorner.Parent = iconFrame
    
    local exclamation = Instance.new("TextLabel")
    exclamation.Size = UDim2.new(1, 0, 1, 0)
    exclamation.BackgroundTransparency = 1
    exclamation.Text = "!"
    exclamation.TextColor3 = Color3.fromRGB(255, 255, 255)
    exclamation.TextSize = 45
    exclamation.Font = Enum.Font.GothamBold
    exclamation.Parent = iconFrame
    
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(1, -80, 0, 60)
    notifLabel.Position = UDim2.new(0, 75, 0, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "NOTIFICATION"
    notifLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    notifLabel.TextSize = 36
    notifLabel.Font = Enum.Font.GothamBold
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = header
    
    -- Message
    local messageBox = Instance.new("Frame")
    messageBox.Size = UDim2.new(1, -40, 0, 180)
    messageBox.Position = UDim2.new(0, 20, 0, 120)
    messageBox.BackgroundTransparency = 1
    messageBox.Parent = mainBg
    
    local message1 = Instance.new("TextLabel")
    message1.Size = UDim2.new(1, 0, 0, 50)
    message1.BackgroundTransparency = 1
    message1.Text = "You have acquired the qualifications"
    message1.TextColor3 = Color3.fromRGB(200, 220, 255)
    message1.TextSize = 26
    message1.Font = Enum.Font.Gotham
    message1.Parent = messageBox
    
    local message2Container = Instance.new("Frame")
    message2Container.Size = UDim2.new(1, 0, 0, 50)
    message2Container.Position = UDim2.new(0, 0, 0, 55)
    message2Container.BackgroundTransparency = 1
    message2Container.Parent = messageBox
    
    local message2a = Instance.new("TextLabel")
    message2a.Size = UDim2.new(0.3, 0, 1, 0)
    message2a.Position = UDim2.new(0.1, 0, 0, 0)
    message2a.BackgroundTransparency = 1
    message2a.Text = "to be a "
    message2a.TextColor3 = Color3.fromRGB(200, 220, 255)
    message2a.TextSize = 26
    message2a.Font = Enum.Font.Gotham
    message2a.TextXAlignment = Enum.TextXAlignment.Right
    message2a.Parent = message2Container
    
    local playerText = Instance.new("TextLabel")
    playerText.Size = UDim2.new(0.25, 0, 1, 0)
    playerText.Position = UDim2.new(0.4, 0, 0, 0)
    playerText.BackgroundTransparency = 1
    playerText.Text = "Player"
    playerText.TextColor3 = Color3.fromRGB(0, 180, 255)
    playerText.TextSize = 30
    playerText.Font = Enum.Font.GothamBold
    playerText.Parent = message2Container
    
    local playerGlow = Instance.new("UIStroke")
    playerGlow.Color = Color3.fromRGB(0, 180, 255)
    playerGlow.Thickness = 2
    playerGlow.Transparency = 0.5
    playerGlow.Parent = playerText
    
    local message2b = Instance.new("TextLabel")
    message2b.Size = UDim2.new(0.3, 0, 1, 0)
    message2b.Position = UDim2.new(0.65, 0, 0, 0)
    message2b.BackgroundTransparency = 1
    message2b.Text = ". Will you accept?"
    message2b.TextColor3 = Color3.fromRGB(200, 220, 255)
    message2b.TextSize = 26
    message2b.Font = Enum.Font.Gotham
    message2b.TextXAlignment = Enum.TextXAlignment.Left
    message2b.Parent = message2Container
    
    -- Buttons
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 70)
    buttonContainer.Position = UDim2.new(0, 0, 1, -120)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainBg
    
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Size = UDim2.new(0, 200, 0, 60)
    acceptBtn.Position = UDim2.new(0.5, -210, 0, 0)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    acceptBtn.BorderSizePixel = 0
    acceptBtn.Text = "ACCEPT"
    acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptBtn.TextSize = 28
    acceptBtn.Font = Enum.Font.GothamBold
    acceptBtn.AutoButtonColor = false
    acceptBtn.Parent = buttonContainer
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 10)
    acceptCorner.Parent = acceptBtn
    
    local declineBtn = Instance.new("TextButton")
    declineBtn.Size = UDim2.new(0, 200, 0, 60)
    declineBtn.Position = UDim2.new(0.5, 10, 0, 0)
    declineBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    declineBtn.BorderSizePixel = 0
    declineBtn.Text = "DECLINE"
    declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    declineBtn.TextSize = 28
    declineBtn.Font = Enum.Font.GothamBold
    declineBtn.AutoButtonColor = false
    declineBtn.Parent = buttonContainer
    
    local declineCorner = Instance.new("UICorner")
    declineCorner.CornerRadius = UDim.new(0, 10)
    declineCorner.Parent = declineBtn
    
    -- Button handlers
    acceptBtn.MouseButton1Click:Connect(function()
        acceptedNotification = true
        
        for _, child in ipairs(mainBg:GetDescendants()) do
            if child:IsA("GuiObject") then
                pcall(function()
                    TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                end)
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    pcall(function()
                        TweenService:Create(child, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                    end)
                end
            end
        end
        
        task.wait(0.5)
        notifPart:Destroy()
        UIModule.createMainUI()
    end)
    
    declineBtn.MouseButton1Click:Connect(function()
        notifPart:Destroy()
    end)
    
    -- Touch-friendly hover effects
    local function setupButtonEffect(button, normalColor, hoverColor)
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor}):Play()
        end)
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    setupButtonEffect(acceptBtn, Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 180, 255))
    setupButtonEffect(declineBtn, Color3.fromRGB(200, 50, 50), Color3.fromRGB(230, 70, 70))
end

-- ═══════════════════════════════════════════════════════════════
-- ⭐ MAIN UI (Mobile Optimized)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createMainUI()
    if uiElements.mainPart and uiElements.mainPart.Parent then return end
    
    -- Main panel
    local mainPart = Instance.new("Part")
    mainPart.Name = "SystemUI"
    mainPart.Size = Vector3.new(12, 12, 0.1)
    mainPart.Anchored = true
    mainPart.CanCollide = false
    mainPart.Material = Enum.Material.ForceField
    mainPart.Transparency = 1
    mainPart.Parent = workspace
    
    uiElements.mainPart = mainPart
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local lookVector = hrp.CFrame.LookVector
        mainPart.CFrame = CFrame.new(hrp.Position + (lookVector * 5) + Vector3.new(0, 1.5, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1200, 1200)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = mainPart
    
    uiElements.surfaceGui = surfaceGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Parent = surfaceGui
    
    -- Borders
    local function createBorder(name, position, size, rotation)
        local border = Instance.new("Frame")
        border.Name = name
        border.Size = size
        border.Position = position
        border.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        border.BorderSizePixel = 0
        border.Parent = container
        
        local grad = Instance.new("UIGradient")
        grad.Rotation = rotation or 0
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.3)
        })
        grad.Parent = border
        return border
    end
    
    local topBorder = createBorder("TopBorder", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 5), 0)
    local bottomBorder = createBorder("BottomBorder", UDim2.new(0, 0, 1, -5), UDim2.new(1, 0, 0, 5), 0)
    local leftBorder = createBorder("LeftBorder", UDim2.new(0, 0, 0, 0), UDim2.new(0, 5, 1, 0), 90)
    local rightBorder = createBorder("RightBorder", UDim2.new(1, -5, 0, 0), UDim2.new(0, 5, 1, 0), 90)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -30, 0, 70)
    header.Position = UDim2.new(0, 15, 0, 12)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.55, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ SOLO LEVELING"
    titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    titleLabel.TextSize = 30
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextScaled = true
    titleLabel.Parent = header
    
    local infoPanel = Instance.new("Frame")
    infoPanel.Size = UDim2.new(0.42, 0, 1, 0)
    infoPanel.Position = UDim2.new(0.58, 0, 0, 0)
    infoPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    infoPanel.BackgroundTransparency = 0.3
    infoPanel.BorderSizePixel = 0
    infoPanel.Parent = header
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoPanel
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, -8, 0.5, 0)
    levelLabel.Position = UDim2.new(0, 4, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level: 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    levelLabel.TextSize = 20
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextScaled = true
    levelLabel.Parent = infoPanel
    
    uiElements.levelLabel = levelLabel
    
    local pointsLabel = Instance.new("TextLabel")
    pointsLabel.Size = UDim2.new(1, -8, 0.5, 0)
    pointsLabel.Position = UDim2.new(0, 4, 0.5, 0)
    pointsLabel.BackgroundTransparency = 1
    pointsLabel.Text = "Points: 5"
    pointsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    pointsLabel.TextSize = 20
    pointsLabel.Font = Enum.Font.GothamBold
    pointsLabel.TextScaled = true
    pointsLabel.Parent = infoPanel
    
    uiElements.pointsLabel = pointsLabel
    
    -- EXP Bar
    local expBarBg = Instance.new("Frame")
    expBarBg.Size = UDim2.new(1, -30, 0, 25)
    expBarBg.Position = UDim2.new(0, 15, 0, 90)
    expBarBg.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    expBarBg.BorderSizePixel = 0
    expBarBg.Parent = container
    
    local expBarCorner = Instance.new("UICorner")
    expBarCorner.CornerRadius = UDim.new(0, 5)
    expBarCorner.Parent = expBarBg
    
    local expBar = Instance.new("Frame")
    expBar.Size = UDim2.new(0, 0, 1, 0)
    expBar.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    expBar.BorderSizePixel = 0
    expBar.Parent = expBarBg
    
    local expBarFillCorner = Instance.new("UICorner")
    expBarFillCorner.CornerRadius = UDim.new(0, 5)
    expBarFillCorner.Parent = expBar
    
    uiElements.expBar = expBar
    
    local expText = Instance.new("TextLabel")
    expText.Size = UDim2.new(1, 0, 1, 0)
    expText.BackgroundTransparency = 1
    expText.Text = "0 / 100 EXP"
    expText.TextColor3 = Color3.fromRGB(255, 255, 255)
    expText.TextSize = 16
    expText.Font = Enum.Font.GothamBold
    expText.ZIndex = 2
    expText.Parent = expBarBg
    
    uiElements.expText = expText
    
    -- Stats Panel (Compact for mobile)
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, -30, 0, 380)
    statsPanel.Position = UDim2.new(0, 15, 0, 125)
    statsPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    statsPanel.BackgroundTransparency = 0.3
    statsPanel.BorderSizePixel = 0
    statsPanel.Parent = container
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 10)
    statsCorner.Parent = statsPanel
    
    local statsStroke = Instance.new("UIStroke")
    statsStroke.Color = Color3.fromRGB(0, 120, 200)
    statsStroke.Thickness = 2
    statsStroke.Transparency = 0.6
    statsStroke.Parent = statsPanel
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Size = UDim2.new(1, -20, 0, 40)
    statsTitle.Position = UDim2.new(0, 10, 0, 8)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "STATS"
    statsTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    statsTitle.TextSize = 24
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsPanel
    
    local statsList = Instance.new("Frame")
    statsList.Size = UDim2.new(1, -20, 1, -60)
    statsList.Position = UDim2.new(0, 10, 0, 55)
    statsList.BackgroundTransparency = 1
    statsList.Parent = statsPanel
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.Padding = UDim.new(0, 8)
    statsLayout.FillDirection = Enum.FillDirection.Vertical
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Parent = statsList
    
    -- Create stats
    local statDefs = {
        {name = "STR", key = "strength", icon = "💪", order = 1},
        {name = "VIT", key = "vitality", icon = "❤️", order = 2},
        {name = "AGI", key = "agility", icon = "⚡", order = 3},
        {name = "INT", key = "intelligence", icon = "🧠", order = 4},
        {name = "SEN", key = "sense", icon = "👁️", order = 5}
    }
    
    for _, stat in ipairs(statDefs) do
        local statRow = Instance.new("Frame")
        statRow.Size = UDim2.new(1, 0, 0, 52)
        statRow.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        statRow.BackgroundTransparency = 0.4
        statRow.BorderSizePixel = 0
        statRow.LayoutOrder = stat.order
        statRow.Parent = statsList
        
        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 8)
        rowCorner.Parent = statRow
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 35, 1, 0)
        iconLabel.Position = UDim2.new(0, 3, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = stat.icon
        iconLabel.TextSize = 24
        iconLabel.Parent = statRow
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 80, 1, 0)
        nameLabel.Position = UDim2.new(0, 40, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = stat.name
        nameLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
        nameLabel.TextSize = 20
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = statRow
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 1, 0)
        valueLabel.Position = UDim2.new(0, 125, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "1"
        valueLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        valueLabel.TextSize = 22
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Parent = statRow
        
        uiElements.statLabels[stat.key] = valueLabel
        
        -- Plus button (mobile friendly)
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 35, 0, 35)
        plusBtn.Position = UDim2.new(1, -90, 0.5, -17.5)
        plusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.TextSize = 24
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.AutoButtonColor = false
        plusBtn.Parent = statRow
        
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 6)
        plusCorner.Parent = plusBtn
        
        -- Minus button
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 35, 0, 35)
        minusBtn.Position = UDim2.new(1, -50, 0.5, -17.5)
        minusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        minusBtn.BorderSizePixel = 0
        minusBtn.Text = "-"
        minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minusBtn.TextSize = 24
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.AutoButtonColor = false
        minusBtn.Parent = statRow
        
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0, 6)
        minusCorner.Parent = minusBtn
        
        -- Button handlers
        plusBtn.MouseButton1Click:Connect(function()
            UIModule.increaseStat(stat.key)
        end)
        
        minusBtn.MouseButton1Click:Connect(function()
            UIModule.decreaseStat(stat.key)
        end)
        
        -- Touch feedback
        local function setupTouchFeedback(btn, normalColor, activeColor)
            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = activeColor}):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
            end)
        end
        
        setupTouchFeedback(plusBtn, Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 180, 255))
        setupTouchFeedback(minusBtn, Color3.fromRGB(200, 50, 50), Color3.fromRGB(230, 70, 70))
    end
    
    -- Abilities Panel (Compact)
    local abPanel = Instance.new("Frame")
    abPanel.Size = UDim2.new(1, -30, 0, 270)
    abPanel.Position = UDim2.new(0, 15, 0, 515)
    abPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    abPanel.BackgroundTransparency = 0.3
    abPanel.BorderSizePixel = 0
    abPanel.Parent = container
    
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 10)
    abCorner.Parent = abPanel
    
    local abStroke = Instance.new("UIStroke")
    abStroke.Color = Color3.fromRGB(0, 120, 200)
    abStroke.Thickness = 2
    abStroke.Transparency = 0.6
    abStroke.Parent = abPanel
    
    local abTitle = Instance.new("TextLabel")
    abTitle.Size = UDim2.new(1, -20, 0, 40)
    abTitle.Position = UDim2.new(0, 10, 0, 8)
    abTitle.BackgroundTransparency = 1
    abTitle.Text = "ABILITIES"
    abTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    abTitle.TextSize = 24
    abTitle.Font = Enum.Font.GothamBold
    abTitle.TextXAlignment = Enum.TextXAlignment.Left
    abTitle.Parent = abPanel
    
    local abContainer = Instance.new("Frame")
    abContainer.Size = UDim2.new(1, -20, 1, -60)
    abContainer.Position = UDim2.new(0, 10, 0, 55)
    abContainer.BackgroundTransparency = 1
    abContainer.Parent = abPanel
    
    local abLayout = Instance.new("UIListLayout")
    abLayout.Padding = UDim.new(0, 10)
    abLayout.FillDirection = Enum.FillDirection.Vertical
    abLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abLayout.Parent = abContainer
    
    -- Create ability buttons
    local shadowBtn = UIModule.createAbilityButton(abContainer, "Shadow Step", "[E]", 1, Color3.fromRGB(100, 50, 200))
    local rampageBtn = UIModule.createAbilityButton(abContainer, "Rampage", "[R]", 2, Color3.fromRGB(200, 50, 50))
    local behindBtn = UIModule.createAbilityButton(abContainer, "Behind You", "[F]", 3, Color3.fromRGB(50, 150, 200))
    
    -- Make ability buttons functional (mobile touch)
    shadowBtn.MouseButton1Click:Connect(function() AbilitySystem.shadowStep() end)
    rampageBtn.MouseButton1Click:Connect(function() AbilitySystem.rampage() end)
    behindBtn.MouseButton1Click:Connect(function() AbilitySystem.behindYou() end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -30, 0, 55)
    closeBtn.Position = UDim2.new(0, 15, 1, -70)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CLOSE"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = container
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        UIModule.toggleUI()
    end)
    
    closeBtn.MouseButton1Down:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(230, 70, 70)}):Play()
    end)
    closeBtn.MouseButton1Up:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
    
    -- Start follow system
    FollowController:start()
    UIModule.updateUI()
    
    -- Border animation (lightweight)
    task.spawn(function()
        local borders = {topBorder, bottomBorder, leftBorder, rightBorder}
        while mainPart and mainPart.Parent do
            for _, border in ipairs(borders) do
                if border then
                    TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                        BackgroundColor3 = Color3.fromRGB(100, 200, 255)
                    }):Play()
                end
            end
            task.wait(2)
            for _, border in ipairs(borders) do
                if border then
                    TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                        BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    }):Play()
                end
            end
            task.wait(2)
        end
    end)
    
    -- Initially hide
    uiElements.isVisible = false
    mainPart.CFrame = mainPart.CFrame * CFrame.new(0, -50, 0)
    
    -- Create toggle button (for mobile)
    UIModule.createToggleButton()
end

-- Create mobile toggle button
function UIModule.createToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SoloLevelingToggle"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 70)
    toggleBtn.Position = UDim2.new(1, -85, 0.5, -35)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "⚡"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 36
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = toggleBtn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 200, 255)
    stroke.Thickness = 3
    stroke.Transparency = 0.4
    stroke.Parent = toggleBtn
    
    uiElements.toggleButton = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        UIModule.toggleUI()
    end)
    
    toggleBtn.MouseButton1Down:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 65, 0, 65),
            BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        }):Play()
    end)
    toggleBtn.MouseButton1Up:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 70, 0, 70),
            BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        }):Play()
    end)
end

-- Toggle UI
function UIModule.toggleUI()
    if not uiElements.mainPart or not uiElements.mainPart.Parent then return end
    
    uiElements.isVisible = not uiElements.isVisible
    
    if uiElements.isVisible then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lookVector = hrp.CFrame.LookVector
            local targetPos = hrp.Position + (lookVector * 5) + Vector3.new(0, 1.5, 0)
            local targetCFrame = CFrame.new(targetPos, hrp.Position + Vector3.new(0, 1.5, 0))
            
            TweenService:Create(uiElements.mainPart, TweenInfo.new(0.3), {CFrame = targetCFrame}):Play()
        end
        FollowController:start()
    else
        FollowController:stop()
        local currentPos = uiElements.mainPart.Position
        TweenService:Create(uiElements.mainPart, TweenInfo.new(0.3), {
            CFrame = CFrame.new(currentPos - Vector3.new(0, 50, 0))
        }):Play()
    end
end

-- Update UI
function UIModule.updateUI()
    if not uiElements.levelLabel then return end
    
    uiElements.levelLabel.Text = "Level: " .. PlayerData.level
    uiElements.pointsLabel.Text = "Points: " .. PlayerData.statPoints
    
    local expPercent = PlayerData.exp / PlayerData.expNeeded
    TweenService:Create(uiElements.expBar, TweenInfo.new(0.3), {
        Size = UDim2.new(expPercent, 0, 1, 0)
    }):Play()
    
    uiElements.expText.Text = string.format("%d / %d EXP", PlayerData.exp, PlayerData.expNeeded)
    
    for key, label in pairs(uiElements.statLabels) do
        if PlayerData.stats[key] then
            label.Text = tostring(PlayerData.stats[key])
        end
    end
end

-- Increase stat
function UIModule.increaseStat(statKey)
    if PlayerData.statPoints <= 0 then
        UIModule.showNotif("No points!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    PlayerData.stats[statKey] = PlayerData.stats[statKey] + 1
    PlayerData.statPoints = PlayerData.statPoints - 1
    
    UIModule.updateUI()
    UIModule.applyStats()
    UIModule.showNotif("+" .. statKey:upper(), Color3.fromRGB(100, 255, 150))
end

-- Decrease stat
function UIModule.decreaseStat(statKey)
    if PlayerData.stats[statKey] <= 1 then
        UIModule.showNotif("Min is 1!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    PlayerData.stats[statKey] = PlayerData.stats[statKey] - 1
    PlayerData.statPoints = PlayerData.statPoints + 1
    
    UIModule.updateUI()
    UIModule.applyStats()
    UIModule.showNotif("-" .. statKey:upper(), Color3.fromRGB(255, 150, 100))
end

-- Show notification (lightweight)
function UIModule.showNotif(message, color)
    if not uiElements.surfaceGui then return end
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 250, 0, 50)
    notif.Position = UDim2.new(0.5, -125, 0, -60)
    notif.BackgroundColor3 = color
    notif.BorderSizePixel = 0
    notif.Parent = uiElements.surfaceGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 1, 0)
    text.Position = UDim2.new(0, 5, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 18
    text.Font = Enum.Font.GothamBold
    text.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.2), {Position = UDim2.new(0.5, -125, 0, 15)}):Play()
    
    task.wait(1.5)
    
    TweenService:Create(notif, TweenInfo.new(0.2), {Position = UDim2.new(0.5, -125, 0, -60)}):Play()
    task.wait(0.2)
    notif:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- 📈 STATS APPLICATION (TSB COMPATIBLE)
-- ═══════════════════════════════════════════════════════════════

function UIModule.applyStats()
    if not character or not humanoid then return end
    
    local str = PlayerData.stats.strength
    local vit = PlayerData.stats.vitality
    local agi = PlayerData.stats.agility
    
    -- Health
    local newMaxHealth = PlayerData.baseHealth + (vit * 20)
    humanoid.MaxHealth = newMaxHealth
    if humanoid.Health > newMaxHealth then
        humanoid.Health = newMaxHealth
    end
    
    -- Speed (TSB compatible - multiple methods)
    local newSpeed = PlayerData.baseWalkSpeed + (agi * 0.5)
    
    -- Method 1: Direct
    pcall(function()
        humanoid.WalkSpeed = newSpeed
    end)
    
    -- Method 2: Continuous application for TSB
    task.spawn(function()
        while character and character.Parent and not PlayerData.abilities.rampage.active do
            task.wait(0.5)
            pcall(function()
                if humanoid.WalkSpeed ~= newSpeed and not PlayerData.abilities.rampage.active then
                    humanoid.WalkSpeed = newSpeed
                end
            end)
        end
    end)
    
    -- Jump
    local newJump = PlayerData.baseJumpPower + (agi * 2)
    pcall(function()
        if humanoid.UseJumpPower then
            humanoid.JumpPower = newJump
        else
            humanoid.JumpHeight = newJump / 3.6
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ⚔️ ABILITY SYSTEM (NO VFX - MOBILE OPTIMIZED)
-- ═══════════════════════════════════════════════════════════════

AbilitySystem = {}

-- Shadow Step
function AbilitySystem.shadowStep()
    local ability = PlayerData.abilities.shadowStep
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotif("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if not character or not rootPart then return end
    
    ability.lastUsed = currentTime
    
    local lookVector = rootPart.CFrame.LookVector
    local targetPos = rootPart.Position + (lookVector * 20)
    
    rootPart.CFrame = CFrame.new(targetPos, targetPos + lookVector)
    
    UIModule.showNotif("Shadow Step!", Color3.fromRGB(150, 100, 255))
end

-- Rampage (NO EFFECTS)
function AbilitySystem.rampage()
    local ability = PlayerData.abilities.rampage
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotif("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if ability.active then
        UIModule.showNotif("Already active!", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if not character or not humanoid or not rootPart then return end
    
    ability.lastUsed = currentTime
    ability.active = true
    
    UIModule.showNotif("RAMPAGE!", Color3.fromRGB(255, 50, 50))
    
    -- Calculate boosted speed
    local agi = PlayerData.stats.agility
    local baseSpeed = PlayerData.baseWalkSpeed + (agi * 0.5)
    local boostedSpeed = baseSpeed * 2.5
    
    -- Apply speed (TSB compatible)
    local function applySpeed()
        pcall(function() humanoid.WalkSpeed = boostedSpeed end)
    end
    
    applySpeed()
    
    -- Maintain speed
    local speedLoop = RunService.Heartbeat:Connect(function()
        if ability.active then
            applySpeed()
        end
    end)
    
    -- Duration
    task.wait(ability.duration)
    
    ability.active = false
    speedLoop:Disconnect()
    
    UIModule.applyStats()
    UIModule.showNotif("Rampage ended", Color3.fromRGB(255, 200, 100))
end

-- Behind You
function AbilitySystem.behindYou()
    local ability = PlayerData.abilities.behindYou
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotif("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if not character or not rootPart then return end
    
    local nearestPlayer = nil
    local nearestDistance = ability.range
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local distance = (otherRoot.Position - rootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = otherPlayer
                end
            end
        end
    end
    
    if not nearestPlayer then
        UIModule.showNotif("No targets!", Color3.fromRGB(255, 150, 100))
        return
    end
    
    ability.lastUsed = currentTime
    
    local targetRoot = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        local behindPos = targetRoot.Position - (targetRoot.CFrame.LookVector * 5)
        rootPart.CFrame = CFrame.new(behindPos, targetRoot.Position)
        
        UIModule.showNotif("Behind You!", Color3.fromRGB(100, 200, 255))
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 🎮 INPUT SYSTEM (Mobile + Keyboard)
-- ═══════════════════════════════════════════════════════════════

local function setupInput()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.X then
            UIModule.toggleUI()
        elseif input.KeyCode == Enum.KeyCode.E then
            AbilitySystem.shadowStep()
        elseif input.KeyCode == Enum.KeyCode.R then
            AbilitySystem.rampage()
        elseif input.KeyCode == Enum.KeyCode.F then
            AbilitySystem.behindYou()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- 🚀 INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local function init()
    -- Wait for character
    if not character or not character.Parent then
        character = player.Character or player.CharacterAdded:Wait()
    end
    
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Wait for game to load
    task.wait(2)
    
    -- Initialize
    pcall(function()
        UIModule.createInitialNotification()
    end)
    
    setupInput()
    UIModule.applyStats()
    
    -- Character respawn handler
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        
        task.wait(1)
        
        if uiElements.mainPart then
            pcall(function() uiElements.mainPart:Destroy() end)
        end
        
        pcall(function()
            UIModule.createMainUI()
            UIModule.applyStats()
        end)
    end)
end

-- Start
pcall(init)

print("═══════════════════════════════════════════════")
print("⚡ SOLO LEVELING - MOBILE OPTIMIZED")
print("📱 Codex/Delta Compatible")
print("🎮 The Strongest Battlegrounds")
print("═══════════════════════════════════════════════")
print("Controls:")
if isMobile then
    print("- Tap ⚡ button to toggle UI")
    print("- Tap ability buttons or use keys")
else
    print("[X] - Toggle UI")
end
print("[E] - Shadow Step")
print("[R] - Rampage (NO EFFECTS)")
print("[F] - Behind You")
print("═══════════════════════════════════════════════")
