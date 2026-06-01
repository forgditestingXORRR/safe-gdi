local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local premiumUsernames = { "0Tripyxman0" }
local function isPremiumUser()
    for _, username in ipairs(premiumUsernames) do
        if LocalPlayer.Name == username then return true end
    end
    return false
end

local function Notify(title, text, duration)
    OrionLib:MakeNotification({ Name = title, Content = text, Image = "rbxassetid://4483345998", Time = duration or 3 })
end

if isPremiumUser() then Notify("Premium Access", "Enjoy premium features, fellow teammate!", 5) end

local Window = OrionLib:MakeWindow({Name = "FE Fling v4 Pro - MM2 Chaos Edition", HidePremium = true, SaveConfig = true, ConfigFolder = "FEFlingV4"})

local MM2Tab        = Window:MakeTab({Name = "MM2 Game Toolkit",   Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FlingTab      = Window:MakeTab({Name = "Fling Matrix",        Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FEAbilitiesTab= Window:MakeTab({Name = "FE Abilities",        Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AntiVoidTab   = Window:MakeTab({Name = "Anti-Void Zone",      Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AntiFlingTab  = Window:MakeTab({Name = "Anti-Fling Shield",   Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MovementTab   = Window:MakeTab({Name = "CFrame Movement",     Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualsTab    = Window:MakeTab({Name = "Visuals & ESP",       Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscTab       = Window:MakeTab({Name = "Server Misc",         Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- State variables
local selectedPlayer
local PlayerDropdown
local isFlinging         = false
local originalCameraSubject
local originalCharacterPos
local isAntiFlingEnabled = false
local flingPower         = 99999
local invisFling         = false
local roleEspEnabled     = false
local gunEspEnabled      = false
local aimbotEnabled      = false
local autoStealGunEnabled= false
local targetFlingRole    = nil
local targetSpecificUser = nil
local xrayEnabled        = false
local cframeSpeedEnabled = false
local cframeSpeedValue   = 5
local flightEnabled      = false
local flightSpeed        = 50
local noclipEnabled      = false
local godModeEnabled     = false
local invis_on           = false
local invisFlingEnabled  = false   -- NEW: invis fling toggle
local feGrabEnabled      = false   -- NEW: grab loop
local feBringEnabled     = false   -- NEW: bring all
local rapidTeleEnabled   = false   -- NEW: rapid teleport fling
local orbitFlingEnabled  = false   -- NEW: orbit + fling combo
local seatTeleportPosition = Vector3.new(-25.95, 400, 3537.55)

-- Helpers
local function getCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHumanoidRootPart()
    local c = getCharacter()
    return c:WaitForChild("HumanoidRootPart", 5)
end
local function updatePlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end
local function getPlayerRole(player)
    if not player then return "Innocent" end
    local bp = player:FindFirstChild("Backpack")
    local ch = player.Character
    if (bp and bp:FindFirstChild("Knife")) or (ch and ch:FindFirstChild("Knife")) then return "Murderer" end
    if (bp and bp:FindFirstChild("Gun"))  or (ch and ch:FindFirstChild("Gun"))  then return "Sheriff" end
    return "Innocent"
end
local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0) end
    if role == "Sheriff"  then return Color3.fromRGB(0, 85, 255) end
    return Color3.fromRGB(0, 255, 76)
end

-- Full character hide/show
local function hideCharacter(character)
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.LocalTransparencyModifier = 1
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = false
        end
    end
    for _, acc in pairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then h.Transparency = 1; h.LocalTransparencyModifier = 1 end
        end
    end
end

local function showCharacter(character)
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 0
            obj.LocalTransparencyModifier = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = true
        end
    end
    for _, acc in pairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then h.Transparency = 0; h.LocalTransparencyModifier = 0 end
        end
    end
end

-- God mode
local function enableGodMode()
    spawn(function()
        while godModeEnabled do
            local c = LocalPlayer.Character
            if c then
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end
            end
            task.wait(0.1)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function()
    if godModeEnabled then task.wait(0.5); enableGodMode() end
end)

-- Core fling
local function performFling(targetPlayer, durationOverride, forceInvis)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local character = getCharacter()
    local humanoidRootPart = getHumanoidRootPart()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not humanoidRootPart or not humanoid or not targetHum or targetHum.Health <= 0 then return end

    originalCameraSubject = Camera.CameraSubject
    originalCharacterPos  = humanoidRootPart.CFrame

    local useInvis = forceInvis or invisFling
    if not useInvis then
        Camera.CameraSubject = targetHum
    else
        -- Hide our character so server doesn't see us snap to target
        hideCharacter(character)
    end

    humanoid.PlatformStand = true

    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(0, flingPower, 0)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = humanoidRootPart

    local duration = durationOverride or 3
    local startTime = tick()

    while isFlinging and targetPlayer and targetPlayer.Character
        and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        and targetHum.Health > 0
        and (tick() - startTime < duration) do
        task.wait()
        if humanoidRootPart and targetHRP then
            local vel = targetHRP.Velocity * 0.125
            humanoidRootPart.CFrame = (targetHRP.CFrame + vel) * CFrame.Angles(0, 0, math.rad(90))
            humanoidRootPart.Velocity = Vector3.zero
        else
            break
        end
    end

    bav:Destroy()
    humanoid.PlatformStand = false
    Camera.CameraSubject = originalCameraSubject
    humanoidRootPart.CFrame = originalCharacterPos
    humanoidRootPart.Velocity = Vector3.zero
    humanoidRootPart.RotVelocity = Vector3.zero

    if useInvis then
        -- Restore visibility after returning
        showCharacter(character)
    end
end

-- Fling all loop
local function flingAllPlayersLoop()
    isFlinging = true
    Notify("Fling All", "Starting 500ms cycle on all players", 3)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isFlinging then performFling(p, 0.5) end
    end
    Notify("Fling All", "Fling cycle complete", 3)
    isFlinging = false
end

-- Role/specific fling loop
task.spawn(function()
    while true do
        if isFlinging and targetFlingRole then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(p)
                    if (targetFlingRole == "Murderer" and role == "Murderer") or
                       (targetFlingRole == "Sheriff"  and role == "Sheriff")  or
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

-- ============================================================
-- NEW: Invis Fling Loop — hides you, flings, restores
-- ============================================================
task.spawn(function()
    while true do
        if invisFlingEnabled and targetSpecificUser then
            performFling(targetSpecificUser, 2, true)
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- NEW: FE Grab — continuously snaps target to your position
-- ============================================================
task.spawn(function()
    while true do
        if feGrabEnabled and targetSpecificUser then
            local hrp = getHumanoidRootPart()
            local target = targetSpecificUser
            if hrp and target and target.Character then
                local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    -- Snap us to them then snap back — server sees them move
                    local saved = hrp.CFrame
                    hrp.CFrame = tHRP.CFrame
                    task.wait(0.05)
                    hrp.CFrame = saved
                end
            end
        end
        task.wait(0.05)
    end
end)

-- ============================================================
-- NEW: FE Bring All — pulls every player to your position
-- ============================================================
task.spawn(function()
    while true do
        if feBringEnabled then
            local hrp = getHumanoidRootPart()
            if hrp then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                        if tHRP then
                            local saved = hrp.CFrame
                            hrp.CFrame = tHRP.CFrame
                            task.wait(0.03)
                            hrp.CFrame = saved
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- NEW: Rapid Teleport Fling — teleports into target repeatedly
-- very fast, more disorienting than standard fling
-- ============================================================
task.spawn(function()
    while true do
        if rapidTeleEnabled and targetSpecificUser then
            local hrp = getHumanoidRootPart()
            local target = targetSpecificUser
            if hrp and target and target.Character then
                local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local hum  = getCharacter():FindFirstChildOfClass("Humanoid")
                if tHRP and hum then
                    local saved = hrp.CFrame
                    hum.PlatformStand = true
                    for i = 1, 8 do
                        if tHRP and tHRP.Parent then
                            hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, 0.1)
                            hrp.Velocity = Vector3.new(math.random(-50,50), math.random(20,80), math.random(-50,50))
                            task.wait(0.03)
                        end
                    end
                    hum.PlatformStand = false
                    hrp.CFrame = saved
                    hrp.Velocity = Vector3.zero
                end
            end
        end
        task.wait(0.05)
    end
end)

-- ============================================================
-- NEW: Orbit + Fling combo — orbit target then fling on overlap
-- ============================================================
task.spawn(function()
    local angle = 0
    while true do
        if orbitFlingEnabled and targetSpecificUser then
            local hrp = getHumanoidRootPart()
            local target = targetSpecificUser
            if hrp and target and target.Character then
                local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local hum  = getCharacter():FindFirstChildOfClass("Humanoid")
                if tHRP and hum then
                    angle = angle + 0.35
                    local orbitCFrame = tHRP.CFrame * CFrame.new(math.cos(angle)*3, 0, math.sin(angle)*3)
                    hum.PlatformStand = true
                    hrp.CFrame = orbitCFrame
                    hrp.Velocity = Vector3.zero
                    -- Fling burst every half rotation
                    if math.abs(math.sin(angle)) < 0.05 then
                        local bav = Instance.new("BodyAngularVelocity")
                        bav.AngularVelocity = Vector3.new(0, flingPower, 0)
                        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bav.Parent = hrp
                        task.wait(0.2)
                        bav:Destroy()
                    end
                end
            end
        else
            local hum = getCharacter() and getCharacter():FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        task.wait(0.03)
    end
end)

-- ESP loops
task.spawn(function()
    while true do
        if roleEspEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("RoleESP_Cham")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "RoleESP_Cham"
                        hl.Parent = p.Character
                    end
                    hl.FillColor = getRoleColor(getPlayerRole(p))
                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
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
        local dg = Workspace:FindFirstChild("GunDrop")
        if gunEspEnabled and dg and dg:IsA("BasePart") then
            if not dg:FindFirstChild("GunESP_Cham") then
                local hl = Instance.new("Highlight")
                hl.Name = "GunESP_Cham"
                hl.Parent = dg
                hl.FillColor = Color3.fromRGB(255,230,0)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
            end
        elseif dg and dg:FindFirstChild("GunESP_Cham") then
            dg.GunESP_Cham:Destroy()
        end
        task.wait(0.5)
    end
end)

local function stealGun()
    local dg = Workspace:FindFirstChild("GunDrop")
    if dg and dg:IsA("BasePart") then
        local hrp = getHumanoidRootPart()
        if hrp then
            local old = hrp.CFrame
            hrp.CFrame = dg.CFrame
            task.wait(0.2)
            hrp.CFrame = old
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

-- RenderStepped
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
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)          then v = v + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)          then v = v - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)          then v = v - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)          then v = v + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)      then v = v + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)  then v = v - Vector3.new(0,1,0) end
        hrp.Velocity = Vector3.zero
        if v.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (v.Unit * (flightSpeed / 10)) end
    end
end)

RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if (noclipEnabled or isAntiFlingEnabled) and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ============================================================
-- MM2 TAB
-- ============================================================
MM2Tab:AddToggle({Name="Role ESP (Chams)", Default=false, Callback=function(v) roleEspEnabled=v Notify("ESP","Role ESP: "..tostring(v)) end})
MM2Tab:AddToggle({Name="Dropped Gun ESP", Default=false, Callback=function(v) gunEspEnabled=v Notify("ESP","Gun ESP: "..tostring(v)) end})
MM2Tab:AddToggle({Name="Murderer Lock Aimbot", Default=false, Callback=function(v) aimbotEnabled=v Notify("Aimbot","Murderer Lock: "..tostring(v)) end})
MM2Tab:AddButton({Name="Instantly Retrieve Gun", Callback=function() stealGun() end})
MM2Tab:AddToggle({Name="Auto-Collect Gun Loop", Default=false, Callback=function(v) autoStealGunEnabled=v Notify("Auto","Auto-Collect Gun: "..tostring(v)) end})
MM2Tab:AddButton({
    Name="Teleport to Safe Lobby",
    Callback=function()
        local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyWorkspace")
        local sp = lobby and lobby:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
        local hrp = getHumanoidRootPart()
        if hrp and sp then hrp.CFrame = sp.CFrame + Vector3.new(0,4,0); Notify("Teleport","Moved to Lobby") end
    end
})
MM2Tab:AddButton({Name="Fling Active Murderer", Callback=function() isFlinging=true targetFlingRole="Murderer" targetSpecificUser=nil Notify("Fling","Targeting Murderer") end})
MM2Tab:AddButton({Name="Fling Active Sheriff",  Callback=function() isFlinging=true targetFlingRole="Sheriff"  targetSpecificUser=nil Notify("Fling","Targeting Sheriff") end})
MM2Tab:AddButton({
    Name="Auto-Kill Murderer (Requires Gun)",
    Callback=function()
        local c = getCharacter()
        local tool = c:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if not tool then Notify("Error","You must hold or own the Gun!",3); return end
        local tm
        for _, p in ipairs(Players:GetPlayers()) do if getPlayerRole(p)=="Murderer" then tm=p; break end end
        if tm and tm.Character and tm.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHumanoidRootPart()
            tool.Parent = c
            hrp.CFrame = tm.Character.HumanoidRootPart.CFrame + (tm.Character.HumanoidRootPart.CFrame.LookVector * -4)
            task.wait(0.1)
            tool:Activate()
            Notify("Auto-Kill","Shot fired at Murderer")
        else
            Notify("Status","No Murderer found")
        end
    end
})

-- ============================================================
-- FLING TAB
-- ============================================================
PlayerDropdown = FlingTab:AddDropdown({
    Name="Target User Profile", Default="", Options=updatePlayerList(),
    Callback=function(v)
        selectedPlayer = Players:FindFirstChild(v)
        Notify("Selection","Target set to "..tostring(v))
    end
})

FlingTab:AddToggle({
    Name="Fling Selected Target", Default=false,
    Callback=function(v)
        isFlinging = v
        if v then
            if selectedPlayer then
                targetSpecificUser = selectedPlayer; targetFlingRole = nil
                Notify("Fling","Engaging target")
            else
                Notify("Target Null","Select a target profile first!",3); isFlinging=false
            end
        else Notify("Fling","Fling Stopped") end
    end
})

FlingTab:AddTextbox({
    Name="Target Username Search", Default="", TextDisappear=true,
    Callback=function(v)
        local input = string.lower(v)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.find(string.lower(p.Name),input) or string.find(string.lower(p.DisplayName),input) then
                isFlinging=true; targetSpecificUser=p; targetFlingRole=nil
                Notify("Fling","Engaged target: "..p.Name); break
            end
        end
    end
})

FlingTab:AddButton({Name="FE Fling All (500ms Cycle)", Callback=function() task.spawn(flingAllPlayersLoop) end})
FlingTab:AddToggle({Name="Invisible Position Fling (Camera)", Default=false, Callback=function(v) invisFling=v Notify("Fling","Invisible Camera: "..tostring(v)) end})

-- NEW FLING BUTTONS
FlingTab:AddToggle({
    Name="Full Invis Fling (Hidden Body + Position)",
    Default=false,
    Callback=function(v)
        invisFlingEnabled = v
        if v then
            if selectedPlayer then
                targetSpecificUser = selectedPlayer
                Notify("Invis Fling","Running — your character is fully hidden during fling",3)
            else
                Notify("Invis Fling","Select a target first!",3)
                invisFlingEnabled = false
            end
        else
            -- Make sure we're visible again
            local c = LocalPlayer.Character
            if c then showCharacter(c) end
            Notify("Invis Fling","Stopped")
        end
    end
})

FlingTab:AddToggle({
    Name="Rapid Teleport Fling",
    Default=false,
    Callback=function(v)
        rapidTeleEnabled = v
        if v and not selectedPlayer then
            Notify("Rapid Fling","Select a target first!",3)
            rapidTeleEnabled = false
        else
            Notify("Rapid Fling","Rapid mode: "..tostring(v))
        end
    end
})

FlingTab:AddToggle({
    Name="Orbit + Fling Combo",
    Default=false,
    Callback=function(v)
        orbitFlingEnabled = v
        if v and not selectedPlayer then
            Notify("Orbit Fling","Select a target first!",3)
            orbitFlingEnabled = false
        else
            Notify("Orbit Fling","Orbit combo: "..tostring(v))
        end
    end
})

FlingTab:AddSlider({
    Name="Fling Power", Min=1000, Max=999999, Default=99999,
    Color=Color3.fromRGB(255,80,0), Increment=1000, ValueName="Force",
    Callback=function(v) flingPower=v end
})

FlingTab:AddButton({
    Name="🛑 EMERGENCY SHUTDOWN ALL ACTION",
    Callback=function()
        isFlinging=false; targetFlingRole=nil; targetSpecificUser=nil
        autoStealGunEnabled=false; aimbotEnabled=false; flightEnabled=false
        cframeSpeedEnabled=false; invisFlingEnabled=false; feGrabEnabled=false
        feBringEnabled=false; rapidTeleEnabled=false; orbitFlingEnabled=false
        local c = LocalPlayer.Character
        if c then showCharacter(c) end
        Notify("SHUTDOWN","All active systems terminated")
    end
})

-- ============================================================
-- FE ABILITIES TAB
-- ============================================================
FEAbilitiesTab:AddToggle({
    Name="FE Invisible (Seat Method)",
    Default=false,
    Callback=function(Value)
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
                    pcall(function() character:MoveTo(savedpos.Position) end)
                    Notify("Invis Failed","Teleport to seat failed - void detected.",3); return
                end
                local Seat = Instance.new("Seat")
                Seat.Parent = workspace; Seat.Anchored = false; Seat.CanCollide = false
                Seat.Name = "invischair"; Seat.Transparency = 1; Seat.Position = seatTeleportPosition
                local Weld = Instance.new("Weld")
                Weld.Part0 = Seat; Weld.Part1 = torso; Weld.Parent = Seat
                task.wait(0.1)
                pcall(function() Seat.CFrame = savedpos end)
                hideCharacter(character)
                Notify("FE Invisible","Ghost mode activated via Seat weld.",3)
            else
                Notify("Error","Missing HumanoidRootPart or Torso",3)
            end
        else
            local inv = workspace:FindFirstChild("invischair")
            if inv then pcall(function() inv:Destroy() end) end
            showCharacter(character)
            Notify("FE Invisible","Character is now fully visible.",3)
        end
    end
})

FEAbilitiesTab:AddToggle({
    Name="FE Grab Selected Target",
    Default=false,
    Callback=function(v)
        feGrabEnabled = v
        if v and not selectedPlayer then
            Notify("FE Grab","Select a target in Fling tab first!",3)
            feGrabEnabled = false
        else
            targetSpecificUser = selectedPlayer
            Notify("FE Grab","Grab loop: "..tostring(v))
        end
    end
})

FEAbilitiesTab:AddToggle({
    Name="FE Bring All Players",
    Default=false,
    Callback=function(v)
        feBringEnabled = v
        Notify("FE Bring","Bring all loop: "..tostring(v))
    end
})

FEAbilitiesTab:AddButton({
    Name="FE Freeze Target in Place",
    Callback=function()
        if not selectedPlayer or not selectedPlayer.Character then
            Notify("Error","No target selected",3); return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            local frozenPos = tHRP.CFrame
            local hrp = getHumanoidRootPart()
            local saved = hrp.CFrame
            -- Rapidly snap to their position to create a desync freeze
            for i = 1, 10 do
                hrp.CFrame = frozenPos
                task.wait(0.02)
            end
            hrp.CFrame = saved
            Notify("FE Freeze","Freeze attempt sent",2)
        end
    end
})

FEAbilitiesTab:AddButton({
    Name="FE Launch Target Upward",
    Callback=function()
        if not selectedPlayer or not selectedPlayer.Character then
            Notify("Error","No target selected",3); return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = getHumanoidRootPart()
        local hum = getCharacter():FindFirstChildOfClass("Humanoid")
        if tHRP and hrp and hum then
            local saved = hrp.CFrame
            hum.PlatformStand = true
            hrp.CFrame = tHRP.CFrame
            hrp.Velocity = Vector3.new(0, 500, 0)
            task.wait(0.15)
            hum.PlatformStand = false
            hrp.CFrame = saved
            hrp.Velocity = Vector3.zero
            Notify("FE Launch","Launched target upward",2)
        end
    end
})

FEAbilitiesTab:AddButton({
    Name="FE Spin Trap Target",
    Callback=function()
        if not selectedPlayer or not selectedPlayer.Character then
            Notify("Error","No target selected",3); return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = getHumanoidRootPart()
        local hum = getCharacter():FindFirstChildOfClass("Humanoid")
        if tHRP and hrp and hum then
            local saved = hrp.CFrame
            hum.PlatformStand = true
            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(0, flingPower, 0)
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bav.Parent = hrp
            for i = 1, 20 do
                if tHRP and tHRP.Parent then
                    hrp.CFrame = tHRP.CFrame
                    task.wait(0.05)
                end
            end
            bav:Destroy()
            hum.PlatformStand = false
            hrp.CFrame = saved
            hrp.Velocity = Vector3.zero
            Notify("FE Spin Trap","Spin trap complete",2)
        end
    end
})

FEAbilitiesTab:AddToggle({
    Name="FE Spin (Tornado)",
    Default=false,
    Callback=function(v)
        local hrp = getHumanoidRootPart()
        if v and hrp then
            local spin = Instance.new("BodyAngularVelocity")
            spin.Name = "FESpinBody"; spin.MaxTorque = Vector3.new(0,math.huge,0)
            spin.AngularVelocity = Vector3.new(0,50,0); spin.Parent = hrp
            Notify("FE Spin","Tornado Spin Enabled")
        elseif hrp then
            local spin = hrp:FindFirstChild("FESpinBody")
            if spin then spin:Destroy() end
            Notify("FE Spin","Tornado Spin Disabled")
        end
    end
})

FEAbilitiesTab:AddButton({
    Name="FE Teleport to Random Player",
    Callback=function()
        local plrs = Players:GetPlayers()
        local rand = plrs[math.random(1,#plrs)]
        if rand ~= LocalPlayer and rand.Character and rand.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHumanoidRootPart()
            if hrp then hrp.CFrame = rand.Character.HumanoidRootPart.CFrame; Notify("Teleported","Teleported to "..rand.Name) end
        end
    end
})

FEAbilitiesTab:AddButton({
    Name="FE Void Fling Target",
    Callback=function()
        if not selectedPlayer or not selectedPlayer.Character then
            Notify("Error","No target selected",3); return
        end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp = getHumanoidRootPart()
        local hum = getCharacter():FindFirstChildOfClass("Humanoid")
        if tHRP and hrp and hum then
            local saved = hrp.CFrame
            hum.PlatformStand = true
            hrp.CFrame = tHRP.CFrame
            hrp.Velocity = Vector3.new(math.random(-200,200), -500, math.random(-200,200))
            task.wait(0.2)
            hum.PlatformStand = false
            hrp.CFrame = saved
            hrp.Velocity = Vector3.zero
            Notify("Void Fling","Sent target toward void",2)
        end
    end
})

-- ============================================================
-- ANTI VOID / ANTI FLING TABS (unchanged)
-- ============================================================
local antiVoidPart
local function createAntiVoid()
    if antiVoidPart then return end
    antiVoidPart = Instance.new("Part")
    antiVoidPart.Name = "SafetyAntiVoid"
    antiVoidPart.Size = Vector3.new(3000,2,3000)
    antiVoidPart.Anchored = true; antiVoidPart.Transparency = 0.6
    antiVoidPart.CanCollide = true; antiVoidPart.BrickColor = BrickColor.new("Crimson")
    local lowestY = 0
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Position.Y < lowestY then lowestY = part.Position.Y end
    end
    antiVoidPart.Position = Vector3.new(0, lowestY - 20, 0)
    antiVoidPart.Parent = Workspace
    Notify("Anti-Void","Safety Plate Deployed")
end
local function removeAntiVoid()
    if antiVoidPart then antiVoidPart:Destroy(); antiVoidPart=nil; Notify("Anti-Void","Safety Plate Removed") end
end

AntiVoidTab:AddToggle({Name="Anti-Void Floor Safety Plate", Default=false, Callback=function(v) if v then createAntiVoid() else removeAntiVoid() end end})
AntiFlingTab:AddToggle({Name="Desync Anti-Fling Matrix", Default=false, Callback=function(v) isAntiFlingEnabled=v Notify("Anti-Fling","Shield: "..tostring(v)) end})
AntiFlingTab:AddButton({
    Name="Instant Velocity Anchor Fix",
    Callback=function()
        local hrp = getHumanoidRootPart()
        if hrp then hrp.Velocity=Vector3.zero; hrp.RotVelocity=Vector3.zero; Notify("Anchored","Velocity stabilized") end
    end
})

-- ============================================================
-- MOVEMENT TAB
-- ============================================================
MovementTab:AddToggle({Name="Enable Advanced CFrame Speed", Default=false, Callback=function(v) cframeSpeedEnabled=v Notify("Speed","CFrame Speed: "..tostring(v)) end})
MovementTab:AddSlider({Name="CFrame Step Multiplier", Min=1, Max=30, Default=5, Color=Color3.fromRGB(255,136,0), Increment=1, ValueName="Velocity", Callback=function(v) cframeSpeedValue=v end})
MovementTab:AddToggle({Name="Noclip Physics Phase", Default=false, Callback=function(v) noclipEnabled=v Notify("Noclip","Phase: "..tostring(v)) end})
MovementTab:AddToggle({Name="6-Axis Camera Flight System", Default=false, Callback=function(v) flightEnabled=v Notify("Flight","Flight: "..tostring(v)) end})
MovementTab:AddSlider({Name="Flight Cruise Velocity", Min=20, Max=200, Default=50, Color=Color3.fromRGB(0,183,255), Increment=5, ValueName="Studs/Sec", Callback=function(v) flightSpeed=v end})

-- ============================================================
-- VISUALS TAB
-- ============================================================
VisualsTab:AddToggle({
    Name="Map X-Ray Framework", Default=false,
    Callback=function(v)
        xrayEnabled = v
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Players) then
                if v then
                    if obj.Transparency == 0 then obj.Transparency=0.5; obj:SetAttribute("XrayOriginal",0) end
                else
                    if obj:GetAttribute("XrayOriginal") then obj.Transparency=0; obj:SetAttribute("XrayOriginal",nil) end
                end
            end
        end
        Notify("Visuals","X-Ray toggled")
    end
})
VisualsTab:AddButton({
    Name="Maximize Ambient Fullbright",
    Callback=function()
        local l = game:GetService("Lighting")
        l.Ambient=Color3.fromRGB(255,255,255); l.OutdoorAmbient=Color3.fromRGB(255,255,255); l.Brightness=3
        Notify("Visuals","Fullbright Activated")
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
MiscTab:AddToggle({Name="God Mode (Second Life)", Default=false, Callback=function(v) godModeEnabled=v if v then enableGodMode() end Notify("Misc","God Mode "..tostring(v)) end})
MiscTab:AddButton({
    Name="Server Hop Instant Reconnect",
    Callback=function()
        Notify("Server Hop","Finding new optimal instance...")
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if not ok then Notify("Error","Failed to fetch server list",3); return end
        local serverList = {}
        for _, v in ipairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(serverList, v.id) end
        end
        if #serverList > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverList[math.random(1,#serverList)], LocalPlayer)
        else
            Notify("Teleport Warning","No alternative instances found.")
        end
    end
})
MiscTab:AddButton({
    Name="Instant Rejoin Active Session",
    Callback=function()
        Notify("Rejoin","Reconnecting...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- Auto refresh dropdown
task.spawn(function()
    while true do PlayerDropdown:Refresh(updatePlayerList(), true); task.wait(2) end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Humanoid")
    if isAntiFlingEnabled or noclipEnabled then
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

OrionLib:Init()
