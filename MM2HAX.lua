local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

-- ── Premium ──────────────────────────────────────────────────
local premiumUsernames = { "0Tripyxman0" }
local function isPremium()
    for _, u in ipairs(premiumUsernames) do
        if LocalPlayer.Name == u then return true end
    end
    return false
end
local function Notify(title, text, dur)
    OrionLib:MakeNotification({ Name = title, Content = text, Image = "rbxassetid://4483345998", Time = dur or 3 })
end
if isPremium() then Notify("Premium", "Welcome back, teammate!", 5) end

-- ── Window ───────────────────────────────────────────────────
local Window = OrionLib:MakeWindow({
    Name = "⚡ Chaos Matrix v5 — MM2",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "ChaosMatrixV5"
})

local MM2Tab      = Window:MakeTab({ Name = "🔪 MM2 Toolkit",      Icon = "rbxassetid://4483345998" })
local FlingTab    = Window:MakeTab({ Name = "💥 Fling Engine",      Icon = "rbxassetid://4483345998" })
local FETab       = Window:MakeTab({ Name = "👻 FE Abilities",      Icon = "rbxassetid://4483345998" })
local MoveTab     = Window:MakeTab({ Name = "🚀 Movement",          Icon = "rbxassetid://4483345998" })
local VisTab      = Window:MakeTab({ Name = "🎨 Visuals & ESP",     Icon = "rbxassetid://4483345998" })
local SafeTab     = Window:MakeTab({ Name = "🛡️ Safety Systems",    Icon = "rbxassetid://4483345998" })
local MiscTab     = Window:MakeTab({ Name = "⚙️ Misc & Server",     Icon = "rbxassetid://4483345998" })

-- ── State ────────────────────────────────────────────────────
local selectedPlayer
local PlayerDropdown
local isFlinging          = false
local targetFlingRole     = nil
local targetSpecificUser  = nil
local flingPower          = 99999
local invisFling          = false   -- camera-only invis fling
local isAntiFlingEnabled  = false
local roleEspEnabled      = false
local gunEspEnabled       = false
local aimbotEnabled       = false
local autoStealGunEnabled = false
local xrayEnabled         = false
local cframeSpeedEnabled  = false
local cframeSpeedValue    = 5
local flightEnabled       = false
local flightSpeed         = 50
local noclipEnabled       = false
local godModeEnabled      = false
local invis_on            = false
local originalCameraSubject
local originalCharacterPos
local antiVoidPart
local seatTeleportPosition = Vector3.new(-25.95, 400, 3537.55)

-- ── Helpers ──────────────────────────────────────────────────
local function getCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHRP()
    local c = getCharacter()
    return c and c:WaitForChild("HumanoidRootPart", 5)
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
    if (bp and bp:FindFirstChild("Gun"))  or (ch and ch:FindFirstChild("Gun"))   then return "Sheriff" end
    return "Innocent"
end
local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 50, 50) end
    if role == "Sheriff"  then return Color3.fromRGB(50, 120, 255) end
    return Color3.fromRGB(50, 255, 100)
end

-- ── Character Visibility (36% transparency = mostly visible) ─
local INVIS_TRANSPARENCY = 0.36

local function hideCharacter(character)
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = INVIS_TRANSPARENCY
            obj.LocalTransparencyModifier = INVIS_TRANSPARENCY
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = INVIS_TRANSPARENCY
        elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            obj.Enabled = false
        end
    end
    for _, acc in pairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then
                h.Transparency = INVIS_TRANSPARENCY
                h.LocalTransparencyModifier = INVIS_TRANSPARENCY
            end
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

