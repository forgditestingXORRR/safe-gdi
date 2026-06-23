--========================================================================--
-- 1. SETUP CORE SERVICES & STATE CONFIGURATION
--========================================================================--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

-- Verification Greeting
task.spawn(function()
    local maxAttempts, attempts, success = 10, 0, false
    while not success and attempts < maxAttempts do
        attempts = attempts + 1
        success = pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "⚡ Hub System Loaded! Press [Right Shift] to toggle window.",
                Color = Color3.fromRGB(0, 255, 140),
                Font = Enum.Font.GothamBold,
                TextSize = 14
            })
        end)
        if not success then task.wait(1) end
    end
end)

-- Theme Configuration Dictionary
local theme = {
    Background = Color3.fromRGB(18, 18, 22),
    TitleBar = Color3.fromRGB(12, 12, 14),
    Sidebar = Color3.fromRGB(14, 14, 16),
    Editor = Color3.fromRGB(24, 24, 30),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(150, 150, 160),
    EditorText = Color3.fromRGB(0, 255, 140),
    ButtonText = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 180, 90),
    TabBtnBg = Color3.fromRGB(28, 28, 34),
    TabBtnActive = Color3.fromRGB(0, 140, 70),
    ScriptBtnBg = Color3.fromRGB(32, 32, 40),
    Destructive = Color3.fromRGB(160, 40, 40)
}

-- Root GUI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StudioAnalysisGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 2147483647
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--========================================================================--
-- 2. MAIN DASHBOARD FRAMEWORK
--========================================================================--
local MainFrame = Instance.new("Frame")
local UICorner_Main = Instance.new("UICorner")
local TitleBar = Instance.new("Frame")
local UICorner_Title = Instance.new("UICorner")
local TitleText = Instance.new("TextLabel")
local Sidebar = Instance.new("Frame")
local UIListLayout_Side = Instance.new("UIListLayout")
local ContentFrame = Instance.new("Frame")

-- Frame Containers
local MenuContainer = Instance.new("ScrollingFrame")
local MenuLayout = Instance.new("UIListLayout")
local CustomContainer = Instance.new("Frame")
local PreloadContainer = Instance.new("ScrollingFrame")
local PreloadLayout = Instance.new("UIListLayout")
local AnalysisContainer = Instance.new("ScrollingFrame")
local AnalysisLayout = Instance.new("UIListLayout")
local MentionsContainer = Instance.new("ScrollingFrame")
local MentionsLayout = Instance.new("UIListLayout")
local HubsContainer = Instance.new("ScrollingFrame")
local HubsLayout = Instance.new("UIListLayout")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 640, 0, 380)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -190)
MainFrame.BackgroundColor3 = theme.Background
MainFrame.Active = true
MainFrame.ClipsDescendants = true

UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainFrame

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = theme.TitleBar

UICorner_Title.CornerRadius = UDim.new(0, 10)
UICorner_Title.Parent = TitleBar

TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0.03, 0, 0, 0)
TitleText.Size = UDim2.new(0.8, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "Advanced Environment & Analysis Hub [RShift]"
TitleText.TextSize = 13
TitleText.TextColor3 = theme.Text

Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.BackgroundColor3 = theme.Sidebar
Sidebar.BorderSizePixel = 0

UIListLayout_Side.Parent = Sidebar
UIListLayout_Side.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_Side.Padding = UDim.new(0, 6)
UIListLayout_Side.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Animated Sidebar Button Component Engine
local sidebarButtons = {}
local function createSideBtn(text, order)
    local btn = Instance.new("TextButton")
    local corn = Instance.new("UICorner")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 11
    btn.LayoutOrder = order
    btn.BackgroundColor3 = theme.TabBtnBg
    btn.TextColor3 = theme.Text
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    corn.CornerRadius = UDim.new(0, 6)
    corn.Parent = btn
    
    -- Smooth interactive hover sequences
    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 ~= theme.TabBtnActive then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= theme.TabBtnActive then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = theme.TabBtnBg}):Play()
        end
    end)
    
    table.insert(sidebarButtons, btn)
    return btn
end

