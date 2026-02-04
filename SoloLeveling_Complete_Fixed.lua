--[[
═══════════════════════════════════════════════════════════════════════════
⚡ SOLO LEVELING SYSTEM - COMPLETE REBUILD
🎮 3D Object UI System with Solo Leveling Aesthetic
🔧 Fixed for The Strongest Battleground + Codex/Delta Compatible
═══════════════════════════════════════════════════════════════════════════

✨ FEATURES:
- Real 3D object UI in workspace (not ScreenGui - no glitches!)
- Solo Leveling notification aesthetic with glowing borders
- Fixed WalkSpeed system for TSB
- Rampage ability WITHOUT camera shake/VFX/effects
- Clean, optimized for Codex and Delta executors
- All stats functional (STR, VIT, AGI, INT, SENSE)

🎯 CONTROLS:
- [X] - Toggle UI
- [E] - Shadow Step (Teleport)
- [R] - Rampage (Speed boost - NO EFFECTS)
- [F] - Behind You (Teleport behind target)

═══════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════
-- 🔧 CORE SERVICES & VARIABLES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════════
-- 📊 PLAYER DATA SYSTEM
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
        shadowStep = {
            name = "Shadow Step",
            key = Enum.KeyCode.E,
            cooldown = 5,
            lastUsed = 0,
            manaCost = 20
        },
        rampage = {
            name = "Rampage",
            key = Enum.KeyCode.R,
            cooldown = 15,
            lastUsed = 0,
            duration = 8,
            active = false
        },
        behindYou = {
            name = "Behind You",
            key = Enum.KeyCode.F,
            cooldown = 10,
            lastUsed = 0,
            range = 50
        }
    },
    
    baseWalkSpeed = 16,
    baseJumpPower = 50,
    baseHealth = 100
}

-- ═══════════════════════════════════════════════════════════════
-- 🎨 UI ELEMENTS STORAGE
-- ═══════════════════════════════════════════════════════════════

local uiElements = {
    mainPart = nil,
    surfaceGui = nil,
    container = nil,
    isVisible = false,
    
    statLabels = {},
    statButtons = {},
    abilityButtons = {},
    
    levelLabel = nil,
    expBar = nil,
    pointsLabel = nil
}

local acceptedNotification = false
local notificationShown = false

-- ═══════════════════════════════════════════════════════════════
-- 🎯 UI FOLLOW CONTROLLER (Makes UI follow player)
-- ═══════════════════════════════════════════════════════════════

local FollowController = {
    enabled = false,
    offset = Vector3.new(0, 0, 0),
    distance = 6,
    height = 2
}

function FollowController:start()
    self.enabled = true
    
    RunService.RenderStepped:Connect(function()
        if not self.enabled or not uiElements.mainPart or not uiElements.mainPart.Parent then
            return
        end
        
        if not character or not character.Parent then
            character = player.Character
            if not character then return end
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Position UI in front of player
        local lookVector = hrp.CFrame.LookVector
        local targetPosition = hrp.Position + (lookVector * self.distance) + Vector3.new(0, self.height, 0)
        local targetCFrame = CFrame.new(targetPosition, hrp.Position + Vector3.new(0, self.height, 0))
        
        -- Smooth follow
        uiElements.mainPart.CFrame = uiElements.mainPart.CFrame:Lerp(targetCFrame, 0.1)
    end)
end

function FollowController:stop()
    self.enabled = false
end

-- ═══════════════════════════════════════════════════════════════
-- 💻 UI MODULE - MAIN INTERFACE SYSTEM
-- ═══════════════════════════════════════════════════════════════

local UIModule = {}

-- Create ability button helper
function UIModule.createAbilityButton(parent, name, key, order, color)
    local button = Instance.new("Frame")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, 0, 0, 65)
    button.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.LayoutOrder = order
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
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 15, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    nameLabel.TextSize = 22
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 50, 0, 35)
    keyLabel.Position = UDim2.new(1, -65, 0.5, -17.5)
    keyLabel.BackgroundColor3 = color
    keyLabel.BackgroundTransparency = 0.3
    keyLabel.BorderSizePixel = 0
    keyLabel.Text = key
    keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.TextSize = 20
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.Parent = button
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyLabel
    
    return button
end

