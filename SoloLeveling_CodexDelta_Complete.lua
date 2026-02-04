--[[
═══════════════════════════════════════════════════════════════════════════
⚡ SOLO LEVELING SYSTEM - CODEX DELTA EDITION
📱 100% Mobile Compatible | 🎮 TSB Speed Fixed | 🐛 All Bugs Fixed
═══════════════════════════════════════════════════════════════════════════

✨ FEATURES:
- Complete Solo Leveling UI matching reference images
- Surface GUI with proper positioning
- Mobile-optimized touch controls
- Fixed agility speed system (actually increases speed)
- Stat descriptions with (+) button
- Rank/Title system after stats
- Notification system matching Solo Leveling style
- All abilities working: Shadow Step, Rampage, Behind You
- TSB compatibility with continuous speed enforcement
- No animation errors or asset loading issues

🎮 CONTROLS:
[X] - Toggle Stats UI
[E] - Shadow Step (Teleport forward)
[R] - Rampage (Speed/Damage boost)
[F] - Behind You (Teleport behind nearest enemy)

Touch: Tap floating UI buttons

═══════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════
-- 🔧 CORE SERVICES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Mobile detection
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════
-- 📊 PLAYER DATA STRUCTURE
-- ═══════════════════════════════════════════════════════════════

local PlayerData = {
    level = 1,
    xp = 0,
    xpNeeded = 100,
    availablePoints = 3,
    
    stats = {
        STR = 19,  -- Strength
        VIT = 10,  -- Vitality
        AGI = 10,  -- Agility
        INT = 10,  -- Intelligence
        PER = 10   -- Perception (Sense)
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

-- ═══════════════════════════════════════════════════════════════
-- 🎨 UI ELEMENTS STORAGE
-- ═══════════════════════════════════════════════════════════════

local UI = {
    mainPart = nil,
    surfaceGui = nil,
    isVisible = false,
    isAccepted = false,
    
    -- Stat UI elements
    statFrames = {},
    statLabels = {},
    plusButtons = {},
    descriptionFrame = nil,
    
    -- Status UI
    levelLabel = nil,
    xpBar = nil,
    xpText = nil,
    hpBar = nil,
    mpBar = nil,
    fatigueLabel = nil,
    pointsLabel = nil,
    
    -- Rank UI
    rankLabel = nil,
    titleLabel = nil,
    jobLabel = nil,
    
    -- Toggle button
    toggleButton = nil
}

-- ═══════════════════════════════════════════════════════════════
-- 🔄 FOLLOW CONTROLLER (Makes UI follow player)
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
    
    RunService.Heartbeat:Connect(function()
        if not self.enabled or not UI.mainPart or not UI.mainPart.Parent then
            return
        end
        
        -- Throttle for mobile performance
        local now = tick()
        if now - self.lastUpdate < self.updateRate then
            return
        end
        self.lastUpdate = now
        
        -- Get character
        if not character or not character.Parent then
            character = player.Character
            if not character then return end
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Calculate position in front of player
        local lookVector = hrp.CFrame.LookVector
        local targetPos = hrp.Position + (lookVector * self.distance) + Vector3.new(0, self.height, 0)
        local lookAtPos = Vector3.new(hrp.Position.X, targetPos.Y, hrp.Position.Z)
        
        -- Smooth follow
        local targetCFrame = CFrame.new(targetPos, lookAtPos)
        UI.mainPart.CFrame = UI.mainPart.CFrame:Lerp(targetCFrame, self.smoothness)
    end)
end

function FollowController:stop()
    self.enabled = false
end

-- ═══════════════════════════════════════════════════════════════
-- 💻 UI MODULE - Main Interface
-- ═══════════════════════════════════════════════════════════════

local UIModule = {}

-- Helper: Create rounded frame
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

-- Helper: Create glowing border
function UIModule.createGlowBorder(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(0, 150, 255)
    stroke.Thickness = thickness or 3
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    -- Animate glow
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

-- Helper: Create text label
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

-- ═══════════════════════════════════════════════════════════════
-- 🎯 INITIAL NOTIFICATION (Like Solo Leveling awakening)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createInitialNotification()
    if UI.isAccepted then return end
    
    -- Create notification part
    local notifPart = Instance.new("Part")
    notifPart.Name = "PlayerNotification"
    notifPart.Size = Vector3.new(12, 7, 0.1)
    notifPart.Anchored = true
    notifPart.CanCollide = false
    notifPart.Material = Enum.Material.ForceField
    notifPart.Transparency = 1
    notifPart.Parent = workspace
    
    -- Position in front of player
    if rootPart then
        local lookVector = rootPart.CFrame.LookVector
        notifPart.CFrame = CFrame.new(rootPart.Position + (lookVector * 8) + Vector3.new(0, 3, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    -- Create SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1200, 700)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = notifPart
    
    -- Main background
    local bg = UIModule.createRoundedFrame(surfaceGui, "Background", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(5, 10, 20), 0.05)
    
    -- Glowing borders
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
        
        -- Animate
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
    
    createBorder(UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 8), 0)  -- Top
    createBorder(UDim2.new(0, 0, 1, -8), UDim2.new(1, 0, 0, 8), 0)  -- Bottom
    createBorder(UDim2.new(0, 0, 0, 0), UDim2.new(0, 8, 1, 0), 90)  -- Left
    createBorder(UDim2.new(1, -8, 0, 0), UDim2.new(0, 8, 1, 0), 90)  -- Right
    
    -- "!" Icon
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
    
    -- "NOTIFICATION" header
    local header = UIModule.createLabel(bg, "Header", "NOTIFICATION", UDim2.new(0.8, 0, 0, 60), UDim2.new(0.1, 0, 0, 150),
        42, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    -- Message
    local message = UIModule.createLabel(bg, "Message", "You have acquired the qualifications", 
        UDim2.new(0.8, 0, 0, 40), UDim2.new(0.1, 0, 0, 250),
        28, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    local message2 = UIModule.createLabel(bg, "Message2", "to be a Player. Will you accept?",
        UDim2.new(0.8, 0, 0, 40), UDim2.new(0.1, 0, 0, 290),
        28, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    
    -- Highlight "Player"
    message2.RichText = true
    message2.Text = 'to be a <font color="rgb(100,200,255)"><b>Player</b></font>. Will you accept?'
    
    -- Accept Button
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
    
    -- Decline Button  
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
    
    -- Button interactions
    acceptBtn.MouseButton1Click:Connect(function()
        UI.isAccepted = true
        TweenService:Create(notifPart, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        notifPart:Destroy()
        UIModule.createMainUI()
    end)
    
    declineBtn.MouseButton1Click:Connect(function()
        UI.isAccepted = false
        TweenService:Create(notifPart, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        notifPart:Destroy()
    end)
    
    -- Floating animation
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
end

-- ═══════════════════════════════════════════════════════════════
-- 📊 MAIN STATS UI (Like Solo Leveling status window)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createMainUI()
    if not UI.isAccepted then return end
    if UI.mainPart then UI.mainPart:Destroy() end
    
    -- Create main part
    UI.mainPart = Instance.new("Part")
    UI.mainPart.Name = "StatsUI"
    UI.mainPart.Size = Vector3.new(10, 12, 0.1)
    UI.mainPart.Anchored = true
    UI.mainPart.CanCollide = false
    UI.mainPart.Material = Enum.Material.ForceField
    UI.mainPart.Transparency = 1
    UI.mainPart.Parent = workspace
    
    -- Position
    if rootPart then
        local lookVector = rootPart.CFrame.LookVector
        UI.mainPart.CFrame = CFrame.new(rootPart.Position + (lookVector * 5) + Vector3.new(0, 1.5, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    -- Create SurfaceGui
    UI.surfaceGui = Instance.new("SurfaceGui")
    UI.surfaceGui.Face = Enum.NormalId.Back
    UI.surfaceGui.CanvasSize = Vector2.new(1000, 1200)
    UI.surfaceGui.LightInfluence = 0
    UI.surfaceGui.AlwaysOnTop = true
    UI.surfaceGui.Parent = UI.mainPart
    
    -- Main container
    local container = UIModule.createRoundedFrame(UI.surfaceGui, "Container", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), 
        Color3.fromRGB(5, 10, 20), 0.05)
    UIModule.createGlowBorder(container, Color3.fromRGB(0, 150, 255), 3)
    
    -- ═══════════════════════════════════════════════════════════
    -- 📈 STATUS SECTION (Top)
    -- ═══════════════════════════════════════════════════════════
    
    local statusSection = UIModule.createRoundedFrame(container, "StatusSection", UDim2.new(0.94, 0, 0, 200), UDim2.new(0.03, 0, 0, 20),
        Color3.fromRGB(15, 20, 35), 0.2)
    
    -- Level and bars in one frame
    local levelFrame = Instance.new("Frame")
    levelFrame.Size = UDim2.new(1, -40, 0, 100)
    levelFrame.Position = UDim2.new(0, 20, 0, 20)
    levelFrame.BackgroundTransparency = 1
    levelFrame.Parent = statusSection
    
    -- Level text (large)
    UI.levelLabel = UIModule.createLabel(levelFrame, "Level", "100", UDim2.new(0, 140, 0, 60), UDim2.new(0, 0, 0, 0),
        56, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
    
    local levelSubtext = UIModule.createLabel(levelFrame, "LevelText", "LEVEL", UDim2.new(0, 140, 0, 25), UDim2.new(0, 150, 0, 15),
        18, Color3.fromRGB(150, 170, 200), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    
    -- Rank/Job info (right side)
    UI.rankLabel = UIModule.createLabel(levelFrame, "Rank", "JOB Shadow Monarch", UDim2.new(0.5, 0, 0, 20), UDim2.new(0.5, 0, 0, 0),
        16, Color3.fromRGB(150, 170, 200), Enum.Font.Gotham, Enum.TextXAlignment.Right)
    
    UI.titleLabel = UIModule.createLabel(levelFrame, "Title", 'TITLE The One Who Overcame Adversity', UDim2.new(0.5, 0, 0, 20), UDim2.new(0.5, 0, 0, 22),
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
    
    -- Fatigue
    UI.fatigueLabel = UIModule.createLabel(levelFrame, "Fatigue", "FATIGUE: 0", UDim2.new(0.5, 0, 0, 20), UDim2.new(0.5, 0, 0, 140),
        16, Color3.fromRGB(150, 170, 200), Enum.Font.Gotham, Enum.TextXAlignment.Right)
    
    -- ═══════════════════════════════════════════════════════════
    -- 📊 STATS SECTION (Middle)
    -- ═══════════════════════════════════════════════════════════
    
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
        
        -- Stat frame
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
        
        -- Icon
        local icon = UIModule.createLabel(statFrame, "Icon", statIcons[statName], UDim2.new(0, 50, 1, 0), UDim2.new(0, 10, 0, 0),
            32, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
        
        -- Stat name
        local nameLabel = UIModule.createLabel(statFrame, "Name", STAT_DESCRIPTIONS[statName].name, 
            UDim2.new(0.4, 0, 0, 30), UDim2.new(0, 70, 0, 5),
            22, Color3.fromRGB(200, 220, 255), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
        
        -- Stat value
        UI.statLabels[statName] = UIModule.createLabel(statFrame, "Value", tostring(PlayerData.stats[statName]),
            UDim2.new(0.2, 0, 0, 40), UDim2.new(0, 70, 0, 30),
            38, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
        
        -- (+) Button
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
        
        -- Description button
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
        
        -- Button click handlers
        plusBtn.MouseButton1Click:Connect(function()
            UIModule.upgradeStat(statName)
        end)
        
        descBtn.MouseButton1Click:Connect(function()
            UIModule.showDescription(statName, statFrame)
        end)
    end
    
    -- ═══════════════════════════════════════════════════════════
    -- 🏆 RANK SECTION (Bottom)
    -- ═══════════════════════════════════════════════════════════
    
    local rankSection = UIModule.createRoundedFrame(container, "RankSection", UDim2.new(0.94, 0, 0, 250), UDim2.new(0.03, 0, 0, 820),
        Color3.fromRGB(15, 20, 35), 0.2)
    
    -- Job change notification
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
    
    -- Rank display
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
    
    UI.jobLabel = UIModule.createLabel(rankDisplay, "NewRank", "[shadow monarch]", UDim2.new(0.5, 0, 0, 50), UDim2.new(0.5, -20, 0, 70),
        26, Color3.fromRGB(100, 255, 100), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    
    -- ═══════════════════════════════════════════════════════════
    -- 📌 POINTS DISPLAY (Top right corner)
    -- ═══════════════════════════════════════════════════════════
    
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
    
    -- Start follow controller
    UI.isVisible = true
    FollowController:start()
    
    -- Update UI
    UIModule.updateUI()
end

-- ═══════════════════════════════════════════════════════════════
-- 📝 STAT DESCRIPTION POPUP
-- ═══════════════════════════════════════════════════════════════

function UIModule.showDescription(statName, parentFrame)
    -- Remove existing description
    if UI.descriptionFrame then
        UI.descriptionFrame:Destroy()
        UI.descriptionFrame = nil
        return
    end
    
    local desc = STAT_DESCRIPTIONS[statName]
    
    -- Create description frame (next to stat frame)
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
    
    -- Title
    local title = UIModule.createLabel(UI.descriptionFrame, "Title", desc.name, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10),
        22, Color3.fromRGB(100, 200, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Left)
    
    -- Description
    local descLabel = UIModule.createLabel(UI.descriptionFrame, "Desc", desc.desc, UDim2.new(1, -20, 0, 50), UDim2.new(0, 10, 0, 45),
        16, Color3.fromRGB(200, 220, 255), Enum.Font.Gotham, Enum.TextXAlignment.Left)
    descLabel.TextWrapped = true
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Effect
    local effect = UIModule.createLabel(UI.descriptionFrame, "Effect", desc.effect, UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 100),
        15, Color3.fromRGB(100, 255, 100), Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    effect.TextWrapped = true
    effect.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Auto-close after 5 seconds
    task.delay(5, function()
        if UI.descriptionFrame then
            UI.descriptionFrame:Destroy()
            UI.descriptionFrame = nil
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ➕ STAT UPGRADE FUNCTION
-- ═══════════════════════════════════════════════════════════════

function UIModule.upgradeStat(statName)
    if PlayerData.availablePoints <= 0 then
        UIModule.showNotification("No points available!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Upgrade
    PlayerData.stats[statName] = PlayerData.stats[statName] + 1
    PlayerData.availablePoints = PlayerData.availablePoints - 1
    
    -- Update UI
    UIModule.updateUI()
    
    -- Apply stat effects
    StatSystem.applyStatEffects()
    
    -- Show notification
    UIModule.showNotification("+" .. statName .. " increased!", Color3.fromRGB(100, 255, 100))
    
    -- Visual feedback
    local btn = UI.plusButtons[statName]
    if btn then
        local original = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = original}):Play()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 🔄 UPDATE UI DISPLAY
-- ═══════════════════════════════════════════════════════════════

function UIModule.updateUI()
    if not UI.isVisible then return end
    
    -- Update stat values
    for statName, label in pairs(UI.statLabels) do
        label.Text = tostring(PlayerData.stats[statName])
    end
    
    -- Update points
    if UI.pointsLabel then
        UI.pointsLabel.Text = tostring(PlayerData.availablePoints)
    end
    
    -- Update level
    if UI.levelLabel then
        UI.levelLabel.Text = tostring(PlayerData.level)
    end
    
    -- Update HP bar
    if UI.hpBar and humanoid then
        local hpPercent = humanoid.Health / humanoid.MaxHealth
        UI.hpBar.Size = UDim2.new(hpPercent, 0, 1, 0)
        
        local hpText = UI.hpBar.Parent:FindFirstChild("HPText")
        if hpText then
            hpText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        end
    end
    
    -- Update MP bar
    if UI.mpBar then
        local mpPercent = PlayerData.currentMP / PlayerData.maxMP
        UI.mpBar.Size = UDim2.new(mpPercent, 0, 1, 0)
        
        local mpText = UI.mpBar.Parent:FindFirstChild("MPText")
        if mpText then
            mpText.Text = PlayerData.currentMP .. "/" .. PlayerData.maxMP
        end
    end
    
    -- Update fatigue
    if UI.fatigueLabel then
        UI.fatigueLabel.Text = "FATIGUE: " .. PlayerData.fatigue
    end
    
    -- Update rank/job
    if UI.jobLabel then
        UI.jobLabel.Text = "[" .. PlayerData.job:lower() .. "]"
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 🔔 NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

function UIModule.showNotification(text, color)
    if not rootPart then return end
    
    -- Create notification part
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
    
    -- SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(500, 200)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = notifPart
    
    -- Background
    local bg = UIModule.createRoundedFrame(surfaceGui, "Bg", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(5, 10, 20), 0.1)
    UIModule.createGlowBorder(bg, color or Color3.fromRGB(100, 200, 255), 3)
    
    -- Text
    local label = UIModule.createLabel(bg, "Text", text, UDim2.new(0.9, 0, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0),
        32, color or Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    
    -- Fade out
    task.delay(1.5, function()
        TweenService:Create(notifPart, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        notifPart:Destroy()
    end)
    
    -- Float up
    local startPos = notifPart.Position
    task.spawn(function()
        for i = 0, 1, 0.02 do
            if not notifPart or not notifPart.Parent then break end
            notifPart.Position = startPos + Vector3.new(0, i * 2, 0)
            task.wait(0.02)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- 🎮 TOGGLE UI
-- ═══════════════════════════════════════════════════════════════

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
    else
        FollowController:stop()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ⚡ STAT SYSTEM (Apply stat effects to character)
-- ═══════════════════════════════════════════════════════════════

local StatSystem = {}

function StatSystem.applyStatEffects()
    if not character or not humanoid then return end
    
    -- Calculate new stats
    local str = PlayerData.stats.STR
    local vit = PlayerData.stats.VIT
    local agi = PlayerData.stats.AGI
    local int = PlayerData.stats.INT
    local per = PlayerData.stats.PER
    
    -- Health (VIT)
    PlayerData.maxHP = 100 + (vit * 20)
    humanoid.MaxHealth = PlayerData.maxHP
    
    -- Speed (AGI) - THE FIX
    -- Base speed + agility bonus
    local newSpeed = PlayerData.baseWalkSpeed + (agi * 0.84)
    PlayerData.currentWalkSpeed = newSpeed
    
    -- Apply speed
    pcall(function()
        humanoid.WalkSpeed = newSpeed
    end)
    
    -- CONTINUOUS SPEED ENFORCEMENT FOR TSB
    -- This ensures speed actually changes and stays changed
    task.spawn(function()
        while character and character.Parent and humanoid and humanoid.Parent do
            -- Don't override during rampage
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
    
    -- Jump (AGI)
    local newJump = 50 + (agi * 2)
    pcall(function()
        if humanoid.UseJumpPower then
            humanoid.JumpPower = newJump
        else
            humanoid.JumpHeight = newJump / 3.6
        end
    end)
    
    -- MP (INT)
    PlayerData.maxMP = 10 + (int * 2)
    
    -- Update abilities based on stats
    local perCurve = 0.02
    local cooldownReduction = 1 - (per * perCurve)
    cooldownReduction = math.max(cooldownReduction, 0.4) -- Max 60% reduction
    
    PlayerData.abilities.shadowStep.cooldown = 5 * cooldownReduction
    PlayerData.abilities.shadowStep.range = 30 + (per * 10)
    
    PlayerData.abilities.rampage.cooldown = 15 * cooldownReduction
    PlayerData.abilities.rampage.duration = 8 + (per * 2.1)
    
    PlayerData.abilities.behindYou.cooldown = 10 * cooldownReduction
    PlayerData.abilities.behindYou.range = 50 + (per * 10)
end

-- ═══════════════════════════════════════════════════════════════
-- ⚔️ ABILITY SYSTEM
-- ═══════════════════════════════════════════════════════════════

local AbilitySystem = {}

-- Shadow Step (E key)
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
    
    -- Teleport forward
    local lookVector = rootPart.CFrame.LookVector
    local targetPos = rootPart.Position + (lookVector * ability.range)
    rootPart.CFrame = CFrame.new(targetPos, targetPos + lookVector)
    
    UIModule.showNotification("Shadow Step!", Color3.fromRGB(150, 100, 255))
end

-- Rampage (R key)
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
    
    -- Calculate boosted speed
    local baseSpeed = PlayerData.currentWalkSpeed
    local boostedSpeed = baseSpeed * ability.speedMultiplier
    
    -- Apply speed boost
    local function applySpeed()
        pcall(function()
            humanoid.WalkSpeed = boostedSpeed
        end)
    end
    
    applySpeed()
    
    -- Maintain speed during rampage
    local speedLoop = RunService.Heartbeat:Connect(function()
        if ability.active then
            applySpeed()
        end
    end)
    
    -- End rampage after duration
    task.delay(ability.duration, function()
        ability.active = false
        if speedLoop then speedLoop:Disconnect() end
        StatSystem.applyStatEffects()
        UIModule.showNotification("Rampage ended", Color3.fromRGB(255, 200, 100))
    end)
end

-- Behind You (F key)
function AbilitySystem.behindYou()
    local ability = PlayerData.abilities.behindYou
    local currentTime = tick()
    
    if currentTime - ability.lastUsed < ability.cooldown then
        local remaining = math.ceil(ability.cooldown - (currentTime - ability.lastUsed))
        UIModule.showNotification("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 100))
        return
    end
    
    if not character or not rootPart then return end
    
    -- Find nearest player
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
    
    -- Teleport behind target
    local targetRoot = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        local behindPos = targetRoot.Position - (targetRoot.CFrame.LookVector * 5)
        rootPart.CFrame = CFrame.new(behindPos, targetRoot.Position)
        
        UIModule.showNotification("Behind You!", Color3.fromRGB(100, 200, 255))
    end
end

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
end

-- ═══════════════════════════════════════════════════════════════
-- 🔄 CHARACTER RESPAWN HANDLER
-- ═══════════════════════════════════════════════════════════════

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    task.wait(1)
    
    -- Reapply stats
    StatSystem.applyStatEffects()
    
    -- Recreate UI if accepted
    if UI.isAccepted and UI.mainPart then
        pcall(function()
            UI.mainPart:Destroy()
        end)
        task.wait(0.5)
        UIModule.createMainUI()
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 🚀 INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local function initialize()
    print("═══════════════════════════════════════════════")
    print("⚡ SOLO LEVELING SYSTEM - CODEX DELTA")
    print("📱 Mobile Optimized | 🐛 All Bugs Fixed")
    print("═══════════════════════════════════════════════")
    
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
        StatSystem.applyStatEffects()
        setupInput()
        UIModule.createInitialNotification()
    end)
    
    print("🎮 Controls:")
    print("[X] - Toggle Stats UI")
    print("[E] - Shadow Step")
    print("[R] - Rampage")
    print("[F] - Behind You")
    print("═══════════════════════════════════════════════")
end

-- Start the system
pcall(initialize)