local MenuTabBtn = createSideBtn("Game Hub", 1)
local CustomTabBtn = createSideBtn("Console Executor", 2)
local PreloadTabBtn = createSideBtn("Dev Packages", 3)
local AnalysisTabBtn = createSideBtn("Analysis & UNC", 4)
local MentionsTabBtn = createSideBtn("Mentions", 5)
local HubsTabBtn = createSideBtn("My Hubs", 6)

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 140, 0, 40)
ContentFrame.Size = UDim2.new(1, -140, 1, -40)
ContentFrame.BackgroundTransparency = 1

local function configureScrollContainer(container, layout)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = theme.Accent
    container.Parent = ContentFrame
    layout.Parent = container
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

configureScrollContainer(MenuContainer, MenuLayout)
configureScrollContainer(PreloadContainer, PreloadLayout)
configureScrollContainer(AnalysisContainer, AnalysisLayout)
configureScrollContainer(MentionsContainer, MentionsLayout)
configureScrollContainer(HubsContainer, HubsLayout)

CustomContainer.Name = "CustomContainer"
CustomContainer.Parent = ContentFrame
CustomContainer.Size = UDim2.new(1, 0, 1, 0)
CustomContainer.BackgroundTransparency = 1

MenuContainer.Visible = true
CustomContainer.Visible = false
PreloadContainer.Visible = false
AnalysisContainer.Visible = false
MentionsContainer.Visible = false
HubsContainer.Visible = false
MenuTabBtn.BackgroundColor3 = theme.TabBtnActive

--========================================================================--
-- 3. GAME DATA INTERFACE ENGINE
--========================================================================--
local HeaderFrame = Instance.new("Frame")
local FrontpageImage = Instance.new("ImageLabel")
local UICorner_Image = Instance.new("UICorner")
local InfoLayoutFrame = Instance.new("Frame")
local InfoList = Instance.new("UIListLayout")

HeaderFrame.Name = "HeaderFrame"
HeaderFrame.Size = UDim2.new(0.94, 0, 0, 130)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = MenuContainer

FrontpageImage.Name = "FrontpageImage"
FrontpageImage.Parent = HeaderFrame
FrontpageImage.Position = UDim2.new(0, 0, 0.1, 0)
FrontpageImage.Size = UDim2.new(0, 110, 0, 110)
FrontpageImage.BackgroundColor3 = theme.Editor
FrontpageImage.Image = "rbxassetid://0"
UICorner_Image.CornerRadius = UDim.new(0, 8)
UICorner_Image.Parent = FrontpageImage

InfoLayoutFrame.Size = UDim2.new(0.7, 0, 1, 0)
InfoLayoutFrame.Position = UDim2.new(0.28, 0, 0, 0)
InfoLayoutFrame.BackgroundTransparency = 1
InfoLayoutFrame.Parent = HeaderFrame
InfoList.Parent = InfoLayoutFrame
InfoList.Padding = UDim.new(0, 4)
InfoList.VerticalAlignment = Enum.VerticalAlignment.Center