-- ── God Mode ─────────────────────────────────────────────────
local function enableGodMode()
    task.spawn(function()
        while godModeEnabled do
            local c = LocalPlayer.Character
            if c then
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.MaxHealth = math.huge
                    hum.Health    = math.huge
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

-- ── Enhanced Fling ───────────────────────────────────────────
-- Back-and-forth lateral oscillation (max ±12 studs left/right)
-- while spinning every axis and spiraling upward by 0.5 studs/cycle
-- until the target is launched, then snaps back.

local function performFling(targetPlayer, durationOverride, forceInvis)
    if not targetPlayer or not targetPlayer.Character then return end
    local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local character = getCharacter()
    local hrp = getHRP()
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if not tHRP or not hrp or not hum or not tHum or tHum.Health <= 0 then return end

    originalCameraSubject = Camera.CameraSubject
    originalCharacterPos  = hrp.CFrame

    local useInvis = forceInvis or invisFling
    if useInvis then
        hideCharacter(character)
    else
        Camera.CameraSubject = tHum
    end

    hum.PlatformStand = true

    -- Multi-axis spin torque
    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(flingPower * 0.4, flingPower, flingPower * 0.6)
    bav.MaxTorque       = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent          = hrp

    local duration  = durationOverride or 3.5
    local startTime = tick()
    local phase     = 0          -- oscillation phase (radians)
    local riseAccum = 0          -- cumulative upward drift

    while isFlinging
        and targetPlayer and targetPlayer.Character
        and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        and tHum.Health > 0
        and (tick() - startTime < duration)
    do
        task.wait()

        -- Re-fetch in case of respawn
        tHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then break end

        phase = phase + 0.22                        -- oscillation speed
        riseAccum = riseAccum + 0.5                 -- 0.5 studs upward per cycle (half-loop)

        -- Lateral offset: pure left/right, clamped to ±12 studs
        local lateralOffset = math.sin(phase) * 12  -- oscillates -12 … +12

        -- Build offset relative to target's look vector
        local right = tHRP.CFrame.RightVector
        local up    = Vector3.new(0, 1, 0)

        local targetCF = tHRP.CFrame
            + (right * lateralOffset)
            + (up    * riseAccum)

        hrp.CFrame   = targetCF * CFrame.Angles(
            math.rad(phase * 40),   -- pitch spin
            math.rad(phase * 60),   -- yaw spin
            math.rad(phase * 30)    -- roll spin
        )
        hrp.Velocity = Vector3.zero
    end

    bav:Destroy()
    hum.PlatformStand = false
    Camera.CameraSubject = originalCameraSubject

    -- Snap back
    if hrp and hrp.Parent then
        hrp.CFrame        = originalCharacterPos
        hrp.Velocity      = Vector3.zero
        hrp.RotVelocity   = Vector3.zero
    end

    if useInvis then showCharacter(character) end
end

-- ── Fling All Loop ───────────────────────────────────────────
local function flingAllLoop()
    isFlinging = true
    Notify("Fling All", "500ms cycle on all players", 3)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isFlinging then performFling(p, 0.5) end
    end
    Notify("Fling All", "Cycle complete", 2)
    isFlinging = false
end

-- ── Continuous Fling Task ────────────────────────────────────
task.spawn(function()
    while true do
        if isFlinging and targetFlingRole then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(p)
                    if (targetFlingRole == "Murderer"     and role == "Murderer") or
                       (targetFlingRole == "Sheriff"      and role == "Sheriff")  or
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

-- ── ESP Loops ────────────────────────────────────────────────
task.spawn(function()
    while true do
        if roleEspEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("RoleESP") or Instance.new("Highlight")
                    hl.Name             = "RoleESP"
                    hl.FillColor        = getRoleColor(getPlayerRole(p))
                    hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency    = 0.35
                    hl.OutlineTransparency = 0.05
                    hl.Parent           = p.Character
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("RoleESP")
                    if hl then hl:Destroy() end
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
            if not dg:FindFirstChild("GunESP") then
                local hl = Instance.new("Highlight")
                hl.Name             = "GunESP"
                hl.FillColor        = Color3.fromRGB(255, 220, 0)
                hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency    = 0.3
                hl.OutlineTransparency = 0
                hl.Parent           = dg
            end
        elseif dg and dg:FindFirstChild("GunESP") then
            dg.GunESP:Destroy()
        end
        task.wait(0.5)
    end
end)

-- ── Gun Steal ────────────────────────────────────────────────
local function stealGun()
    local dg = Workspace:FindFirstChild("GunDrop")
    if dg and dg:IsA("BasePart") then
        local hrp = getHRP()
        if hrp then
            local old = hrp.CFrame
            hrp.CFrame = dg.CFrame
            task.wait(0.2)
            hrp.CFrame = old
            Notify("Gun", "Teleported to dropped gun", 2)
        end
    end
end
task.spawn(function()
    while true do
        if autoStealGunEnabled then stealGun() end
        task.wait(0.3)
    end
end)

-- ── RenderStepped ────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local hum = character and character:FindFirstChildOfClass("Humanoid")

    if aimbotEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and getPlayerRole(p) == "Murderer" then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.Head.Position)
                break
            end
        end
    end

    if cframeSpeedEnabled and hrp and hum and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * cframeSpeedValue * 0.1)
    end

    if flightEnabled and hrp then
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then v = v + Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then v = v - Camera.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then v = v - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then v = v + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then v = v + Vector3.new(0,1,0)        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then v = v - Vector3.new(0,1,0)        end
        hrp.Velocity = Vector3.zero
        if v.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (v.Unit * (flightSpeed / 10)) end
    end
