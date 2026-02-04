--[[
═══════════════════════════════════════════════════════════════
⚡ SOLO LEVELING SYSTEM - NEW 3D UI (OBJECT-BASED)
Recreated UI matching the Solo Leveling notification aesthetic
═══════════════════════════════════════════════════════════════

🔧 INSTALLATION INSTRUCTIONS:
1. Find this section in your original script (around line 2850-3044):
   - Search for "function UIModule.createInitialNotification()"
   - Delete the ENTIRE function from "function UIModule.createInitialNotification()" 
     to the "end" before "-- PLAYER MONITORING" comment

2. Replace it with the new createInitialNotification function from this file
   (The one marked with "⭐ NEW NOTIFICATION FUNCTION - REPLACE OLD ONE")

3. Find this section (around line 1050-1440):
   - Search for "function UIModule.createMainUI()"
   - Delete the ENTIRE function from "function UIModule.createMainUI()"
     to its matching "end"

4. Replace it with the new createMainUI function from this file
   (The one marked with "⭐ NEW MAIN UI FUNCTION - REPLACE OLD ONE")

5. The rest of your script logic remains EXACTLY the same!
]]

-- ═══════════════════════════════════════════════════════════════
-- ⭐ NEW NOTIFICATION FUNCTION - REPLACE OLD ONE (Line ~2850-3044)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createInitialNotification()
    if acceptedNotification then return end
    
    InputAuthority:lockSystem(999)
    
    -- Create the 3D notification panel part
    local notifPart = Instance.new("Part")
    notifPart.Name = "SystemNotificationPanel"
    notifPart.Size = Vector3.new(12, 7, 0.1)
    notifPart.Anchored = true
    notifPart.CanCollide = false
    notifPart.Material = Enum.Material.ForceField
    notifPart.Transparency = 1
    notifPart.Parent = workspace
    
    -- Position in front of player
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
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
    
    -- Main background
    local mainBg = Instance.new("Frame")
    mainBg.Size = UDim2.new(1, 0, 1, 0)
    mainBg.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    mainBg.BackgroundTransparency = 0.1
    mainBg.BorderSizePixel = 0
    mainBg.Parent = surfaceGui
    
    -- Glowing border effect (top)
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
    
    -- Left border
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
    
    -- Header section with notification icon
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -40, 0, 100)
    header.Position = UDim2.new(0, 20, 0, 30)
    header.BackgroundTransparency = 1
    header.Parent = mainBg
    
    -- Notification icon
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
    
    -- Main message line 1
    local message1 = Instance.new("TextLabel")
    message1.Size = UDim2.new(1, 0, 0, 60)
    message1.Position = UDim2.new(0, 0, 0, 0)
    message1.BackgroundTransparency = 1
    message1.Text = "You have acquired the qualifications"
    message1.TextColor3 = Color3.fromRGB(200, 220, 255)
    message1.TextSize = 32
    message1.Font = Enum.Font.Gotham
    message1.Parent = messageBox
    
    -- Main message line 2 with "Player" highlighted
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
    
    -- Button container
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -80, 0, 120)
    buttonContainer.Position = UDim2.new(0, 40, 1, -160)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainBg
    
    -- ACCEPT button
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Size = UDim2.new(0, 380, 0, 90)
    acceptBtn.Position = UDim2.new(0, 60, 0, 0)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    acceptBtn.BorderSizePixel = 0
    acceptBtn.Text = "ACCEPT"
    acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptBtn.TextSize = 32
    acceptBtn.Font = Enum.Font.GothamBold
    acceptBtn.AutoButtonColor = false
    acceptBtn.Parent = buttonContainer
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 8)
    acceptCorner.Parent = acceptBtn
    
    local acceptStroke = Instance.new("UIStroke")
    acceptStroke.Color = Color3.fromRGB(100, 200, 255)
    acceptStroke.Thickness = 3
    acceptStroke.Transparency = 0.3
    acceptStroke.Parent = acceptBtn
    
    -- DECLINE button
    local declineBtn = Instance.new("TextButton")
    declineBtn.Size = UDim2.new(0, 380, 0, 90)
    declineBtn.Position = UDim2.new(1, -440, 0, 0)
    declineBtn.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    declineBtn.BorderSizePixel = 0
    declineBtn.Text = "DECLINE"
    declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    declineBtn.TextSize = 32
    declineBtn.Font = Enum.Font.GothamBold
    declineBtn.AutoButtonColor = false
    declineBtn.Parent = buttonContainer
    
    local declineCorner = Instance.new("UICorner")
    declineCorner.CornerRadius = UDim.new(0, 8)
    declineCorner.Parent = declineBtn
    
    local declineStroke = Instance.new("UIStroke")
    declineStroke.Color = Color3.fromRGB(100, 120, 140)
    declineStroke.Thickness = 3
    declineStroke.Transparency = 0.3
    declineStroke.Parent = declineBtn
    
    -- Button hover effects
    acceptBtn.MouseEnter:Connect(function()
        TweenService:Create(acceptBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        }):Play()
        TweenService:Create(acceptStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    
    acceptBtn.MouseLeave:Connect(function()
        TweenService:Create(acceptBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        }):Play()
        TweenService:Create(acceptStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
    declineBtn.MouseEnter:Connect(function()
        TweenService:Create(declineBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(71, 85, 105)
        }):Play()
        TweenService:Create(declineStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    
    declineBtn.MouseLeave:Connect(function()
        TweenService:Create(declineBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(51, 65, 85)
        }):Play()
        TweenService:Create(declineStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
    -- Button actions
    acceptBtn.MouseButton1Click:Connect(function()
        acceptedNotification = true
        TweenService:Create(notifPart, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(mainBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        notifPart:Destroy()
        UIModule.createMainUI()
    end)
    
    declineBtn.MouseButton1Click:Connect(function()
        acceptedNotification = false
        TweenService:Create(notifPart, TweenInfo.new(0.5), {Transparency = 1}):Play()
        TweenService:Create(mainBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        notifPart:Destroy()
    end)
    
    -- Floating animation with smooth following
    task.spawn(function()
        local t = 0
        while notifPart and notifPart.Parent do
            t = t + task.wait(0.05)
            local bobY = math.sin(t * 2) * 0.3
            
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local charLook = hrp.CFrame.LookVector
                local targetPos = hrp.Position + (charLook * 8) + Vector3.new(0, 3 + bobY, 0)
                local lookAtPos = Vector3.new(hrp.Position.X, notifPart.Position.Y, hrp.Position.Z)
                notifPart.CFrame = notifPart.CFrame:Lerp(
                    CFrame.new(targetPos, lookAtPos) * CFrame.Angles(0, math.pi, 0),
                    0.12
                )
            end
        end
    end)
    
    -- Border pulse animation
    task.spawn(function()
        while notifPart and notifPart.Parent do
            TweenService:Create(topBorder, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            }):Play()
            TweenService:Create(bottomBorder, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            }):Play()
            task.wait(1.5)
            TweenService:Create(topBorder, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            }):Play()
            TweenService:Create(bottomBorder, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            }):Play()
            task.wait(1.5)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ⭐ NEW MAIN UI FUNCTION - REPLACE OLD ONE (Line ~1050-1440)
-- ═══════════════════════════════════════════════════════════════

function UIModule.createMainUI()
    if mainPart then
        mainPart:Destroy()
        mainPart = nil
    end
    
    InputAuthority:unlockAll()
    
    -- Create the 3D UI part
    mainPart = Instance.new("Part")
    mainPart.Name = "SoloLevelingPanel"
    mainPart.Size = Vector3.new(10, 12, 0.1)
    mainPart.Anchored = true
    mainPart.CanCollide = false
    mainPart.Material = Enum.Material.ForceField
    mainPart.Transparency = 1
    mainPart.Parent = workspace
    
    -- Create SurfaceGui
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "MainUI"
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.CanvasSize = Vector2.new(1000, 1200)
    surfaceGui.LightInfluence = 0
    surfaceGui.AlwaysOnTop = true
    surfaceGui.Parent = mainPart
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.Parent = surfaceGui
    
    -- Glowing borders
    local function createBorder(name, size, position, rotation)
        local border = Instance.new("Frame")
        border.Name = name
        border.Size = size
        border.Position = position
        border.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        border.BorderSizePixel = 0
        border.ZIndex = 10
        border.Parent = container
        
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = rotation or 0
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.4)
        })
        gradient.Parent = border
        
        return border
    end
    
    createBorder("TopBorder", UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 0, 0))
    createBorder("BottomBorder", UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 1, -6))
    createBorder("LeftBorder", UDim2.new(0, 6, 1, 0), UDim2.new(0, 0, 0, 0), 90)
    createBorder("RightBorder", UDim2.new(0, 6, 1, 0), UDim2.new(1, -6, 0, 0), 90)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -40, 0, 80)
    header.Position = UDim2.new(0, 20, 0, 20)
    header.BackgroundTransparency = 1
    header.Parent = container
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ PLAYER SYSTEM"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextSize = 38
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(0, 150, 255)
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.5
    titleStroke.Parent = title
    
    -- Stats panel
    local statsPanel = Instance.new("Frame")
    statsPanel.Name = "StatsPanel"
    statsPanel.Size = UDim2.new(1, -40, 0, 520)
    statsPanel.Position = UDim2.new(0, 20, 0, 120)
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
    
    -- Level and XP display
    local levelFrame = Instance.new("Frame")
    levelFrame.Name = "LevelFrame"
    levelFrame.Size = UDim2.new(1, -30, 0, 100)
    levelFrame.Position = UDim2.new(0, 15, 0, 15)
    levelFrame.BackgroundTransparency = 1
    levelFrame.Parent = statsPanel
    
    uiElements.levelLabel = Instance.new("TextLabel")
    uiElements.levelLabel.Name = "LevelLabel"
    uiElements.levelLabel.Size = UDim2.new(1, 0, 0, 45)
    uiElements.levelLabel.BackgroundTransparency = 1
    uiElements.levelLabel.Text = "LEVEL: 1"
    uiElements.levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiElements.levelLabel.TextSize = 32
    uiElements.levelLabel.Font = Enum.Font.GothamBold
    uiElements.levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    uiElements.levelLabel.Parent = levelFrame
    
    uiElements.xpLabel = Instance.new("TextLabel")
    uiElements.xpLabel.Name = "XPLabel"
    uiElements.xpLabel.Size = UDim2.new(1, 0, 0, 25)
    uiElements.xpLabel.Position = UDim2.new(0, 0, 0, 50)
    uiElements.xpLabel.BackgroundTransparency = 1
    uiElements.xpLabel.Text = "XP: 0 / 100"
    uiElements.xpLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    uiElements.xpLabel.TextSize = 20
    uiElements.xpLabel.Font = Enum.Font.Gotham
    uiElements.xpLabel.TextXAlignment = Enum.TextXAlignment.Left
    uiElements.xpLabel.Parent = levelFrame
    
    -- XP Bar
    local xpBarBg = Instance.new("Frame")
    xpBarBg.Name = "XPBarBackground"
    xpBarBg.Size = UDim2.new(1, 0, 0, 12)
    xpBarBg.Position = UDim2.new(0, 0, 0, 80)
    xpBarBg.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
    xpBarBg.BorderSizePixel = 0
    xpBarBg.Parent = levelFrame
    
    local xpBarCorner = Instance.new("UICorner")
    xpBarCorner.CornerRadius = UDim.new(1, 0)
    xpBarCorner.Parent = xpBarBg
    
    uiElements.xpBar = Instance.new("Frame")
    uiElements.xpBar.Name = "XPBar"
    uiElements.xpBar.Size = UDim2.new(0, 0, 1, 0)
    uiElements.xpBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    uiElements.xpBar.BorderSizePixel = 0
    uiElements.xpBar.Parent = xpBarBg
    
    local xpBarFillCorner = Instance.new("UICorner")
    xpBarFillCorner.CornerRadius = UDim.new(1, 0)
    xpBarFillCorner.Parent = uiElements.xpBar
    
    local xpGradient = Instance.new("UIGradient")
    xpGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 255))
    })
    xpGradient.Parent = uiElements.xpBar
    
    -- HP Bar
    local hpFrame = Instance.new("Frame")
    hpFrame.Name = "HPFrame"
    hpFrame.Size = UDim2.new(1, -30, 0, 60)
    hpFrame.Position = UDim2.new(0, 15, 0, 130)
    hpFrame.BackgroundTransparency = 1
    hpFrame.Parent = statsPanel
    
    uiElements.hpLabel = Instance.new("TextLabel")
    uiElements.hpLabel.Name = "HPLabel"
    uiElements.hpLabel.Size = UDim2.new(1, 0, 0, 25)
    uiElements.hpLabel.BackgroundTransparency = 1
    uiElements.hpLabel.Text = "HP: 100 / 100"
    uiElements.hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    uiElements.hpLabel.TextSize = 22
    uiElements.hpLabel.Font = Enum.Font.GothamBold
    uiElements.hpLabel.TextXAlignment = Enum.TextXAlignment.Left
    uiElements.hpLabel.Parent = hpFrame
    
    local hpBarBg = Instance.new("Frame")
    hpBarBg.Name = "HPBarBackground"
    hpBarBg.Size = UDim2.new(1, 0, 0, 18)
    hpBarBg.Position = UDim2.new(0, 0, 0, 35)
    hpBarBg.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    hpBarBg.BorderSizePixel = 0
    hpBarBg.Parent = hpFrame
    
    local hpBarCorner = Instance.new("UICorner")
    hpBarCorner.CornerRadius = UDim.new(1, 0)
    hpBarCorner.Parent = hpBarBg
    
    uiElements.hpBar = Instance.new("Frame")
    uiElements.hpBar.Name = "HPBar"
    uiElements.hpBar.Size = UDim2.new(1, 0, 1, 0)
    uiElements.hpBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    uiElements.hpBar.BorderSizePixel = 0
    uiElements.hpBar.Parent = hpBarBg
    
    local hpBarFillCorner = Instance.new("UICorner")
    hpBarFillCorner.CornerRadius = UDim.new(1, 0)
    hpBarFillCorner.Parent = uiElements.hpBar
    
    local hpGradient = Instance.new("UIGradient")
    hpGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 80))
    })
    hpGradient.Parent = uiElements.hpBar
    
    -- Stat points available
    uiElements.pointsLabel = Instance.new("TextLabel")
    uiElements.pointsLabel.Name = "PointsLabel"
    uiElements.pointsLabel.Size = UDim2.new(1, -30, 0, 35)
    uiElements.pointsLabel.Position = UDim2.new(0, 15, 0, 210)
    uiElements.pointsLabel.BackgroundTransparency = 1
    uiElements.pointsLabel.Text = "⭐ AVAILABLE POINTS: 0"
    uiElements.pointsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    uiElements.pointsLabel.TextSize = 24
    uiElements.pointsLabel.Font = Enum.Font.GothamBold
    uiElements.pointsLabel.TextXAlignment = Enum.TextXAlignment.Center
    uiElements.pointsLabel.Parent = statsPanel
    
    -- Stats container
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.Size = UDim2.new(1, -30, 0, 240)
    statsContainer.Position = UDim2.new(0, 15, 0, 260)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = statsPanel
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.Padding = UDim.new(0, 8)
    statsLayout.FillDirection = Enum.FillDirection.Vertical
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Parent = statsContainer
    
    -- Create stat rows
    local stats = {
        {name = "Strength", key = "strength", color = Color3.fromRGB(255, 100, 100)},
        {name = "Agility", key = "agility", color = Color3.fromRGB(100, 255, 100)},
        {name = "Perception", key = "perception", color = Color3.fromRGB(255, 200, 100)},
        {name = "Vitality", key = "vitality", color = Color3.fromRGB(255, 100, 255)},
        {name = "Intelligence", key = "intelligence", color = Color3.fromRGB(100, 200, 255)}
    }
    
    for i, stat in ipairs(stats) do
        local statRow = Instance.new("Frame")
        statRow.Name = stat.key .. "Row"
        statRow.Size = UDim2.new(1, 0, 0, 42)
        statRow.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
        statRow.BackgroundTransparency = 0.5
        statRow.BorderSizePixel = 0
        statRow.LayoutOrder = i
        statRow.Parent = statsContainer
        
        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 6)
        rowCorner.Parent = statRow
        
        local statLabel = Instance.new("TextLabel")
        statLabel.Size = UDim2.new(0.5, -80, 1, 0)
        statLabel.Position = UDim2.new(0, 15, 0, 0)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = stat.name
        statLabel.TextColor3 = stat.color
        statLabel.TextSize = 20
        statLabel.Font = Enum.Font.GothamBold
        statLabel.TextXAlignment = Enum.TextXAlignment.Left
        statLabel.Parent = statRow
        
        uiElements.statLabels[stat.key] = Instance.new("TextLabel")
        uiElements.statLabels[stat.key].Size = UDim2.new(0, 60, 1, 0)
        uiElements.statLabels[stat.key].Position = UDim2.new(0.5, -80, 0, 0)
        uiElements.statLabels[stat.key].BackgroundTransparency = 1
        uiElements.statLabels[stat.key].Text = "0"
        uiElements.statLabels[stat.key].TextColor3 = Color3.fromRGB(255, 255, 255)
        uiElements.statLabels[stat.key].TextSize = 22
        uiElements.statLabels[stat.key].Font = Enum.Font.GothamBold
        uiElements.statLabels[stat.key].Parent = statRow
        
        -- Plus button
        local plusBtn = Instance.new("TextButton")
        plusBtn.Name = "PlusButton"
        plusBtn.Size = UDim2.new(0, 38, 0, 38)
        plusBtn.Position = UDim2.new(1, -130, 0.5, -19)
        plusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.TextSize = 24
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.AutoButtonColor = false
        plusBtn.Parent = statRow
        
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0.2, 0)
        plusCorner.Parent = plusBtn
        
        -- Minus button
        local minusBtn = Instance.new("TextButton")
        minusBtn.Name = "MinusButton"
        minusBtn.Size = UDim2.new(0, 38, 0, 38)
        minusBtn.Position = UDim2.new(1, -82, 0.5, -19)
        minusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        minusBtn.BorderSizePixel = 0
        minusBtn.Text = "-"
        minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minusBtn.TextSize = 28
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.AutoButtonColor = false
        minusBtn.Parent = statRow
        
        local minusCorner = Instance.new("UICorner")
        minusCorner.CornerRadius = UDim.new(0.2, 0)
        minusCorner.Parent = minusBtn
        
        -- Info button
        local infoBtn = Instance.new("TextButton")
        infoBtn.Name = "InfoButton"
        infoBtn.Size = UDim2.new(0, 38, 0, 38)
        infoBtn.Position = UDim2.new(1, -34, 0.5, -19)
        infoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        infoBtn.BorderSizePixel = 0
        infoBtn.Text = "?"
        infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoBtn.TextSize = 22
        infoBtn.Font = Enum.Font.GothamBold
        infoBtn.AutoButtonColor = false
        infoBtn.Parent = statRow
        
        local infoCorner = Instance.new("UICorner")
        infoCorner.CornerRadius = UDim.new(0.2, 0)
        infoCorner.Parent = infoBtn
        
        -- Button connections
        plusBtn.MouseButton1Click:Connect(function()
            UIModule.increaseStat(stat.key)
        end)
        
        minusBtn.MouseButton1Click:Connect(function()
            UIModule.decreaseStat(stat.key)
        end)
        
        infoBtn.MouseButton1Click:Connect(function()
            UIModule.showStatDescription(stat.key, statRow)
        end)
        
        -- Hover effects
        plusBtn.MouseEnter:Connect(function()
            TweenService:Create(plusBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            }):Play()
        end)
        plusBtn.MouseLeave:Connect(function()
            TweenService:Create(plusBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            }):Play()
        end)
        
        minusBtn.MouseEnter:Connect(function()
            TweenService:Create(minusBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(230, 70, 70)
            }):Play()
        end)
        minusBtn.MouseLeave:Connect(function()
            TweenService:Create(minusBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            }):Play()
        end)
        
        infoBtn.MouseEnter:Connect(function()
            TweenService:Create(infoBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(130, 130, 130)
            }):Play()
        end)
        infoBtn.MouseLeave:Connect(function()
            TweenService:Create(infoBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            }):Play()
        end)
    end
    
    -- Abilities panel
    local abilitiesPanel = Instance.new("Frame")
    abilitiesPanel.Name = "AbilitiesPanel"
    abilitiesPanel.Size = UDim2.new(1, -40, 0, 400)
    abilitiesPanel.Position = UDim2.new(0, 20, 0, 660)
    abilitiesPanel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    abilitiesPanel.BackgroundTransparency = 0.3
    abilitiesPanel.BorderSizePixel = 0
    abilitiesPanel.Parent = container
    
    local abilitiesCorner = Instance.new("UICorner")
    abilitiesCorner.CornerRadius = UDim.new(0, 10)
    abilitiesCorner.Parent = abilitiesPanel
    
    local abilitiesStroke = Instance.new("UIStroke")
    abilitiesStroke.Color = Color3.fromRGB(0, 120, 200)
    abilitiesStroke.Thickness = 2
    abilitiesStroke.Transparency = 0.6
    abilitiesStroke.Parent = abilitiesPanel
    
    local abilitiesTitle = Instance.new("TextLabel")
    abilitiesTitle.Size = UDim2.new(1, -30, 0, 50)
    abilitiesTitle.Position = UDim2.new(0, 15, 0, 10)
    abilitiesTitle.BackgroundTransparency = 1
    abilitiesTitle.Text = "ABILITIES"
    abilitiesTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    abilitiesTitle.TextSize = 28
    abilitiesTitle.Font = Enum.Font.GothamBold
    abilitiesTitle.TextXAlignment = Enum.TextXAlignment.Left
    abilitiesTitle.Parent = abilitiesPanel
    
    -- Ability buttons container
    local abilityContainer = Instance.new("Frame")
    abilityContainer.Size = UDim2.new(1, -30, 1, -80)
    abilityContainer.Position = UDim2.new(0, 15, 0, 70)
    abilityContainer.BackgroundTransparency = 1
    abilityContainer.Parent = abilitiesPanel
    
    local abilityLayout = Instance.new("UIListLayout")
    abilityLayout.Padding = UDim.new(0, 12)
    abilityLayout.FillDirection = Enum.FillDirection.Vertical
    abilityLayout.SortOrder = Enum.SortOrder.LayoutOrder
    abilityLayout.Parent = abilityContainer
    
    -- Shadow Step
    uiElements.abilityButtons.shadowStep = UIModule.createAbilityButton(
        abilityContainer,
        "Shadow Step",
        "[E]",
        1,
        Color3.fromRGB(100, 50, 200)
    )
    
    -- Rampage
    uiElements.abilityButtons.rampage = UIModule.createAbilityButton(
        abilityContainer,
        "Rampage",
        "[R]",
        2,
        Color3.fromRGB(200, 50, 50)
    )
    
    -- Behind You
    uiElements.abilityButtons.behindYou = UIModule.createAbilityButton(
        abilityContainer,
        "Behind You",
        "[F]",
        3,
        Color3.fromRGB(50, 150, 200)
    )
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(1, -40, 0, 60)
    closeBtn.Position = UDim2.new(0, 20, 1, -80)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CLOSE"
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
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(230, 70, 70)
        }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        }):Play()
    end)
    
    -- Start follow controller
    FollowController:start()
    UIModule.updateUI()
    
    -- Border pulse animation
    task.spawn(function()
        local borders = {
            container:FindFirstChild("TopBorder"),
            container:FindFirstChild("BottomBorder"),
            container:FindFirstChild("LeftBorder"),
            container:FindFirstChild("RightBorder")
        }
        
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
end

-- ═══════════════════════════════════════════════════════════════
-- 📝 INSTALLATION SUMMARY
-- ═══════════════════════════════════════════════════════════════
--[[
WHAT TO DO:

1. Open your original Sus.txt script
2. Find line ~2850 "function UIModule.createInitialNotification()"
3. Delete from that line to the matching "end" (before "PLAYER MONITORING")
4. Copy-paste the NEW createInitialNotification function from above

5. Find line ~1050 "function UIModule.createMainUI()"  
6. Delete from that line to the matching "end"
7. Copy-paste the NEW createMainUI function from above

That's it! All other logic stays the same - combat, stats, abilities, etc.
The UI will now be a 3D object in the world with Solo Leveling aesthetics!
]]
