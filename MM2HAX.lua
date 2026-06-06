local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local premiumUsernames = {
    "0Tripyxman0"
}

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

local function Notify(title, text, duration)
    OrionLib:MakeNotification({
        Name = title,
        Content = text,
        Image = "rbxassetid://4483345998",
        Time = duration or 3
    })
end

local function sendChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if textChannel then
                textChannel:SendAsync(msg)
            end
        else
            local sayMsgEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if sayMsgEvent and sayMsgEvent:FindFirstChild("SayMessageRequest") then
                sayMsgEvent.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

if isPremiumUser() then
    Notify("Premium Access", "Enjoy premium features, fellow teammate!", 5)
end

local Window = OrionLib:MakeWindow({Name = "FE Fling v3 Pro - MM2 Chaos Edition", HidePremium = true, SaveConfig = true, ConfigFolder = "FEFlingV3"})

local MM2Tab = Window:MakeTab({Name = "MM2 Game Toolkit", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FlingTab = Window:MakeTab({Name = "Fling Matrix", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FEAbilitiesTab = Window:MakeTab({Name = "FE Abilities", Icon = "rbxassetid://4483345998", PremiumOnly = false})
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
local invisFling = false
local roleEspEnabled = false
local gunEspEnabled = false
local aimbotEnabled = false
local autoStealGunEnabled = false
local targetFlingRole = nil
local targetSpecificUser = nil
local xrayEnabled = false
local cframeSpeedEnabled = false
local cframeSpeedValue = 5
local flightEnabled = false
local flightSpeed = 50
local noclipEnabled = false
local godModeEnabled = false
local seizureModeEnabled = false
local fakeLagEnabled = false

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoidRootPart()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart", 5)
end

local function enableGodMode()
    spawn(function()
        while godModeEnabled do
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end
            end
            task.wait(0.1)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if godModeEnabled then
        task.wait(0.5)
        enableGodMode()
    end
end)

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
    if hasKnife then return "Murderer"
    elseif hasGun then return "Sheriff"
    else return "Innocent" end
end

local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0) end
    if role == "Sheriff" then return Color3.fromRGB(0, 85, 255) end
    return Color3.fromRGB(0, 255, 76)
end

local function performFling(targetPlayer, durationOverride)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local character = getCharacter()
    local humanoidRootPart = getHumanoidRootPart()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not targetHRP or not humanoidRootPart or not humanoid or not targetHum or targetHum.Health <= 0 then return end
    
    originalCameraSubject = Camera.CameraSubject
    originalCharacterPos = humanoidRootPart.CFrame
    if not invisFling then
        Camera.CameraSubject = targetHum
    end

    humanoid.PlatformStand = true

    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, flingPower, 0)
    bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyAngularVelocity.Parent = humanoidRootPart

    local duration = durationOverride or 3
    local startTime = tick()
    
    while isFlinging and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetHum.Health > 0 and (tick() - startTime < duration) do
        task.wait()
        if humanoidRootPart and targetHRP then
            local velocityOffset = targetHRP.Velocity * 0.125
            local predictedCFrame = targetHRP.CFrame + velocityOffset
            
            humanoidRootPart.CFrame = predictedCFrame * CFrame.Angles(0, 0, math.rad(90))
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        else
            break
        end
    end

    bodyAngularVelocity:Destroy()
    humanoid.PlatformStand = false
    
    Camera.CameraSubject = originalCameraSubject
    humanoidRootPart.CFrame = originalCharacterPos
    humanoidRootPart.Velocity = Vector3.zero
    humanoidRootPart.RotVelocity = Vector3.zero
end

local function flingAllPlayersLoop()
    isFlinging = true
    Notify("Fling All", "Starting 500ms cycle on all players", 3)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isFlinging then
            performFling(p, 0.5)
        end
    end
    Notify("Fling All", "Fling cycle complete", 3)
    isFlinging = false
end

task.spawn(function()
    while true do
        if isFlinging and targetFlingRole then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(p)
                    if (targetFlingRole == "Murderer" and role == "Murderer") or
                       (targetFlingRole == "Sheriff" and role == "Sheriff") or
                       (targetFlingRole == "AllInnocents" and role == "Innocent") then
                        performFling(p, 3)
                    end
                end
            end
        elseif isFlinging and targetSpecificUser then
            performFling(targetSpecificUser, 3)
        end
        task.wait(0.1)
    end
end)

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

local function stealGun()
    local droppedGun = Workspace:FindFirstChild("GunDrop")
    if droppedGun and droppedGun:IsA("BasePart") then
        local hrp = getHumanoidRootPart()
        if hrp then
            local oldCFrame = hrp.CFrame
            hrp.CFrame = droppedGun.CFrame
            task.wait(0.2)
            hrp.CFrame = oldCFrame
            Notify("Gun Stolen", "Teleported to dropped gun", 2)
        end
    end
end

task.spawn(function()
    while true do
        if autoStealGunEnabled then stealGun() end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        if seizureModeEnabled then
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)))
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if fakeLagEnabled then
            local hrp = getHumanoidRootPart()
            if hrp then
                hrp.Anchored = true
                task.wait(math.random(1, 3) / 10)
                hrp.Anchored = false
            end
        end
        task.wait(math.random(2, 5) / 10)
    end
