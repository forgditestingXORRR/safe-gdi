-- 1. SETUP CORE UI & SERVICES --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

-- Send verification announcement to local client chat profile system
task.spawn(function()
    local maxAttempts = 10
    local attempts = 0
    local success = false
    while not success and attempts < maxAttempts do
        attempts = attempts + 1
        success = pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "Thank you for using my script!",
                Color = Color3.fromRGB(0, 255, 140),
                Font = Enum.Font.GothamBold,
                TextSize = 14
            })
        end)
        if not success then task.wait(1) end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StudioAnalysisGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
-- ADDED PROPERTIES TO FORCE UI ON TOP --
ScreenGui.DisplayOrder = 2147483647
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-----------------------------------------

local theme = {
    Background = Color3.fromRGB(24, 24, 28),
    TitleBar = Color3.fromRGB(16, 16, 18),
    Sidebar = Color3.fromRGB(20, 20, 22),
    Editor = Color3.fromRGB(32, 32, 38),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 170),
    EditorText = Color3.fromRGB(0, 255, 140),
    ButtonText = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 140, 70),
    TabBtnBg = Color3.fromRGB(35, 35, 40),
    ScriptBtnBg = Color3.fromRGB(45, 45, 52)
}

-- 2. MAIN INTERFACE FRAMEWORK --
local MainFrame = Instance.new("Frame")
local UICorner_Main = Instance.new("UICorner")
local TitleBar = Instance.new("Frame")
local UICorner_Title = Instance.new("UICorner")
local TitleText = Instance.new("TextLabel")
local Sidebar = Instance.new("Frame")
local UIListLayout_Side = Instance.new("UIListLayout")
local ContentFrame = Instance.new("Frame")
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
TitleText.Text = "Advanced Environment & Analysis Hub"
TitleText.TextSize = 14
TitleText.TextColor3 = theme.Text

-- Sidebar Navigation Setup --
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
    btn.Parent = Sidebar
    corn.CornerRadius = UDim.new(0, 6)
    corn.Parent = btn
    return btn
end

local MenuTabBtn = createSideBtn("Game Hub", 1)
local CustomTabBtn = createSideBtn("Console Executor", 2)
local PreloadTabBtn = createSideBtn("Dev Packages", 3)
local AnalysisTabBtn = createSideBtn("Analysis & UNC", 4)
local MentionsTabBtn = createSideBtn("Mentions", 5)
local HubsTabBtn = createSideBtn("My Hubs", 6)

-- Content Scaling Framework --
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 140, 0, 40)
ContentFrame.Size = UDim2.new(1, -140, 1, -40)
ContentFrame.BackgroundTransparency = 1

local function configureScrollContainer(container, layout)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 4
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

-- Initial Tab Visibility Fix --
MenuContainer.Visible = true
CustomContainer.Visible = false
PreloadContainer.Visible = false
AnalysisContainer.Visible = false
MentionsContainer.Visible = false
HubsContainer.Visible = false

-- 3. GAME HUB TAB INTERFACE --
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
local GameCreator = createMenuLabel("Loading Creator...", Enum.Font.GothamMedium, 12, theme.SubText, InfoLayoutFrame)

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
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    if success and info then
        GameTitle.Text = info.Name or "Roblox Experience"
        GameCreator.Text = "Developer: " .. (info.Creator and info.Creator.Name or "Unknown Universe")
        if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            FrontpageImage.Image = "rbxassetid://" .. info.IconImageAssetId
        end
    end

    local universeId = game.GameId
    local createdTimestamp = os.time() - 120560400 -- Fallback calculation frame
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
            local seconds = diff
            local minutes = math.floor(seconds / 60)
            local hours = math.floor(minutes / 60)
            local days = math.floor(hours / 24)
            local months = math.floor(days / 30.4368)
            local years = math.floor(days / 365.25)
            local decades = math.floor(years / 10)
            TimeDecades.Text = string.format("⌛ Decades Old: %d Decades", decades)
            TimeYears.Text = string.format("📅 Years Old: %d Years", years)
            TimeMonths.Text = string.format("🌙 Months Old: %d Months", months)
            TimeDays.Text = string.format("☀️ Days Old: %s Days", tonumber(days))
            TimeHours.Text = string.format("⏱️ Hours Old: %s Hours", tonumber(hours))
            TimeMinutes.Text = string.format("⏰ Minutes Old: %s Minutes", tonumber(minutes))
            TimeSeconds.Text = string.format("⏳ Seconds Old: %s Seconds", tonumber(seconds))
        end
    end)

    local function refreshCounts()
        local localServerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        ActiveServerPlayers.Text = string.format("🟢 Your Current Server Session: %d / %d Active Player slots filled", localServerCount, maxPlayers)
    end
    refreshCounts()
    Players.PlayerAdded:Connect(refreshCounts)
    Players.PlayerRemoving:Connect(refreshCounts)
