local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
end)

-- ==========================================
-- GLOBAL HOTKEY CONFIG
-- ==========================================
local Hotkeys = {
    RecordKey = Enum.KeyCode.R,
    PlayKey = Enum.KeyCode.P,
    RollbackKey = Enum.KeyCode.X,
    AntiAfkKey = Enum.KeyCode.K,
    ToggleUIKey = Enum.KeyCode.RightControl
}

-- ==========================================
-- UI SETUP (Xnozi Theme & LED Animation)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XnoziUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if ScreenGui.Parent ~= game:GetService("CoreGui") then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 380)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- ORANGE LED ANIMATED BORDER
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.LineJoinMode = Enum.LineJoinMode.Round
MainStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 200, 80)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(40, 15, 5)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0))
})
UIGradient.Parent = MainStroke

local rotationSpeed = 90
RunService.RenderStepped:Connect(function(deltaTime)
    UIGradient.Rotation = (UIGradient.Rotation + rotationSpeed * deltaTime) % 360
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Sidebar

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(1, -30, 0, 25)
BrandTitle.Position = UDim2.new(0, 18, 0, 18)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "Xnozi"
BrandTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
BrandTitle.TextSize = 18
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.Parent = Sidebar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -30, 0, 15)
Subtitle.Position = UDim2.new(0, 18, 0, 42)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Subscription: Lifetime"
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 115)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -80)
TabContainer.Position = UDim2.new(0, 10, 0, 75)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabContainer

local ContentHeader = Instance.new("TextLabel")
ContentHeader.Size = UDim2.new(1, -210, 0, 30)
ContentHeader.Position = UDim2.new(0, 200, 0, 15)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Text = "Macro"
ContentHeader.TextColor3 = Color3.fromRGB(200, 200, 210)
ContentHeader.TextSize = 14
ContentHeader.Font = Enum.Font.GothamMedium
ContentHeader.TextXAlignment = Enum.TextXAlignment.Left
ContentHeader.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -210, 1, -60)
ContentArea.Position = UDim2.new(0, 200, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ==========================================
-- TAB SYSTEM & UI COMPONENTS
-- ==========================================
local pages = {}
local tabButtons = {}

local function createTab(name, layoutOrder)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIGridLayout")
    pageLayout.CellSize = UDim2.new(0, 380, 0, 240)
    pageLayout.CellPadding = UDim2.new(0, 12, 0, 12)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    local btn = Instance.new("TextButton")
    btn.Name = name .. "TabBtn"
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.LayoutOrder = layoutOrder or 1
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(120, 120, 135)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabContainer

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 12)
    btnPadding.Parent = btn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    pages[name] = page
    tabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for tName, tPage in pairs(pages) do
            local isSelected = (tName == name)
            tPage.Visible = isSelected
            if isSelected then
                tabButtons[tName].BackgroundTransparency = 0.6
                tabButtons[tName].BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                tabButtons[tName].TextColor3 = Color3.fromRGB(255, 255, 255)
                ContentHeader.Text = tName
            else
                tabButtons[tName].BackgroundTransparency = 1
                tabButtons[tName].TextColor3 = Color3.fromRGB(120, 120, 135)
            end
        end
    end)

    return page
end

local function createCard(parent, titleText)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(38, 38, 48)
    stroke.Thickness = 1
    stroke.Parent = card

    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -20, 0, 20)
    cardTitle.Position = UDim2.new(0, 12, 0, 10)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = titleText
    cardTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
    cardTitle.TextSize = 13
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card

    return card
end

local function createToggle(parent, labelText, yPos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 24)
    frame.Position = UDim2.new(0, 12, 0, yPos or 36)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(150, 150, 165)
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 36, 0, 18)
    switchBg.Position = UDim2.new(1, -36, 0.5, -9)
    switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    switchBg.Text = ""
    switchBg.Parent = frame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
    circle.BorderSizePixel = 0
    circle.Parent = switchBg

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    local toggled = false
    local function setToggleState(state)
        toggled = state
        if toggled then
            switchBg.BackgroundColor3 = Color3.fromRGB(255, 140, 20)
            circle.Position = UDim2.new(1, -16, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        else
            switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            circle.Position = UDim2.new(0, 2, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(180, 180, 195)
        end
    end

    switchBg.MouseButton1Click:Connect(function()
        setToggleState(not toggled)
        if callback then callback(toggled) end
    end)

    return setToggleState
end

local function createActionButton(parent, labelText, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 24)
    btn.Position = UDim2.new(0, 12, 0, yPos or 68)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = labelText .. "  >"
    btn.TextColor3 = Color3.fromRGB(170, 170, 185)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function createKeybindSelector(parent, labelText, yPos, defaultKey, onKeyChanged)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 24)
    frame.Position = UDim2.new(0, 12, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(150, 150, 165)
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 80, 0, 20)
    bindBtn.Position = UDim2.new(1, -80, 0.5, -10)
    bindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    bindBtn.Text = defaultKey and defaultKey.Name or "None"
    bindBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    bindBtn.TextSize = 10
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = bindBtn

    local isListening = false
    bindBtn.MouseButton1Click:Connect(function()
        if isListening then return end
        isListening = true
        bindBtn.Text = "..."
        bindBtn.TextColor3 = Color3.fromRGB(255, 200, 100)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                bindBtn.Text = input.KeyCode.Name
                bindBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
                isListening = false
                conn:Disconnect()
                if onKeyChanged then onKeyChanged(input.KeyCode) end
            end
        end)
    end)