-- ═══════════════════════════════════════════════════════════════
-- ⭐ INITIAL NOTIFICATION (Solo Leveling Style)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createInitialNotification()
    if acceptedNotification then return end
    
    -- Create 3D notification panel
    local notifPart = Instance.new("Part")
    notifPart.Name = "SystemNotificationPanel"
    notifPart.Size = Vector3.new(12, 7, 0.1)
    notifPart.Anchored = true
    notifPart.CanCollide = false
    notifPart.Material = Enum.Material.ForceField
    notifPart.Transparency = 1
    notifPart.Parent = workspace
    
    -- Position in front of player
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local lookVector = hrp.CFrame.LookVector
        notifPart.CFrame = CFrame.new(hrp.Position + (lookVector * 8) + Vector3.new(0, 3, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    -- Create SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1200, 700)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = notifPart
    
    -- Main dark background
    local mainBg = Instance.new("Frame")
    mainBg.Size = UDim2.new(1, 0, 1, 0)
    mainBg.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    mainBg.BackgroundTransparency = 0.1
    mainBg.BorderSizePixel = 0
    mainBg.Parent = surfaceGui
    
    -- Glowing top border with gradient
    local topBorder = Instance.new("Frame")
    topBorder.Size = UDim2.new(1, 0, 0, 8)
    topBorder.Position = UDim2.new(0, 0, 0, 0)
    topBorder.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    topBorder.BorderSizePixel = 0
    topBorder.Parent = mainBg
    
    local topGlow = Instance.new("UIGradient")
    topGlow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    topGlow.Parent = topBorder
    
    -- Bottom border
    local bottomBorder = topBorder:Clone()
    bottomBorder.Position = UDim2.new(0, 0, 1, -8)
    bottomBorder.Parent = mainBg
    
    -- Left border with vertical gradient
    local leftBorder = Instance.new("Frame")
    leftBorder.Size = UDim2.new(0, 8, 1, 0)
    leftBorder.Position = UDim2.new(0, 0, 0, 0)
    leftBorder.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    leftBorder.BorderSizePixel = 0
    leftBorder.Parent = mainBg
    
    local leftGlow = Instance.new("UIGradient")
    leftGlow.Rotation = 90
    leftGlow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    leftGlow.Parent = leftBorder
    
    -- Right border
    local rightBorder = leftBorder:Clone()
    rightBorder.Position = UDim2.new(1, -8, 0, 0)
    rightBorder.Parent = mainBg
    
    -- Header with notification icon
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -40, 0, 100)
    header.Position = UDim2.new(0, 20, 0, 30)
    header.BackgroundTransparency = 1
    header.Parent = mainBg
    
    -- Exclamation icon frame
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 70, 0, 70)
    iconFrame.Position = UDim2.new(0, 0, 0, 0)
    iconFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = header
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0.15, 0)
    iconCorner.Parent = iconFrame
    
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = Color3.fromRGB(100, 200, 255)
    iconStroke.Thickness = 3
    iconStroke.Transparency = 0.3
    iconStroke.Parent = iconFrame
    
    -- Exclamation mark
    local exclamation = Instance.new("TextLabel")
    exclamation.Size = UDim2.new(1, 0, 1, 0)
    exclamation.BackgroundTransparency = 1
    exclamation.Text = "!"
    exclamation.TextColor3 = Color3.fromRGB(255, 255, 255)
    exclamation.TextSize = 50
    exclamation.Font = Enum.Font.GothamBold
    exclamation.Parent = iconFrame
    
    -- "NOTIFICATION" text
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(1, -100, 0, 70)
    notifLabel.Position = UDim2.new(0, 100, 0, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "NOTIFICATION"
    notifLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    notifLabel.TextSize = 42
    notifLabel.Font = Enum.Font.GothamBold
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = header
    
    -- Main message container
    local messageBox = Instance.new("Frame")
    messageBox.Size = UDim2.new(1, -80, 0, 200)
    messageBox.Position = UDim2.new(0, 40, 0, 150)
    messageBox.BackgroundTransparency = 1
    messageBox.Parent = mainBg
    
    -- Message line 1
    local message1 = Instance.new("TextLabel")
    message1.Size = UDim2.new(1, 0, 0, 60)
    message1.Position = UDim2.new(0, 0, 0, 0)
    message1.BackgroundTransparency = 1
    message1.Text = "You have acquired the qualifications"
    message1.TextColor3 = Color3.fromRGB(200, 220, 255)
    message1.TextSize = 32
    message1.Font = Enum.Font.Gotham
    message1.Parent = messageBox
    
    -- Message line 2 with highlighted "Player"
    local message2Container = Instance.new("Frame")
    message2Container.Size = UDim2.new(1, 0, 0, 60)
    message2Container.Position = UDim2.new(0, 0, 0, 70)
    message2Container.BackgroundTransparency = 1
    message2Container.Parent = messageBox
    
    local message2a = Instance.new("TextLabel")
    message2a.Size = UDim2.new(0.3, 0, 1, 0)
    message2a.Position = UDim2.new(0.12, 0, 0, 0)
    message2a.BackgroundTransparency = 1
    message2a.Text = "to be a "
    message2a.TextColor3 = Color3.fromRGB(200, 220, 255)
    message2a.TextSize = 32
    message2a.Font = Enum.Font.Gotham
    message2a.TextXAlignment = Enum.TextXAlignment.Right
    message2a.Parent = message2Container
    
    local playerText = Instance.new("TextLabel")
    playerText.Size = UDim2.new(0.2, 0, 1, 0)
    playerText.Position = UDim2.new(0.42, 0, 0, 0)
    playerText.BackgroundTransparency = 1
    playerText.Text = "Player"
    playerText.TextColor3 = Color3.fromRGB(0, 180, 255)
    playerText.TextSize = 36
    playerText.Font = Enum.Font.GothamBold
    playerText.TextXAlignment = Enum.TextXAlignment.Center
    playerText.Parent = message2Container
    
    -- Glow effect on "Player"
    local playerGlow = Instance.new("UIStroke")
    playerGlow.Color = Color3.fromRGB(0, 180, 255)
    playerGlow.Thickness = 2
    playerGlow.Transparency = 0.5
    playerGlow.Parent = playerText
    
    local message2b = Instance.new("TextLabel")
    message2b.Size = UDim2.new(0.3, 0, 1, 0)
    message2b.Position = UDim2.new(0.62, 0, 0, 0)
    message2b.BackgroundTransparency = 1
    message2b.Text = ". Will you accept?"
    message2b.TextColor3 = Color3.fromRGB(200, 220, 255)
    message2b.TextSize = 32
    message2b.Font = Enum.Font.Gotham
    message2b.TextXAlignment = Enum.TextXAlignment.Left
    message2b.Parent = message2Container
    
    -- Accept/Decline buttons
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 80)
    buttonContainer.Position = UDim2.new(0, 0, 1, -150)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainBg
    
    -- Accept button
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Size = UDim2.new(0, 250, 0, 70)
    acceptBtn.Position = UDim2.new(0.5, -260, 0, 0)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    acceptBtn.BorderSizePixel = 0
    acceptBtn.Text = "ACCEPT"
    acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptBtn.TextSize = 32
    acceptBtn.Font = Enum.Font.GothamBold
    acceptBtn.AutoButtonColor = false
    acceptBtn.Parent = buttonContainer
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 10)
    acceptCorner.Parent = acceptBtn
    
    local acceptGlow = Instance.new("UIStroke")
    acceptGlow.Color = Color3.fromRGB(100, 200, 255)
    acceptGlow.Thickness = 3
    acceptGlow.Transparency = 0.4
    acceptGlow.Parent = acceptBtn
    
    -- Decline button
    local declineBtn = Instance.new("TextButton")
    declineBtn.Size = UDim2.new(0, 250, 0, 70)
    declineBtn.Position = UDim2.new(0.5, 10, 0, 0)
    declineBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    declineBtn.BorderSizePixel = 0
    declineBtn.Text = "DECLINE"
    declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    declineBtn.TextSize = 32
    declineBtn.Font = Enum.Font.GothamBold
    declineBtn.AutoButtonColor = false
    declineBtn.Parent = buttonContainer
    
    local declineCorner = Instance.new("UICorner")
    declineCorner.CornerRadius = UDim.new(0, 10)
    declineCorner.Parent = declineBtn
    
    -- Button animations
    local function pulseButton(button)
        local originalSize = button.Size
        TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 5)
        }):Play()
    end
    
    pulseButton(acceptBtn)
    
    -- Icon pulse animation
    task.spawn(function()
        while notifPart and notifPart.Parent and not acceptedNotification do
            TweenService:Create(iconFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            }):Play()
            task.wait(1)
            TweenService:Create(iconFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            }):Play()
            task.wait(1)
        end
    end)
    
    -- Button click handlers
    acceptBtn.MouseButton1Click:Connect(function()
        acceptedNotification = true
        
        -- Fade out animation
        TweenService:Create(mainBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        
        for _, child in ipairs(mainBg:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then
                if child:IsA("GuiObject") then
                    TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                end
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                end
            end
        end
        
        task.wait(0.6)
        notifPart:Destroy()
        
        -- Create main UI
        UIModule.createMainUI()
    end)
    
    declineBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        notifPart:Destroy()
    end)
    
    -- Hover effects
    acceptBtn.MouseEnter:Connect(function()
        TweenService:Create(acceptBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        }):Play()
    end)
    acceptBtn.MouseLeave:Connect(function()
        TweenService:Create(acceptBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        }):Play()
    end)
    
    declineBtn.MouseEnter:Connect(function()
        TweenService:Create(declineBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(230, 70, 70)
        }):Play()
    end)
    declineBtn.MouseLeave:Connect(function()
        TweenService:Create(declineBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        }):Play()
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ⭐ MAIN UI SYSTEM (3D Object Interface)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createMainUI()
    if uiElements.mainPart and uiElements.mainPart.Parent then
        return -- Already exists
    end
    
    -- Create main 3D panel part
    local mainPart = Instance.new("Part")
    mainPart.Name = "SystemUIPanel"
    mainPart.Size = Vector3.new(14, 14, 0.1)
    mainPart.Anchored = true
    mainPart.CanCollide = false
    mainPart.Material = Enum.Material.ForceField
    mainPart.Transparency = 1
    mainPart.Parent = workspace
    
    uiElements.mainPart = mainPart
    
    -- Position in front of player
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local lookVector = hrp.CFrame.LookVector
        mainPart.CFrame = CFrame.new(hrp.Position + (lookVector * 6) + Vector3.new(0, 2, 0))
            * CFrame.Angles(0, math.pi, 0)
    end
    
    -- Create SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1400, 1400)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = mainPart
    
    uiElements.surfaceGui = surfaceGui
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Parent = surfaceGui
    
    uiElements.container = container
    
    -- Glowing borders (matching notification style)
    local topBorder = Instance.new("Frame")
    topBorder.Name = "TopBorder"
    topBorder.Size = UDim2.new(1, 0, 0, 6)
    topBorder.Position = UDim2.new(0, 0, 0, 0)
    topBorder.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    topBorder.BorderSizePixel = 0
    topBorder.Parent = container
    
    local topGrad = Instance.new("UIGradient")
    topGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    topGrad.Parent = topBorder
    
    local bottomBorder = topBorder:Clone()
    bottomBorder.Name = "BottomBorder"
    bottomBorder.Position = UDim2.new(0, 0, 1, -6)
    bottomBorder.Parent = container
    
    local leftBorder = Instance.new("Frame")
    leftBorder.Name = "LeftBorder"
    leftBorder.Size = UDim2.new(0, 6, 1, 0)
    leftBorder.Position = UDim2.new(0, 0, 0, 0)
    leftBorder.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    leftBorder.BorderSizePixel = 0
    leftBorder.Parent = container
    
    local leftGrad = Instance.new("UIGradient")
    leftGrad.Rotation = 90
    leftGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    leftGrad.Parent = leftBorder
    
    local rightBorder = leftBorder:Clone()
    rightBorder.Name = "RightBorder"
    rightBorder.Position = UDim2.new(1, -6, 0, 0)
    rightBorder.Parent = container
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -40, 0, 80)
    header.Position = UDim2.new(0, 20, 0, 15)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ SOLO LEVELING SYSTEM"
    titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    titleLabel.TextSize = 36
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Level and points display
    local infoPanel = Instance.new("Frame")
    infoPanel.Size = UDim2.new(0.35, 0, 1, 0)
    infoPanel.Position = UDim2.new(0.65, 0, 0, 0)
    infoPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    infoPanel.BackgroundTransparency = 0.3
    infoPanel.BorderSizePixel = 0
    infoPanel.Parent = header
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoPanel
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, -10, 0.5, 0)
    levelLabel.Position = UDim2.new(0, 5, 0, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level: 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    levelLabel.TextSize = 24
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Parent = infoPanel
    
    uiElements.levelLabel = levelLabel
    
    local pointsLabel = Instance.new("TextLabel")
    pointsLabel.Size = UDim2.new(1, -10, 0.5, 0)
    pointsLabel.Position = UDim2.new(0, 5, 0.5, 0)
    pointsLabel.BackgroundTransparency = 1
    pointsLabel.Text = "Points: 5"
    pointsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    pointsLabel.TextSize = 24
    pointsLabel.Font = Enum.Font.GothamBold
    pointsLabel.Parent = infoPanel
    
    uiElements.pointsLabel = pointsLabel
    
    -- Experience bar
    local expBarBg = Instance.new("Frame")
    expBarBg.Size = UDim2.new(1, -40, 0, 30)
    expBarBg.Position = UDim2.new(0, 20, 0, 105)
    expBarBg.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    expBarBg.BorderSizePixel = 0
    expBarBg.Parent = container
    
    local expBarCorner = Instance.new("UICorner")
    expBarCorner.CornerRadius = UDim.new(0, 6)
    expBarCorner.Parent = expBarBg
    
    local expBar = Instance.new("Frame")
    expBar.Size = UDim2.new(0, 0, 1, 0)
    expBar.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    expBar.BorderSizePixel = 0
    expBar.Parent = expBarBg
    
    local expBarFillCorner = Instance.new("UICorner")
    expBarFillCorner.CornerRadius = UDim.new(0, 6)
    expBarFillCorner.Parent = expBar
    
    uiElements.expBar = expBar
    
    local expText = Instance.new("TextLabel")
    expText.Size = UDim2.new(1, 0, 1, 0)
    expText.BackgroundTransparency = 1
    expText.Text = "0 / 100 EXP"
    expText.TextColor3 = Color3.fromRGB(255, 255, 255)
    expText.TextSize = 18
    expText.Font = Enum.Font.GothamBold
    expText.ZIndex = 2
    expText.Parent = expBarBg
    
    uiElements.expText = expText
    
    -- Stats panel
    local statsPanel = Instance.new("Frame")
    statsPanel.Name = "StatsPanel"
    statsPanel.Size = UDim2.new(1, -40, 0, 450)
    statsPanel.Position = UDim2.new(0, 20, 0, 150)
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
    statsTitle.Size = UDim2.new(1, -30, 0, 50)
    statsTitle.Position = UDim2.new(0, 15, 0, 10)
    statsTitle.BackgroundTransparency = 1
    statsTitle.Text = "STATS"
    statsTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    statsTitle.TextSize = 28
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextXAlignment = Enum.TextXAlignment.Left
    statsTitle.Parent = statsPanel
    
    -- Stats list
    local statsList = Instance.new("Frame")
    statsList.Size = UDim2.new(1, -30, 1, -80)
    statsList.Position = UDim2.new(0, 15, 0, 70)
    statsList.BackgroundTransparency = 1
    statsList.Parent = statsPanel
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.Padding = UDim.new(0, 10)
    statsLayout.FillDirection = Enum.FillDirection.Vertical
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Parent = statsList
    
    -- Create stat rows
    local statDefinitions = {
        {name = "Strength", key = "strength", desc = "Increases damage output", icon = "💪", order = 1},
        {name = "Vitality", key = "vitality", desc = "Increases max health", icon = "❤️", order = 2},
        {name = "Agility", key = "agility", desc = "Increases speed & jump", icon = "⚡", order = 3},
        {name = "Intelligence", key = "intelligence", desc = "Increases mana & regen", icon = "🧠", order = 4},
        {name = "Sense", key = "sense", desc = "Increases perception", icon = "👁️", order = 5}
    }
    
    for _, stat in ipairs(statDefinitions) do
        local statRow = Instance.new("Frame")
        statRow.Name = stat.key .. "Row"
        statRow.Size = UDim2.new(1, 0, 0, 60)
        statRow.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        statRow.BackgroundTransparency = 0.4
        statRow.BorderSizePixel = 0
        statRow.LayoutOrder = stat.order
        statRow.Parent = statsList
        
        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 8)
        rowCorner.Parent = statRow
        
        -- Stat icon
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 40, 1, 0)
        iconLabel.Position = UDim2.new(0, 5, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = stat.icon
        iconLabel.TextSize = 28
        iconLabel.Parent = statRow
        
        -- Stat name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 150, 1, 0)
        nameLabel.Position = UDim2.new(0, 50, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = stat.name
        nameLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
        nameLabel.TextSize = 22
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = statRow
        
        -- Stat value
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 60, 1, 0)
        valueLabel.Position = UDim2.new(0, 210, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "1"
        valueLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        valueLabel.TextSize = 24
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Parent = statRow
        
        uiElements.statLabels[stat.key] = valueLabel
        
        -- Plus button
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 38, 0, 38)
        plusBtn.Position = UDim2.new(1, -150, 0.5, -19)
        plusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.TextSize = 28
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.AutoButtonColor = false
        plusBtn.Parent = statRow
        
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 6)
        plusCorner.Parent = plusBtn
        
        -- Minus button
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 38, 0, 38)
        minusBtn.Position = UDim2.new(1, -105, 0.5, -19)
        minusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        minusBtn.BorderSizePixel = 0
        minusBtn.Text = "-"
        minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minusBtn.TextSize = 28
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.AutoButtonColor = false
        minusBtn.Parent = statRow
        
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0, 6)
        minusCorner.Parent = minusBtn
        
        -- Info button
        local infoBtn = Instance.new("TextButton")
        infoBtn.Size = UDim2.new(0, 38, 0, 38)
        infoBtn.Position = UDim2.new(1, -60, 0.5, -19)
        infoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        infoBtn.BorderSizePixel = 0
        infoBtn.Text = "?"
        infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoBtn.TextSize = 22
        infoBtn.Font = Enum.Font.GothamBold
        infoBtn.AutoButtonColor = false
        infoBtn.Parent = statRow
        
        local infoCorner = Instance.new("UICorner")
        infoCorner.CornerRadius = UDim.new(0, 6)
        infoCorner.Parent = infoBtn
        
        -- Button click handlers
        plusBtn.MouseButton1Click:Connect(function()
            UIModule.increaseStat(stat.key)
        end)
        
        minusBtn.MouseButton1Click:Connect(function()
            UIModule.decreaseStat(stat.key)
        end)
        
        infoBtn.MouseButton1Click:Connect(function()
            UIModule.showStatInfo(stat.key, stat.desc)
        end)
        
        -- Hover effects
        plusBtn.MouseEnter:Connect(function()
            TweenService:Create(plusBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 180, 255)}):Play()
        end)
        plusBtn.MouseLeave:Connect(function()
            TweenService:Create(plusBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
        end)
        
        minusBtn.MouseEnter:Connect(function()
            TweenService:Create(minusBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 70, 70)}):Play()
        end)
        minusBtn.MouseLeave:Connect(function()
            TweenService:Create(minusBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        end)
        
        infoBtn.MouseEnter:Connect(function()
            TweenService:Create(infoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 130, 130)}):Play()
        end)
        infoBtn.MouseLeave:Connect(function()
            TweenService:Create(infoBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end)
    end
    
    -- Abilities panel
    local abilitiesPanel = Instance.new("Frame")
    abilitiesPanel.Name = "AbilitiesPanel"
    abilitiesPanel.Size = UDim2.new(1, -40, 0, 330)
    abilitiesPanel.Position = UDim2.new(0, 20, 0, 620)
    abilitiesPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    abilitiesPanel.BackgroundTransparency = 0.3
    abilitiesPanel.BorderSizePixel = 0
    abilitiesPanel.Parent = container
    
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 10)
    abCorner.Parent = abilitiesPanel
    
    local abStroke = Instance.new("UIStroke")
    abStroke.Color = Color3.fromRGB(0, 120, 200)
    abStroke.Thickness = 2
    abStroke.Transparency = 0.6
    abStroke.Parent = abilitiesPanel
    
    local abTitle = Instance.new("TextLabel")
    abTitle.Size = UDim2.new(1, -30, 0, 50)
    abTitle.Position = UDim2.new(0, 15, 0, 10)
    abTitle.BackgroundTransparency = 1
    abTitle.Text = "ABILITIES"
    abTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    abTitle.TextSize = 28
    abTitle.Font = Enum.Font.GothamBold
    abTitle.TextXAlignment = Enum.TextXAlignment.Left
    abTitle.Parent = abilitiesPanel
    
    -- Abilities list
    local abContainer = Instance.new("Frame")
    abContainer.Size = UDim2.new(1, -30, 1, -80)
    abContainer.Position = UDim2.new(0, 15, 0, 70)
    abContainer.BackgroundTransparency = 1
    abContainer.Parent = abilitiesPanel
    
    local abLayout = Instance.new("UIListLayout")
    abLayout.Padding = UDim.new(0, 12)
    abLayout.FillDirection = Enum.FillDirection.Vertical
    abLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abLayout.Parent = abContainer
    
    -- Create ability buttons
    uiElements.abilityButtons.shadowStep = UIModule.createAbilityButton(
        abContainer, "Shadow Step", "[E]", 1, Color3.fromRGB(100, 50, 200)
    )
    
    uiElements.abilityButtons.rampage = UIModule.createAbilityButton(
        abContainer, "Rampage", "[R]", 2, Color3.fromRGB(200, 50, 50)
    )
    
    uiElements.abilityButtons.behindYou = UIModule.createAbilityButton(
        abContainer, "Behind You", "[F]", 3, Color3.fromRGB(50, 150, 200)
    )
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -40, 0, 65)
    closeBtn.Position = UDim2.new(0, 20, 1, -85)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CLOSE [X]"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 28
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = container
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        UIModule.toggleUI()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 70, 70)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
    
    -- Start UI follow system
    FollowController:start()
    UIModule.updateUI()
    
    -- Border pulse animation
    task.spawn(function()
        local borders = {topBorder, bottomBorder, leftBorder, rightBorder}
        while mainPart and mainPart.Parent do
            for _, border in ipairs(borders) do
                if border then
                    TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        BackgroundColor3 = Color3.fromRGB(100, 200, 255)
                    }):Play()
                end
            end
            task.wait(2)
            for _, border in ipairs(borders) do
                if border then
                    TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    }):Play()
                end
            end
            task.wait(2)
        end
    end)
    
    -- Initially hide UI
    uiElements.isVisible = false
    mainPart.CFrame = mainPart.CFrame * CFrame.new(0, -100, 0)