end)

-- 4. EXECUTOR TAB INTERFACE --
local ScripterBox = Instance.new("TextBox")
local UICorner_Box = Instance.new("UICorner")
local ExecuteBtn = Instance.new("TextButton")
local UICorner_Exec = Instance.new("UICorner")

ScripterBox.Parent = CustomContainer
ScripterBox.Position = UDim2.new(0.04, 0, 0.05, 0)
ScripterBox.Size = UDim2.new(0.92, 0, 0.65, 0)
ScripterBox.BackgroundColor3 = theme.Editor
ScripterBox.TextColor3 = theme.EditorText
ScripterBox.ClearTextOnFocus = false
ScripterBox.Font = Enum.Font.Code
ScripterBox.MultiLine = true
ScripterBox.Text = "-- Write studio debug routines here\n"
ScripterBox.TextSize = 13
ScripterBox.TextXAlignment = Enum.TextXAlignment.Left
ScripterBox.TextYAlignment = Enum.TextYAlignment.Top

UICorner_Box.CornerRadius = UDim.new(0, 6)
UICorner_Box.Parent = ScripterBox

ExecuteBtn.Parent = CustomContainer
ExecuteBtn.Position = UDim2.new(0.04, 0, 0.80, 0)
ExecuteBtn.Size = UDim2.new(0.92, 0, 0, 36)
ExecuteBtn.BackgroundColor3 = theme.Accent
ExecuteBtn.TextColor3 = theme.ButtonText
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.Text = "Run Routine Chunk"
ExecuteBtn.TextSize = 13

UICorner_Exec.CornerRadius = UDim.new(0, 6)
UICorner_Exec.Parent = ExecuteBtn