end)

RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")
   
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
    if cframeSpeedEnabled and hrp and hum then
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * cframeSpeedValue * 0.1)
        end
    end
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

MM2Tab:AddButton({
    Name = "Reveal Roles in Chat (Sheriff & Murd)",
    Callback = function()
        local murdererName = "[None Detected]"
        local sheriffName = "[None Detected]"
        
        for _, p in ipairs(Players:GetPlayers()) do
            local role = getPlayerRole(p)
            if role == "Murderer" then
                murdererName = p.Name
            elseif role == "Sheriff" then
                sheriffName = p.Name
            end
        end
        
        local chatMessage = " The Murderer is " .. murdererName .. " | The Sheriff is " .. sheriffName
        sendChatMessage(chatMessage)
        Notify("Roles Exposed", "Message broadcasted to server chat!", 4)
    end
})

MM2Tab:AddToggle({ Name = "Role ESP (Chams)", Default = false, Callback = function(Value) roleEspEnabled = Value Notify("ESP", "Role ESP set to " .. tostring(Value)) end })
MM2Tab:AddToggle({ Name = "Dropped Gun ESP", Default = false, Callback = function(Value) gunEspEnabled = Value Notify("ESP", "Gun ESP set to " .. tostring(Value)) end })
MM2Tab:AddToggle({ Name = "Murderer Lock Aimbot", Default = false, Callback = function(Value) aimbotEnabled = Value Notify("Aimbot", "Murderer Lock set to " .. tostring(Value)) end })
MM2Tab:AddButton({ Name = "Instantly Retrieve Gun", Callback = function() stealGun() end })
MM2Tab:AddToggle({ Name = "Auto-Collect Gun Loop", Default = false, Callback = function(Value) autoStealGunEnabled = Value Notify("Auto", "Auto-Collect Gun set to " .. tostring(Value)) end })

MM2Tab:AddButton({
    Name = "Teleport to Safe Lobby",
    Callback = function()
        local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyWorkspace")
        local spawnLoc = lobby and lobby:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
        local hrp = getHumanoidRootPart()
        if hrp and spawnLoc then 
            hrp.CFrame = spawnLoc.CFrame + Vector3.new(0, 4, 0) 
            Notify("Teleport", "Moved to Lobby")
        end
    end
})

MM2Tab:AddButton({ Name = "Fling Active Murderer", Callback = function() isFlinging = true targetFlingRole = "Murderer" targetSpecificUser = nil Notify("Fling", "Targeting Murderer") end })
MM2Tab:AddButton({ Name = "Fling Active Sheriff", Callback = function() isFlinging = true targetFlingRole = "Sheriff" targetSpecificUser = nil Notify("Fling", "Targeting Sheriff") end })

MM2Tab:AddButton({
    Name = "Auto-Kill Murderer (Requires Gun)",
    Callback = function()
        local character = getCharacter()
        local tool = character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if not tool then
            Notify("Error", "You must hold or own the Gun!", 3)
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
            Notify("Auto-Kill", "Shot fired at Murderer")
        else
            Notify("Status", "No Murderer found")
        end
    end
})