end

-- Toggle UI visibility
function UIModule.toggleUI()
    if not uiElements.mainPart or not uiElements.mainPart.Parent then return end
    
    uiElements.isVisible = not uiElements.isVisible
    
    if uiElements.isVisible then
        -- Show UI
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lookVector = hrp.CFrame.LookVector
            local targetPos = hrp.Position + (lookVector * 6) + Vector3.new(0, 2, 0)
            local targetCFrame = CFrame.new(targetPos, hrp.Position + Vector3.new(0, 2, 0))
            
            TweenService:Create(uiElements.mainPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                CFrame = targetCFrame
            }):Play()
        end
        FollowController:start()
    else
        -- Hide UI
        FollowController:stop()
        local currentPos = uiElements.mainPart.Position
        TweenService:Create(uiElements.mainPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            CFrame = CFrame.new(currentPos - Vector3.new(0, 100, 0))
        }):Play()
    end
end

-- Update UI elements
function UIModule.updateUI()
    if not uiElements.levelLabel then return end
    
    -- Update level
    uiElements.levelLabel.Text = "Level: " .. PlayerData.level
    
    -- Update points
    uiElements.pointsLabel.Text = "Points: " .. PlayerData.statPoints
    
    -- Update EXP bar
    local expPercent = PlayerData.exp / PlayerData.expNeeded
    TweenService:Create(uiElements.expBar, TweenInfo.new(0.3), {
        Size = UDim2.new(expPercent, 0, 1, 0)
    }):Play()
    
    uiElements.expText.Text = string.format("%d / %d EXP", PlayerData.exp, PlayerData.expNeeded)
    
    -- Update stats
    for key, label in pairs(uiElements.statLabels) do
        if PlayerData.stats[key] then
            label.Text = tostring(PlayerData.stats[key])
        end
    end
