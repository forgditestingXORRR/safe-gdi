local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
                return true  -- Username matches, user is premium
            end
        end
    end
    return false  -- No match found
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
 
local Window = OrionLib:MakeWindow({Name = "FE Fling v2 - MM2 Edition", HidePremium = true, SaveConfig = true, ConfigFolder = "FEFlingV2"})
local MM2Tab = Window:MakeTab({Name = "MM2 Games", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local FlingTab = Window:MakeTab({Name = "Fling", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AntiVoidTab = Window:MakeTab({Name = "Anti Void", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AntiFlingTab = Window:MakeTab({Name = "Anti Fling", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
 
local selectedPlayer
local PlayerDropdown
local isFlinging = false
local originalCameraSubject
local originalCharacterPos
local isAntiFlingEnabled = false
local flingPower = 9999
local flingRadius = 1
local invisFling = false

-- MM2 Feature States
local roleEspEnabled = false
local gunEspEnabled = false
local aimbotEnabled = false
local autoStealGunEnabled = false
local targetFlingRole = nil -- Tracks group flings ("Murderer", "Sheriff", "Innocent", "AllInnocents")
local targetSpecificUser = nil

-- Function to get character and HumanoidRootPart
local function getCharacter()
    local character = LocalPlayer.Character
    if not character then
        repeat
            character = LocalPlayer.Character
            task.wait()
        until character
    end
    return character
end
 
local function getHumanoidRootPart()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart")
end
 
-- Function to update player list
local function updatePlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- Helper functions to detect MM2 Roles via Backpack/Character items
local function getPlayerRole(player)
    if not player then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    local hasKnife = (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))
    local hasGun = (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))
    
    if hasKnife then
        return "Murderer"
    elseif hasGun then
        if backpack and backpack:FindFirstChild("Gun") and backpack.Gun:FindFirstChild("PinkThemed") then
            return "Sheriff"
        end
        return "Sheriff"
    else
        return "Innocent"
    end
end

-- Get role color for ESP Highlights
local function getRoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0) end
    if role == "Sheriff" then return Color3.fromRGB(0, 0, 255) end
    if role == "Hero" then return Color3.fromRGB(255, 255, 0) end
    return Color3.fromRGB(0, 255, 0) -- Innocent
end

-- Position prediction mechanism (3 studs prediction forward when walking, 0 studs when still/airborne)
local function getPredictedPosition(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return nil end
    local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return nil end
    
    if humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
        return rootPart.Position + (humanoid.MoveDirection * 3)
    else
        return rootPart.Position
    end
end

-- Universal Fling Core Function (Patched with dynamic linear constraints)
local function performFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
 
    local character = getCharacter()
    local humanoidRootPart = getHumanoidRootPart()
 
    originalCameraSubject = Camera.CameraSubject
    originalCharacterPos = humanoidRootPart.CFrame
 
    if not invisFling then
        local tHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if tHum then Camera.CameraSubject = tHum end
    end
    
    -- High power body mechanics injection to bypass client-side tracking overrides
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
 
    while isFlinging and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
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
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.Health = character.Humanoid.MaxHealth
    end
    
    humanoidRootPart = getHumanoidRootPart()
    humanoidRootPart.CFrame = originalCharacterPos
    humanoidRootPart.Velocity = Vector3.zero
    humanoidRootPart.RotVelocity = Vector3.zero
end

-- Loop handler for specialized Group Flings
task.spawn(function()
    while true do
        if isFlinging and targetFlingRole then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(p)
                    local shouldFling = false
                    
                    if targetFlingRole == "Murderer" and role == "Murderer" then shouldFling = true
                    elseif targetFlingRole == "Sheriff" and role == "Sheriff" then shouldFling = true
                    elseif targetFlingRole == "Innocent" and role == "Innocent" then shouldFling = true
                    elseif targetFlingRole == "AllInnocents" and (role == "Innocent" or role == "Hero") then shouldFling = true
                    end
                    
                    if shouldFling then
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

-- 300ms Refresh Loop for Role ESP Chams (Handles joins, leaves, and dynamic role changes)
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
        task.wait(0.3)
    end
end)

-- Gun ESP Logic
task.spawn(function()
    while true do
        if gunEspEnabled then
            local droppedGun = Workspace:FindFirstChild("GunDrop")
            if droppedGun and droppedGun:IsA("BasePart") then
                local highlight = droppedGun:FindFirstChild("GunESP_Cham")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "GunESP_Cham"
                    highlight.Parent = droppedGun
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        else
            local droppedGun = Workspace:FindFirstChild("GunDrop")
            if droppedGun and droppedGun:FindFirstChild("GunESP_Cham") then
                droppedGun.GunESP_Cham:Destroy()
            end
        end
        task.wait(0.5)
    end
end)

-- Manual/Auto Gun Steal Logic
local function stealGun()
    local droppedGun = Workspace:FindFirstChild("GunDrop")
    if droppedGun and droppedGun:IsA("BasePart") then
        local hrp = getHumanoidRootPart()
        if hrp then
            local oldCFrame = hrp.CFrame
            hrp.CFrame = droppedGun.CFrame
            task.wait(0.1)
            hrp.CFrame = oldCFrame
        end
    end
end

task.spawn(function()
    while true do
        if autoStealGunEnabled then
            stealGun()
        end
        task.wait(0.2)
    end
end)

-- Fixed Aimbot Logic (Locks CFrame explicitly onto Murderer Head Part)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if getPlayerRole(p) == "Murderer" then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end
end)

--- ==========================================================
--- MM2 GAMES UI COMPONENTS
--- ==========================================================

MM2Tab:AddToggle({
    Name = "Role ESP (Backpack Based)",
    Default = false,
    Callback = function(Value)
        roleEspEnabled = Value
    end
})

MM2Tab:AddToggle({
    Name = "Gun ESP",
    Default = false,
    Callback = function(Value)
        gunEspEnabled = Value
    end
})

MM2Tab:AddToggle({
    Name = "Aimbot (Lock onto Murderer)",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end
})

MM2Tab:AddButton({
    Name = "Steal Dropped Gun",
    Callback = function()
        stealGun()
    end
})

MM2Tab:AddToggle({
    Name = "Auto Steal Gun",
    Default = false,
    Callback = function(Value)
        autoStealGunEnabled = Value
    end
})

MM2Tab:AddButton({
    Name = "Hide (Spawn in Lobby)",
    Callback = function()
        local lobbySpawn = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("SpawnLocation") 
            or Workspace:FindFirstChild("SpawnLocation")
        local hrp = getHumanoidRootPart()
        if hrp and lobbySpawn then
            hrp.CFrame = lobbySpawn.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

MM2Tab:AddButton({
    Name = "Fling Murderer",
    Callback = function()
        isFlinging = true
        targetFlingRole = "Murderer"
        targetSpecificUser = nil
    end
})

MM2Tab:AddButton({
    Name = "Fling Sheriff",
    Callback = function()
        isFlinging = true
        targetFlingRole = "Sheriff"
        targetSpecificUser = nil
    end
})

MM2Tab:AddButton({
    Name = "Fling All Innocents",
    Callback = function()
        isFlinging = true
        targetFlingRole = "AllInnocents"
        targetSpecificUser = nil
    end
})

MM2Tab:AddTextbox({
    Name = "Fling via Username/Display",
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

MM2Tab:AddButton({
    Name = "🛑 STOP ALL ACTION / FLINGS",
    Callback = function()
        isFlinging = false
        targetFlingRole = nil
        targetSpecificUser = nil
        autoStealGunEnabled = false
        aimbotEnabled = false
    end
})

--- ==========================================================
--- PRE-EXISTING UI ELEMENTS
--- ==========================================================

PlayerDropdown = FlingTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = updatePlayerList(),
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value)
    end    
})
 
FlingTab:AddToggle({
    Name = "Fling Player",
    Default = false,
    Callback = function(Value)
        isFlinging = Value
        if isFlinging then
            if selectedPlayer then
                targetSpecificUser = selectedPlayer
                targetFlingRole = nil
            else
                OrionLib:MakeNotification({
                    Name = "Fling Error",
                    Content = "Please select a player first!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
                FlingTab:GetToggle("Fling Player").Set(false)
            end
        end
    end,
})
 
FlingTab:AddTextbox({
    Name = "Fling Power",
    Default = "9999",
    TextDisappear = false,
    Callback = function(Value)
        local newPower = tonumber(Value)
        if newPower and newPower > 0 then
            flingPower = newPower
        else
            OrionLib:MakeNotification({
                Name ="Invalid Input",
                Content ="Please enter a valid number greater than 0 for Fling Power.",
                Image ="rbxassetid://4483345998",
                Time=3,
            })
        end 
   end,
})
 
FlingTab:AddTextbox({
   Name ="Fling Radius",
   Default ="1",
   TextDisappear=false,
   Callback=function(Value)
       local newRadius=tonumber(Value)
       if newRadius and newRadius>0 then 
           flingRadius=newRadius 
       else 
           OrionLib:MakeNotification({
               Name="Invalid Input",
               Content="Please enter a valid number greater than 0 for Fling Radius.",
               Image="rbxassetid://4483345998",
               Time=3,
           }) 
       end 
   end,
})
 
FlingTab:AddToggle({
   Name="Invisible Fling",
   Default=false,
   Callback=function(Value) 
       invisFling = Value 
   end,
})
 
local function updateDropdown()
   PlayerDropdown:Refresh(updatePlayerList(), true) 
end 
 
Players.PlayerAdded:Connect(updateDropdown) 
Players.PlayerRemoving:Connect(updateDropdown)
 
task.spawn(function() 
   while true do 
       updateDropdown() 
       task.wait(1) 
   end 
end)
 
local antiVoidPart 
 
local function createAntiVoid() 
   if antiVoidPart then return end 
 
   antiVoidPart=Instance.new("Part") 
   antiVoidPart.Name="AntiVoidPart" 
   antiVoidPart.Size=Vector3.new(2048, 1, 2048) 
   antiVoidPart.Anchored=true 
   antiVoidPart.Transparency=0.5 
   antiVoidPart.CanCollide=true  
   antiVoidPart.BrickColor=BrickColor.new("Really blue")  
 
   local lowestY=math.huge  
   for _, part in pairs(Workspace:GetDescendants()) do  
       if part:IsA("BasePart") then  
           lowestY=math.min(lowestY, part.Position.Y)  
       end  
   end  
   antiVoidPart.Position=Vector3.new(0, lowestY - 5, 0)  
 
   antiVoidPart.Parent=Workspace  
end 
 
local function removeAntiVoid() 
   if antiVoidPart then  
       antiVoidPart:Destroy()  
       antiVoidPart=nil  
   end  
end 
 
AntiVoidTab:AddToggle({ 
   Name="Anti Void", 
   Default=false, 
   Callback=function(Value)  
       if Value then  
           createAntiVoid()  
       else  
           removeAntiVoid()  
       end  
   end  
})
 
local function disableLocalPlayerCollisions() 
   local character=getCharacter() 
   for _, part in pairs(character:GetDescendants()) do  
       if part:IsA("BasePart") then  
           part.CanCollide=false  
       end   
   end   
end 
 
local function enableLocalPlayerCollisions() 
   local character=getCharacter() 
   for _, part in pairs(character:GetDescendants()) do  
       if part:IsA("BasePart") then  
           part.CanCollide=true  
       end   
   end   
end 
 
local function performAntiFling() 
   disableLocalPlayerCollisions()
 
   while isAntiFlingEnabled do  
       RunService.Heartbeat:Wait()  
   end  
 
   enableLocalPlayerCollisions()   
end 
 
AntiFlingTab:AddToggle({ 
   Name="Enable Anti Fling", 
   Default=false, 
   Callback=function(Value)  
       isAntiFlingEnabled=Value  
       if isAntiFlingEnabled then  
           performAntiFling()  
       else  
           enableLocalPlayerCollisions()  
       end  
   end  
})
 
local isSuperJumpEnabled=false
 
MiscTab:AddToggle({ 
   Name="Super Jump", 
   Default=false, 
   Callback=function(Value) 
       isSuperJumpEnabled=Value 
       local character=getCharacter() 
       if character and character:FindFirstChild("Humanoid") then 
           character.Humanoid.JumpPower=isSuperJumpEnabled and 100 or 50 
       end 
   end  
})
 
local isSpeedEnabled=false
 
MiscTab:AddToggle({ 
   Name="Speed Boost", 
   Default=false, 
   Callback=function(Value) 
       isSpeedEnabled=Value 
       local character=getCharacter() 
       if character and character:FindFirstChild("Humanoid") then 
           character.Humanoid.WalkSpeed=isSpeedEnabled and 32 or 16 
       end  
   end  
})
 
MiscTab:AddButton({ 
   Name="Teleport to Random Player", 
   Callback=function() 
       local players=Players:GetPlayers() 
       local randomPlayer=players[math.random(1, #players)] 
       if randomPlayer~=LocalPlayer and randomPlayer.Character then 
           local character=getCharacter() 
           character:SetPrimaryPartCFrame(randomPlayer.Character.PrimaryPart.CFrame)         
       end     
     end     
})
 
local noclipEnabled=false
 
MiscTab:AddToggle({    
     Name="Noclip",    
     Default=false,    
     Callback=function(Value)    
         noclipEnabled=Value    
         if noclipEnabled then    
             RunService:BindToRenderStep("Noclip", 0, function()    
                 local character=getCharacter()    
                 if character and character:FindFirstChild("Humanoid") then    
                     character.Humanoid:ChangeState(11)    
                 end    
             end)    
         else    
             RunService:UnbindFromRenderStep("Noclip")    
         end    
     end    
})
 
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
     local humanoid=newCharacter:WaitForChild("Humanoid")
     
     if isSuperJumpEnabled then     
         humanoid.JumpPower=100     
     end     
     
     if isSpeedEnabled then     
         humanoid.WalkSpeed=32     
     end     
     
     if isAntiFlingEnabled then     
         disableLocalPlayerCollisions()     
     end     
end)
 
local iPlayer={}
 
function iPlayer:premium()
     return isPremiumUser()
end
 
OrionLib:Init()