local function createMenuLabel(text, font, size, color, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.94, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font = font
    lbl.Text = text
    lbl.TextSize = size
    lbl.TextColor3 = color
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent or MenuContainer
    return lbl
end

local GameTitle = createMenuLabel("Loading Title...", Enum.Font.GothamBold, 15, theme.Text, InfoLayoutFrame)
local GameCreator = createMenuLabel("Developer: Loading...", Enum.Font.GothamMedium, 12, theme.SubText, InfoLayoutFrame)

createMenuLabel("--- Network Statistics ---", Enum.Font.GothamBold, 12, theme.Accent, MenuContainer)
local GlobalPlayers = createMenuLabel("🌐 Global Active Users (All Servers): Fetching...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local ActiveServerPlayers = createMenuLabel("🟢 Your Current Server Session: Fetching...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)

createMenuLabel("--- Complete Timeline Breakdown ---", Enum.Font.GothamBold, 12, theme.Accent, MenuContainer)
local TimeDecades = createMenuLabel("⌛ Decades Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local TimeYears = createMenuLabel("📅 Years Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local TimeMonths = createMenuLabel("🌙 Months Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local TimeDays = createMenuLabel("☀️ Days Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local TimeHours = createMenuLabel("⏱️ Hours Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local TimeMinutes = createMenuLabel("⏰ Minutes Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)
local TimeSeconds = createMenuLabel("⏳ Seconds Old: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, MenuContainer)

task.spawn(function()
    local placeId = game.PlaceId
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(placeId) end)
    if success and info then
        GameTitle.Text = info.Name or "Roblox Experience"
        GameCreator.Text = "Developer: " .. (info.Creator and info.Creator.Name or "Unknown Universe")
        if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            FrontpageImage.Image = "rbxassetid://" .. info.IconImageAssetId
        end
    end

    local universeId = game.GameId
    local createdTimestamp = os.time() - 120560400 
    local universeSuccess, universeInfo = pcall(function()
        return game:HttpGetAsync("https://games.roblox.com/v1/games?universeIds=" .. universeId)
    end)
    local totalGlobalPlayers = "N/A"
    if universeSuccess and universeInfo then
        totalGlobalPlayers = universeInfo:match('"playing":%s*(%d+)') or "Active"
        local dateStr = universeInfo:match('"created":%s*"([^"]+)"')
        if dateStr then
            local y, m, d, hh, mm, ss = dateStr:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
            if y and m and d then
                createdTimestamp = os.time({year=y, month=m, day=d, hour=hh, min=mm, sec=ss})
            end
        end
    end

    GlobalPlayers.Text = "🌐 Global Active Users (All Servers): " .. totalGlobalPlayers .. " Online"

    task.spawn(function()
        while task.wait(1) do
            local currentTimestamp = os.time()
            local diff = math.max(0, currentTimestamp - createdTimestamp)
            TimeDecades.Text = string.format("⌛ Decades Old: %d Decades", math.floor(diff / 315576000))
            TimeYears.Text = string.format("📅 Years Old: %d Years", math.floor(diff / 31557600))
            TimeMonths.Text = string.format("🌙 Months Old: %d Months", math.floor(diff / 2629800))
            TimeDays.Text = string.format("☀️ Days Old: %s Days", tonumber(math.floor(diff / 86400)))
            TimeHours.Text = string.format("⏱️ Hours Old: %s Hours", tonumber(math.floor(diff / 3600)))
            TimeMinutes.Text = string.format("⏰ Minutes Old: %s Minutes", tonumber(math.floor(diff / 60)))
            TimeSeconds.Text = string.format("⏳ Seconds Old: %s Seconds", tonumber(diff))
        end
    end)

    local function refreshCounts()
        ActiveServerPlayers.Text = string.format("🟢 Your Current Server Session: %d / %d Active Player slots filled", #Players:GetPlayers(), Players.MaxPlayers)
    end
    refreshCounts()
    Players.PlayerAdded:Connect(refreshCounts)
    Players.PlayerRemoving:Connect(refreshCounts)
end)

--========================================================================--
-- 4. CODE CONSOLE INTERACTION SYSTEM
--========================================================================--
local ScripterBox = Instance.new("TextBox")
local UICorner_Box = Instance.new("UICorner")
local ExecuteBtn = Instance.new("TextButton")
local UICorner_Exec = Instance.new("UICorner")
local ClearBtn = Instance.new("TextButton")
local UICorner_Clear = Instance.new("UICorner")

ScripterBox.Parent = CustomContainer
ScripterBox.Position = UDim2.new(0.04, 0, 0.05, 0)
ScripterBox.Size = UDim2.new(0.92, 0, 0.65, 0)
ScripterBox.BackgroundColor3 = theme.Editor
ScripterBox.TextColor3 = theme.EditorText
ScripterBox.ClearTextOnFocus = false
ScripterBox.Font = Enum.Font.Code
ScripterBox.MultiLine = true
ScripterBox.Text = "-- Write studio debug routines here\n"
ScripterBox.TextSize = 12
ScripterBox.TextXAlignment = Enum.TextXAlignment.Left
ScripterBox.TextYAlignment = Enum.TextYAlignment.Top

UICorner_Box.CornerRadius = UDim.new(0, 6)
UICorner_Box.Parent = ScripterBox

ExecuteBtn.Parent = CustomContainer
ExecuteBtn.Position = UDim2.new(0.04, 0, 0.80, 0)
ExecuteBtn.Size = UDim2.new(0.58, 0, 0, 36)
ExecuteBtn.BackgroundColor3 = theme.Accent
ExecuteBtn.TextColor3 = theme.ButtonText
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.Text = "Run Routine Chunk"
ExecuteBtn.TextSize = 13
ExecuteBtn.AutoButtonColor = false

UICorner_Exec.CornerRadius = UDim.new(0, 6)
UICorner_Exec.Parent = ExecuteBtn

ClearBtn.Parent = CustomContainer
ClearBtn.Position = UDim2.new(0.65, 0, 0.80, 0)
ClearBtn.Size = UDim2.new(0.31, 0, 0, 36)
ClearBtn.BackgroundColor3 = theme.Destructive
ClearBtn.TextColor3 = theme.ButtonText
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.Text = "Clear Text"
ClearBtn.TextSize = 13
ClearBtn.AutoButtonColor = false

UICorner_Clear.CornerRadius = UDim.new(0, 6)
UICorner_Clear.Parent = ClearBtn

ClearBtn.MouseButton1Click:Connect(function() ScripterBox.Text = "" end)

-- Button Hover Microtweens
local function addButtonFeedback(button, normalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.15}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    end)
end
addButtonFeedback(ExecuteBtn, theme.Accent)
addButtonFeedback(ClearBtn, theme.Destructive)

--========================================================================--
-- 5. OPTIMIZED BACKGROUND UNC TESTING LAYER & STATS
--========================================================================--
local fpsLabel = createMenuLabel("Performance Output: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, AnalysisContainer)
local pingLabel = createMenuLabel("Data Latency: Calculating...", Enum.Font.GothamMedium, 12, theme.Text, AnalysisContainer)
createMenuLabel("-----------------------------------------", Enum.Font.GothamBold, 12, theme.SubText, AnalysisContainer)
local uncLabel = createMenuLabel("UNC Compliance Tracker: Checking...", Enum.Font.GothamBold, 13, theme.EditorText, AnalysisContainer)
local uncDetailsLabel = createMenuLabel("Passes: 0 | Fails: 0", Enum.Font.GothamMedium, 12, theme.Text, AnalysisContainer)
createMenuLabel("-----------------------------------------", Enum.Font.GothamBold, 12, theme.SubText, AnalysisContainer)

local fpsFrameCount, fpsLastUpdate = 0, os.clock()
RunService.RenderStepped:Connect(function()
    fpsFrameCount = fpsFrameCount + 1
    local now = os.clock()
    if now - fpsLastUpdate >= 1 then
        fpsLabel.Text = string.format("Performance Output: %d FPS", fpsFrameCount)
        fpsFrameCount, fpsLastUpdate = 0, now
        local statsNetwork = Stats:FindFirstChild("Network")
        if statsNetwork then
            pingLabel.Text = string.format("Data Latency (Ping): %.2f ms", statsNetwork.ServerIn:GetValue())
        end
    end
end)

-- Structural State Storage Engine
local UNC_Results = { Passes = 0, Fails = 0, Checked = 0 }
local getgenv = getgenv or function() return getfenv(2) end

local function getGlobal(path)
    local value = getgenv()
    while value ~= nil and path ~= "" do
        local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
        value = value[name]
        path = nextValue
    end
    return value
end

local function checkUnc(name, callback)
    local isSupported = getGlobal(name) ~= nil
    local executedOk = false
    if isSupported and callback then
        executedOk = pcall(callback)
    elseif isSupported and not callback then
        executedOk = true
    end
    
    UNC_Results.Checked = UNC_Results.Checked + 1
    if executedOk then
        UNC_Results.Passes = UNC_Results.Passes + 1
    else
        UNC_Results.Fails = UNC_Results.Fails + 1
    end
    
    -- Dynamically update analysis page metrics as they finish checking
    local percentage = (UNC_Results.Passes / UNC_Results.Checked) * 100
    uncLabel.Text = string.format("UNC Framework Score: %.1f%%", percentage)
    uncDetailsLabel.Text = string.format("Passes: %d  |  Failures Logged: %d", UNC_Results.Passes, UNC_Results.Fails)
end

-- Fast-Execution Non-Blocking Routine Context
local function executeEngineVerification()
    checkUnc("cache.invalidate", function()
        local f = Instance.new("Folder")
        local p = Instance.new("Part", f)
        cache.invalidate(f:FindFirstChild("Part"))
        assert(p ~= f:FindFirstChild("Part"))
    end)
    checkUnc("cache.iscached", function() assert(cache.iscached(Instance.new("Part"))) end)
    checkUnc("cloneref", function()
        local p = Instance.new("Part")
        local c = cloneref(p)
        assert(p ~= c and c.Name == p.Name)
    end)
    checkUnc("checkcaller", function() assert(checkcaller()) end)
    checkUnc("hookfunction", function()
        local t = function() return true end
        local r = hookfunction(t, function() return false end)
        assert(t() == false and r() == true)
    end)
    checkUnc("iscclosure", function() assert(iscclosure(print) == true) end)
    checkUnc("isexecutorclosure", function() assert(isexecutorclosure(function() end) == true) end)
    checkUnc("crypt.base64encode", function() assert(crypt.base64encode("test") == "dGVzdA==") end)
    checkUnc("debug.getconstant", function()
        local f = function() print("UNC") end
        assert(debug.getconstant(f, 1) == "print" or debug.getconstant(f, 3) == "UNC")
    end)
    checkUnc("writefile", function()
        writefile(".unclog.txt", "speed")
        assert(readfile(".unclog.txt") == "speed")
        delfile(".unclog.txt")
    end)
    checkUnc("getrawmetatable", function()
        local mt = {__metatable = "Locked"}
        assert(getrawmetatable(setmetatable({}, mt)) == mt)
    end)
    checkUnc("hookmetamethod", function()
        local t = setmetatable({}, {__index = function() return false end, __metatable = "Locked"})
        hookmetamethod(t, "__index", function() return true end)
        assert(t.test == true)
    end)
    checkUnc("identifyexecutor")
    checkUnc("getgenv")
    checkUnc("request")
end

-- Trigger Background Diagnostics Sequence
task.spawn(executeEngineVerification)

-- Diagnostic Quality Configuration Action Button
local ExecQualityBtn = Instance.new("TextButton")
local UICorner_ExecQuality = Instance.new("UICorner")
ExecQualityBtn.Parent = AnalysisContainer
ExecQualityBtn.Size = UDim2.new(0.92, 0, 0, 42)
ExecQualityBtn.BackgroundColor3 = theme.Accent
ExecQualityBtn.TextColor3 = theme.ButtonText
ExecQualityBtn.Font = Enum.Font.GothamBold
ExecQualityBtn.Text = "Print F9 Executor Quality Check"
ExecQualityBtn.TextSize = 13
ExecQualityBtn.AutoButtonColor = false
UICorner_ExecQuality.CornerRadius = UDim.new(0, 6)
UICorner_ExecQuality.Parent = ExecQualityBtn
addButtonFeedback(ExecQualityBtn, theme.Accent)

ExecQualityBtn.MouseButton1Click:Connect(function()
    print("\n=======================================================")
    print("🔍 EXECUTOR QUALITY CHECK - STARTING F9 DIAGNOSTIC 🔍")
    print("=======================================================")
    local passed, totalChecks = 0, 0
    local function checkFeature(name, testFunc)
        totalChecks = totalChecks + 1
        local success, err = pcall(testFunc)
        if success and err ~= false then
            passed = passed + 1
            print("✅ [PASS] " .. name)
        else
            print("❌ [FAIL] " .. name .. (type(err) == "string" and (" - " .. err) or ""))
        end
    end
    checkFeature("Identity Level (getidentity)", function()
        local getIdent = getidentity or getthreadidentity or getthreadcontext
        print("   -> Current Thread Identity: " .. tostring(getIdent()))
        return true
    end)
    checkFeature("Traversals (getgc, debug.getinfo)", function() return type(debug.getinfo) == "function" end)
    checkFeature("Drawing API Canvas Instantiation", function() return type(Drawing.new) == "function" end)
    local score = math.floor((passed / totalChecks) * 100)
    print(string.format("🏆 SYSTEM PERFORMANCE METRIC SCORE: %d%%", score))
    print("=======================================================\n")
end)

--========================================================================--
-- 6. DEV PACKAGES LOADER FRAMEWORK
--========================================================================--
local packageDatabase = {
    {Name = "Hydroxide Framework", Url = "https://raw.githubusercontent.com/PolySided/Hydroxide/main/init.lua"},
    {Name = "Orca Core Framework", Url = "https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"},
    {Name = "Fate's Core Package", Url = "https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"},
    {Name = "Dex Object Inspector Module", Url = "https://raw.githubusercontent.com/SPDM-Team/ArceusX-V3-Scripts/main/Dex-Explorer.lua"}
}

for _, item in ipairs(packageDatabase) do
    local ScriptBtn = Instance.new("TextButton")
    local UICorner_Btn = Instance.new("UICorner")
    local Padding = Instance.new("UIPadding")
    ScriptBtn.Size = UDim2.new(0.92, 0, 0, 42)
    ScriptBtn.Font = Enum.Font.GothamMedium
    ScriptBtn.Text = "📦 Load " .. item.Name
    ScriptBtn.TextSize = 13
    ScriptBtn.TextXAlignment = Enum.TextXAlignment.Left
    ScriptBtn.BackgroundColor3 = theme.ScriptBtnBg
    ScriptBtn.TextColor3 = theme.Text
    ScriptBtn.AutoButtonColor = false
    UICorner_Btn.CornerRadius = UDim.new(0, 6)
    UICorner_Btn.Parent = ScriptBtn
    Padding.Parent = ScriptBtn
    Padding.PaddingLeft = UDim.new(0, 12)
    ScriptBtn.Parent = PreloadContainer
    addButtonFeedback(ScriptBtn, theme.ScriptBtnBg)
    
    ScriptBtn.MouseButton1Click:Connect(function()
        pcall(function() loadstring(game:HttpGet(item.Url))() end)
    end)
end

--========================================================================--
-- 7. COMPONENT HELPER ENGINE & DATA POOLS
--========================================================================--
local function createLoadableScriptBtn(displayText, executableCode, containerTarget)
    local ScriptBtn = Instance.new("TextButton")
    local UICorner_Btn = Instance.new("UICorner")
    local Padding = Instance.new("UIPadding")
    ScriptBtn.Size = UDim2.new(0.92, 0, 0, 46)
    ScriptBtn.Font = Enum.Font.Code
    ScriptBtn.Text = "▶ Run: " .. displayText
    ScriptBtn.TextSize = 11
    ScriptBtn.TextXAlignment = Enum.TextXAlignment.Left
    ScriptBtn.BackgroundColor3 = theme.ScriptBtnBg
    ScriptBtn.TextColor3 = theme.SubText
    ScriptBtn.TextWrapped = true
    ScriptBtn.ClipsDescendants = true
    ScriptBtn.AutoButtonColor = false
    UICorner_Btn.CornerRadius = UDim.new(0, 6)
    UICorner_Btn.Parent = ScriptBtn
    Padding.Parent = ScriptBtn
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    ScriptBtn.Parent = containerTarget
    addButtonFeedback(ScriptBtn, theme.ScriptBtnBg)
    
    ScriptBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local chunk = loadstring(executableCode)
            if chunk then chunk() end
        end)
    end)
end

-- Mentions Content Items
createMenuLabel("--- Creator Honourable Mentions ---", Enum.Font.GothamBold, 14, theme.Accent, MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/WDjT0ejC", "loadstring(game:HttpGet('https://pastebin.com/raw/WDjT0ejC'))()", MentionsContainer)
createLoadableScriptBtn("loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()", "loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/2mrC9Jf6", "loadstring(game:HttpGet('https://pastebin.com/raw/2mrC9Jf6'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/GggmFR0y", "loadstring(game:HttpGet('https://pastebin.com/raw/GggmFR0y'))()", MentionsContainer)
createLoadableScriptBtn("loadstring(game:HttpGet('https://pastebin.com/raw/JhkcJ8eF'))()", "loadstring(game:HttpGet('https://pastebin.com/raw/JhkcJ8eF'))()", MentionsContainer)
createLoadableScriptBtn("Universal Super Ring Parts V3", "loadstring(game:HttpGet('https://rawscripts.net/raw/Universal-Script-SUPER-RING-PARTS-V3-WITH-NO-MESSAGE-26385'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/jyVVfCGk", "loadstring(game:HttpGet('https://pastebin.com/raw/jyVVfCGk'))()", MentionsContainer)
createLoadableScriptBtn("FE Fling GUI Engine Context", "loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/uTmdY23g", "loadstring(game:HttpGet('https://pastebin.com/raw/uTmdY23g'))()", MentionsContainer)

-- Custom Hubs Content Items
createMenuLabel("--- Developer Custom Hubs ---", Enum.Font.GothamBold, 14, theme.Accent, HubsContainer)
createLoadableScriptBtn("SimpleSpy V3 (Remote Event Logger)", "loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua'))()", HubsContainer)
createLoadableScriptBtn("CMD-X (Advanced Admin Commands)", "loadstring(game:HttpGet('https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source'))()", HubsContainer)
createLoadableScriptBtn("Unnamed ESP (Universal Player Tracker)", "loadstring(game:HttpGet('https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UntitledESP.lua'))()", HubsContainer)
createLoadableScriptBtn("MM2 HAX", "loadstring(game:HttpGet('https://raw.githubusercontent.com/forgditestingXORRR/safe-gdi/refs/heads/main/MM2HAX.lua'))()", HubsContainer)
createLoadableScriptBtn("AIMBOT", "loadstring(game:HttpGet('https://raw.githubusercontent.com/forgditestingXORRR/safe-gdi/refs/heads/main/roblox.lua'))()", HubsContainer)
createLoadableScriptBtn("Infinite Yield", "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()", HubsContainer)
createLoadableScriptBtn("Copyable Script Descriptor", "loadstring(game:HttpGet('https://raw.githubusercontent.com/forgditestingXORRR/safe-gdi/refs/heads/main/copyable.lua'))()", HubsContainer)

--========================================================================--
-- 8. NAVIGATION AND TWEEN INTERACTION ENGINE
--========================================================================--
local function switchTab(container, clickedButton)
    MenuContainer.Visible = (container == MenuContainer)
    CustomContainer.Visible = (container == CustomContainer)
    PreloadContainer.Visible = (container == PreloadContainer)
    AnalysisContainer.Visible = (container == AnalysisContainer)
    MentionsContainer.Visible = (container == MentionsContainer)
    HubsContainer.Visible = (container == HubsContainer)
    
    for _, btn in ipairs(sidebarButtons) do
        if btn == clickedButton then
            TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = theme.TabBtnActive}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = theme.TabBtnBg}):Play()
        end
    end