end

-- Generate Pages (Features 제거됨)
local MacroPage = createTab("Macro", 1)
local RollbackPage = createTab("Rollback", 2)
local UtilizePage = createTab("Utilize", 3)
local HotkeysPage = createTab("Hotkeys", 4)

pages["Macro"].Visible = true
tabButtons["Macro"].BackgroundTransparency = 0.6
tabButtons["Macro"].BackgroundColor3 = Color3.fromRGB(35, 35, 45)
tabButtons["Macro"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================
-- LOGIC IMPLEMENTATION
-- ==========================================

--- 1. MACRO TAB ---
local isRecording = false
local isPlaying = false
local isLooping = false
local recordedFrames = {}
local recordConnection = nil

local macroCard = createCard(MacroPage, "Macro Controls")

local setRecordToggle
local setPlayToggle

local function toggleRecording(forceState)
    local newState = (forceState ~= nil) and forceState or not isRecording
    if isPlaying then return end
    isRecording = newState
    if setRecordToggle then setRecordToggle(isRecording) end

    if isRecording then
        recordedFrames = {}
        local startTime = tick()

        recordConnection = RunService.RenderStepped:Connect(function()
            if HumanoidRootPart then
                local activeKeys = {}
                for _, inputObj in ipairs(UserInputService:GetKeysPressed()) do
                    table.insert(activeKeys, inputObj.KeyCode.Name)
                end

                local m1Pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                local m2Pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                local mousePos = UserInputService:GetMouseLocation()

                table.insert(recordedFrames, {
                    Time = tick() - startTime,
                    CFrame = {HumanoidRootPart.CFrame:GetComponents()},
                    Keys = activeKeys,
                    M1 = m1Pressed,
                    M2 = m2Pressed,
                    MousePos = {X = mousePos.X, Y = mousePos.Y}
                })
            end
        end)
    else
        if recordConnection then
            recordConnection:Disconnect()
            recordConnection = nil
        end
    end
end

local function togglePlay(forceState)
    local targetState = (forceState ~= nil) and forceState or not isPlaying
    
    if isRecording or #recordedFrames == 0 then 
        if setPlayToggle then setPlayToggle(false) end
        return 
    end

    if not targetState then
        isPlaying = false
        if setPlayToggle then setPlayToggle(false) end
        return
    end

    isPlaying = true
    if setPlayToggle then setPlayToggle(true) end

    task.spawn(function()
        repeat
            local playbackStartTime = tick()
            local activeKeysHeld = {}
            local m1State = false
            local m2State = false

            for _, frame in ipairs(recordedFrames) do
                if not isPlaying then break end
                
                local targetTime = playbackStartTime + frame.Time
                while isPlaying do
                    local remaining = targetTime - tick()
                    if remaining <= 0 then break end
                    RunService.RenderStepped:Wait()
                end
                
                if not isPlaying then break end

                if HumanoidRootPart and frame.CFrame then
                    HumanoidRootPart.CFrame = CFrame.new(unpack(frame.CFrame))
                end

                local currentFrameKeys = {}
                for _, keyName in ipairs(frame.Keys) do
                    local keyCode = Enum.KeyCode[keyName]
                    if keyCode then
                        currentFrameKeys[keyCode] = true
                        if not activeKeysHeld[keyCode] then
                            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                            activeKeysHeld[keyCode] = true
                        end
                    end
                end

                for keyCode, _ in pairs(activeKeysHeld) do
                    if not currentFrameKeys[keyCode] then
                        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                        activeKeysHeld[keyCode] = nil
                    end
                end

                local posX, posY = frame.MousePos.X, frame.MousePos.Y
                if frame.M1 ~= m1State then
                    VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, frame.M1, game, 0)
                    m1State = frame.M1
                end
                if frame.M2 ~= m2State then
                    VirtualInputManager:SendMouseButtonEvent(posX, posY, 1, frame.M2, game, 0)
                    m2State = frame.M2
                end

                if (m1State or m2State) and Character then
                    local tool = Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end

            for keyCode, _ in pairs(activeKeysHeld) do
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end
            if m1State then VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end
            if m2State then VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0) end

        until not isLooping or not isPlaying

        isPlaying = false
        if setPlayToggle then setPlayToggle(false) end
    end)
