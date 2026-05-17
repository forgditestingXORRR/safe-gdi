local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalAudio = SoundService:FindFirstChild("ClientSpotifyAudio") or Instance.new("Sound")
LocalAudio.Name = "ClientSpotifyAudio"
LocalAudio.Parent = SoundService

local DistortionEffect = LocalAudio:FindFirstChild("ClientDistortion") or Instance.new("DistortionSoundEffect")
DistortionEffect.Name = "ClientDistortion"
DistortionEffect.Level = 0
DistortionEffect.Parent = LocalAudio

local Config = {
    Volume = 0.5,
    PlaybackSpeed = 1,
    DistortionLevel = 0,
    Looped = false,
    VisualizerEnabled = true
}

local Window = OrionLib:MakeWindow({
    Name = "CLIENT AUDIO SUITE & CENTURION VISUALIZER", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Initializing Anti-AFK Matrix Architecture"
})

local PlayerTab     = Window:MakeTab({ Name = "Media Player", Icon = "rbxassetid://4483345998" })
local EffectsTab    = Window:MakeTab({ Name = "Audio Matrix", Icon = "rbxassetid://4483345998" })
local VisualizerTab = Window:MakeTab({ Name = "Loudness Meter", Icon = "rbxassetid://4483345998" })
local UtilityTab    = Window:MakeTab({ Name = "System Utilities", Icon = "rbxassetid://4483345998" })

local AudioIDInput = ""
PlayerTab:AddTextbox({
    Name = "Audio Asset ID / Proxy URI",
    Default = "",
    TextDisappear = false,
    Callback = function(Value) AudioIDInput = Value end
})

PlayerTab:AddButton({
    Name = "Load & Play Audio",
    Callback = function()
        local cleanID = AudioIDInput:match("rbxasset://") and AudioIDInput or AudioIDInput:gsub("%D", "")
        
        if cleanID ~= "" then
            LocalAudio:Stop()
            
            if AudioIDInput:match("rbxasset://") then
                LocalAudio.SoundId = AudioIDInput
            else
                LocalAudio.SoundId = "rbxassetid://" .. cleanID
            end
            
            LocalAudio.Volume = Config.Volume
            LocalAudio.PlaybackSpeed = Config.PlaybackSpeed
            LocalAudio.Looped = Config.Looped
            
            task.spawn(function()
                local t = 0
                while not LocalAudio.IsLoaded and t < 4 do
                    t = t + task.wait(0.1)
                end
                
                if LocalAudio.IsLoaded or LocalAudio.TimeLength > 0 then
                    LocalAudio:Play()
                    OrionLib:MakeNotification({
                        Name = "Media Player",
                        Content = "Successfully verified and streaming asset channel.",
                        Time = 3
                    })
                else
                    LocalAudio.TimePosition = 0
                    LocalAudio:Play()
                    
                    task.wait(0.2)
                    if LocalAudio.PlaybackLoudness > 0 or LocalAudio.IsPlaying then
                        OrionLib:MakeNotification({
                            Name = "Media Player",
                            Content = "Streaming via raw unindexed server cache.",
                            Time = 3
                        })
                    else
                        LocalAudio:Stop()
                        OrionLib:MakeNotification({
                            Name = "Asset Error",
                            Content = "This ID is fully restricted or purged from the CDN.",
                            Time = 4
                        })
                    end
                end
            end)
        else
            OrionLib:MakeNotification({
                Name = "Media Error",
                Content = "Invalid Asset path specified.",
                Time = 3
            })
        end
    end
})

PlayerTab:AddButton({ Name = "Pause / Resume Toggle", Callback = function() if LocalAudio.IsPlaying then LocalAudio:Pause() else LocalAudio:Resume() end end })
PlayerTab:AddButton({ Name = "Stop Playback", Callback = function() LocalAudio:Stop() end })
PlayerTab:AddToggle({ Name = "Loop Playback Track", Default = false, Callback = function(State) Config.Looped = State LocalAudio.Looped = State end })
PlayerTab:AddSlider({
    Name = "Master Volume", Min = 0, Max = 10, Default = 5, Increment = 0.5, ValueName = "Gain",
    Callback = function(Value) Config.Volume = Value / 10 LocalAudio.Volume = Config.Volume end
})

EffectsTab:AddSlider({
    Name = "Distortion Level", Min = 0, Max = 10, Default = 0, Increment = 1, ValueName = "Intensity",
    Callback = function(Value) Config.DistortionLevel = Value / 10 DistortionEffect.Level = Config.DistortionLevel end
})
EffectsTab:AddSlider({
    Name = "Playback Pitch/Speed Factor", Min = 5, Max = 30, Default = 10, Increment = 1, ValueName = "SpeedMultiplier",
    Callback = function(Value) Config.PlaybackSpeed = Value / 10 LocalAudio.PlaybackSpeed = Config.PlaybackSpeed end
})