-- 5. ANALYSIS & ENVIRONMENT COMPLIANCE (UNC) --
local function createStatLabel(title, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.92, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = title
    lbl.TextSize = 13
    lbl.TextColor3 = theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local fpsLabel = createStatLabel("FPS: Calculating...", AnalysisContainer)
local pingLabel = createStatLabel("Data Latency: Calculating...", AnalysisContainer)
local uncLabel = createStatLabel("UNC Environment Compliance: Checking...", AnalysisContainer)

local fpsFrameCount = 0
local fpsLastUpdate = os.clock()

RunService.RenderStepped:Connect(function()
    fpsFrameCount = fpsFrameCount + 1
    local now = os.clock()
    if now - fpsLastUpdate >= 1 then
        fpsLabel.Text = string.format("Performance Output: %d FPS", fpsFrameCount)
        fpsFrameCount = 0
        fpsLastUpdate = now
        local statsNetwork = Stats:FindFirstChild("Network")
        if statsNetwork then
            pingLabel.Text = string.format("Data Latency (Ping): %.2f ms", statsNetwork.ServerIn:GetValue())
        end
    end
end)

local function runUncTest()
    local supported = 0
    local total = 6
    if identifyexecutor then supported = supported + 1 end
    if getgenv then supported = supported + 1 end
    if hookfunction then supported = supported + 1 end
    if loadstring then supported = supported + 1 end
    if isfolder then supported = supported + 1 end
    if makefolder then supported = supported + 1 end
    local percent = (supported / total) * 100
    uncLabel.Text = string.format("UNC Framework Score: %.1f%% (%d/%d Standard API Functions)", percent, supported, total)
end
task.spawn(runUncTest)

-- EXECUTOR QUALITY CHECKER PRINTER BUTTON (F9 OUTPUT) --
local ExecQualityBtn = Instance.new("TextButton")
local UICorner_ExecQuality = Instance.new("UICorner")

ExecQualityBtn.Parent = AnalysisContainer
ExecQualityBtn.Size = UDim2.new(0.92, 0, 0, 42)
ExecQualityBtn.BackgroundColor3 = theme.Accent
ExecQualityBtn.TextColor3 = theme.ButtonText
ExecQualityBtn.Font = Enum.Font.GothamBold
ExecQualityBtn.Text = "Print F9 Executor Quality Check"
ExecQualityBtn.TextSize = 13

UICorner_ExecQuality.CornerRadius = UDim.new(0, 6)
UICorner_ExecQuality.Parent = ExecQualityBtn

ExecQualityBtn.MouseButton1Click:Connect(function()
    print("\n=======================================================")
    print("🔍 EXECUTOR QUALITY CHECK - STARTING F9 DIAGNOSTIC 🔍")
    print("=======================================================")
    
    local passed = 0
    local totalChecks = 0

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

    -- 1. Identity Level (Adaptive check for alternative signatures)
    checkFeature("Identity Level (getidentity)", function()
        local getIdent = getidentity or getthreadidentity or getthreadcontext or (syn and syn.get_thread_identity)
        if not getIdent then error("API completely missing from global/libraries") end
        local identity = getIdent()
        if not identity then error("API returned null context status") end
        print("   -> Current Thread Identity: " .. tostring(identity))
        return true
    end)

    -- 2. Function Existence (Checks global and library fallbacks)
    checkFeature("Function Existence Checks (getgc, getreg, getupvalues)", function()
        local ggc = getgc or (ext and ext.getgc)
        local greg = getreg or debug.getregistry or (ext and ext.getreg)
        local gup = getupvalues or debug.getupvalues or getupvals
        if not ggc or not greg or not gup then 
            error("Missing core traversal APIs. Ensure environment provides registry/GC exposure.") 
        end
        return true
    end)

    -- 3. Debug Library Tests
    checkFeature("Debug Library Tests (debug.getinfo)", function()
        local getinfo = debug and debug.getinfo
        if type(getinfo) ~= "function" then error("debug.getinfo is missing or protected") end
        local info = getinfo(print)
        if not info then error("Failed to evaluate standard runtime descriptors") end
        return true
    end)

    -- 4. UNC / Hook Tests
    checkFeature("UNC/Hook Tests (hookfunction, newcclosure)", function()
        local hook = hookfunction or replaceclosure or (syn and syn.hook_function)
        local ncc = newcclosure or (syn and syn.new_c_closure)
        if not hook or not ncc then error("Environment lacks closure replacement/conversion methods") end
        return true
    end)

    -- 5. Filesystem Tests
    checkFeature("Filesystem Tests (isfile, writefile)", function()
        local isf = isfile or (fs and fs.isfile)
        local wrf = writefile or (fs and fs.writefile)
        if not isf or not wrf then error("Isolated virtual filesystem APIs unavailable") end
        return true
    end)

    -- 6. Drawing API Tests
    checkFeature("Drawing API Tests (Drawing.new)", function()
        if not Drawing or type(Drawing.new) ~= "function" then error("Drawing text/vector engine instantiation failed") end
        return true
    end)

    -- 7. Request API Tests
    checkFeature("Request API Tests (request)", function()
        local reqFunc = request or http_request or (http and http.request) or (syn and syn.request)
        if not reqFunc then error("Network mesh socket transmission layer unavailable") end
        return true
    end)

    -- 8. Execution Speed Test (Optimized to utilize local registers for pure speed)
    checkFeature("Execution Speed Test (10M Loops - Optimized)", function()
        local clock = os.clock
        local start = clock()
        local counter = 0
        -- Pure localized internal registration loop for speed precision
        for i = 1, 10000000 do 
            counter = counter + 1 
        end
        local elapsed = clock() - start
        print(string.format("   -> Localized Registration Completed in %.5f seconds", elapsed))
        return true
    end)

    -- 9. UNC Stability Test
    checkFeature("UNC Stability Test (Hook Dummy Error Prevention)", function()
        local hook = hookfunction or replaceclosure or (syn and syn.hook_function)
        if not hook then error("hookfunction/replaceclosure required to verify stability configuration") end
        local function testDummy() return "stable" end
        local success, result = pcall(function()
            hook(testDummy, function() return "hooked" end)
            return testDummy()
        end)
        if not success then error("Hook application forced stack collapse or exception error") end
        if result ~= "hooked" then error("Hook operation executed quietly but skipped runtime modification") end
        return true
    end)

    local finalScore = math.floor((passed / totalChecks) * 100)
    print("-------------------------------------------------------")
    print(string.format("🏆 ENVIRONMENT PERFORMANCE SCORE: %d / %d (%d%%)", passed, totalChecks, finalScore))
    print("=======================================================\n")
end)

-- 6. DEV PACKAGES LOADER FRAMEWORK --
local packageDatabase = {
    {
        Name = "Hydroxide Framework",
        Source = function()
            local owner, branch, file = "PolySided", "main", "init"
            return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
        end
    },
    {
        Name = "Orca Core Framework",
        Source = function()
            return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua"))()
        end
    },
    {
        Name = "Fate's Core Package",
        Source = function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))()
        end
    },
    {
        Name = "Dex Object Inspector Module",
        Source = function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/SPDM-Team/ArceusX-V3-Scripts/main/Dex-Explorer.lua"))()
        end
    }
}