end

setRecordToggle = createToggle(macroCard, "Record Macro", 32, function(active)
    toggleRecording(active)
end)

setPlayToggle = createToggle(macroCard, "Enable Macro", 60, function(active)
    togglePlay(active)
end)

createToggle(macroCard, "Loop Macro", 88, function(active)
    isLooping = active
end)

createActionButton(macroCard, "Save Macro to File", 120, function()
    if #recordedFrames == 0 then return end
    pcall(function()
        local json = HttpService:JSONEncode(recordedFrames)
        writefile("Xnozi_Macro.json", json)
    end)
end)

createActionButton(macroCard, "Load Macro from File", 150, function()
    if isfile and isfile("Xnozi_Macro.json") then
        pcall(function()
            local json = readfile("Xnozi_Macro.json")
            recordedFrames = HttpService:JSONDecode(json)
        end)
    end
end)

--- 2. ROLLBACK TAB ---
local rollbackCard = createCard(RollbackPage, "Rollback Controls")
local isRollbackArmed = false

local function executeRollback()
    if not isRollbackArmed then return end

    local t = tick()
    while tick() - t < 1.0 do
        for i = 1, 100000 do
            local _ = math.sin(i) * math.cos(i)
        end
    end

    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end

createToggle(rollbackCard, "Activate Rollback", 32, function(active)
    isRollbackArmed = active
end)

createActionButton(rollbackCard, "Confirm Rollback", 64, function()
    executeRollback()
end)

--- 3. UTILIZE TAB ---
local utilizeCard = createCard(UtilizePage, "Player & Server Utilities")

local isAntiAfkActive = false
local afkConnection = nil
local setAntiAfkToggle

local function toggleAntiAfk(forceState)
    local newState = (forceState ~= nil) and forceState or not isAntiAfkActive
    isAntiAfkActive = newState
    if setAntiAfkToggle then setAntiAfkToggle(isAntiAfkActive) end

    if isAntiAfkActive then
        afkConnection = LocalPlayer.Idled:Connect(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
        end)
    else
        if afkConnection then
            afkConnection:Disconnect()
            afkConnection = nil
        end
    end
end

-- Anti-AFK 토글 버튼 (Utilize 카테고리로 이전)
setAntiAfkToggle = createToggle(utilizeCard, "Activate Anti-AFK", 32, function(active)
    toggleAntiAfk(active)
end)

createActionButton(utilizeCard, "Reset Character", 64, function()
    if Character then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Health = 0 end
    end
end)

createActionButton(utilizeCard, "Rejoin Same Server", 96, function()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

createActionButton(utilizeCard, "Rejoin New Server", 128, function()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end)

--- 4. HOTKEYS TAB ---
local hotkeyCard = createCard(HotkeysPage, "Keybind Settings")

createKeybindSelector(hotkeyCard, "Macro Record", 32, Hotkeys.RecordKey, function(newKey)
    Hotkeys.RecordKey = newKey
end)

createKeybindSelector(hotkeyCard, "Macro Play", 60, Hotkeys.PlayKey, function(newKey)
    Hotkeys.PlayKey = newKey
end)

createKeybindSelector(hotkeyCard, "Execute Rollback", 88, Hotkeys.RollbackKey, function(newKey)
    Hotkeys.RollbackKey = newKey
end)

createKeybindSelector(hotkeyCard, "Anti-AFK Toggle", 116, Hotkeys.AntiAfkKey, function(newKey)
    Hotkeys.AntiAfkKey = newKey
end)

createKeybindSelector(hotkeyCard, "Toggle UI", 144, Hotkeys.ToggleUIKey, function(newKey)
    Hotkeys.ToggleUIKey = newKey
end)

-- Global Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Hotkeys.RecordKey then
            toggleRecording()
        elseif input.KeyCode == Hotkeys.PlayKey then
            togglePlay()
        elseif input.KeyCode == Hotkeys.RollbackKey then
            executeRollback()
        elseif input.KeyCode == Hotkeys.AntiAfkKey then
            toggleAntiAfk()
        elseif input.KeyCode == Hotkeys.ToggleUIKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)