end)

RunService.Stepped:Connect(function()
    if (noclipEnabled or isAntiFlingEnabled) and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- MM2 TAB
-- ════════════════════════════════════════════════════════════
MM2Tab:AddSection({ Name = "📡 ESP & Detection" })
MM2Tab:AddToggle({ Name = "Role ESP (Highlights)", Default = false, Callback = function(v) roleEspEnabled = v; Notify("ESP", "Role ESP: " .. tostring(v)) end })
MM2Tab:AddToggle({ Name = "Dropped Gun ESP",        Default = false, Callback = function(v) gunEspEnabled  = v; Notify("ESP", "Gun ESP: "  .. tostring(v)) end })
MM2Tab:AddToggle({ Name = "Murderer Lock Aimbot",   Default = false, Callback = function(v) aimbotEnabled  = v; Notify("Aimbot", tostring(v)) end })

MM2Tab:AddSection({ Name = "🔫 Gun Control" })
MM2Tab:AddButton({ Name = "Instantly Retrieve Gun",  Callback = function() stealGun() end })
MM2Tab:AddToggle({ Name = "Auto-Collect Gun Loop",   Default = false, Callback = function(v) autoStealGunEnabled = v end })
MM2Tab:AddButton({
    Name = "Auto-Kill Murderer",
    Callback = function()
        local c = getCharacter()
        local tool = c:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if not tool then Notify("Error", "You need the Gun equipped!", 3); return end
        for _, p in ipairs(Players:GetPlayers()) do
            if getPlayerRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = getHRP()
                tool.Parent = c
                hrp.CFrame = p.Character.HumanoidRootPart.CFrame + (p.Character.HumanoidRootPart.CFrame.LookVector * -4)
                task.wait(0.1)
                tool:Activate()
                Notify("Auto-Kill", "Shot fired at " .. p.Name, 2)
                break
            end
        end
    end
})

MM2Tab:AddSection({ Name = "🎯 Role Fling" })
MM2Tab:AddButton({ Name = "Fling Active Murderer", Callback = function() isFlinging = true; targetFlingRole = "Murderer"; targetSpecificUser = nil; Notify("Fling", "Targeting Murderer") end })
MM2Tab:AddButton({ Name = "Fling Active Sheriff",  Callback = function() isFlinging = true; targetFlingRole = "Sheriff";  targetSpecificUser = nil; Notify("Fling", "Targeting Sheriff")  end })
MM2Tab:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyWorkspace")
        local sp = lobby and lobby:FindFirstChildOfClass("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
        local hrp = getHRP()
        if hrp and sp then hrp.CFrame = sp.CFrame + Vector3.new(0, 4, 0); Notify("Teleport", "Moved to Lobby") end
    end
})

-- ════════════════════════════════════════════════════════════
-- FLING TAB
-- ════════════════════════════════════════════════════════════
FlingTab:AddSection({ Name = "🎯 Target Selection" })
PlayerDropdown = FlingTab:AddDropdown({
    Name = "Select Target",
    Default = "",
    Options = updatePlayerList(),
    Callback = function(v)
        selectedPlayer = Players:FindFirstChild(v)
        Notify("Target", "Locked onto " .. tostring(v))
    end
})