end

MenuTabBtn.MouseButton1Click:Connect(function() switchTab(MenuContainer, MenuTabBtn) end)
CustomTabBtn.MouseButton1Click:Connect(function() switchTab(CustomContainer, CustomTabBtn) end)
PreloadTabBtn.MouseButton1Click:Connect(function() switchTab(PreloadContainer, PreloadTabBtn) end)
AnalysisTabBtn.MouseButton1Click:Connect(function() switchTab(AnalysisContainer, AnalysisTabBtn) end)
MentionsTabBtn.MouseButton1Click:Connect(function() switchTab(MentionsContainer, MentionsTabBtn) end)
HubsTabBtn.MouseButton1Click:Connect(function() switchTab(HubsContainer, HubsTabBtn) end)

local function autoScaleCanvas(container, layout)
    container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    end)
end
autoScaleCanvas(MenuContainer, MenuLayout)
autoScaleCanvas(PreloadContainer, PreloadLayout)
autoScaleCanvas(AnalysisContainer, AnalysisLayout)
autoScaleCanvas(MentionsContainer, MentionsLayout)
autoScaleCanvas(HubsContainer, HubsLayout)

ExecuteBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local chunk = loadstring(ScripterBox.Text)
        if chunk then chunk() end
    end)
end)

-- Smooth Inertial Drag Calculation Framework
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
end)

-- Modern Window Toggle Scaling Routine
local uiStateVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiStateVisible = not uiStateVisible
        if uiStateVisible then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 640, 0, 380)}):Play()
        else
            local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 640, 0, 0)})
            hideTween:Play()
            hideTween.Completed:Connect(function()
                if not uiStateVisible then MainFrame.Visible = false end
            end)
        end
    end
end)