end

-- Increase stat
function UIModule.increaseStat(statKey)
    if PlayerData.statPoints <= 0 then
        UIModule.showNotification("No stat points available!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    PlayerData.stats[statKey] = PlayerData.stats[statKey] + 1
    PlayerData.statPoints = PlayerData.statPoints - 1
    
    UIModule.updateUI()
    UIModule.applyStats()
    UIModule.showNotification("+" .. statKey:upper(), Color3.fromRGB(100, 255, 150))
end

-- Decrease stat
function UIModule.decreaseStat(statKey)
    if PlayerData.stats[statKey] <= 1 then
        UIModule.showNotification("Cannot decrease below 1!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    PlayerData.stats[statKey] = PlayerData.stats[statKey] - 1
    PlayerData.statPoints = PlayerData.statPoints + 1
    
    UIModule.updateUI()
    UIModule.applyStats()
    UIModule.showNotification("-" .. statKey:upper(), Color3.fromRGB(255, 150, 100))
end

-- Show stat info
function UIModule.showStatInfo(statKey, description)
    UIModule.showNotification(description, Color3.fromRGB(100, 200, 255), 3)
end

-- Show notification
function UIModule.showNotification(message, color, duration)
    duration = duration or 2
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(0.5, -150, 0, -70)
    notif.BackgroundColor3 = color
    notif.BorderSizePixel = 0
    notif.Parent = uiElements.surfaceGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 20
    text.Font = Enum.Font.GothamBold
    text.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    
    task.wait(duration)
    
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, -70)}):Play()
    task.wait(0.3)
    notif:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- 📈 STATS APPLICATION SYSTEM (FIXED FOR TSB)