PlayerDropdown = FlingTab:AddDropdown({
    Name = "Target User Profile",
    Default = "",
    Options = updatePlayerList(),
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value)
        Notify("Selection", "Target set to " .. tostring(Value))
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
                Notify("Fling", "Engaging target")
            else
                Notify("Target Null", "Select a target profile first!", 3)
                isFlinging = false
            end
        else
            Notify("Fling", "Fling Stopped")
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
                Notify("Fling", "Engaged target: " .. p.Name)
                break
            end
        end
    end
})

FlingTab:AddButton({ Name = "FE Fling All (500ms Cycle)", Callback = function() task.spawn(flingAllPlayersLoop) end })
FlingTab:AddToggle({ Name = "Invisible Position Fling", Default = false, Callback = function(Value) invisFling = Value Notify("Fling", "Invisible Camera set to " .. tostring(Value)) end })

FlingTab:AddButton({
    Name = "EMERGENCY SHUTDOWN ALL ACTION",
    Callback = function()
        isFlinging = false
        targetFlingRole = nil
        targetSpecificUser = nil
        autoStealGunEnabled = false
        aimbotEnabled = false
        flightEnabled = false
        cframeSpeedEnabled = false
        seizureModeEnabled = false
        fakeLagEnabled = false
        local hrp = getHumanoidRootPart()
        if hrp then hrp.Anchored = false end
        Notify("SHUTDOWN", "All active systems terminated")
    end
})

local seatTeleportPosition = Vector3.new(-25.95, 400, 3537.55)
local invis_on = false

FEAbilitiesTab:AddToggle({
    Name = "FE Invisible (Seat Method)",
    Default = false,
    Callback = function(Value)
        invis_on = Value
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        
        if invis_on then
            if humanoidRootPart and torso then
                local savedpos = humanoidRootPart.CFrame
                pcall(function() character:MoveTo(seatTeleportPosition) end)
                task.wait(0.1)
                
                if not character:FindFirstChild("HumanoidRootPart") or character.HumanoidRootPart.Position.Y < -50 then
                    pcall(function() character:MoveTo(savedpos) end)
                    Notify("Invis Failed", "Teleport to seat failed - void detected.", 3)
                    return
                end
                
                local Seat = Instance.new('Seat')
                Seat.Parent = workspace
                Seat.Anchored = false
                Seat.CanCollide = false
                Seat.Name = 'invischair'
                Seat.Transparency = 1
                Seat.Position = seatTeleportPosition
                
                local Weld = Instance.new("Weld")
                Weld.Part0 = Seat
                Weld.Part1 = torso
                Weld.Parent = Seat
                
                task.wait(0.1)
                pcall(function() Seat.CFrame = savedpos end)
                
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0.75
                    end
                end
                
                Notify("FE Invisible", "Ghost mode activated via Seat weld.", 3)
            else
                Notify("Error", "Missing HumanoidRootPart or Torso", 3)
            end
        else
            local inv = workspace:FindFirstChild('invischair')
            if inv then
                pcall(function() inv:Destroy() end)
            end
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                end
            end
            
            Notify("FE Invisible", "Character is now fully visible.", 3)
        end
    end
})

FEAbilitiesTab:AddToggle({
    Name = "FE Spin (Tornado)",
    Default = false,
    Callback = function(Value)
        local hrp = getHumanoidRootPart()
        if Value and hrp then
            local spin = Instance.new("BodyAngularVelocity")
            spin.Name = "FESpinBody"
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, 50, 0)
            spin.Parent = hrp
            Notify("FE Spin", "Tornado Spin Enabled")
        elseif hrp then
            local spin = hrp:FindFirstChild("FESpinBody")
            if spin then spin:Destroy() end
            Notify("FE Spin", "Tornado Spin Disabled")
        end
    end
})

