local _1 = loadstring(game:HttpGet(('\104\116\116\112\115\58\47\47\115\105\114\105\117\115\46\109\101\110\117\47\114\97\121\102\105\101\108\100')))()
local _2 = _1:CreateWindow({
    Name = "\115\117\98\32\50\32\118\97\101\104\122",
    LoadingTitle = "\82\97\121\102\105\101\108\100\32\73\110\116\101\114\102\97\99\101",
    LoadingSubtitle = "\98\121\32\118\97\101\104\122",
    ConfigurationSaving = {Enabled = false, FolderName = nil, FileName = "\66\105\103\72\117\98"},
    Discord = {Enabled = false, Code = "", SaveJoin = false},
    KeySystem = false,
    KeySettings = {Title = "\85\110\116\105\116\108\101\100", Subtitle = "\75\101\121", Note = "", FileName = "\75\101\121", SaveKey = true, GrabKeyFromUrl = "", Key = {"\72\101\108\108\111"}}
})
local _3 = _2:CreateTab("\65\117\116\111\102\97\114\109", 109121102062195)
local _4 = _2:CreateTab("\83\101\116\116\105\110\103\115", 99579688577014)
local _5 = game:GetService("\80\108\97\121\101\114\115").LocalPlayer
getgenv().farming = false
getgenv().farmsettings = {purchase = true, upgrade = true, collect = true, cashdrop = true, fruit = true, buttonesp = true, buttontp = false}
local _6
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:find("\84\121\99\111\111\110") and v:FindFirstChild("\79\119\110\101\114") and v.Owner.Value == _5 then
        _6 = v
        break
    end
end
local _7 = {K = 1e3, M = 1e6, B = 1e9, T = 1e12, Qd = 1e15, Qn = 1e18, Sx = 1e21, Sxd = 1e21, Sp = 1e24, Oc = 1e27, No = 1e30, Dc = 1e33}
local function _8(str)
    local c = str:gsub("[\226\128\128-\226\128\143]", "")
    local m, s = c:match("\37\36\40\91\37\100\37\44\37\46\93\43\41\40\37\97\42\41")
    if not m then return nil end
    local n = tonumber((m:gsub("\44", "")))
    if not n then return nil end
    if s == "" then return n end
    local mult = _7[s]
    if not mult then
        s = s:sub(1,1):upper() .. s:sub(2):lower()
        mult = _7[s]
    end
    return mult and (n * mult) or n
end
local _9 = _6 and _6:FindFirstChild("\80\117\114\99\104\97\115\101\115")
if _6 and _6:FindFirstChild("\82\101\109\111\116\101\115") and _6.Remotes:FindFirstChild("\80\104\111\110\101\79\102\102\101\114") then
    _6.Remotes.PhoneOffer.OnClientEvent:Connect(function()
        if getgenv().farming then _6.Remotes.PhoneOffer:FireServer("\65\99\99\101\112\116") end
    end)
end

local function updateESP(buttonInstance, shouldDisplay)
    local existing = buttonInstance:FindFirstChild("ButtonESP")
    if shouldDisplay and getgenv().farmsettings.buttonesp then
        if not existing then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ButtonESP"
            box.Size = (buttonInstance:IsA("Model") and buttonInstance:GetExtentsSize()) or buttonInstance.Size + Vector3.new(0.1, 0.1, 0.1)
            box.Color3 = Color3.fromRGB(0, 255, 128)
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Adornee = buttonInstance
            box.Transparency = 0.5
            box.Parent = buttonInstance
        end
    else
        if existing then existing:Destroy() end
    end
end