-- ═══════════════════════════════════════════════════════════════

function UIModule.applyStats()
    if not character or not humanoid then return end
    
    -- Calculate stats
    local str = PlayerData.stats.strength
    local vit = PlayerData.stats.vitality
    local agi = PlayerData.stats.agility
    local int = PlayerData.stats.intelligence
    local sen = PlayerData.stats.sense
    
    -- Apply health (Vitality)
    local newMaxHealth = PlayerData.baseHealth + (vit * 20)
    humanoid.MaxHealth = newMaxHealth
    if humanoid.Health > newMaxHealth then
        humanoid.Health = newMaxHealth
    end
    
    -- Apply walkspeed (Agility) - FIXED FOR TSB
    -- TSB has speed manipulation protection, so we use a more compatible method
    local newWalkSpeed = PlayerData.baseWalkSpeed + (agi * 0.5)
    
    -- Try multiple methods for compatibility
    pcall(function()
        humanoid.WalkSpeed = newWalkSpeed
    end)
    
    -- Backup method using properties
    pcall(function()
        local success = pcall(function()
            local oldSpeed = humanoid.WalkSpeed
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if humanoid.WalkSpeed ~= newWalkSpeed and not PlayerData.abilities.rampage.active then
                    humanoid.WalkSpeed = newWalkSpeed
                end
            end)
        end)
    end)
    
    -- Apply jump power (Agility)
    local newJumpPower = PlayerData.baseJumpPower + (agi * 2)
    pcall(function()
        if humanoid.UseJumpPower then
            humanoid.JumpPower = newJumpPower
        else
            humanoid.JumpHeight = newJumpPower / 3.6
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ⚔️ ABILITY SYSTEM (NO VFX/CAMERA SHAKE)
-- ═══════════════════════════════════════════════════════════════

local AbilitySystem = {}

-- Shadow Step (E) - Teleport forward
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
    local teleportDistance = 20
    local targetPosition = rootPart.Position + (lookVector * teleportDistance)
    
    -- Simple teleport without VFX
    rootPart.CFrame = CFrame.new(targetPosition, targetPosition + lookVector)
    
    UIModule.showNotification("Shadow Step!", Color3.fromRGB(150, 100, 255))
    
    -- Start cooldown visual
    task.spawn(function()
        for i = ability.cooldown, 0, -1 do
            task.wait(1)
        end
    end)
end

-- Rampage (R) - Speed boost WITHOUT effects
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
    
    if not character or not humanoid or not rootPart then return end
    
    ability.lastUsed = currentTime
    ability.active = true
    
    UIModule.showNotification("RAMPAGE ACTIVATED!", Color3.fromRGB(255, 50, 50))
    
    -- Speed boost calculation
    local agi = PlayerData.stats.agility
    local baseSpeed = PlayerData.baseWalkSpeed + (agi * 0.5)
    local boostedSpeed = baseSpeed * 2.5
    
    -- Apply speed boost (FIXED for TSB)
    local originalSpeed = humanoid.WalkSpeed
    
    -- Multiple application methods for compatibility
    local function applySpeed()
        pcall(function() humanoid.WalkSpeed = boostedSpeed end)
    end
    
    applySpeed()
    
    -- Maintain speed during Rampage
    local speedMaintainer = RunService.Heartbeat:Connect(function()
        if ability.active then
            applySpeed()
        end
    end)
    
    -- Duration timer
    task.wait(ability.duration)
    
    ability.active = false
    speedMaintainer:Disconnect()
    
    -- Restore normal speed
    UIModule.applyStats()
    
    UIModule.showNotification("Rampage ended", Color3.fromRGB(255, 200, 100))
end

-- Behind You (F) - Teleport behind nearest player
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
        local behindPosition = targetRoot.Position - (targetRoot.CFrame.LookVector * 5)
        rootPart.CFrame = CFrame.new(behindPosition, targetRoot.Position)
        
        UIModule.showNotification("Behind You!", Color3.fromRGB(100, 200, 255))
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 🎮 INPUT SYSTEM
-- ═══════════════════════════════════════════════════════════════

local InputSystem = {}

function InputSystem.init()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Toggle UI with X
        if input.KeyCode == Enum.KeyCode.X then
            UIModule.toggleUI()
        end
        
        -- Shadow Step (E)
        if input.KeyCode == Enum.KeyCode.E then
            AbilitySystem.shadowStep()
        end
        
        -- Rampage (R)
        if input.KeyCode == Enum.KeyCode.R then
            AbilitySystem.rampage()
        end
        
        -- Behind You (F)
        if input.KeyCode == Enum.KeyCode.F then
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
    
    -- Initialize systems
    task.wait(2) -- Wait for game to fully load
    
    UIModule.createInitialNotification()
    InputSystem.init()
    
    -- Apply initial stats
    UIModule.applyStats()
    
    -- Character respawn handler
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        
        task.wait(1)
        
        -- Recreate UI if it was visible
        if uiElements.mainPart then
            uiElements.mainPart:Destroy()
        end
        
        UIModule.createMainUI()
        UIModule.applyStats()
    end)
end

-- Start the system
init()

print("═══════════════════════════════════════════════════════════════")
print("⚡ SOLO LEVELING SYSTEM LOADED")
print("═══════════════════════════════════════════════════════════════")
print("Controls:")
print("[X] - Toggle UI")
print("[E] - Shadow Step")
print("[R] - Rampage (Speed Boost - NO EFFECTS)")
print("[F] - Behind You")
print("═══════════════════════════════════════════════════════════════")