FlingTab:AddTextbox({
    Name = "Search Username",
    Default = "",
    TextDisappear = true,
    Callback = function(v)
        local input = string.lower(v)
        for _, p in ipairs(Players:GetPlayers()) do
            if string.find(string.lower(p.Name), input) or string.find(string.lower(p.DisplayName), input) then
                selectedPlayer = p
                isFlinging = true
                targetSpecificUser = p
                targetFlingRole    = nil
                Notify("Fling", "Engaged: " .. p.Name)
                break
            end
        end
    end
})

FlingTab:AddSection({ Name = "⚡ Fling Controls" })
FlingTab:AddToggle({
    Name = "Fling Selected Target",
    Default = false,
    Callback = function(v)
        isFlinging = v
        if v then
            if selectedPlayer then
                targetSpecificUser = selectedPlayer
                targetFlingRole    = nil
                Notify("Fling", "Engaging " .. selectedPlayer.Name)
            else
                isFlinging = false
                Notify("Error", "Select a target first!", 3)
            end
        else
            Notify("Fling", "Stopped")
        end
    end
})

FlingTab:AddToggle({
    Name = "Invisible Fling (Camera Offset)",
    Default = false,
    Callback = function(v)
        invisFling = v
        Notify("Invis Fling", "Camera invis: " .. tostring(v))
    end
})

FlingTab:AddButton({
    Name = "Fling All Players (500ms)",
    Callback = function() task.spawn(flingAllLoop) end
})

FlingTab:AddSection({ Name = "🎛️ Fling Parameters" })
FlingTab:AddSlider({
    Name      = "Fling Power",
    Min       = 1000,
    Max       = 999999,
    Default   = 99999,
    Color     = Color3.fromRGB(255, 80, 0),
    Increment = 1000,
    ValueName = "Force",
    Callback  = function(v) flingPower = v end
})

FlingTab:AddSection({ Name = "🛑 Emergency" })
FlingTab:AddButton({
    Name = "🛑 Kill All Systems",
    Callback = function()
        isFlinging          = false
        targetFlingRole     = nil
        targetSpecificUser  = nil
        autoStealGunEnabled = false
        aimbotEnabled       = false
        flightEnabled       = false
        cframeSpeedEnabled  = false
        local c = LocalPlayer.Character
        if c then showCharacter(c) end
        Notify("SHUTDOWN", "All systems terminated", 4)
    end
})

-- ════════════════════════════════════════════════════════════
-- FE ABILITIES TAB
-- ════════════════════════════════════════════════════════════
FETab:AddSection({ Name = "👻 Invisibility" })
FETab:AddToggle({
    Name = "FE Invisible (Seat Method)",
    Default = false,
    Callback = function(v)
        invis_on = v
        local character = LocalPlayer.Character
        if not character then return end
        local hrp   = character:FindFirstChild("HumanoidRootPart")
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if v then
            if hrp and torso then
                local savedCF = hrp.CFrame
                pcall(function() character:MoveTo(seatTeleportPosition) end)
                task.wait(0.1)
                if not character:FindFirstChild("HumanoidRootPart") or character.HumanoidRootPart.Position.Y < -50 then
                    pcall(function() character:MoveTo(savedCF.Position) end)
                    Notify("Invis Failed", "Void detected — aborted", 3); return
                end
                local Seat = Instance.new("Seat")
                Seat.Anchored     = false
                Seat.CanCollide   = false
                Seat.Transparency = 1
                Seat.Name         = "invischair"
                Seat.Position     = seatTeleportPosition
                Seat.Parent       = Workspace
                local Weld = Instance.new("Weld")
                Weld.Part0  = Seat
                Weld.Part1  = torso
                Weld.Parent = Seat
                task.wait(0.1)
                pcall(function() Seat.CFrame = savedCF end)
                hideCharacter(character)
                Notify("FE Invisible", "Ghost mode active (36% visible)", 3)
            else
                Notify("Error", "Missing HRP or Torso", 3)
            end
        else
            local inv = Workspace:FindFirstChild("invischair")
            if inv then pcall(function() inv:Destroy() end) end
            showCharacter(character)
            Notify("FE Invisible", "Fully visible again", 2)
        end
    end
})

FETab:AddSection({ Name = "🤜 Target Attacks" })
FETab:AddButton({
    Name = "FE Freeze Target",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then Notify("Error", "No target", 3); return end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        if tHRP and hrp then
            local saved = hrp.CFrame
            for i = 1, 10 do hrp.CFrame = tHRP.CFrame; task.wait(0.02) end
            hrp.CFrame = saved
            Notify("FE Freeze", "Freeze attempt sent", 2)
        end
    end
})

