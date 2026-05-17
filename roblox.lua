local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- // Configuration & States
local AimbotEnabled = false
local TeamCheck = true
local FOVRadius = 100
local ShowFOV = false
local ESPEnabled = false

local CFrameSpeedEnabled = false
local SpeedValue = 5
local InfJumpEnabled = false
local NoclipEnabled = false

-- // Mouse Trigger State
local IsMouseButtonDown = false

-- // Services & Instances
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Draw Engine FOV Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 136)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- // Window Lifecycle Initializer
local Window = OrionLib:MakeWindow({
    Name = "RIVALS MECHANICS DEVELOPMENT", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Initializing Interface Framework"
})

local CombatTab = Window:MakeTab({
    Name = "Combat Core",
    Icon = "rbxassetid://4483345998",
    Premium = false
})

local MovementTab = Window:MakeTab({
    Name = "Movement Core",
    Icon = "rbxassetid://4483345998",
    Premium = false
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals Core",
    Icon = "rbxassetid://4483345998",
    Premium = false
})

-------------------------------------------------------------------
-- SYSTEMS CORE FUNCTIONS
-------------------------------------------------------------------
local function FetchValidTarget()
    local CurrentTarget = nil
    local MinDistance = FOVRadius
    local MouseLocation = UserInputService:GetMouseLocation()

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local headPart = targetPlayer.Character:FindFirstChild("Head")
            local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if headPart and humanoid and humanoid.Health > 0 then
                if not TeamCheck or targetPlayer.Team ~= LocalPlayer.Team then
                    local ScreenPosition, TargetVisible = Camera:WorldToViewportPoint(headPart.Position)
                    if TargetVisible then
                        local ScreenDistance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MouseLocation).Magnitude
                        
                        if ScreenDistance < MinDistance then
                            MinDistance = ScreenDistance
                            CurrentTarget = headPart
                        end
                    end
                end
            end
        end
    end
    return CurrentTarget
end

local function ApplyCharacterHighlight(character)
    if not character:FindFirstChild("SystemHighlightInstance") then
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "SystemHighlightInstance"
        Highlight.FillColor = Color3.fromRGB(0, 255, 136)
        Highlight.FillTransparency = 0.4
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.OutlineTransparency = 0
        Highlight.Parent = character
    end
end

local function PurgeCharacterHighlight(character)
    local TargetHighlight = character:FindFirstChild("SystemHighlightInstance")
    if TargetHighlight then
        TargetHighlight:Destroy()
    end
end

-------------------------------------------------------------------
-- CONTROLS AND INTERFACE DEFINITIONS
-------------------------------------------------------------------
CombatTab:AddToggle({
    Name = "Mouse Triggered Aimbot",
    Default = false,
    Callback = function(State)
        AimbotEnabled = State
    end    
})

CombatTab:AddToggle({
    Name = "Team Alignment Filter",
    Default = true,
    Callback = function(State)
        TeamCheck = State
    end    
})

CombatTab:AddSlider({
    Name = "Detection Field Radius",
    Min = 30,
    Max = 400,
    Default = 100,
    Color = Color3.fromRGB(0, 255, 136),
    Increment = 5,
    ValueName = "Pixels",
    Callback = function(Value)
        FOVRadius = Value
    end    
})

CombatTab:AddToggle({
    Name = "Render Field Boundaries",
    Default = false,
    Callback = function(State)
        ShowFOV = State
    end    
})

MovementTab:AddToggle({
    Name = "CFrame Vector Translation",
    Default = false,
    Callback = function(State)
        CFrameSpeedEnabled = State
    end
})

MovementTab:AddSlider({
    Name = "Translation Magnitude (Speed)",
    Min = 1,
    Max = 5337,
    Default = 5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Factor",
    Callback = function(Value)
        SpeedValue = Value
    end
})

MovementTab:AddToggle({
    Name = "Infinite Jump State Bypass",
    Default = false,
    Callback = function(State)
        InfJumpEnabled = State
    end
})

MovementTab:AddToggle({
    Name = "Spatial Clipping Bypass (Noclip)",
    Default = false,
    Callback = function(State)
        NoclipEnabled = State
    end
})

VisualsTab:AddToggle({
    Name = "Enclosed Target Outlining (ESP)",
    Default = false,
    Callback = function(State)
        ESPEnabled = State
        if not State then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    PurgeCharacterHighlight(player.Character)
                end
            end
        end
    end    
})

-------------------------------------------------------------------
-- LIFECYCLE EXECUTION LOOPS
-------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsMouseButtonDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsMouseButtonDown = false
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled then
        local localCharacter = LocalPlayer.Character
        local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
        if localHumanoid then
            localHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- High Priority Camera Lock Loop to override game calculations
RunService:BindToRenderStep("CameraLockSystem", Enum.RenderPriority.Camera.Value + 1, function()
    if AimbotEnabled and IsMouseButtonDown then
        local ActiveTarget = FetchValidTarget()
        if ActiveTarget then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, ActiveTarget.Position)
        end
    end
end)

-- Standard Loop for Movement and UI Elements
RunService.RenderStepped:Connect(function()
    local LocalCharacter = LocalPlayer.Character
    if not LocalCharacter then return end
    
    local LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid")
    local LocalHRP = LocalCharacter:FindFirstChild("HumanoidRootPart")
    local MouseLocation = UserInputService:GetMouseLocation()

    if ShowFOV then
        FOVCircle.Position = MouseLocation
        FOVCircle.Radius = FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if CFrameSpeedEnabled and LocalHRP and LocalHumanoid then
        if LocalHumanoid.MoveDirection.Magnitude > 0 then
            LocalHRP.CFrame = LocalHRP.CFrame + (LocalHumanoid.MoveDirection * (SpeedValue / 1000))
        end
    end

    if NoclipEnabled then
        for _, object in pairs(LocalCharacter:GetDescendants()) do
            if object:IsA("BasePart") then
                object.CanCollide = false
            end
        end
    end

    if ESPEnabled then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                local currentHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if currentHumanoid and currentHumanoid.Health > 0 then
                    if not TeamCheck or targetPlayer.Team ~= LocalPlayer.Team then
                        ApplyCharacterHighlight(targetPlayer.Character)
                    else
                        PurgeCharacterHighlight(targetPlayer.Character)
                    end
                else
                    PurgeCharacterHighlight(targetPlayer.Character)
                end
            end
        end
    end
end)

OrionLib:Init()