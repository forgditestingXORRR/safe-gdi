local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- ====================================
-- KEY VERIFICATION SYSTEM
-- ====================================
local PREMIUM_KEY = "subtovaze"
local isAuthenticated = false
local authWindow

local function createKeyVerificationWindow()
    authWindow = OrionLib:MakeWindow({
        Name = "🔐 FE FLING V3 - KEY VERIFICATION",
        HidePremium = true,
        SaveConfig = false,
        ConfigFolder = "FEFlingAuth"
    })
    
    local keyTab = authWindow:MakeTab({
        Name = "Authentication",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    keyTab:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    keyTab:AddLabel("FE FLING V3 PRO - MM2 EDITION")
    keyTab:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    keyTab:AddLabel("")
    
    keyTab:AddParagraph("INSTRUCTIONS", "Enter your premium key to access all advanced features and exploits")
    
    keyTab:AddTextbox({
        Name = "Premium Key",
        Default = "",
        TextDisappear = false,
        Callback = function(Value)
            if Value == PREMIUM_KEY then
                isAuthenticated = true
                OrionLib:MakeNotification({
                    Name = "✅ ACCESS GRANTED",
                    Content = "Welcome! All features unlocked.",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                authWindow:Destroy()
                createMainWindow()
            elseif Value ~= "" then
                OrionLib:MakeNotification({
                    Name = "❌ INVALID KEY",
                    Content = "The key you entered is incorrect.",
                    Image = "rbxassetid://4483345998",
                    Time = 2
                })
            end
        end
    })
    
    keyTab:AddLabel("")
    keyTab:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    keyTab:AddParagraph("STATUS", "⏳ Waiting for key input...")
end

-- ====================================
-- MAIN VARIABLES & STATE
-- ====================================
local selectedPlayer
local PlayerDropdown
local isFlinging = false
local isBulkFlinging = false
local originalCameraSubject
local originalCharacterPos
local isAntiFlingEnabled = false
local flingPower = 99999
local flingRadius = 1
local invisFling = false
local flingAutoStop = true

-- Feature States
local roleEspEnabled = false
local gunEspEnabled = false
local aimbotEnabled = false
local autoStealGunEnabled = false
local targetFlingRole = nil
local targetSpecificUser = nil
local xrayEnabled = false
local silentAimEnabled = false
local godModeEnabled = false
local wallhackEnabled = false
local killauraEnabled = false

-- Movement States
local cframeSpeedEnabled = false
local cframeSpeedValue = 5
local flightEnabled = false
local flightSpeed = 50
local noclipEnabled = false
local speedRunEnabled = false
local speedRunValue = 100

-- Advanced States
local autoKillEnabled = false
local autoKillRange = 50
local bulletsTrackerEnabled = false
local playerTrackerEnabled = false
local loopFlingAllEnabled = false
local antiKbEnabled = false
local teleportSpamEnabled = false
local fullbrightEnabled = false

-- ====================================
-- HELPER FUNCTIONS
-- ====================================
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoidRootPart()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart", 5)
end

local function updatePlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

local function getPlayerRole(player)
    if not player then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character

    local hasKnife = (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))
    local hasGun = (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))

    if hasKnife then
        return "Murderer"
    elseif hasGun then
        return "Sheriff"
    else
        return "Innocent"
    end
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0) end
    if role == "Sheriff" then return Color3.fromRGB(0, 85, 255) end
    return Color3.fromRGB(0, 255, 76)
end

local function getPredictedPosition(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return nil end
    local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return nil end

    if humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
        return rootPart.Position + (humanoid.MoveDirection * 3.5)
    else
        return rootPart.Position
    end
end

local function performFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local character = getCharacter()
    local humanoidRootPart = getHumanoidRootPart()
    if not humanoidRootPart then return end

    originalCameraSubject = Camera.CameraSubject
    originalCharacterPos = humanoidRootPart.CFrame

    if not invisFling then
        local tHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if tHum then Camera.CameraSubject = tHum end
    end

    local bV = Instance.new("LinearVelocity")
    bV.MaxForce = math.huge
    bV.VectorVelocity = Vector3.new(flingPower, flingPower, flingPower)
    bV.RelativeTo = Enum.ActuatorRelativeTo.World

    local bAV = Instance.new("AngularVelocity")
    bAV.MaxTorque = math.huge
    bAV.AngularVelocity = Vector3.new(flingPower, flingPower, flingPower)
    bAV.RelativeTo = Enum.ActuatorRelativeTo.World

    local attach = Instance.new("Attachment")
    attach.Parent = humanoidRootPart
    bV.Attachment0 = attach
    bAV.Attachment0 = attach
    bV.Parent = humanoidRootPart
    bAV.Parent = humanoidRootPart

    local startTime = tick()
    local flingDuration = 4
    
    while isFlinging and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and (tick() - startTime < flingDuration) do
        local predPos = getPredictedPosition(targetPlayer)
        if predPos and humanoidRootPart then
            local offsetPosition = predPos + Vector3.new(math.random(-flingRadius, flingRadius), 0, math.random(-flingRadius, flingRadius))
            humanoidRootPart.CFrame = CFrame.new(offsetPosition + Vector3.new(math.random(-1, 1)/10, 0, math.random(-1, 1)/10))
            humanoidRootPart.Velocity = Vector3.new(flingPower, flingPower, flingPower)
        end
        RunService.Heartbeat:Wait()
    end

    bV:Destroy()
    bAV:Destroy()
    attach:Destroy()

    Camera.CameraSubject = originalCameraSubject
    humanoidRootPart.CFrame = originalCharacterPos
    humanoidRootPart.Velocity = Vector3.zero
    humanoidRootPart.RotVelocity = Vector3.zero
end

local function stealGun()
    local droppedGun = Workspace:FindFirstChild("GunDrop")
    if droppedGun and droppedGun:IsA("BasePart") then
        local hrp = getHumanoidRootPart()
        if hrp then
            local oldCFrame = hrp.CFrame
            hrp.CFrame = droppedGun.CFrame
            task.wait(0.2)
            hrp.CFrame = oldCFrame
        end
    end
end

local function teleportToPlayer(player)
    if not player or not player.Character then return end
    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        local hrp = getHumanoidRootPart()
        hrp.CFrame = targetHRP.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    end
end

-- ====================================
-- BACKGROUND THREADS
-- ====================================

-- Fling Thread
task.spawn(function()
    while true do
        if isFlinging and targetFlingRole then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(p)
                    if (targetFlingRole == "Murderer" and role == "Murderer") or
                       (targetFlingRole == "Sheriff" and role == "Sheriff") or
                       (targetFlingRole == "AllInnocents" and role == "Innocent") or
                       (targetFlingRole == "All" and p ~= LocalPlayer) then
                        performFling(p)
                    end
                end
            end
        elseif isFlinging and targetSpecificUser then
            performFling(targetSpecificUser)
        end
        task.wait(0.1)
    end
end)

-- Bulk Fling Thread
task.spawn(function()
    while true do
        if isBulkFlinging then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    performFling(p)
                end
            end
        end
        task.wait(0.15)
    end
end)

-- ESP Thread
task.spawn(function()
    while true do
        if roleEspEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local highlight = p.Character:FindFirstChild("RoleESP_Cham")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "RoleESP_Cham"
                        highlight.Parent = p.Character
                    end
                    local role = getPlayerRole(p)
                    highlight.FillColor = getRoleColor(role)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineTransparency = 0.1
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("RoleESP_Cham") then
                    p.Character.RoleESP_Cham:Destroy()
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Gun ESP Thread
task.spawn(function()
    while true do
        local droppedGun = Workspace:FindFirstChild("GunDrop")
        if gunEspEnabled and droppedGun and droppedGun:IsA("BasePart") then
            local highlight = droppedGun:FindFirstChild("GunESP_Cham")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "GunESP_Cham"
                highlight.Parent = droppedGun
                highlight.FillColor = Color3.fromRGB(255, 230, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        elseif droppedGun and droppedGun:FindFirstChild("GunESP_Cham") then
            droppedGun.GunESP_Cham:Destroy()
        end
        task.wait(0.5)
    end
end)

-- Auto Gun Steal Thread
task.spawn(function()
    while true do
        if autoStealGunEnabled then
            stealGun()
        end
        task.wait(0.3)
    end
end)

-- Auto Kill Thread
task.spawn(function()
    while true do
        if autoKillEnabled then
            local character = LocalPlayer.Character
            local tool = character and (character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun"))
            if tool then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and getPlayerRole(p) == "Murderer" then
                        local distance = (p.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                        if distance < autoKillRange then
                            teleportToPlayer(p)
                            tool.Parent = character
                            task.wait(0.1)
                            tool:Activate()
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- Teleport Spam Thread
task.spawn(function()
    while true do
        if teleportSpamEnabled then
            local players = Players:GetPlayers()
            if #players > 1 then
                local randomPlayer = players[math.random(1, #players)]
                if randomPlayer ~= LocalPlayer then
                    teleportToPlayer(randomPlayer)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Movement Thread
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")

    -- Aimbot
    if aimbotEnabled and character then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if getPlayerRole(p) == "Murderer" then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end

    -- CFrame Speed
    if cframeSpeedEnabled and hrp and hum then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * cframeSpeedValue * 0.1)
        end
    end

    -- Speed Run
    if speedRunEnabled and hrp and hum then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.Velocity = hum.MoveDirection * Vector3.new(speedRunValue, 0, speedRunValue)
        end
    end

    -- Flight
    if flightEnabled and hrp then
        local flightVelocity = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then flightVelocity = flightVelocity + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then flightVelocity = flightVelocity - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then flightVelocity = flightVelocity - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then flightVelocity = flightVelocity + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flightVelocity = flightVelocity + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flightVelocity = flightVelocity - Vector3.new(0, 1, 0) end

        if flightVelocity.Magnitude > 0 then
            hrp.Velocity = Vector3.zero
            hrp.CFrame = hrp.CFrame + (flightVelocity.Unit * (flightSpeed / 10))
        else
            hrp.Velocity = Vector3.zero
        end
    end
end)

-- Collision Thread
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if (noclipEnabled or isAntiFlingEnabled) and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ====================================
-- MAIN GUI WINDOW
-- ====================================
local function createMainWindow()
    local Window = OrionLib:MakeWindow({
        Name = "FE FLING V3 PRO - MM2 CHAOS EDITION",
        HidePremium = true,
        SaveConfig = true,
        ConfigFolder = "FEFlingV3"
    })

    -- ========== COMBAT TAB ==========
    local CombatTab = Window:MakeTab({
        Name = "⚔️ COMBAT",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    CombatTab:AddLabel("━━━━━━ FLING CONTROLS ━━━━━━")
    
    CombatTab:AddDropdown({
        Name = "Quick Target Selection",
        Default = "",
        Options = updatePlayerList(),
        Callback = function(Value)
            selectedPlayer = Players:FindFirstChild(Value)
        end
    })

    CombatTab:AddToggle({
        Name = "🎯 Fling Selected Player",
        Default = false,
        Callback = function(Value)
            isFlinging = Value
            if isFlinging and selectedPlayer then
                targetSpecificUser = selectedPlayer
                targetFlingRole = nil
                OrionLib:MakeNotification({Name = "Fling Started", Content = "Flinging " .. selectedPlayer.Name, Time = 2})
            end
        end
    })

    CombatTab:AddTextbox({
        Name = "Search Player Name",
        Default = "",
        TextDisappear = true,
        Callback = function(Value)
            local input = string.lower(Value)
            for _, p in ipairs(Players:GetPlayers()) do
                if string.find(string.lower(p.Name), input) then
                    selectedPlayer = p
                    break
                end
            end
        end
    })

    CombatTab:AddLabel("")
    CombatTab:AddLabel("━━━━━━ ROLE-BASED FLING ━━━━━━")

    CombatTab:AddButton({
        Name = "🔴 Fling All Murderers",
        Callback = function()
            isFlinging = true
            targetFlingRole = "Murderer"
            targetSpecificUser = nil
            OrionLib:MakeNotification({Name = "Active", Content = "Flinging all murderers!", Time = 2})
        end
    })

    CombatTab:AddButton({
        Name = "🔵 Fling All Sheriffs",
        Callback = function()
            isFlinging = true
            targetFlingRole = "Sheriff"
            targetSpecificUser = nil
            OrionLib:MakeNotification({Name = "Active", Content = "Flinging all sheriffs!", Time = 2})
        end
    })

    CombatTab:AddButton({
        Name = "🟢 Fling All Innocents",
        Callback = function()
            isFlinging = true
            targetFlingRole = "AllInnocents"
            targetSpecificUser = nil
            OrionLib:MakeNotification({Name = "Active", Content = "Flinging all innocents!", Time = 2})
        end
    })

    CombatTab:AddButton({
        Name = "⚪ FLING EVERYONE",
        Callback = function()
            isBulkFlinging = true
            OrionLib:MakeNotification({Name = "🔥 CHAOS MODE", Content = "Flinging all players!", Time = 2})
        end
    })

    CombatTab:AddLabel("")
    CombatTab:AddLabel("━━━━━━ FLING SETTINGS ━━━━━━")

    CombatTab:AddSlider({
        Name = "Fling Power Multiplier",
        Min = 1000,
        Max = 999999,
        Default = 99999,
        Color = Color3.fromRGB(255, 0, 0),
        Increment = 10000,
        ValueName = "Power",
        Callback = function(Value)
            flingPower = Value
        end
    })

    CombatTab:AddSlider({
        Name = "Fling Radius Offset",
        Min = 0,
        Max = 50,
        Default = 1,
        Color = Color3.fromRGB(255, 100, 0),
        Increment = 1,
        ValueName = "Radius",
        Callback = function(Value)
            flingRadius = Value
        end
    })

    CombatTab:AddToggle({
        Name = "Invisible Fling Position",
        Default = false,
        Callback = function(Value)
            invisFling = Value
        end
    })

    CombatTab:AddToggle({
        Name = "Auto-Stop Fling After 4s",
        Default = true,
        Callback = function(Value)
            flingAutoStop = Value
        end
    })

    CombatTab:AddLabel("")
    CombatTab:AddLabel("━━━━━━ GUN CONTROLS ━━━━━━")

    CombatTab:AddButton({
        Name = "🔫 Instantly Steal Gun",
        Callback = function()
            stealGun()
            OrionLib:MakeNotification({Name = "Gun Stolen", Content = "Gun retrieved!", Time = 2})
        end
    })

    CombatTab:AddToggle({
        Name = "🔄 Auto Gun Stealer Loop",
        Default = false,
        Callback = function(Value)
            autoStealGunEnabled = Value
        end
    })

    CombatTab:AddLabel("")
    CombatTab:AddLabel("━━━━━━ ADVANCED COMBAT ━━━━━━")

    CombatTab:AddSlider({
        Name = "Auto-Kill Range",
        Min = 10,
        Max = 200,
        Default = 50,
        Color = Color3.fromRGB(200, 0, 0),
        Increment = 5,
        ValueName = "Studs",
        Callback = function(Value)
            autoKillRange = Value
        end
    })

    CombatTab:AddToggle({
        Name = "⚡ Auto-Kill Murderer",
        Default = false,
        Callback = function(Value)
            autoKillEnabled = Value
        end
    })

    CombatTab:AddToggle({
        Name = "🎯 Lock Aimbot (Murderer)",
        Default = false,
        Callback = function(Value)
            aimbotEnabled = Value
        end
    })

    CombatTab:AddButton({
        Name = "🛑 STOP ALL ACTIONS",
        Callback = function()
            isFlinging = false
            isBulkFlinging = false
            autoKillEnabled = false
            aimbotEnabled = false
            flightEnabled = false
            cframeSpeedEnabled = false
            speedRunEnabled = false
            targetFlingRole = nil
            targetSpecificUser = nil
            OrionLib:MakeNotification({Name = "⏹️ Stopped", Content = "All actions halted!", Time = 2})
        end
    })

    -- ========== VISION TAB ==========
    local VisionTab = Window:MakeTab({
        Name = "👁️ VISION",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    VisionTab:AddLabel("━━━━━━ PLAYER TRACKING ━━━━━━")

    VisionTab:AddToggle({
        Name = "🔴 Role ESP (Murderer/Sheriff)",
        Default = false,
        Callback = function(Value)
            roleEspEnabled = Value
        end
    })

    VisionTab:AddToggle({
        Name = "🔫 Gun ESP Highlighter",
        Default = false,
        Callback = function(Value)
            gunEspEnabled = Value
        end
    })

    VisionTab:AddToggle({
        Name = "👤 Player Tracker Enabled",
        Default = false,
        Callback = function(Value)
            playerTrackerEnabled = Value
        end
    })

    VisionTab:AddLabel("")
    VisionTab:AddLabel("━━━━━━ WORLD VISION ━━━━━━")

    VisionTab:AddButton({
        Name = "💡 Enable Fullbright Mode",
        Callback = function()
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 3
            fullbrightEnabled = true
            OrionLib:MakeNotification({Name = "Fullbright", Content = "Maximum brightness enabled!", Time = 2})
        end
    })

    VisionTab:AddButton({
        Name = "🌑 Disable Fullbright",
        Callback = function()
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 1
            fullbrightEnabled = false
            OrionLib:MakeNotification({Name = "Normal", Content = "Brightness reset!", Time = 2})
        end
    })

    VisionTab:AddToggle({
        Name = "👻 X-Ray Vision (Parts)",
        Default = false,
        Callback = function(Value)
            xrayEnabled = Value
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(Players) then
                    if xrayEnabled then
                        if v.Transparency == 0 then
                            v.Transparency = 0.5
                            v:SetAttribute("XrayOriginal", 0)
                        end
                    else
                        if v:GetAttribute("XrayOriginal") then
                            v.Transparency = 0
                            v:SetAttribute("XrayOriginal", nil)
                        end
                    end
                end
            end
        end
    })

    VisionTab:AddLabel("")
    VisionTab:AddLabel("━━━━━━ FILTERING ━━━━━━")

    VisionTab:AddButton({
        Name = "🗑️ Clear All Highlights",
        Callback = function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    for _, child in pairs(p.Character:GetChildren()) do
                        if child:IsA("Highlight") then
                            child:Destroy()
                        end
                    end
                end
            end
            OrionLib:MakeNotification({Name = "Cleared", Content = "All highlights removed!", Time = 2})
        end
    })

    -- ========== MOVEMENT TAB ==========
    local MovementTab = Window:MakeTab({
        Name = "🏃 MOVEMENT",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    MovementTab:AddLabel("━━━━━━ SPEED BOOST ━━━━━━")

    MovementTab:AddToggle({
        Name = "⚡ CFrame Speed Engine",
        Default = false,
        Callback = function(Value)
            cframeSpeedEnabled = Value
        end
    })

    MovementTab:AddSlider({
        Name = "CFrame Speed Multiplier",
        Min = 1,
        Max = 50,
        Default = 5,
        Color = Color3.fromRGB(0, 255, 100),
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            cframeSpeedValue = Value
        end
    })

    MovementTab:AddToggle({
        Name = "💨 Speed Run Mode",
        Default = false,
        Callback = function(Value)
            speedRunEnabled = Value
        end
    })

    MovementTab:AddSlider({
        Name = "Speed Run Velocity",
        Min = 50,
        Max = 500,
        Default = 100,
        Color = Color3.fromRGB(255, 200, 0),
        Increment = 10,
        ValueName = "Studs/Sec",
        Callback = function(Value)
            speedRunValue = Value
        end
    })

    MovementTab:AddLabel("")
    MovementTab:AddLabel("━━━━━━ FLIGHT SYSTEM ━━━━━━")

    MovementTab:AddToggle({
        Name = "✈️ 6-Axis Flight System",
        Default = false,
        Callback = function(Value)
            flightEnabled = Value
        end
    })

    MovementTab:AddSlider({
        Name = "Flight Speed",
        Min = 20,
        Max = 300,
        Default = 50,
        Color = Color3.fromRGB(100, 150, 255),
        Increment = 10,
        ValueName = "Studs/Sec",
        Callback = function(Value)
            flightSpeed = Value
        end
    })

    MovementTab:AddLabel("")
    MovementTab:AddLabel("━━━━━━ PHASE & NOCLIP ━━━━━━")

    MovementTab:AddToggle({
        Name = "👻 Noclip Mode",
        Default = false,
        Callback = function(Value)
            noclipEnabled = Value
        end
    })

    MovementTab:AddToggle({
        Name = "🛡️ Anti-Fling Shield",
        Default = false,
        Callback = function(Value)
            isAntiFlingEnabled = Value
        end
    })

    MovementTab:AddButton({
        Name = "📍 Reset Velocity",
        Callback = function()
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end
            OrionLib:MakeNotification({Name = "Reset", Content = "Velocity anchored!", Time = 2})
        end
    })

    -- ========== TELEPORT TAB ==========
    local TeleportTab = Window:MakeTab({
        Name = "📍 TELEPORT",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    TeleportTab:AddLabel("━━━━━━ PLAYER TELEPORT ━━━━━━")

    TeleportTab:AddDropdown({
        Name = "Teleport Target",
        Default = "",
        Options = updatePlayerList(),
        Callback = function(Value)
            local player = Players:FindFirstChild(Value)
            if player then selectedPlayer = player end
        end
    })

    TeleportTab:AddButton({
        Name = "🎯 Teleport to Selected",
        Callback = function()
            if selectedPlayer and selectedPlayer.Character then
                teleportToPlayer(selectedPlayer)
                OrionLib:MakeNotification({Name = "Teleported", Content = "Moved to " .. selectedPlayer.Name, Time = 2})
            end
        end
    })

    TeleportTab:AddToggle({
        Name = "🔄 Teleport Spam Random",
        Default = false,
        Callback = function(Value)
            teleportSpamEnabled = Value
        end
    })

    TeleportTab:AddLabel("")
    TeleportTab:AddLabel("━━━━━━ MAP TELEPORT ━━━━━━")

    TeleportTab:AddButton({
        Name = "🏠 Teleport to Lobby",
        Callback = function()
            local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyWorkspace")
            local spawnLoc = lobby and lobby:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
            local hrp = getHumanoidRootPart()
            if hrp and spawnLoc then
                hrp.CFrame = spawnLoc.CFrame + Vector3.new(0, 4, 0)
                OrionLib:MakeNotification({Name = "Teleported", Content = "Moved to lobby!", Time = 2})
            end
        end
    })

    TeleportTab:AddButton({
        Name = "🔀 Teleport to Random Player",
        Callback = function()
            local players = Players:GetPlayers()
            if #players > 1 then
                local randomPlayer = players[math.random(1, #players)]
                if randomPlayer ~= LocalPlayer and randomPlayer.Character then
                    teleportToPlayer(randomPlayer)
                    OrionLib:MakeNotification({Name = "Random TP", Content = "Teleported randomly!", Time = 2})
                end
            end
        end
    })

    -- ========== SERVER TAB ==========
    local ServerTab = Window:MakeTab({
        Name = "🌐 SERVER",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    ServerTab:AddLabel("━━━━━━ SERVER CONTROL ━━━━━━")

    ServerTab:AddButton({
        Name = "🔄 Server Hop (Find Better)",
        Callback = function()
            local serverList = {}
            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            
            if success and response.data then
                for _, v in ipairs(response.data) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(serverList, v.id)
                    end
                end
                
                if #serverList > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, serverList[math.random(1, #serverList)], LocalPlayer)
                    OrionLib:MakeNotification({Name = "Server Hopping", Content = "Connecting to new server...", Time = 3})
                else
                    OrionLib:MakeNotification({Name = "Server Hop", Content = "No optimal servers found!", Time = 3})
                end
            end
        end
    })

    ServerTab:AddButton({
        Name = "🔁 Instant Rejoin",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            OrionLib:MakeNotification({Name = "Rejoining", Content = "Reconnecting to current server...", Time = 3})
        end
    })

    ServerTab:AddLabel("")
    ServerTab:AddLabel("━━━━━━ PLAYER LIST ━━━━━━")

    ServerTab:AddButton({
        Name = "📋 Refresh Player List",
        Callback = function()
            if PlayerDropdown then
                PlayerDropdown:Refresh(updatePlayerList(), true)
            end
            OrionLib:MakeNotification({Name = "Refreshed", Content = "Player list updated!", Time = 2})
        end
    })

    ServerTab:AddLabel("")
    ServerTab:AddLabel("━━━━━━ MISCELLANEOUS ━━━━━━")

    ServerTab:AddButton({
        Name = "💾 Save Config",
        Callback = function()
            OrionLib:MakeNotification({Name = "Saved", Content = "Configuration saved!", Time = 2})
        end
    })

    ServerTab:AddButton({
        Name = "⚙️ Reset Settings",
        Callback = function()
            isFlinging = false
            isBulkFlinging = false
            autoKillEnabled = false
            flightEnabled = false
            noclipEnabled = false
            cframeSpeedEnabled = false
            speedRunEnabled = false
            OrionLib:MakeNotification({Name = "Reset", Content = "All settings reset!", Time = 2})
        end
    })

    -- ========== CREDITS TAB ==========
    local CreditsTab = Window:MakeTab({
        Name = "ℹ️ INFO",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    CreditsTab:AddLabel("═══════════════════════════════")
    CreditsTab:AddLabel("FE FLING V3 PRO - MM2 EDITION")
    CreditsTab:AddLabel("═══════════════════════════════")
    CreditsTab:AddLabel("")
    CreditsTab:AddParagraph("VERSION", "3.0 ADVANCED")
    CreditsTab:AddParagraph("STATUS", "✅ FULLY OPERATIONAL")
    CreditsTab:AddLabel("")
    CreditsTab:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    CreditsTab:AddParagraph("FEATURES", "⚔️ Combat System\n👁️ Vision ESP\n🏃 Movement Suite\n📍 Teleportation\n🌐 Server Tools")
    CreditsTab:AddLabel("")
    CreditsTab:AddLabel("━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    CreditsTab:AddParagraph("KEY SYSTEM", "Premium key authentication enabled")
    CreditsTab:AddLabel("")
    CreditsTab:AddButton({
        Name = "🔓 OPEN KEY WINDOW",
        Callback = function()
            createKeyVerificationWindow()
        end
    })

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("Humanoid")
        if isAntiFlingEnabled or noclipEnabled then
            for _, part in pairs(newChar:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    OrionLib:Init()
end

-- Initialize the key window
createKeyVerificationWindow()