FETab:AddButton({
    Name = "FE Launch Upward",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then Notify("Error", "No target", 3); return end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        local hum  = getCharacter():FindFirstChildOfClass("Humanoid")
        if tHRP and hrp and hum then
            local saved = hrp.CFrame
            hum.PlatformStand = true
            hrp.CFrame   = tHRP.CFrame
            hrp.Velocity = Vector3.new(0, 500, 0)
            task.wait(0.15)
            hum.PlatformStand = false
            hrp.CFrame   = saved
            hrp.Velocity = Vector3.zero
            Notify("FE Launch", "Launched upward", 2)
        end
    end
})

FETab:AddButton({
    Name = "FE Void Fling Target",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then Notify("Error", "No target", 3); return end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        local hum  = getCharacter():FindFirstChildOfClass("Humanoid")
        if tHRP and hrp and hum then
            local saved = hrp.CFrame
            hum.PlatformStand = true
            hrp.CFrame   = tHRP.CFrame
            hrp.Velocity = Vector3.new(math.random(-200, 200), -500, math.random(-200, 200))
            task.wait(0.2)
            hum.PlatformStand = false
            hrp.CFrame   = saved
            hrp.Velocity = Vector3.zero
            Notify("Void Fling", "Sent toward void", 2)
        end
    end
})

FETab:AddButton({
    Name = "FE Spin Trap",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then Notify("Error", "No target", 3); return end
        local tHRP = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        local hum  = getCharacter():FindFirstChildOfClass("Humanoid")
        if tHRP and hrp and hum then
            local saved = hrp.CFrame
            hum.PlatformStand = true
            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(0, flingPower, 0)
            bav.MaxTorque       = Vector3.new(math.huge, math.huge, math.huge)
            bav.Parent          = hrp
            for i = 1, 20 do
                if tHRP and tHRP.Parent then hrp.CFrame = tHRP.CFrame; task.wait(0.05) end
            end
            bav:Destroy()
            hum.PlatformStand = false
            hrp.CFrame   = saved
            hrp.Velocity = Vector3.zero
            Notify("Spin Trap", "Complete", 2)
        end
    end
})

FETab:AddToggle({
    Name = "FE Tornado Spin (Self)",
    Default = false,
    Callback = function(v)
        local hrp = getHRP()
        if v and hrp then
            local spin = Instance.new("BodyAngularVelocity")
            spin.Name           = "FETornado"
            spin.MaxTorque      = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, 50, 0)
            spin.Parent         = hrp
            Notify("Tornado", "Spin enabled")
        elseif hrp then
            local s = hrp:FindFirstChild("FETornado")
            if s then s:Destroy() end
            Notify("Tornado", "Spin disabled")
        end
    end
})

FETab:AddButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local list = Players:GetPlayers()
        local rand = list[math.random(1, #list)]
        if rand ~= LocalPlayer and rand.Character and rand.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = getHRP()
            if hrp then hrp.CFrame = rand.Character.HumanoidRootPart.CFrame; Notify("Teleport", "→ " .. rand.Name) end
        end
    end
})

-- ════════════════════════════════════════════════════════════
-- MOVEMENT TAB
-- ════════════════════════════════════════════════════════════
MoveTab:AddSection({ Name = "⚡ Speed" })
MoveTab:AddToggle({ Name = "CFrame Speed Override", Default = false, Callback = function(v) cframeSpeedEnabled = v; Notify("Speed", tostring(v)) end })
MoveTab:AddSlider({ Name = "Speed Multiplier", Min = 1, Max = 30, Default = 5, Color = Color3.fromRGB(255, 136, 0), Increment = 1, ValueName = "×", Callback = function(v) cframeSpeedValue = v end })

MoveTab:AddSection({ Name = "🚀 Flight" })
MoveTab:AddToggle({ Name = "6-Axis Flight", Default = false, Callback = function(v) flightEnabled = v; Notify("Flight", tostring(v)) end })
MoveTab:AddSlider({ Name = "Flight Speed", Min = 20, Max = 200, Default = 50, Color = Color3.fromRGB(0, 183, 255), Increment = 5, ValueName = "studs/s", Callback = function(v) flightSpeed = v end })