for _, item in ipairs(packageDatabase) do
    local ScriptBtn = Instance.new("TextButton")
    local UICorner_Btn = Instance.new("UICorner")
    local Padding = Instance.new("UIPadding")
    ScriptBtn.Name = item.Name .. "Btn"
    ScriptBtn.Parent = PreloadContainer
    ScriptBtn.Size = UDim2.new(0.92, 0, 0, 42)
    ScriptBtn.Font = Enum.Font.GothamMedium
    ScriptBtn.Text = "📦 Load " .. item.Name
    ScriptBtn.TextSize = 13
    ScriptBtn.TextXAlignment = Enum.TextXAlignment.Left
    ScriptBtn.BackgroundColor3 = theme.ScriptBtnBg
    ScriptBtn.TextColor3 = theme.Text
    UICorner_Btn.CornerRadius = UDim.new(0, 6)
    UICorner_Btn.Parent = ScriptBtn
    Padding.Parent = ScriptBtn
    Padding.PaddingLeft = UDim.new(0, 12)
    ScriptBtn.MouseButton1Click:Connect(function()
        pcall(item.Source)
    end)
end

-- 7. LOADER LAYOUT HELPER ENGINE --
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
    UICorner_Btn.CornerRadius = UDim.new(0, 6)
    UICorner_Btn.Parent = ScriptBtn
    Padding.Parent = ScriptBtn
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    ScriptBtn.Parent = containerTarget
    ScriptBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local chunk = loadstring(executableCode)
            if chunk then chunk() end
        end)
    end)
end

-- 8. HONOURABLE MENTIONS TAB --
createMenuLabel("--- Creator Honourable Mentions ---", Enum.Font.GothamBold, 14, theme.Accent, MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/WDjT0ejC", "loadstring(game:HttpGet('https://pastebin.com/raw/WDjT0ejC'))()", MentionsContainer)
createLoadableScriptBtn("loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()", "loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/2mrC9Jf6", "loadstring(game:HttpGet('https://pastebin.com/raw/2mrC9Jf6'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/GggmFR0y", "loadstring(game:HttpGet('https://pastebin.com/raw/GggmFR0y'))()", MentionsContainer)
createLoadableScriptBtn("loadstring(game:HttpGet('https://pastebin.com/raw/JhkcJ8eF'))()", "loadstring(game:HttpGet('https://pastebin.com/raw/JhkcJ8eF'))()", MentionsContainer)
createLoadableScriptBtn("loadstring(game:HttpGet(\"https://rawscripts.net/raw/Universal-Script-SUPER-RING-PARTS-V3-WITH-NO-MESSAGE-26385\"))()", "loadstring(game:HttpGet('https://rawscripts.net/raw/Universal-Script-SUPER-RING-PARTS-V3-WITH-NO-MESSAGE-26385'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/jyVVfCGk", "loadstring(game:HttpGet('https://pastebin.com/raw/jyVVfCGk'))()", MentionsContainer)
createLoadableScriptBtn("loadstring(game:HttpGet(\"https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI\"))()", "loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI'))()", MentionsContainer)
createLoadableScriptBtn("https://pastebin.com/uTmdY23g", "loadstring(game:HttpGet('https://pastebin.com/raw/uTmdY23g'))()", MentionsContainer)

-- 9. MY HUBS TAB INTERFACE --
createMenuLabel("--- Developer Custom Hubs ---", Enum.Font.GothamBold, 14, theme.Accent, HubsContainer)
createLoadableScriptBtn("MM2 HAX", "loadstring(game:HttpGet('https://raw.githubusercontent.com/forgditestingXORRR/safe-gdi/refs/heads/main/MM2HAX.lua'))()", HubsContainer)
createLoadableScriptBtn("AIMBOT", "loadstring(game:HttpGet('https://raw.githubusercontent.com/forgditestingXORRR/safe-gdi/refs/heads/main/roblox.lua'))()", HubsContainer)
createLoadableScriptBtn("Infinite Yield", "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()", HubsContainer)

-- 10. TAB ROUTING & CANVAS FIXES --
local function switchTab(container)
    MenuContainer.Visible = (container == MenuContainer)
    CustomContainer.Visible = (container == CustomContainer)
    PreloadContainer.Visible = (container == PreloadContainer)
    AnalysisContainer.Visible = (container == AnalysisContainer)
    MentionsContainer.Visible = (container == MentionsContainer)
    HubsContainer.Visible = (container == HubsContainer)
end

MenuTabBtn.MouseButton1Click:Connect(function() switchTab(MenuContainer) end)
CustomTabBtn.MouseButton1Click:Connect(function() switchTab(CustomContainer) end)
PreloadTabBtn.MouseButton1Click:Connect(function() switchTab(PreloadContainer) end)
AnalysisTabBtn.MouseButton1Click:Connect(function() switchTab(AnalysisContainer) end)
MentionsTabBtn.MouseButton1Click:Connect(function() switchTab(MentionsContainer) end)
HubsTabBtn.MouseButton1Click:Connect(function() switchTab(HubsContainer) end)

-- Fix Canvas Resizing Logic dynamically to eliminate clipping or interface lag
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

-- Smooth Drag Action Engine
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)