local _10 = _3:CreateToggle({
    Name = "\65\117\116\102\97\114\109",
    CurrentValue = false,
    Flag = "\65\117\116\102\97\114\109\84\111\103\103\108\101",
    Callback = function(val)
        getgenv().farming = val
        if not getgenv().farming or not _6 then return end
        local st = _6:FindFirstChild("\86\97\108\117\101\115") and _6.Values:FindFirstChild("\73\110\99\111\109\101") and _6.Values.Income:FindFirstChild("\83\116\114\101\97\109\115")
        
        task.spawn(function()
            while getgenv().farming and _6 and st do
                if getgenv().farmsettings.collect then
                    for _, v in pairs(st:GetChildren()) do
                        if _6.Remotes:FindFirstChild("\87\97\107\101\73\110\99\111\109\101\83\116\114\101\97\109") then
                            _6.Remotes.WakeIncomeStream:InvokeServer(v.Name)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        
        task.spawn(function()
            while getgenv().farming and _6 and _9 do
                pcall(function()
                    if not getgenv().farmsettings.upgrade then return end
                    for _, fld in pairs(_9:GetChildren()) do
                        local upg = fld:FindFirstChild(fld.Name)
                        if upg and upg:GetAttribute("\69\110\97\98\108\101\100") and upg:FindFirstChild(fld.Name) and upg[fld.Name]:FindFirstChild("\85\112\103\114\97\100\101") then
                            upg[fld.Name].Upgrade:InvokeServer(1)
                        end
                    end
                end)
                task.wait()
            end
        end)

        task.spawn(function()
            while getgenv().farming and _6 and _9 do
                pcall(function()
                    for _, fld in pairs(_9:GetChildren()) do
                        if fld:FindFirstChild("\66\117\116\116\111\110\115") then
                            for _, z in pairs(fld.Buttons:GetChildren()) do
                                if z:IsA("\70\111\108\100\101\114") then
                                    for _, btn in pairs(z:GetChildren()) do
                                        if btn:GetAttribute("\83\104\111\119\110") and btn:GetAttribute("\69\110\97\98\108\101\100") and not btn:GetAttribute("\80\117\114\99\104\97\115\101\100") and btn:FindFirstChild("\66\117\116\116\111\110") and btn.Button:FindFirstChild("\71\117\105") and btn.Button.Gui:FindFirstChild("\80\114\105\99\101") then
                                            local prc = _8(btn.Button.Gui.Price.Text)
                                            local csh = _5:FindFirstChild("\108\101\97\100\101\114\115\116\97\116\115") and _5.leaderstats:FindFirstChild("\67\97\115\104") and _8(tostring(_5.leaderstats.Cash.Value))
                                            
                                            local affordable = prc and csh and prc <= csh
                                            updateESP(btn.Button, affordable)

                                            if affordable and getgenv().farmsettings.purchase then
                                                if getgenv().farmsettings.buttontp and _5.Character and _5.Character:FindFirstChild("HumanoidRootPart") then
                                                    _5.Character.HumanoidRootPart.CFrame = btn.Button.CFrame + Vector3.new(0, 2, 0)
                                                    task.wait(0.05)
                                                end
                                                if _5.Character and _5.Character:FindFirstChild("\72\101\97\100") then
                                                    firetouchinterest(_5.Character.Head, btn.Button, true) task.wait() firetouchinterest(_5.Character.Head, btn.Button, false)
                                                end
                                            end
                                        end
                                    end
                                elseif z:IsA("\77\111\100\101\108") then
                                    if z:GetAttribute("\83\104\111\119\110") and z:GetAttribute("\69\110\97\98\108\101\100") and not z:GetAttribute("\80\117\114\99\104\97\115\101\100") and z:FindFirstChild("\66\117\116\116\111\110") and z.Button:FindFirstChild("\71\117\105") and z.Button.Gui:FindFirstChild("\80\114\105\99\101") then
                                        local prc = _8(z.Button.Gui.Price.Text)
                                        local csh = _5:FindFirstChild("\108\101\97\100\101\114\115\116\97\116\115") and _5.leaderstats:FindFirstChild("\67\97\115\104") and _8(tostring(_5.leaderstats.Cash.Value))
                                        
                                        local affordable = prc and csh and prc <= csh
                                        updateESP(z.Button, affordable)

                                        if affordable and getgenv().farmsettings.purchase then
                                            if getgenv().farmsettings.buttontp and _5.Character and _5.Character:FindFirstChild("HumanoidRootPart") then
                                                _5.Character.HumanoidRootPart.CFrame = z.Button.CFrame + Vector3.new(0, 2, 0)
                                                task.wait(0.05)
                                            end
                                            if _5.Character and _5.Character:FindFirstChild("\72\101\97\100") then
                                                firetouchinterest(_5.Character.Head, z.Button, true) task.wait() firetouchinterest(_5.Character.Head, z.Button, false)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                pcall(function()
                    if not getgenv().farmsettings.cashdrop then return end
                    local cd = workspace:FindFirstChild("\67\97\115\104\68\114\111\112\115")
                    if cd then
                        for _, v in pairs(cd:GetChildren()) do
                            if _5.Character and _5.Character:FindFirstChild("\72\101\97\100") then
                                firetouchinterest(_5.Character.Head, v, true) task.wait() firetouchinterest(_5.Character.Head, v, false)
                            end
                        end
                    end
                end)
                pcall(function()
                    if not getgenv().farmsettings.fruit then return end
                    local tr = _6:FindFirstChild("\67\111\110\115\116\97\110\116") and _6.Constant:FindFirstChild("\84\114\101\101\115")
                    if tr then
                        for _, t in pairs(tr:GetChildren()) do
                            for _, fr in pairs(t:GetChildren()) do
                                if fr.Name == "\70\114\117\105\116" then
                                    local pt = fr:FindFirstChild("\67\108\105\99\107\80\97\114\116")
                                    local det = pt and pt:FindFirstChild("\67\108\105\99\107\68\101\116\101\99\116\111\114")
                                    if det then
                                        fireclickdetector(det)
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.2)
            end
        end)
    end
})
local _11 = _3:CreateLabel("\83\101\116\116\105\110\103\115\58")
local _12 = _3:CreateToggle({Name = "\65\117\116\111\32\80\117\114\99\104\97\115\101", CurrentValue = true, Flag = "\65\117\116\111\80\117\114\99\104\97\115\101", Callback = function(v) getgenv().farmsettings.purchase = v end})
local _13 = _3:CreateToggle({Name = "\65\117\116\111\32\67\111\108\108\101\99\116", CurrentValue = true, Flag = "\65\117\116\111\67\111\108\108\101\99\116", Callback = function(v) getgenv().farmsettings.collect = v end})
local _14 = _3:CreateToggle({Name = "\65\117\116\111\32\85\112\103\114\97\100\101", CurrentValue = true, Flag = "\65\117\116\111\85\112\103\114\97\100\101", Callback = function(v) getgenv().farmsettings.upgrade = v end})
local _15 = _3:CreateToggle({Name = "\65\117\116\111\32\67\97\115\104\32\68\114\111\112", CurrentValue = true, Flag = "\65\117\116\111\67\97\115\104\68\114\111\112", Callback = function(v) getgenv().farmsettings.cashdrop = v end})
local _16 = _3:CreateToggle({Name = "\65\117\116\111\32\80\105\101\107\117\112\32\70\114\117\105\116", CurrentValue = true, Flag = "\65\117\116\111\80\105\99\107\117\112\70\114\117\105\116", Callback = function(v) getgenv().farmsettings.fruit = v end})
local _19 = _3:CreateToggle({Name = "\66\117\116\116\111\110\32\69\83\80\32\40\65\102\102\111\114\100\97\98\108\101\41", CurrentValue = true, Flag = "\66\117\116\116\111\110\69\83\80", Callback = function(v) getgenv().farmsettings.buttonesp = v end})
local _20 = _3:CreateToggle({Name = "\65\117\116\111\32\84\80\32\116\111\32\66\117\116\116\111\110", CurrentValue = false, Flag = "\65\117\116\111\84\80\66\117\116\116\111\110", Callback = function(v) getgenv().farmsettings.buttontp = v end})

getgenv().antiafk = true
_5.Idled:Connect(function()
    if getgenv().antiafk then
        game:GetService("\86\105\114\116\117\97\108\85\115\101\114"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        game:GetService("\86\105\114\116\117\97\108\85\115\101\114"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)
local _17 = _4:CreateToggle({Name = "\68\105\115\97\98\108\101\32\51\68\32\82\101\110\100\101\114\105\110\103", CurrentValue = false, Flag = "\68\105\115\97\98\108\101\51\68", Callback = function(v) game:GetService("\82\117\110\83\101\114\118\105\99\101"):Set3dRenderingEnabled(not v) end})
local _18 = _4:CreateToggle({Name = "\65\110\116\105\32\65\70\75", CurrentValue = true, Flag = "\65\110\116\105\65\70\75", Callback = function(v) getgenv().antiafk = v end})
