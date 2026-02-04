--[[
═══════════════════════════════════════════════════════════════════════════
⚡ SOLO LEVELING SYSTEM - CODEX DELTA EDITION v2.0
📱 100% Mobile Compatible | 🎮 TSB Speed Fixed | 🐛 All Bugs Fixed
═══════════════════════════════════════════════════════════════════════════
]]

print("═══════════════════════════════════════════════")
print("⚡ SOLO LEVELING LOADING...")
print("═══════════════════════════════════════════════")

-- ═══════════════════════════════════════════════════════════════
-- 🔧 CORE SERVICES
-- ═══════════════════════════════════════════════════════════════

print("[1/10] Loading services...")

local success, error = pcall(function()
    
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

print("✅ Services loaded")

local player = Players.LocalPlayer
print("✅ Player: " .. player.Name)

local character = player.Character or player.CharacterAdded:Wait()
print("✅ Character loaded")

local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
print("✅ Humanoid & RootPart loaded")

-- Mobile detection
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
print("✅ Device: " .. (IS_MOBILE and "MOBILE" or "PC"))

print("[2/10] Initializing data...")

-- ═══════════════════════════════════════════════════════════════
-- 📊 PLAYER DATA STRUCTURE
-- ═══════════════════════════════════════════════════════════════

local PlayerData = {
    level = 1,
    xp = 0,
    xpNeeded = 100,
    availablePoints = 3,
    
    stats = {
        STR = 19,
        VIT = 10,
        AGI = 10,
        INT = 10,
        PER = 10
    },
    
    rank = "Player",
    title = "Necromancer",
    job = "Shadow Monarch",
    
    maxHP = 100,
    currentHP = 100,
    maxMP = 10,
    currentMP = 10,
    fatigue = 0,
    
    baseWalkSpeed = 16,
    currentWalkSpeed = 16,
    
    abilities = {
        shadowStep = {
            unlocked = true,
            level = 1,
            cooldown = 5,
            lastUsed = 0,
            range = 30
        },
        rampage = {
            unlocked = true,
            level = 1,
            cooldown = 15,
            lastUsed = 0,
            duration = 8,
            active = false,
            speedMultiplier = 2.5
        },
        behindYou = {
            unlocked = true,
            level = 1,
            cooldown = 10,
            lastUsed = 0,
            range = 50
        }
    },
    
    kills = 0,
    deaths = 0
}

print("✅ Player data initialized")

print("[3/10] Loading stat descriptions...")

-- ═══════════════════════════════════════════════════════════════
-- 📝 STAT DESCRIPTIONS
-- ═══════════════════════════════════════════════════════════════

local STAT_DESCRIPTIONS = {
    STR = {
        name = "STRENGTH",
        desc = "Increases physical damage output and attack power.",
        effect = "+2 Damage per point"
    },
    VIT = {
        name = "VITALITY", 
        desc = "Increases maximum HP and health regeneration.",
        effect = "+20 HP per point\n+0.5 HP/sec regen per point"
    },
    AGI = {
        name = "AGILITY",
        desc = "Increases movement speed and dash distance.",
        effect = "+0.84 Speed per point\n+1.5 Dash range per point"
    },
    INT = {
        name = "INTELLIGENCE",
        desc = "Increases XP gain and reduces ability cooldowns.",
        effect = "+5% XP per point\n-1% Cooldown per point"
    },
    PER = {
        name = "PERCEPTION",
        desc = "Increases detection range and ability effectiveness.",
        effect = "+10 Detection range\n+2.1s Rampage duration per point"
    }
}

print("✅ Stat descriptions loaded")

print("[4/10] Setting up UI storage...")

-- ═══════════════════════════════════════════════════════════════
-- 🎨 UI ELEMENTS STORAGE
-- ═══════════════════════════════════════════════════════════════

local UI = {
    mainPart = nil,
    surfaceGui = nil,
    isVisible = false,
    isAccepted = false,
    
    statFrames = {},
    statLabels = {},
    plusButtons = {},
    descriptionFrame = nil,
    
    levelLabel = nil,
    xpBar = nil,
    xpText = nil,
    hpBar = nil,
    mpBar = nil,
    fatigueLabel = nil,
    pointsLabel = nil,
    
    rankLabel = nil,
    titleLabel = nil,
    jobLabel = nil,
    
    toggleButton = nil
}

print("✅ UI storage ready")

print("[5/10] Creating follow controller...")

-- ═══════════════════════════════════════════════════════════════
-- 🔄 FOLLOW CONTROLLER
-- ═══════════════════════════════════════════════════════════════

local FollowController = {
    enabled = false,
    distance = 5,
    height = 1.5,
    smoothness = 0.12,
    updateRate = 0.05,
    lastUpdate = 0
}

function FollowController:start()
    self.enabled = true
    print("✅ Follow controller started")
    
    RunService.Heartbeat:Connect(function()
        if not self.enabled or not UI.mainPart or not UI.mainPart.Parent then
            return
        end
        
        local now = tick()
        if now - self.lastUpdate < self.updateRate then
            return
        end
        self.lastUpdate = now
        
        if not character or not character.Parent then
            character = player.Character
            if not character then return end
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local lookVector = hrp.CFrame.LookVector
        local targetPos = hrp.Position + (lookVector * self.distance) + Vector3.new(0, self.height, 0)
        local lookAtPos = Vector3.new(hrp.Position.X, targetPos.Y, hrp.Position.Z)
        
        local targetCFrame = CFrame.new(targetPos, lookAtPos)
        UI.mainPart.CFrame = UI.mainPart.CFrame:Lerp(targetCFrame, self.smoothness)
    end)
end

function FollowController:stop()
    self.enabled = false
    print("⏸ Follow controller stopped")
end

print("✅ Follow controller ready")

print("[6/10] Creating UI module...")

-- ═══════════════════════════════════════════════════════════════
-- 💻 UI MODULE
-- ═══════════════════════════════════════════════════════════════

local UIModule = {}

function UIModule.createRoundedFrame(parent, name, size, position, bgColor, transparency)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = bgColor or Color3.fromRGB(10, 15, 25)
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    return frame
end

function UIModule.createGlowBorder(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(0, 150, 255)
    stroke.Thickness = thickness or 3
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    task.spawn(function()
        while stroke and stroke.Parent do
            for i = 0, 1, 0.02 do
                if not stroke or not stroke.Parent then break end
                stroke.Transparency = 0.2 + (math.sin(i * math.pi * 2) * 0.15)
                task.wait(0.05)
            end
        end
    end)
    
    return stroke
end

function UIModule.createLabel(parent, name, text, size, position, textSize, textColor, font, alignment)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.Size = size or UDim2.new(1, 0, 1, 0)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.TextSize = textSize or 24
    label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    label.Font = font or Enum.Font.GothamBold
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.8
    label.Parent = parent
    
    return label
end

print("✅ UI helpers created")

print("[7/10] Creating notification system...")

-- ═══════════════════════════════════════════════════════════════
-- 🎯 INITIAL NOTIFICATION
-- ═══════════════════════════════════════════════════════════════

function UIModule.createInitialNotification()
    if UI.isAccepted then return end
    
    print("📢 Creating player notification...")
    
    local notifPart = Instance.new("Part")
    notifPart.Name = "PlayerNotification"
    notifPart.Size = Vector3.new(12, 7, 0.1)
    notifPart.Anchored = true
    notifPart.CanCollide = false
    notifPart.Material = Enum.Material.ForceField
    notifPart.Transparency = 1
    notifPart.Parent = workspace
    
    if rootPart then
        local lookVector = rootPart.CFrame.LookVector
        notifPart.CFrame = CFrame.new(rootPart.Position + (lookVector * 8) + Vector3.new(0, 3, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1200, 700)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = notifPart
    
    local bg = UIModule.createRoundedFrame(surfaceGui, "Background", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 
        Color3.fromRGB(5, 10, 20), 0.05)
    
    local function createBorder(pos, size, rotation)
        local border = Instance.new("Frame")
        border.Size = size
        border.Position = pos
        border.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        border.BorderSizePixel = 0
        border.ZIndex = 2
        border.Parent = bg
        
        local grad = Instance.new("UIGradient")
        grad.Rotation = rotation or 0
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.5)
        })
        grad.Parent = border
        
        task.spawn(function()
            while border and border.Parent do
                for i = 0, 360, 2 do
                    if not border or not border.Parent then break end
                    grad.Rotation = i
                    task.wait(0.03)
                end
            end
        end)
    end
    
    createBorder(UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 8), 0)
    createBorder(UDim2.new(0, 0, 1, -8), UDim2.new(1, 0, 0, 8), 0)
    createBorder(UDim2.new(0, 0, 0, 0), UDim2.new(0, 8, 1, 0), 90)
    createBorder(UDim2.new(1, -8, 0, 0), UDim2.new(0, 8, 1, 0), 90)
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 80, 0, 80)
    iconFrame.Position = UDim2.new(0.5, -40, 0, 50)
    iconFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    iconFrame.BackgroundTransparency = 0.2
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = bg
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
    
    UIModule.createGlowBorder(iconFrame, Color3.fromRGB(100, 200, 255), 4)
    
    local icon = UIModule.createLabel(iconFrame, "Icon", "!", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 
        60, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    local header = UIModule.createLabel(bg, "Header", "NOTIFICATION", UDim2.new(0.8, 0, 0, 60), UDim2.new(0.1, 0, 0, 150),
        42, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    local message = UIModule.createLabel(bg, "Message", "You have acquired the qualifications", 
        UDim2.new(0.8, 0, 0, 40), UDim2.new(0.1, 0, 0, 250),
        28, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    local message2 = UIModule.createLabel(bg, "Message2", "to be a Player. Will you accept?",
        UDim2.new(0.8, 0, 0, 40), UDim2.new(0.1, 0, 0, 290),
        28, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    message2.RichText = true
    message2.Text = 'to be a <font color="rgb(100,200,255)"><b>Player</b></font>. Will you accept?'
    
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Size = UDim2.new(0, 400, 0, 80)
    acceptBtn.Position = UDim2.new(0.5, -450, 1, -130)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    acceptBtn.BackgroundTransparency = 0.1
    acceptBtn.BorderSizePixel = 0
    acceptBtn.Text = ""
    acceptBtn.AutoButtonColor = false
    acceptBtn.Parent = bg
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 10)
    acceptCorner.Parent = acceptBtn
    
    UIModule.createGlowBorder(acceptBtn, Color3.fromRGB(100, 200, 255), 3)
    
    local acceptLabel = UIModule.createLabel(acceptBtn, "Label", "ACCEPT", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        36, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    local declineBtn = Instance.new("TextButton")
    declineBtn.Size = UDim2.new(0, 400, 0, 80)
    declineBtn.Position = UDim2.new(0.5, 50, 1, -130)
    declineBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    declineBtn.BackgroundTransparency = 0.1
    declineBtn.BorderSizePixel = 0
    declineBtn.Text = ""
    declineBtn.AutoButtonColor = false
    declineBtn.Parent = bg
    
    local declineCorner = Instance.new("UICorner")
    declineCorner.CornerRadius = UDim.new(0, 10)
    declineCorner.Parent = declineBtn
    
    local declineStroke = Instance.new("UIStroke")
    declineStroke.Color = Color3.fromRGB(100, 120, 150)
    declineStroke.Thickness = 2
    declineStroke.Transparency = 0.5
    declineStroke.Parent = declineBtn
    
    local declineLabel = UIModule.createLabel(declineBtn, "Label", "DECLINE", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        36, Color3.fromRGB(200, 200, 200), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    acceptBtn.MouseButton1Click:Connect(function()
        print("✅ Player accepted!")
        UI.isAccepted = true
        TweenService:Create(notifPart, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        notifPart:Destroy()
        UIModule.createMainUI()
    end)
    
    declineBtn.MouseButton1Click:Connect(function()
        print("❌ Player declined")
        UI.isAccepted = false
        TweenService:Create(notifPart, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        notifPart:Destroy()
    end)
    
    task.spawn(function()
        local t = 0
        while notifPart and notifPart.Parent do
            t = t + 0.05
            local bobY = math.sin(t * 2) * 0.4
            
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local lookVec = hrp.CFrame.LookVector
                local targetPos = hrp.Position + (lookVec * 8) + Vector3.new(0, 3 + bobY, 0)
                local lookAtPos = Vector3.new(hrp.Position.X, notifPart.Position.Y, hrp.Position.Z)
                notifPart.CFrame = notifPart.CFrame:Lerp(CFrame.new(targetPos, lookAtPos), 0.1)
            end
            
            task.wait(0.05)
        end
    end)
    
    print("✅ Notification created and visible!")
end

print("[8/10] Creating main UI...")

-- ═══════════════════════════════════════════════════════════════
-- 📊 MAIN UI
-- ═══════════════════════════════════════════════════════════════

function UIModule.createMainUI()
    if not UI.isAccepted then return end
    if UI.mainPart then UI.mainPart:Destroy() end
    
    print("🎨 Building main stats UI...")
    
    UI.mainPart = Instance.new("Part")
    UI.mainPart.Name = "StatsUI"
    UI.mainPart.Size = Vector3.new(10, 12, 0.1)
    UI.mainPart.Anchored = true
    UI.mainPart.CanCollide = false
    UI.mainPart.Material = Enum.Material.ForceField
    UI.mainPart.Transparency = 1
    UI.mainPart.Parent = workspace
    
    if rootPart then
        local lookVector = rootPart.CFrame.LookVector
        UI.mainPart.CFrame = CFrame.new(rootPart.Position + (lookVector * 5) + Vector3.new(0, 1.5, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    UI.surfaceGui = Instance.new("SurfaceGui")
    UI.surfaceGui.Face = Enum.NormalId.Back
    UI.surfaceGui.CanvasSize = Vector2.new(1000, 1200)
    UI.surfaceGui.LightInfluence = 0
    UI.surfaceGui.AlwaysOnTop = true
    UI.surfaceGui.Parent = UI.mainPart
    
    local container = UIModule.createRoundedFrame(UI.surfaceGui, "Container", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 
        Color3.fromRGB(5, 10, 20), 0.05)
    UIModule.createGlowBorder(container, Color3.fromRGB(0, 150, 255), 3)
    
    -- Status section
    local statusSection = UIModule.createRoundedFrame(container, "StatusSection", UDim2.new(0.94, 0, 0, 200), UDim2.new(0.03, 0, 0, 20),
        Color3.fromRGB(15, 20, 35), 0.2)
    
    local levelFrame = Instance.new("Frame")
    levelFrame.Size = UDim2.new(1, -40, 0, 100)
    levelFrame.Position = UDim2.new(0, 20, 0, 20)
    levelFrame.BackgroundTransparency = 1
    levelFrame.Parent = statusSection
    
    UI.levelLabel = UIModule.createLabel(levelFrame, "Level", tostring(PlayerData.level), UDim2.new(0, 140, 0, 60), UDim2.new(0, 0, 0, 0),
        56, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
    
    local levelSubtext = UIModule.createLabel(levelFrame, "LevelText", "LEVEL", UDim2.new(0, 140, 0, 25), UDim2.new(0, 150, 0, 15),
        18, Color3.fromRGB(150, 170, 200), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    
    UI.rankLabel = UIModule.createLabel(levelFrame, "Rank", "JOB " .. PlayerData.job, UDim2.new(0.5, 0, 0, 20), UDim2.new(0.5, 0, 0, 0),
        16, Color3.fromRGB(150, 170, 200), Enum.Font.Gotham, Enum.TextXAlignment.Right)
    
    UI.titleLabel = UIModule.createLabel(levelFrame, "Title", "TITLE " .. PlayerData.title, UDim2.new(0.5, 0, 0, 20), UDim2.new(0.5, 0, 0, 22),
        16, Color3.fromRGB(150, 170, 200), Enum.Font.Gotham, Enum.TextXAlignment.Right)
    
    -- HP Bar
    local hpContainer = Instance.new("Frame")
    hpContainer.Size = UDim2.new(1, 0, 0, 30)
    hpContainer.Position = UDim2.new(0, 0, 0, 70)
    hpContainer.BackgroundTransparency = 1
    hpContainer.Parent = levelFrame
    
    local hpIcon = UIModule.createLabel(hpContainer, "Icon", "+", UDim2.new(0, 30, 1, 0), UDim2.new(0, 0, 0, 0),
        32, Color3.fromRGB(255, 100, 100), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    local hpBarBg = UIModule.createRoundedFrame(hpContainer, "HPBarBg", UDim2.new(0, 450, 1, -8), UDim2.new(0, 40, 0, 4),
        Color3.fromRGB(30, 20, 20), 0.3)
    
    UI.hpBar = UIModule.createRoundedFrame(hpBarBg, "HPBar", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(255, 80, 80), 0)
    
    local hpText = UIModule.createLabel(hpBarBg, "HPText", "100/100", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        16, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    
    -- MP Bar
    local mpContainer = Instance.new("Frame")
    mpContainer.Size = UDim2.new(1, 0, 0, 30)
    mpContainer.Position = UDim2.new(0, 0, 0, 105)
    mpContainer.BackgroundTransparency = 1
    mpContainer.Parent = levelFrame
    
    local mpIcon = UIModule.createLabel(mpContainer, "Icon", "▼", UDim2.new(0, 30, 1, 0), UDim2.new(0, 0, 0, 0),
        20, Color3.fromRGB(100, 150, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    local mpBarBg = UIModule.createRoundedFrame(mpContainer, "MPBarBg", UDim2.new(0, 450, 1, -8), UDim2.new(0, 40, 0, 4),
        Color3.fromRGB(20, 25, 40), 0.3)
    
    UI.mpBar = UIModule.createRoundedFrame(mpBarBg, "MPBar", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(100, 150, 255), 0)
    
    local mpText = UIModule.createLabel(mpBarBg, "MPText", "10/10", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        16, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    
    UI.fatigueLabel = UIModule.createLabel(levelFrame, "Fatigue", "FATIGUE: 0", UDim2.new(0.5, 0, 0, 20), UDim2.new(0.5, 0, 0, 140),
        16, Color3.fromRGB(150, 170, 200), Enum.Font.Gotham, Enum.TextXAlignment.Right)
    
    -- Stats section
    local statsSection = UIModule.createRoundedFrame(container, "StatsSection", UDim2.new(0.94, 0, 0, 550), UDim2.new(0.03, 0, 0, 240),
        Color3.fromRGB(15, 20, 35), 0.2)
    
    local statsOrder = {"STR", "VIT", "AGI", "INT", "PER"}
    local statIcons = {
        STR = "⚔",
        VIT = "♥",
        AGI = "⚡",
        INT = "◆",
        PER = "👁"
    }
    
    for i, statName in ipairs(statsOrder) do
        local yPos = 20 + ((i - 1) * 90)
        
        local statFrame = Instance.new("Frame")
        statFrame.Name = statName .. "Frame"
        statFrame.Size = UDim2.new(0.94, 0, 0, 70)
        statFrame.Position = UDim2.new(0.03, 0, 0, yPos)
        statFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
        statFrame.BackgroundTransparency = 0.3
        statFrame.BorderSizePixel = 0
        statFrame.Parent = statsSection
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = statFrame
        
        UI.statFrames[statName] = statFrame
        
        local icon = UIModule.createLabel(statFrame, "Icon", statIcons[statName], UDim2.new(0, 50, 1, 0), UDim2.new(0, 10, 0, 0),
            32, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
        
        local nameLabel = UIModule.createLabel(statFrame, "Name", STAT_DESCRIPTIONS[statName].name, 
            UDim2.new(0.4, 0, 0, 30), UDim2.new(0, 70, 0, 5),
            22, Color3.fromRGB(200, 220, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
        
        UI.statLabels[statName] = UIModule.createLabel(statFrame, "Value", tostring(PlayerData.stats[statName]),
            UDim2.new(0.2, 0, 0, 40), UDim2.new(0, 70, 0, 30),
            38, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
        
        local plusBtn = Instance.new("TextButton")
        plusBtn.Name = "PlusBtn"
        plusBtn.Size = UDim2.new(0, 45, 0, 45)
        plusBtn.Position = UDim2.new(1, -110, 0.5, -22.5)
        plusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        plusBtn.BackgroundTransparency = 0.2
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextSize = 32
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.Font = Enum.Font.GothamBlack
        plusBtn.AutoButtonColor = false
        plusBtn.Parent = statFrame
        
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 8)
        plusCorner.Parent = plusBtn
        
        local plusStroke = Instance.new("UIStroke")
        plusStroke.Color = Color3.fromRGB(100, 200, 255)
        plusStroke.Thickness = 2
        plusStroke.Transparency = 0.4
        plusStroke.Parent = plusBtn
        
        UI.plusButtons[statName] = plusBtn
        
        local descBtn = Instance.new("TextButton")
        descBtn.Name = "DescBtn"
        descBtn.Size = UDim2.new(0, 45, 0, 45)
        descBtn.Position = UDim2.new(1, -55, 0.5, -22.5)
        descBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
        descBtn.BackgroundTransparency = 0.2
        descBtn.BorderSizePixel = 0
        descBtn.Text = "?"
        descBtn.TextSize = 28
        descBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        descBtn.Font = Enum.Font.GothamBold
        descBtn.AutoButtonColor = false
        descBtn.Parent = statFrame
        
        local descCorner = Instance.new("UICorner")
        descCorner.CornerRadius = UDim.new(0, 8)
        descCorner.Parent = descBtn
        
        local descStroke = Instance.new("UIStroke")
        descStroke.Color = Color3.fromRGB(100, 120, 150)
        descStroke.Thickness = 2
        descStroke.Transparency = 0.6
        descStroke.Parent = descBtn
        
        plusBtn.MouseButton1Click:Connect(function()
            UIModule.upgradeStat(statName)
        end)
        
        descBtn.MouseButton1Click:Connect(function()
            UIModule.showDescription(statName, statFrame)
        end)
    end
    
    -- Rank section
    local rankSection = UIModule.createRoundedFrame(container, "RankSection", UDim2.new(0.94, 0, 0, 250), UDim2.new(0.03, 0, 0, 820),
        Color3.fromRGB(15, 20, 35), 0.2)
    
    local jobFrame = Instance.new("Frame")
    jobFrame.Size = UDim2.new(0.9, 0, 0, 80)
    jobFrame.Position = UDim2.new(0.05, 0, 0, 20)
    jobFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    jobFrame.BackgroundTransparency = 0.3
    jobFrame.BorderSizePixel = 0
    jobFrame.Parent = rankSection
    
    local jobCorner = Instance.new("UICorner")
    jobCorner.CornerRadius = UDim.new(0, 8)
    jobCorner.Parent = jobFrame
    
    UIModule.createLabel(jobFrame, "Header", "NOTIFICATION", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 10),
        18, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    
    UIModule.createLabel(jobFrame, "Message", "Your job has changed", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 35),
        22, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    local rankDisplay = Instance.new("Frame")
    rankDisplay.Size = UDim2.new(0.9, 0, 0, 130)
    rankDisplay.Position = UDim2.new(0.05, 0, 0, 110)
    rankDisplay.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    rankDisplay.BackgroundTransparency = 0.3
    rankDisplay.BorderSizePixel = 0
    rankDisplay.Parent = rankSection
    
    local rankCorner = Instance.new("UICorner")
    rankCorner.CornerRadius = UDim.new(0, 8)
    rankCorner.Parent = rankDisplay
    
    UIModule.createLabel(rankDisplay, "OldRank", "[necromancer]", UDim2.new(0.5, 0, 0, 50), UDim2.new(0, 20, 0, 20),
        26, Color3.fromRGB(150, 150, 150), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    UIModule.createLabel(rankDisplay, "Arrow", "↓", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 50),
        36, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    UI.jobLabel = UIModule.createLabel(rankDisplay, "NewRank", "[" .. PlayerData.job:lower() .. "]", 
        UDim2.new(0.5, 0, 0, 50), UDim2.new(0.5, -20, 0, 70),
        26, Color3.fromRGB(100, 255, 100), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    
    -- Points display
    local pointsFrame = UIModule.createRoundedFrame(container, "PointsFrame", UDim2.new(0, 200, 0, 60), UDim2.new(1, -220, 0, 20),
        Color3.fromRGB(0, 150, 255), 0.2)
    UIModule.createGlowBorder(pointsFrame, Color3.fromRGB(100, 200, 255), 2)
    
    UIModule.createLabel(pointsFrame, "Label", "Available", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 5),
        16, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    UIModule.createLabel(pointsFrame, "Label2", "Ability Points:", UDim2.new(0.5, 0, 0, 25), UDim2.new(0, 10, 0, 30),
        18, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    
    UI.pointsLabel = UIModule.createLabel(pointsFrame, "Points", tostring(PlayerData.availablePoints),
        UDim2.new(0.4, 0, 0, 30), UDim2.new(0.6, 0, 0, 27),
        32, Color3.fromRGB(255, 255, 100), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    UI.isVisible = true
    FollowController:start()
    UIModule.updateUI()
    
    print("✅ Main UI created successfully!")
end

function UIModule.showDescription(statName, parentFrame)
    if UI.descriptionFrame then
        UI.descriptionFrame:Destroy()
        UI.descriptionFrame = nil
        return
    end
    
    local desc = STAT_DESCRIPTIONS[statName]
    
    UI.descriptionFrame = Instance.new("Frame")
    UI.descriptionFrame.Name = "DescriptionFrame"
    UI.descriptionFrame.Size = UDim2.new(0, 450, 0, 140)
    UI.descriptionFrame.Position = UDim2.new(1, 20, 0, -35)
    UI.descriptionFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
    UI.descriptionFrame.BackgroundTransparency = 0
    UI.descriptionFrame.BorderSizePixel = 0
    UI.descriptionFrame.ZIndex = 10
    UI.descriptionFrame.Parent = parentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = UI.descriptionFrame
    
    UIModule.createGlowBorder(UI.descriptionFrame, Color3.fromRGB(100, 200, 255), 3)
    
    local title = UIModule.createLabel(UI.descriptionFrame, "Title", desc.name, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10),
        22, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
    
    local descLabel = UIModule.createLabel(UI.descriptionFrame, "Desc", desc.desc, UDim2.new(1, -20, 0, 50), UDim2.new(0, 10, 0, 45),
        16, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Left)
    descLabel.TextWrapped = true
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    local effect = UIModule.createLabel(UI.descriptionFrame, "Effect", desc.effect, UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 100),
        15, Color3.fromRGB(100, 255, 100), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    effect.TextWrapped = true
    effect.TextYAlignment = Enum.TextYAlignment.Top
    
    task.delay(5, function()
        if UI.descriptionFrame then
            UI.descriptionFrame:Destroy()
            UI.descriptionFrame = nil
        end
    end)
end

function UIModule.upgradeStat(statName)
    if PlayerData.availablePoints <= 0 then
        UIModule.showNotification("No points available!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    PlayerData.stats[statName] = PlayerData.stats[statName] + 1
    PlayerData.availablePoints = PlayerData.availablePoints - 1
    
    UIModule.updateUI()
    StatSystem.applyStatEffects()
    UIModule.showNotification("+" .. statName .. " increased!", Color3.fromRGB(100, 255, 100))
    
    print("📈 Upgraded " .. statName .. " to " .. PlayerData.stats[statName])
    
    local btn = UI.plusButtons[statName]
    if btn then
        local original = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = original}):Play()
    end
end

function UIModule.updateUI()
    if not UI.isVisible then return end
    
    for statName, label in pairs(UI.statLabels) do
        label.Text = tostring(PlayerData.stats[statName])
    end
    
    if UI.pointsLabel then
        UI.pointsLabel.Text = tostring(PlayerData.availablePoints)
    end
    
    if UI.levelLabel then
        UI.levelLabel.Text = tostring(PlayerData.level)
    end
    
    if UI.hpBar and humanoid then
        local hpPercent = humanoid.Health / humanoid.MaxHealth
        UI.hpBar.Size = UDim2.new(hpPercent, 0, 1, 0)
        
        local hpText = UI.hpBar.Parent:FindFirstChild("HPText")
        if hpText then
            hpText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        end
    end
    
    if UI.mpBar then
        local mpPercent = PlayerData.currentMP / PlayerData.maxMP
        UI.mpBar.Size = UDim2.new(mpPercent, 0, 1, 0)
        
        local mpText = UI.mpBar.Parent:FindFirstChild("MPText")
        if mpText then
            mpText.Text = PlayerData.currentMP .. "/" .. PlayerData.maxMP
        end
    end
    
    if UI.fatigueLabel then
        UI.fatigueLabel.Text = "FATIGUE: " .. PlayerData.fatigue
    end
    
    if UI.jobLabel then
        UI.jobLabel.Text = "[" .. PlayerData.job:lower() .. "]"
    end
end

function UIModule.showNotification(text, color)
    if not rootPart then return end
    
    local notifPart = Instance.new("Part")
    notifPart.Size = Vector3.new(5, 2, 0.1)
    notifPart.Anchored = true
    notifPart.CanCollide = false
    notifPart.Material = Enum.Material.ForceField
    notifPart.Transparency = 1
    notifPart.Parent = workspace
    
    local lookVector = rootPart.CFrame.LookVector
    notifPart.CFrame = CFrame.new(rootPart.Position + (lookVector * 4) + Vector3.new(0, 3, 0))
        * CFrame.Angles(0, math.pi, 0)
    
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(500, 200)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = notifPart
    
    local bg = UIModule.createRoundedFrame(surfaceGui, "Bg", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(5, 10, 20), 0.1)
    UIModule.createGlowBorder(bg, color or Color3.fromRGB(100, 200, 255), 3)
    
    local label = UIModule.createLabel(bg, "Text", text, UDim2.new(0.9, 0, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0),
        32, color or Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    task.delay(1.5, function()
        TweenService:Create(notifPart, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        notifPart:Destroy()
    end)
    
    local startPos = notifPart.Position
    task.spawn(function()
        for i = 0, 1, 0.02 do
            if not notifPart or not notifPart.Parent then break end
            notifPart.Position = startPos + Vector3.new(0, i * 2, 0)
            task.wait(0.02)
        end
    end)
end

function UIModule.toggleUI()
    if not UI.isAccepted then return end
    
    UI.isVisible = not UI.isVisible
    
    if UI.mainPart then
        UI.mainPart.Transparency = UI.isVisible and 1 or 1
        if UI.surfaceGui then
            UI.surfaceGui.Enabled = UI.isVisible
        end
    end
    
    if UI.isVisible then
        FollowController:start()
        print("👁 UI visible")
    else
        FollowController:stop()
        print("🙈 UI hidden")
    end
end

print("[9/10] Creating stat and ability systems...")

-- ═══════════════════════════════════════════════════════════════
-- ⚡ STAT SYSTEM
-- ═══════════════════════════════════════════════════════════════

local StatSystem = {}

function StatSystem.applyStatEffects()
    if not character or not humanoid then return end
    
    local str = PlayerData.stats.STR
    local vit = PlayerData.stats.VIT
    local agi = PlayerData.stats.AGI
    local int = PlayerData.stats.INT
    local per = PlayerData.stats.PER
    
    PlayerData.maxHP = 100 + (vit * 20)
    humanoid.MaxHealth = PlayerData.maxHP
    
    local newSpeed = PlayerData.baseWalkSpeed + (agi * 0.84)
    PlayerData.currentWalkSpeed = newSpeed
    
    pcall(function()
        humanoid.WalkSpeed = newSpeed
    end)
    
    print("⚡ Speed applied: " .. newSpeed .. " (AGI: " .. agi .. ")")
    
    task.spawn(function()
        while character and character.Parent and humanoid and humanoid.Parent do
            if not PlayerData.abilities.rampage.active then
                pcall(function()
                    if humanoid.WalkSpeed ~= newSpeed then
                        humanoid.WalkSpeed = newSpeed
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
    
    local newJump = 50 + (agi * 2)
    pcall(function()
        if humanoid.UseJumpPower then
            humanoid.JumpPower = newJump
        else
            humanoid.JumpHeight = newJump / 3.6
        end
    end)
    
    PlayerData.maxMP = 10 + (int * 2)
    
    local perCurve = 0.02
    local cooldownReduction = 1 - (per * perCurve)
    cooldownReduction = math.max(cooldownReduction, 0.4)
    
    PlayerData.abilities.shadowStep.cooldown = 5 * cooldownReduction
    PlayerData.abilities.shadowStep.range = 30 + (per * 10)
    
    PlayerData.abilities.rampage.cooldown = 15 * cooldownReduction
    PlayerData.abilities.rampage.duration = 8 + (per * 2.1)
    
    PlayerData.abilities.behindYou.cooldown = 10 * cooldownReduction
    PlayerData.abilities.behindYou.range = 50 + (per * 10)
    
    print("✅ All stats applied successfully")
end

-- ═══════════════════════════════════════════════════════════════
-- ⚔️ ABILITY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local AbilitySystem = {}

function AbilitySystem.shadowStep()
    local ability = PlayerData.abilities.shadowStep
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotification("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if not character or not rootPart then return end
    
    ability.lastUsed = currentTime
    
    local lookVector = rootPart.CFrame.LookVector
    local targetPos = rootPart.Position + (lookVector * ability.range)
    rootPart.CFrame = CFrame.new(targetPos, targetPos + lookVector)
    
    UIModule.showNotification("Shadow Step!", Color3.fromRGB(150, 100, 255))
    print("⚡ Shadow Step used!")
end

function AbilitySystem.rampage()
    local ability = PlayerData.abilities.rampage
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotification("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if ability.active then
        UIModule.showNotification("Already active!", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if not character or not humanoid then return end
    
    ability.lastUsed = currentTime
    ability.active = true
    
    UIModule.showNotification("RAMPAGE!", Color3.fromRGB(255, 50, 50))
    print("💥 RAMPAGE activated!")
    
    local baseSpeed = PlayerData.currentWalkSpeed
    local boostedSpeed = baseSpeed * ability.speedMultiplier
    
    local function applySpeed()
        pcall(function()
            humanoid.WalkSpeed = boostedSpeed
        end)
    end
    
    applySpeed()
    
    local speedLoop = RunService.Heartbeat:Connect(function()
        if ability.active then
            applySpeed()
        end
    end)
    
    task.delay(ability.duration, function()
        ability.active = false
        if speedLoop then speedLoop:Disconnect() end
        StatSystem.applyStatEffects()
        UIModule.showNotification("Rampage ended", Color3.fromRGB(255, 200, 100))
        print("✅ Rampage ended")
    end)
end

function AbilitySystem.behindYou()
    local ability = PlayerData.abilities.behindYou
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotification("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
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
        UIModule.showNotification("No targets in range!", Color3.fromRGB(255, 150, 100))
        return
    end
    
    ability.lastUsed = currentTime
    
    local targetRoot = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        local behindPos = targetRoot.Position - (targetRoot.CFrame.LookVector * 5)
        rootPart.CFrame = CFrame.new(behindPos, targetRoot.Position)
        
        UIModule.showNotification("Behind You!", Color3.fromRGB(100, 200, 255))
        print("👻 Behind You used on " .. nearestPlayer.Name)
    end
end

print("[10/10] Setting up input and initialization...")

-- ═══════════════════════════════════════════════════════════════
-- 🎮 INPUT HANDLING
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
    
    print("✅ Input handling setup")
end

-- ═══════════════════════════════════════════════════════════════
-- 🔄 CHARACTER RESPAWN
-- ═══════════════════════════════════════════════════════════════

player.CharacterAdded:Connect(function(newChar)
    print("🔄 Character respawned, reloading...")
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    task.wait(1)
    
    StatSystem.applyStatEffects()
    
    if UI.isAccepted and UI.mainPart then
        pcall(function()
            UI.mainPart:Destroy()
        end)
        task.wait(0.5)
        UIModule.createMainUI()
    end
    
    print("✅ Character reload complete")
end)

-- ═══════════════════════════════════════════════════════════════
-- 🚀 INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local function initialize()
    if not character or not character.Parent then
        character = player.Character or player.CharacterAdded:Wait()
    end
    
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    task.wait(2)
    
    pcall(function()
        StatSystem.applyStatEffects()
        setupInput()
        UIModule.createInitialNotification()
    end)
    
    print("═══════════════════════════════════════════════")
    print("✅ SOLO LEVELING LOADED SUCCESSFULLY!")
    print("═══════════════════════════════════════════════")
    print("🎮 Controls:")
    print("[X] - Toggle Stats UI")
    print("[E] - Shadow Step")
    print("[R] - Rampage")
    print("[F] - Behind You")
    print("═══════════════════════════════════════════════")
    print("💡 Look for the notification in front of you!")
    print("═══════════════════════════════════════════════")
end

initialize()

end)

if not success then
    print("═══════════════════════════════════════════════")
    print("❌ ERROR LOADING SOLO LEVELING:")
    print(error)
    print("═══════════════════════════════════════════════")
else
    print("═══════════════════════════════════════════════")
    print("✅✅✅ SCRIPT FULLY LOADED! ✅✅✅")
    print("═══════════════════════════════════════════════")
end