MoveTab:AddSection({ Name = "🔧 Physics" })
MoveTab:AddToggle({ Name = "Noclip", Default = false, Callback = function(v) noclipEnabled = v; Notify("Noclip", tostring(v)) end })

-- ════════════════════════════════════════════════════════════
-- VISUALS TAB
-- ════════════════════════════════════════════════════════════
VisTab:AddSection({ Name = "🌟 World" })
VisTab:AddToggle({
    Name = "Map X-Ray",
    Default = false,
    Callback = function(v)
        xrayEnabled = v
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Players) then
                if v then
                    if obj.Transparency == 0 then obj.Transparency = 0.5; obj:SetAttribute("XO", 0) end
                else
                    if obj:GetAttribute("XO") then obj.Transparency = 0; obj:SetAttribute("XO", nil) end
                end
            end
        end
        Notify("X-Ray", tostring(v))
    end
})
VisTab:AddButton({
    Name = "Fullbright",
    Callback = function()
        local l = game:GetService("Lighting")
        l.Ambient         = Color3.fromRGB(255, 255, 255)
        l.OutdoorAmbient  = Color3.fromRGB(255, 255, 255)
        l.Brightness      = 3
        Notify("Fullbright", "Activated")
    end
})

-- ════════════════════════════════════════════════════════════
-- SAFETY TAB
-- ════════════════════════════════════════════════════════════
SafeTab:AddSection({ Name = "🛡️ Anti-Fling" })
SafeTab:AddToggle({ Name = "Anti-Fling (No Collide)", Default = false, Callback = function(v) isAntiFlingEnabled = v; Notify("Anti-Fling", tostring(v)) end })
SafeTab:AddButton({
    Name = "Stabilize Velocity",
    Callback = function()
        local hrp = getHRP()
        if hrp then hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero; Notify("Stabilized", "Velocity zeroed") end
    end
})

SafeTab:AddSection({ Name = "🟥 Anti-Void" })
SafeTab:AddToggle({
    Name = "Anti-Void Floor Plate",
    Default = false,
    Callback = function(v)
        if v then
            if antiVoidPart then return end
            antiVoidPart = Instance.new("Part")
            antiVoidPart.Name        = "AntiVoidPlate"
            antiVoidPart.Size        = Vector3.new(3000, 2, 3000)
            antiVoidPart.Anchored    = true
            antiVoidPart.Transparency = 0.6
            antiVoidPart.CanCollide  = true
            antiVoidPart.BrickColor  = BrickColor.new("Crimson")
            local lowestY = 0
            for _, p in pairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") and p.Position.Y < lowestY then lowestY = p.Position.Y end
            end
            antiVoidPart.Position = Vector3.new(0, lowestY - 20, 0)
            antiVoidPart.Parent   = Workspace
            Notify("Anti-Void", "Floor plate deployed")
        else
            if antiVoidPart then antiVoidPart:Destroy(); antiVoidPart = nil end
            Notify("Anti-Void", "Plate removed")
        end
    end
})

SafeTab:AddSection({ Name = "🔒 God Mode" })
SafeTab:AddToggle({ Name = "God Mode (Infinite Health)", Default = false, Callback = function(v) godModeEnabled = v; if v then enableGodMode() end; Notify("God Mode", tostring(v)) end })

-- ════════════════════════════════════════════════════════════
-- MISC TAB
-- ════════════════════════════════════════════════════════════
MiscTab:AddSection({ Name = "🌐 Server" })
MiscTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        Notify("Server Hop", "Scanning instances...")
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
        end)
        if not ok then Notify("Error", "Failed to fetch servers", 3); return end
        local servers = {}
        for _, v in ipairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            Notify("Server Hop", "No alternate servers found", 3)
        end
    end
})
MiscTab:AddButton({
    Name = "Rejoin",
    Callback = function()
        Notify("Rejoin", "Reconnecting...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- ── Auto-refresh dropdown ────────────────────────────────────
task.spawn(function()
    while true do
        PlayerDropdown:Refresh(updatePlayerList(), true)
        task.wait(2)
    end
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