VisualizerTab:AddToggle({ Name = "Render Realtime Loudness Meter", Default = true, Callback = function(State) Config.VisualizerEnabled = State end })

-------------------------------------------------------------------
-- UTILITY TAB (ANTI-AFK SYSTEM)
-------------------------------------------------------------------
local AntiAfkConnection = nil
UtilityTab:AddToggle({
    Name = "Enable Anti-AFK Disconnect Protection",
    Default = false,
    Callback = function(State)
        if State then
            if not AntiAfkConnection then
                local localPlayer = Players.LocalPlayer
                AntiAfkConnection = localPlayer.Idled:Connect(function()
                    local virtualUser = game:GetService("VirtualUser")
                    virtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    virtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end)
                OrionLib:MakeNotification({
                    Name = "Security Protocol",
                    Content = "Anti-AFK active. Idle disconnect protection engaged.",
                    Time = 4
                })
            end
        else
            if AntiAfkConnection then
                AntiAfkConnection:Disconnect()
                AntiAfkConnection = nil
                OrionLib:MakeNotification({
                    Name = "Security Protocol",
                    Content = "Anti-AFK disabled.",
                    Time = 3
                })
            end
        end
    end
})

local CoreGui = game:GetService("CoreGui")
local VisualizerScreen = Instance.new("ScreenGui")
VisualizerScreen.Name = "ClientAudioVisualizerContainer"
VisualizerScreen.ResetOnSpawn = false
VisualizerScreen.Parent = CoreGui

local FrameContainer = Instance.new("Frame")
FrameContainer.Size = UDim2.new(0, 1020, 0, 160)
FrameContainer.Position = UDim2.new(0.5, -510, 0.75, 0)
FrameContainer.BackgroundTransparency = 0.7
FrameContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FrameContainer.BorderSizePixel = 0
FrameContainer.Parent = VisualizerScreen

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = FrameContainer

local TotalBars = 100
local VisualizerBars = {}
local MaxBarHeight = 140
local BarWidth = 8  
local BarSpacing = 10

for i = 1, TotalBars do
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, BarWidth, 0, 2)
    Bar.Position = UDim2.new(0, (i - 1) * BarSpacing + 15, 1, -10)
    Bar.AnchorPoint = Vector2.new(0, 1)
    Bar.BorderSizePixel = 0
    
    if i <= 25 then
        Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    elseif i <= 50 then
        Bar.BackgroundColor3 = Color3.fromRGB(0, 225, 255)
    elseif i <= 75 then
        Bar.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    elseif i <= 93 then
        Bar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    else
        Bar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
    
    Bar.BackgroundTransparency = 0.2
    Bar.Parent = FrameContainer
    table.insert(VisualizerBars, Bar)
end

RunService.RenderStepped:Connect(function()
    if not Config.VisualizerEnabled or not LocalAudio.IsPlaying then
        for _, Bar in pairs(VisualizerBars) do
            TweenService:Create(Bar, TweenInfo.new(0.15), {Size = UDim2.new(0, BarWidth, 0, 2)}):Play()
        end
        return
    end

    local RelativeLoudness = LocalAudio.PlaybackLoudness
    
    for index, Bar in ipairs(VisualizerBars) do
        local TargetHeight = 2
        
        if RelativeLoudness > 0 then
            local FrequencyModifier = math.sin((index / TotalBars) * math.pi)
            
            local GlobalDampeningFactor = 0.6 
            local HighTierClamp = (index > 75) and 0.4 or 1
            
            local GroupIndex = math.floor((index - 1) / 4) + 1
            
            local TimeScale = tick() * (12 + (GroupIndex % 5)) 
            local AsynchronousWave = math.sin(TimeScale + (GroupIndex * 0.5)) * 0.1
            local PerlinNoise = math.noise(GroupIndex * 0.15, tick() * 8) * 0.08
            
            local DistributionFactor = math.clamp(
                ((RelativeLoudness / 500) * FrequencyModifier * GlobalDampeningFactor * HighTierClamp) 
                + AsynchronousWave 
                + PerlinNoise, 
                0, 
                1
            )
            
            TargetHeight = math.clamp(DistributionFactor * MaxBarHeight, 2, MaxBarHeight)
        end
        
        TweenService:Create(Bar, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Size = UDim2.new(0, BarWidth, 0, TargetHeight)}):Play()
    end
end)

VisualizerTab:AddButton({
    Name = "Destroy Framework GUI & Clear Memory",
    Callback = function()
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
        end
        LocalAudio:Stop()
        LocalAudio:Destroy()
        VisualizerScreen:Destroy()
        OrionLib:Destroy()
    end
})

OrionLib:Init()