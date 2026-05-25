local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
 
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
 
-- Premium usernames list
local premiumUsernames = {
    "0Tripyxman0"
}
 
-- Function to check if the local player is a premium user
local function isPremiumUser()
    local player = LocalPlayer
    if player then
        for _, username in ipairs(premiumUsernames) do
            if player.Name == username then
                return true
            end
        end
    end
    return false
end
 
-- Notify premium users
if isPremiumUser() then
    OrionLib:MakeNotification({
        Name = "Premium Access",
        Content = "Enjoy premium features, fellow teammate!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end
 
local Window = OrionLib:MakeWindow({Name = "FE Fling v3 Pro - MM2 Chaos Edition", HidePremium = true, SaveConfig = true, ConfigFolder = "FEFlingV3"})

-- Advanced Tabs Expansion
local MM2Tab = Window:MakeTab({Name = "MM2 Game Toolkit", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FlingTab = Window:MakeTab({Name = "Fling Matrix", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AntiVoidTab = Window:MakeTab({Name = "Anti-Void Zone", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AntiFlingTab = Window:MakeTab({Name = "Anti-Fling Shield", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MovementTab = Window:MakeTab({Name = "CFrame Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualsTab = Window:MakeTab({Name = "Visuals & ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscTab = Window:MakeTab({Name = "Server Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
 
local selectedPlayer
local PlayerDropdown
local isFlinging = false
local originalCameraSubject
local originalCharacterPos
local isAntiFlingEnabled = false
local flingPower = 99999
local flingRadius = 1
local invisFling = false

-- Feature States
local roleEspEnabled = false
local gunEspEnabled = false
local aimbotEnabled = false
local autoStealGunEnabled = false
local targetFlingRole = nil 
local targetSpecificUser = nil
local xrayEnabled = false
local silentAimEnabled = false
local loopKillAllEnabled = false

-- Movement States
local cframeSpeedEnabled = false
local cframeSpeedValue = 5
local flightEnabled = false
local flightSpeed = 50
local noclipEnabled = false

-- Function to safely get character and parts
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
 
local function getHumanoidRootPart()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart", 5)
end
 
-- Dynamic player list updates
local function updatePlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- Helper functions to accurately parse MM2 roles
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
    return Color3.fromRGB(0, 255, 76) -- Innocent
end

-- Positional movement prediction for high-speed tracking targets
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

-- Advanced Fling Core Mechanics Implementation
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
    
    -- Linear Vector manipulation bypass loops
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
    while isFlinging and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and (tick() - startTime < 4) do
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

-- Global Thread Handlers
task.spawn(function()
    while true do
        if isFlinging and targetFlingRole then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(p)
                    if (targetFlingRole == "Murderer" and role == "Murderer") or
                       (targetFlingRole == "Sheriff" and role == "Sheriff") or
                       (targetFlingRole == "AllInnocents" and role == "Innocent") then
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

-- Visual Tracker Thread
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

-- Dropped Gun Finder Thread
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

-- Gun Fetch Utility Execution
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

task.spawn(function()
    while true do
        if autoStealGunEnabled then
            stealGun()
        end
        task.wait(0.3)
    end
end)

-- Frame Update Connections (Noclip, CFrame Speed, Flight Engine, Aimbot Loops)
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    
    -- Camera Lock Aimbot Logic
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

    -- Advanced Custom CFrame Speed Engine
    if cframeSpeedEnabled and hrp and hum then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * cframeSpeedValue * 0.1)
        end
    end

    -- Universal Flight Matrix Engine
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

-- Collision Phase Loop Handler
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

--- ==========================================================
--- TAB COMPONENTS & BUTTON INJECTIONS
--- ==========================================================

-- MM2 ADVANCED MANAGEMENT TAB
MM2Tab:AddToggle({
    Name = "Role ESP (Chams)",
    Default = false,
    Callback = function(Value) roleEspEnabled = Value end
})

MM2Tab:AddToggle({
    Name = "Dropped Gun ESP",
    Default = false,
    Callback = function(Value) gunEspEnabled = Value end
})

MM2Tab:AddToggle({
    Name = "Murderer Lock Aimbot",
    Default = false,
    Callback = function(Value) aimbotEnabled = Value end
})

MM2Tab:AddButton({
    Name = "Instantly Retrieve Gun",
    Callback = function() stealGun() end
})

MM2Tab:AddToggle({
    Name = "Auto-Collect Gun Loop",
    Default = false,
    Callback = function(Value) autoStealGunEnabled = Value end
})

MM2Tab:AddButton({
    Name = "Teleport to Safe Lobby",
    Callback = function()
        local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyWorkspace")
        local spawnLoc = lobby and lobby:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
        local hrp = getHumanoidRootPart()
        if hrp and spawnLoc then hrp.CFrame = spawnLoc.CFrame + Vector3.new(0, 4, 0) end
    end
})

MM2Tab:AddButton({
    Name = "Fling Active Murderer",
    Callback = function()
        isFlinging = true
        targetFlingRole = "Murderer"
        targetSpecificUser = nil
    end
})

MM2Tab:AddButton({
    Name = "Fling Active Sheriff",
    Callback = function()
        isFlinging = true
        targetFlingRole = "Sheriff"
        targetSpecificUser = nil
    end
})

MM2Tab:AddButton({
    Name = "Kill/Fling Innocents",
    Callback = function()
        isFlinging = true
        targetFlingRole = "AllInnocents"
        targetSpecificUser = nil
    end
})

MM2Tab:AddButton({
    Name = "Auto-Kill Murderer (Requires Gun)",
    Callback = function()
        local character = getCharacter()
        local tool = character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if not tool then
            OrionLib:MakeNotification({Name = "Error", Content = "You must hold or own the Gun!", Time = 3})
            return
        end
        local targetMurd
        for _, p in ipairs(Players:GetPlayers()) do
            if getPlayerRole(p) == "Murderer" then targetMurd = p break end
        end
        if targetMurd and targetMurd.Character and targetMurd.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHumanoidRootPart()
            tool.Parent = character
            hrp.CFrame = targetMurd.Character.HumanoidRootPart.CFrame + (targetMurd.Character.HumanoidRootPart.CFrame.LookVector * -4)
            task.wait(0.1)
            tool:Activate()
        end
    end
})

-- UNIVERSAL FLING CONFIGURATION MATRIX TAB
PlayerDropdown = FlingTab:AddDropdown({
    Name = "Target User Profile",
    Default = "",
    Options = updatePlayerList(),
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value)
    end    
})
 
FlingTab:AddToggle({
    Name = "Fling Selected Target",
    Default = false,
    Callback = function(Value)
        isFlinging = Value
        if isFlinging then
            if selectedPlayer then
                targetSpecificUser = selectedPlayer
                targetFlingRole = nil
            else
                OrionLib:MakeNotification({Name = "Target Null", Content = "Select a target profile first!", Time = 3})
            end
        end
    end,
})

FlingTab:AddTextbox({
    Name = "Target Username Search",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        local input = string.lower(Value)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.find(string.lower(p.Name), input) or string.find(string.lower(p.DisplayName), input) then
                isFlinging = true
                targetSpecificUser = p
                targetFlingRole = nil
                break
            end
        end
    end
})
 
FlingTab:AddTextbox({
    Name = "Fling Velocity Power",
    Default = "99999",
    TextDisappear = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val then flingPower = val end
    end,
})
 
FlingTab:AddTextbox({
    Name = "Fling Sweep Radius",
    Default = "1",
    TextDisappear = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val then flingRadius = val end
    end,
})
 
FlingTab:AddToggle({
    Name = "Invisible Position Fling",
    Default = false,
    Callback = function(Value) invisFling = Value end,
})

FlingTab:AddButton({
    Name = "🛑 EMERGENCY SHUTDOWN ALL ACTION",
    Callback = function()
        isFlinging = false
        targetFlingRole = nil
        targetSpecificUser = nil
        autoStealGunEnabled = false
        aimbotEnabled = false
        flightEnabled = false
        cframeSpeedEnabled = false
    end
})

-- ANTI-VOID ZONE TAB
local antiVoidPart 
local function createAntiVoid() 
    if antiVoidPart then return end 
    antiVoidPart = Instance.new("Part") 
    antiVoidPart.Name = "SafetyAntiVoid" 
    antiVoidPart.Size = Vector3.new(3000, 2, 3000) 
    antiVoidPart.Anchored = true 
    antiVoidPart.Transparency = 0.6 
    antiVoidPart.CanCollide = true  
    antiVoidPart.BrickColor = BrickColor.new("Crimson")  
 
    local lowestY = 0 
    for _, part in pairs(Workspace:GetDescendants()) do 
        if part:IsA("BasePart") and part.Position.Y < lowestY then   
            lowestY = part.Position.Y 
        end  
    end  
    antiVoidPart.Position = Vector3.new(0, lowestY - 20, 0)  
    antiVoidPart.Parent = Workspace  
end 
 
local function removeAntiVoid() 
    if antiVoidPart then  
        antiVoidPart:Destroy()  
        antiVoidPart = nil  
    end  
end 
 
AntiVoidTab:AddToggle({ 
    Name = "Anti-Void Floor Safety Plate", 
    Default = false, 
    Callback = function(Value)  
        if Value then createAntiVoid() else removeAntiVoid() end  
    end  
})

-- ANTI-FLING COLLISION TAB
AntiFlingTab:AddToggle({ 
    Name = "Desync Anti-Fling Matrix", 
    Default = false, 
    Callback = function(Value)  
        isAntiFlingEnabled = Value  
    end  
})

AntiFlingTab:AddButton({
    Name = "Instant Velocity Anchor Fix",
    Callback = function()
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
})

-- ADVANCED MOVEMENT ENGINE TAB
MovementTab:AddToggle({
    Name = "Enable Advanced CFrame Speed",
    Default = false,
    Callback = function(Value) cframeSpeedEnabled = Value end
})

MovementTab:AddSlider({
    Name = "CFrame Step Multiplier",
    Min = 1,
    Max = 30,
    Default = 5,
    Color = Color3.fromRGB(255, 136, 0),
    Increment = 1,
    ValueName = "Velocity Multiplier",
    Callback = function(Value) cframeSpeedValue = Value end
})

MovementTab:AddToggle({
    Name = "Noclip Physics Phase",
    Default = false,
    Callback = function(Value) noclipEnabled = Value end
})

MovementTab:AddToggle({
    Name = "6-Axis Camera Flight System",
    Default = false,
    Callback = function(Value) flightEnabled = Value end
})

MovementTab:AddSlider({
    Name = "Flight Cruise Velocity",
    Min = 20,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(0, 183, 255),
    Increment = 5,
    ValueName = "Studs/Sec",
    Callback = function(Value) flightSpeed = Value end
})

-- VISUALS & WORLD ENGINE TAB
VisualsTab:AddToggle({
    Name = "Map X-Ray Framework",
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

VisualsTab:AddButton({
    Name = "Maximize Ambient Fullbright",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 3
    end
})

-- MISC TAB Essentials
MiscTab:AddButton({ 
    Name = "Phase Teleport to Random Player", 
    Callback = function() 
        local plrs = Players:GetPlayers() 
        local rand = plrs[math.random(1, #plrs)] 
        if rand ~= LocalPlayer and rand.Character and rand.Character:FindFirstChild("HumanoidRootPart") then 
            local hrp = getHumanoidRootPart()
            if hrp then hrp.CFrame = rand.Character.HumanoidRootPart.CFrame end
        end     
    end     
})

MiscTab:AddButton({
    Name = "Server Hop Instant Reconnect",
    Callback = function()
        local serverList = {}
        for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(serverList, v.id)
            end
        end
        if #serverList > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverList[math.random(1, #serverList)], LocalPlayer)
        else
            OrionLib:MakeNotification({Name = "Teleport Warning", Content = "No alternative optimal instances discovered.", Time = 3})
        end
    end
})

MiscTab:AddButton({
    Name = "Instant Rejoin Active Session",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- Realtime Sync Context Update Loops
local function runAutoRefreshDropdown()
    while true do 
        PlayerDropdown:Refresh(updatePlayerList(), true) 
        task.wait(2) 
    end 
end
task.spawn(runAutoRefreshDropdown)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Humanoid")
    if isAntiFlingEnabled or noclipEnabled then
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
 
OrionLib:Init()