FEAbilitiesTab:AddButton({
    Name = "FE Teleport to Random Player",
    Callback = function()
        local plrs = Players:GetPlayers()
        local rand = plrs[math.random(1, #plrs)]
        if rand ~= LocalPlayer and rand.Character and rand.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHumanoidRootPart()
            if hrp then 
                hrp.CFrame = rand.Character.HumanoidRootPart.CFrame 
                Notify("Teleported", "Teleported to " .. rand.Name)
            end
        end
    end
})

FEAbilitiesTab:AddButton({
    Name = "FE Launch Skyward",
    Callback = function()
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.Velocity = Vector3.new(0, 750, 0)
            Notify("FE Launch", "Launched into the sky")
        end
    end
})

FEAbilitiesTab:AddToggle({
    Name = "FE Seizure Mode",
    Default = false,
    Callback = function(Value)
        seizureModeEnabled = Value
        Notify("FE Seizure", "Seizure mode set to " .. tostring(Value))
    end
})

FEAbilitiesTab:AddToggle({
    Name = "FE Static Float (Anchor)",
    Default = false,
    Callback = function(Value)
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.Anchored = Value
            Notify("FE Float", "Static float set to " .. tostring(Value))
        end
    end
})

FEAbilitiesTab:AddToggle({
    Name = "FE Network Fake Lag",
    Default = false,
    Callback = function(Value)
        fakeLagEnabled = Value
        if not Value then
            local hrp = getHumanoidRootPart()
            if hrp then hrp.Anchored = false end
        end
        Notify("FE Lag", "Fake lag set to " .. tostring(Value))
    end
})

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
    Notify("Anti-Void", "Safety Plate Deployed")
end

local function removeAntiVoid()
    if antiVoidPart then
        antiVoidPart:Destroy()
        antiVoidPart = nil
        Notify("Anti-Void", "Safety Plate Removed")
    end
end

AntiVoidTab:AddToggle({ Name = "Anti-Void Floor Safety Plate", Default = false, Callback = function(Value) if Value then createAntiVoid() else removeAntiVoid() end end })
AntiFlingTab:AddToggle({ Name = "Desync Anti-Fling Matrix", Default = false, Callback = function(Value) isAntiFlingEnabled = Value Notify("Anti-Fling", "Shield matrix set to " .. tostring(Value)) end })
AntiFlingTab:AddButton({
    Name = "Instant Velocity Anchor Fix",
    Callback = function()
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            Notify("Anchored", "Velocity stabilized")
        end
    end
})

MovementTab:AddToggle({ Name = "Enable Advanced CFrame Speed", Default = false, Callback = function(Value) cframeSpeedEnabled = Value Notify("Speed", "CFrame Speed: " .. tostring(Value)) end })
MovementTab:AddSlider({ Name = "CFrame Step Multiplier", Min = 1, Max = 30, Default = 5, Color = Color3.fromRGB(255, 136, 0), Increment = 1, ValueName = "Velocity", Callback = function(Value) cframeSpeedValue = Value end })
MovementTab:AddToggle({ Name = "Noclip Physics Phase", Default = false, Callback = function(Value) noclipEnabled = Value Notify("Noclip", "Phase physics set to " .. tostring(Value)) end })
MovementTab:AddToggle({ Name = "6-Axis Camera Flight System", Default = false, Callback = function(Value) flightEnabled = Value Notify("Flight", "Flight system set to " .. tostring(Value)) end })
MovementTab:AddSlider({ Name = "Flight Cruise Velocity", Min = 20, Max = 200, Default = 50, Color = Color3.fromRGB(0, 183, 255), Increment = 5, ValueName = "Studs/Sec", Callback = function(Value) flightSpeed = Value end })

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
        Notify("Visuals", "X-Ray framework toggled")
    end
})

VisualsTab:AddButton({
    Name = "Maximize Ambient Fullbright",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 3
        Notify("Visuals", "Fullbright Activated")
    end
})

MiscTab:AddToggle({ Name = "God Mode (Second Life)", Default = false, Callback = function(Value) godModeEnabled = Value if Value then enableGodMode() end Notify("Misc", "God Mode " .. tostring(Value)) end })

MiscTab:AddButton({
    Name = "Server Hop Instant Reconnect",
    Callback = function()
        Notify("Server Hop", "Finding new optimal instance...")
        local serverList = {}
        for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(serverList, v.id)
            end
        end
        if #serverList > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverList[math.random(1, #serverList)], LocalPlayer)
        else
            Notify("Teleport Warning", "No alternative optimal instances discovered.")
        end
    end
})

MiscTab:AddButton({
    Name = "Instant Rejoin Active Session",
    Callback = function()
        Notify("Rejoin", "Reconnecting...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

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
