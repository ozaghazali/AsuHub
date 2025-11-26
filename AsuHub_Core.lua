-- ===================================================================
-- [[ SYSTEM: ANTI-DOUBLE EXECUTE & CLEANUP (FIXED) ]]
-- ===================================================================

-- Hentikan sesi lama sebelum memulai yang baru
if getgenv().AsuHub_Session then
    if getgenv().AsuHub_Session.Matikan then
        getgenv().AsuHub_Session.Matikan()
    end
    task.wait(0.1)
end

local SessionConnections = {} 
local SessionStop = false     

local function CleanupSession()
    SessionStop = true -- Sinyal untuk mematikan semua loop (Fly/Platform)
    
    -- 1. Putuskan Koneksi
    for _, conn in pairs(SessionConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect()
        elseif type(conn) == "thread" then task.cancel(conn) end
    end
    
    -- 2. Reset Karakter (PERBAIKAN KARAKTER KAKU)
    local plr = game:GetService("Players").LocalPlayer
    if plr and plr.Character then
        local char = plr.Character
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")

        -- Hapus Part Script
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v.Name == "AsuHub_FlyGyro" or v.Name == "AsuHub_FlyVelocity" then
                    v:Destroy()
                end
            end
        end
        
        local plat = game:GetService("Workspace"):FindFirstChild("AsuHub_Platform")
        if plat then plat:Destroy() end

        -- KEMBALIKAN STATE HUMANOID
        if hum then 
            hum.PlatformStand = false 
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    -- 3. Hapus GUI
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("AsuHub") then CoreGui.AsuHub:Destroy() end
    if CoreGui:FindFirstChild("AsuHub_ESP_Holder") then CoreGui.AsuHub_ESP_Holder:Destroy() end
end

getgenv().AsuHub_Session = { Matikan = CleanupSession }

local function TrackConn(c) table.insert(SessionConnections, c); return c end
local function TrackCoroutine(c) table.insert(SessionConnections, c); return c end

-- ===================================================================
-- [[ SERVICES & VARIABLES ]]
-- ===================================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mouse = player:GetMouse()

-- Wait for LocalPlayer to be fully loaded if not ready
if not player then
    player = game.Players.LocalPlayer or game.Players.PlayerAdded:Wait()
end

-- Wait for Character if nil
local character = player.Character
if not character then
    character = player.CharacterAdded:Wait()
end

-- Now proceed with humanoid check
local humanoid = character:WaitForChild("Humanoid")
local isR15 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R15

-- Teleport Function
local function teleportCharacter(character, position)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- ===================================================================
-- [[ FREECAM MODULE ]]
-- ===================================================================

local FreecamModule = (function()
    local v1 = {}
    local v_u_3 = math.abs
    local v_u_4 = math.clamp
    local v_u_5 = math.exp
    local v_u_6 = math.rad
    local v_u_7 = math.sign
    local v_u_8 = math.sqrt
    local v_u_9 = math.tan
    local v_u_10 = game:GetService("ContextActionService")
    local v11 = game:GetService("Players")
    local v_u_12 = game:GetService("RunService")
    local v_u_13 = game:GetService("StarterGui")
    local v_u_14 = game:GetService("UserInputService")
    local v_u_15 = game:GetService("Workspace")
    local v_u_16 = v11.LocalPlayer
    if not v_u_16 then
        v11:GetPropertyChangedSignal("LocalPlayer"):Wait()
        v_u_16 = v11.LocalPlayer
    end
    local v_u_17 = v_u_15.CurrentCamera
    v_u_15:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local v18 = v_u_15.CurrentCamera
        if v18 then
            v_u_17 = v18
        end
    end)
    local v_u_19 = Enum.ContextActionPriority.High.Value
    local v_u_20 = Vector2.new(0.75, 1) * 8
    local v_u_21 = {}
    v_u_21.__index = v_u_21
    function v_u_21.new(p22, p23)
        local v24 = v_u_21
        local v25 = setmetatable({}, v24)
        v25.f = p22
        v25.p = p23
        v25.v = p23 * 0
        return v25
    end
    function v_u_21.Update(p26, p27, p28)
        local v29 = p26.f * 2 * 3.141592653589793
        local v30 = p26.p
        local v31 = p26.v
        local v32 = p28 - v30
        local v33 = v_u_5(-v29 * p27)
        local v34 = p28 + (v31 * p27 - v32 * (v29 * p27 + 1)) * v33
        local v35 = (v29 * p27 * (v32 * v29 - v31) + v31) * v33
        p26.p = v34
        p26.v = v35
        return v34
    end
    function v_u_21.Reset(p36, p37)
        p36.p = p37
        p36.v = p37 * 0
    end
    local v_u_38 = Vector3.new()
    local v_u_39 = Vector2.new()
    local v_u_40 = 0
    local v_u_41 = v_u_21.new(1.5, (Vector3.new()))
    local v_u_42 = v_u_21.new(1, Vector2.new())
    local v_u_43 = v_u_21.new(4, 0)
    local v_u_44 = {}
    local function v_u_46(p45)
        return v_u_7(p45) * v_u_4((v_u_5(2 * ((v_u_3(p45) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
    end
    local v_u_47 = { ButtonX = 0, ButtonY = 0, DPadDown = 0, DPadUp = 0, ButtonL2 = 0, ButtonR2 = 0, Thumbstick1 = Vector2.new(), Thumbstick2 = Vector2.new() }
    local v_u_48 = { W = 0, A = 0, S = 0, D = 0, E = 0, Q = 0, U = 0, H = 0, J = 0, K = 0, I = 0, Y = 0, Up = 0, Down = 0, LeftShift = 0, RightShift = 0 }
    local v_u_49 = { Delta = Vector2.new(), MouseWheel = 0 }
    local v_u_50 = Vector2.new(1, 1) * 0.04908738521234052
    local v_u_51 = Vector2.new(1, 1) * 0.39269908169872414
    local v_u_52 = 1
    function v_u_44.Vel(p53)
        v_u_52 = v_u_4(v_u_52 + p53 * (v_u_48.Up - v_u_48.Down) * 0.75, 0.01, 4)
        local v54 = v_u_46(v_u_47.Thumbstick1.X)
        local v55 = v_u_46(v_u_47.ButtonR2) - v_u_46(v_u_47.ButtonL2)
        local v56 = v_u_46
        local v57 = -v_u_47.Thumbstick1.Y
        local v58 = Vector3.new(v54, v55, v56(v57)) * Vector3.new(1, 1, 1)
        local v59 = v_u_48.D - v_u_48.A + v_u_48.K - v_u_48.H
        local v60 = v_u_48.E - v_u_48.Q + v_u_48.I - v_u_48.Y
        local v61 = v_u_48.S - v_u_48.W + v_u_48.J - v_u_48.U
        local v62 = Vector3.new(v59, v60, v61) * Vector3.new(1, 1, 1)
        local v63 = v_u_14:IsKeyDown(Enum.KeyCode.LeftShift) or v_u_14:IsKeyDown(Enum.KeyCode.RightShift)
        return (v58 + v62) * (v_u_52 * (v63 and 0.25 or 1))
    end
    function v_u_44.Pan(_)
        local v64 = Vector2.new(v_u_46(v_u_47.Thumbstick2.Y), v_u_46(-v_u_47.Thumbstick2.X)) * v_u_51
        local v65 = v_u_49.Delta * v_u_50
        v_u_49.Delta = Vector2.new()
        return v64 + v65
    end
    function v_u_44.Fov(_)
        local v66 = (v_u_47.ButtonX - v_u_47.ButtonY) * 0.25
        local v67 = v_u_49.MouseWheel * 1
        v_u_49.MouseWheel = 0
        return v66 + v67
    end
    local function v_u_70(_, p68, p69)
        v_u_48[p69.KeyCode.Name] = p68 == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
    end
    local function v_u_73(_, p71, p72)
        v_u_47[p72.KeyCode.Name] = p71 == Enum.UserInputState.Begin and 1 or 0
        return Enum.ContextActionResult.Sink
    end
    local function v_u_76(_, _, p74)
        local v75 = p74.Delta
        v_u_49.Delta = Vector2.new(-v75.y, -v75.x)
        return Enum.ContextActionResult.Sink
    end
    local function v_u_78(_, _, p77)
        v_u_47[p77.KeyCode.Name] = p77.Position
        return Enum.ContextActionResult.Sink
    end
    local function v_u_80(_, _, p79)
        v_u_47[p79.KeyCode.Name] = p79.Position.z
        return Enum.ContextActionResult.Sink
    end
    local function v_u_82(_, _, p81)
        v_u_49[p81.UserInputType.Name] = -p81.Position.z
        return Enum.ContextActionResult.Sink
    end
    local v_u_83 = nil
    function v_u_44.StartCapture()
        v_u_10:BindActionAtPriority("FreecamKeyboard", v_u_70, false, v_u_19, Enum.KeyCode.W, Enum.KeyCode.U, Enum.KeyCode.A, Enum.KeyCode.H, Enum.KeyCode.S, Enum.KeyCode.J, Enum.KeyCode.D, Enum.KeyCode.K, Enum.KeyCode.E, Enum.KeyCode.I, Enum.KeyCode.Q, Enum.KeyCode.Y, Enum.KeyCode.Up, Enum.KeyCode.Down)
        v_u_10:BindActionAtPriority("FreecamMousePan", v_u_76, false, v_u_19, Enum.UserInputType.MouseMovement)
        v_u_10:BindActionAtPriority("FreecamMouseWheel", v_u_82, false, v_u_19, Enum.UserInputType.MouseWheel)
        v_u_10:BindActionAtPriority("FreecamGamepadButton", v_u_73, false, v_u_19, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
        v_u_10:BindActionAtPriority("FreecamGamepadTrigger", v_u_80, false, v_u_19, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
        v_u_10:BindActionAtPriority("FreecamGamepadThumbstick", v_u_78, false, v_u_19, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
        local touchMovedConn = v_u_14.TouchMoved:Connect(function(p84)
            local v85 = p84.Delta
            v_u_49.Delta = Vector2.new(-v85.Y, -v85.X)
        end)
        v_u_83 = touchMovedConn
    end
    function v_u_44.StopCapture()
        if v_u_83 then
            v_u_83:Disconnect()
            v_u_83 = nil
        end
        v_u_52 = 1
        local v86 = v_u_47; for v87, v88 in pairs(v86) do v86[v87] = v88 * 0 end
        local v89 = v_u_48; for v90, v91 in pairs(v89) do v89[v90] = v91 * 0 end
        local v92 = v_u_49; for v93, v94 in pairs(v92) do v92[v93] = v94 * 0 end
        v_u_10:UnbindAction("FreecamKeyboard"); v_u_10:UnbindAction("FreecamMousePan"); v_u_10:UnbindAction("FreecamMouseWheel")
        v_u_10:UnbindAction("FreecamGamepadButton"); v_u_10:UnbindAction("FreecamGamepadTrigger"); v_u_10:UnbindAction("FreecamGamepadThumbstick")
    end
    local function v_u_112(p95)
        local v96 = v_u_17.ViewportSize
        local v97 = v_u_9(v_u_40 / 2) * 2
        local v98 = v96.x / v96.y * v97
        local v99 = p95.rightVector;
        local v100 = p95.upVector; 
        local v101 = p95.lookVector
        local v102 = Vector3.new();
        local v103 = 512
        for v104 = 0, 1, 0.5 do
            for v105 = 0, 1, 0.5 do
                local v106 = (v104 - 0.5) * v98;
                local v107 = (v105 - 0.5) * v97
                local v108 = v99 * v106 - v100 * v107 + v101;
                local v109 = p95.p + v108 * 0.1
                local _, v110 = v_u_15:FindPartOnRay(Ray.new(v109, v108.unit * v103))
                local v111 = (v110 - v109).magnitude
                if v111 < v103 then v102 = v108.unit; v103 = v111 end
            end
        end
        return v101:Dot(v102) * v103
    end
    local function v_u_119(p113)
        local v114 = v_u_41:Update(p113, v_u_44.Vel(p113)); local v115 = v_u_42:Update(p113, v_u_44.Pan(p113));
        local v116 = v_u_43:Update(p113, v_u_44.Fov(p113))
        local v117 = v_u_8(0.7002075382097097 / v_u_9((v_u_6(v_u_40 / 2))))
        v_u_40 = v_u_4(v_u_40 + v116 * 300 * (p113 / v117), 1, 120)
        v_u_39 = v_u_39 + v115 * v_u_20 * (p113 / v117)
        v_u_39 = Vector2.new(v_u_4(v_u_39.x, -1.5707963267948966, 1.5707963267948966), v_u_39.y % 6.283185307179586)
        local v118 = CFrame.new(v_u_38) * CFrame.fromOrientation(v_u_39.x, v_u_39.y, 0) * CFrame.new(v114 * Vector3.new(64, 64, 64) * p113)
        v_u_38 = v118.p
        v_u_17.CFrame = v118
        v_u_17.Focus = v118 * CFrame.new(0, 0, -v_u_112(v118))
        v_u_17.FieldOfView = v_u_40
    end
    local v_u_120 = {}
    local v_u_121, v_u_122, v_u_123, v_u_124, v_u_125, v_u_126 = nil, nil, nil, nil, nil, nil
    local v_u_127 = {}
    local v_u_128 = { Backpack = true, Chat = true, Health = true, PlayerList = true }
    local v_u_129 = { BadgesNotificationsActive = true, PointsNotificationsActive = true }
    function v_u_120.Push()
        for v130 in pairs(v_u_128) do v_u_128[v130] = v_u_13:GetCoreGuiEnabled(Enum.CoreGuiType[v130]); v_u_13:SetCoreGuiEnabled(Enum.CoreGuiType[v130], false) end
        for v131 in pairs(v_u_129) do v_u_129[v131] = v_u_13:GetCore(v131); v_u_13:SetCore(v131, false) end
        local v132 = v_u_16:FindFirstChildOfClass("PlayerGui")
        if v132 then
            for _, v133 in pairs(v132:GetChildren()) do
                if v133:IsA("ScreenGui") and v133.Enabled and v133.Name ~= "TeleportControlGui" then v_u_127[#v_u_127 + 1] = v133; v133.Enabled = false end
            end
        end
        v_u_126 = v_u_17.FieldOfView; v_u_17.FieldOfView = 70; v_u_123 = v_u_17.CameraType; v_u_17.CameraType = Enum.CameraType.Custom
        v_u_125 = v_u_17.CFrame; v_u_124 = v_u_17.Focus; v_u_122 = v_u_14.MouseIconEnabled; v_u_14.MouseIconEnabled = false
        v_u_121 = v_u_14.MouseBehavior; v_u_14.MouseBehavior = Enum.MouseBehavior.Default
    end
    function v_u_120.Pop()
        for v134, v135 in pairs(v_u_128) do v_u_13:SetCoreGuiEnabled(Enum.CoreGuiType[v134], v135) end
        for v136, v137 in pairs(v_u_129) do v_u_13:SetCore(v136, v137) end
        for _, v138 in pairs(v_u_127) do if v138 and v138.Parent then v138.Enabled = true end end
        v_u_17.FieldOfView = v_u_126; v_u_126 = nil; v_u_17.CameraType = v_u_123; v_u_123 = nil; v_u_17.CFrame = v_u_125; v_u_125 = nil
        v_u_17.Focus = v_u_124; v_u_124 = nil; v_u_14.MouseIconEnabled = v_u_122; v_u_122 = nil; v_u_14.MouseBehavior = v_u_121; v_u_121 = nil
    end
    local function v_u_140()
        local v139 = v_u_17.CFrame
        v_u_39 = Vector2.new(v139:toEulerAnglesYXZ()); v_u_38 = v139.p; v_u_40 = v_u_17.FieldOfView
        v_u_41:Reset((Vector3.new())); v_u_42:Reset(Vector2.new()); v_u_43:Reset(0)
        v_u_120.Push()
        v_u_12:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, v_u_119)
        v_u_44.StartCapture()
    end
    local v_u_141 = false
    function v1.ToggleFreecam()
        if v_u_141 then
            v_u_44.StopCapture()
            v_u_12:UnbindFromRenderStep("Freecam")
            v_u_120.Pop()
        else
            v_u_140()
        end
        v_u_141 = not v_u_141
        return v_u_141
    end
    return v1
end)()

-- ===================================================================
-- [[ FLY SYSTEM (UPDATED) ]]
-- ===================================================================

local flyEnabled = false
local flyKeyDown, flyKeyUp
local flyControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local flyBaseSpeed = 50

local function stopFly()
    flyEnabled = false
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            -- Bersihkan Movers secara spesifik
            if root:FindFirstChild("AsuHub_FlyGyro") then root.AsuHub_FlyGyro:Destroy() end
            if root:FindFirstChild("AsuHub_FlyVelocity") then root.AsuHub_FlyVelocity:Destroy() end
        end
    end
end

local function startFly()
    if flyEnabled then return end
    
    -- [[ ANTI-COLLISION ]] 
    -- Jika Platform aktif, matikan dulu!
    if platformEnabled then
        togglePlatform(false)
        -- Update UI Toggle Platform (Jika variabel UI tersedia)
        -- if PlatformToggleUI then PlatformToggleUI:Set(false) end 
    end
    
    flyEnabled = true
    
    local T = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not T then return end

    local BG = Instance.new("BodyGyro", T)
    local BV = Instance.new("BodyVelocity", T)
    BG.Name = "AsuHub_FlyGyro"
    BV.Name = "AsuHub_FlyVelocity"
    BG.P = 9e4
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    task.spawn(function()
        while flyEnabled do
            if SessionStop then stopFly(); break end 
            if not player.Character or not player.Character:FindFirstChild("Humanoid") then stopFly(); break end
            
            player.Character.Humanoid.PlatformStand = true
            BG.CFrame = Workspace.CurrentCamera.CFrame
            
            local direction = Vector3.new()
            if flyControl.F > 0 then direction = direction + Workspace.CurrentCamera.CFrame.LookVector end
            if flyControl.B < 0 then direction = direction - Workspace.CurrentCamera.CFrame.LookVector end
            if flyControl.L < 0 then direction = direction - Workspace.CurrentCamera.CFrame.RightVector end
            if flyControl.R > 0 then direction = direction + Workspace.CurrentCamera.CFrame.RightVector end
            if flyControl.Q > 0 then direction = direction + Vector3.new(0, 1, 0) end
            if flyControl.E < 0 then direction = direction - Vector3.new(0, 1, 0) end
            
            if direction.Magnitude > 0 then
                BV.Velocity = direction * flyBaseSpeed
            else
                BV.Velocity = Vector3.new(0, 0, 0)
            end
            task.wait()
        end
    end)

    -- Keybinds
    if flyKeyDown then flyKeyDown:Disconnect() end
    flyKeyDown = TrackConn(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local k = input.KeyCode.Name:lower()
        if k == "w" then flyControl.F = 1
        elseif k == "s" then flyControl.B = -1
        elseif k == "a" then flyControl.L = -1
        elseif k == "d" then flyControl.R = 1
        elseif k == "e" then flyControl.Q = 1
        elseif k == "q" then flyControl.E = -1
        end
    end))

    if flyKeyUp then flyKeyUp:Disconnect() end
    flyKeyUp = TrackConn(UserInputService.InputEnded:Connect(function(input)
        local k = input.KeyCode.Name:lower()
        if k == "w" then flyControl.F = 0
        elseif k == "s" then flyControl.B = 0
        elseif k == "a" then flyControl.L = 0
        elseif k == "d" then flyControl.R = 0
        elseif k == "e" then flyControl.Q = 0
        elseif k == "q" then flyControl.E = 0
        end
    end))
end

-- ===================================================================
-- [[ ESP SYSTEM ]] (MODIFIED: Added Health)
-- ===================================================================

local ESP_FRIEND_COLOR = Color3.fromRGB(0, 0, 255)
local ESP_ENEMY_COLOR = Color3.fromRGB(255, 0, 0) 
local ESP_USE_TEAM_COLOR = true

local espHolder = Instance.new("Folder", game:GetService("CoreGui"))
espHolder.Name = "AsuHub_ESP_Holder"

local espNameTagTemplate = Instance.new("BillboardGui")
espNameTagTemplate.Name = "ESP_NameTag"
espNameTagTemplate.Enabled = true
-- Ukuran diperbesar sedikit agar muat 3 baris (Distance, Name, Health)
espNameTagTemplate.Size = UDim2.new(0, 200, 0, 70) 
espNameTagTemplate.AlwaysOnTop = true
espNameTagTemplate.StudsOffset = Vector3.new(0, 3.5, 0)

local espListLayout = Instance.new("UIListLayout", espNameTagTemplate)
espListLayout.FillDirection = Enum.FillDirection.Vertical
espListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
espListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 1. Distance Label
local espDistanceLabel = Instance.new("TextLabel", espNameTagTemplate)
espDistanceLabel.Name = "Distance"
espDistanceLabel.BackgroundTransparency = 1
espDistanceLabel.Size = UDim2.new(1, 0, 0, 20)
espDistanceLabel.TextSize = 14
espDistanceLabel.TextColor3 = Color3.new(1, 1, 1)
espDistanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
espDistanceLabel.TextStrokeTransparency = 0.2
espDistanceLabel.Text = " 0 m "
espDistanceLabel.Font = Enum.Font.SourceSans

-- 2. Name Label
local espTagLabel = Instance.new("TextLabel", espNameTagTemplate)
espTagLabel.Name = "Tag"
espTagLabel.BackgroundTransparency = 1
espTagLabel.Size = UDim2.new(1, 0, 0, 20)
espTagLabel.TextSize = 16
espTagLabel.TextColor3 = Color3.new(1, 1, 1)
espTagLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
espTagLabel.TextStrokeTransparency = 0.4
espTagLabel.Text = "PlayerName"
espTagLabel.Font = Enum.Font.SourceSansBold

-- 3. Health Label (BARU DITAMBAHKAN)
local espHealthLabel = Instance.new("TextLabel", espNameTagTemplate)
espHealthLabel.Name = "Health"
espHealthLabel.BackgroundTransparency = 1
espHealthLabel.Size = UDim2.new(1, 0, 0, 20)
espHealthLabel.TextSize = 12
espHealthLabel.TextColor3 = Color3.new(0, 1, 0) -- Default Hijau
espHealthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
espHealthLabel.TextStrokeTransparency = 0.4
espHealthLabel.Text = "HP: 100"
espHealthLabel.Font = Enum.Font.SourceSansBold

local espEnabled = false
local espConnection = nil

local function removeESP(target)
    if target.Character then
        local highlight = target.Character:FindFirstChild("AsuHub_ESP_Highlight")
        if highlight then
            highlight:Destroy()
        end

        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
    end

    local nameTag = espHolder:FindFirstChild(target.Name .. "_NameTag")
    if nameTag then
        nameTag:Destroy()
    end
end

local function updateESP(target, color)
    local localPlayerHead = player.Character and player.Character:FindFirstChild("Head")
    
    if target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChildOfClass("Humanoid") then
        local head = target.Character.Head
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")

        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        -- Update Highlight (Kotak di badan)
        local highlight = target.Character:FindFirstChild("AsuHub_ESP_Highlight") 
        if not highlight then
            highlight = Instance.new("Highlight") 
            highlight.Name = "AsuHub_ESP_Highlight"
            highlight.Adornee = target.Character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.OutlineTransparency = 1
            highlight.FillColor = color
            highlight.Parent = target.Character
        else
            highlight.FillColor = color
        end

        -- Create/Get NameTag
        local nameTag = espHolder:FindFirstChild(target.Name .. "_NameTag")
        if not nameTag then
            nameTag = espNameTagTemplate:Clone()
            nameTag.Name = target.Name .. "_NameTag"
            nameTag.Adornee = head
            nameTag.Parent = espHolder
        end
        
        if nameTag.Adornee ~= head then
            nameTag.Adornee = head
        end
        
        -- Update Nama
        local tagLabel = nameTag:FindFirstChild("Tag")
        if tagLabel then
            tagLabel.Text = target.DisplayName
            tagLabel.TextColor3 = color
        end

        -- Update Jarak
        local distanceLabel = nameTag:FindFirstChild("Distance")
        if distanceLabel then
            if localPlayerHead then
                local distance = (localPlayerHead.Position - head.Position).Magnitude
                distanceLabel.Text = " " .. math.floor(distance + 0.5) .. " m "
            else
                distanceLabel.Text = " - m "
            end
            distanceLabel.TextColor3 = color
        end

        -- Update Health (BARU)
        local healthLabel = nameTag:FindFirstChild("Health")
        if healthLabel then
            local hp = math.floor(humanoid.Health)
            local maxHp = humanoid.MaxHealth
            healthLabel.Text = "HP: " .. hp
            
            -- Logika Warna HP (Hijau -> Kuning -> Merah)
            local hpPercent = hp / maxHp
            healthLabel.TextColor3 = Color3.fromHSV(hpPercent * 0.3, 1, 1) 
        end

    else
        removeESP(target)
    end
end

local function stopESP()
    if not espEnabled then return end
    espEnabled = false
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    for _, v in ipairs(Players:GetPlayers()) do
        removeESP(v) 
    end
end

local function startESP()
    if espEnabled then return end
    espEnabled = true
    
    espConnection = TrackConn(RunService.Heartbeat:Connect(function()
        local allPlayers = Players:GetPlayers()
        local activeESPPlayers = {}

        for _, v in ipairs(allPlayers) do
            if v ~= player then
                local color = ESP_USE_TEAM_COLOR and v.TeamColor.Color or 
                             ((player.TeamColor == v.TeamColor) and ESP_FRIEND_COLOR or ESP_ENEMY_COLOR)
                updateESP(v, color)
                activeESPPlayers[v.Name] = true
            else
                removeESP(v)
            end
        end

        for _, child in ipairs(espHolder:GetChildren()) do
            if child:IsA("BillboardGui") then
                local playerName = string.gsub(child.Name, "_NameTag", "")
                if not activeESPPlayers[playerName] then
                    child:Destroy()
                end
            end
        end
    end))
end

-- ===================================================================
-- [[ PLAYER FEATURES ]]
-- ===================================================================

local noclipEnabled = false
local noclipConnection

local godModeEnabled = false
local godModeConnection

-- Variabel luar untuk menyimpan koneksi
local JumpConn = nil

local function toggleInfiniteJump(state)
    -- 1. Selalu bersihkan koneksi lama dulu
    if JumpConn then
        JumpConn:Disconnect()
        JumpConn = nil
    end

    -- 2. Jika diaktifkan (True)
    if state then
        JumpConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Space then
                local char = player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                
                -- Logika Lompat Paksa
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        -- Masukkan ke daftar pembersih global (agar mati saat script di-run ulang)
        if TrackConn then TrackConn(JumpConn) end
        
        -- Rayfield:Notify dipindah ke UI jika diperlukan
    end
end

local function toggleNoclip(state)
    noclipEnabled = state
    
    if state then
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        noclipConnection = TrackConn(RunService.Stepped:Connect(function()
            if noclipEnabled and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end))
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true 
                end
            end
            
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CanCollide = false
            end
        end
    end
end

local function toggleGodMode(state)
    godModeEnabled = state
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    
    if state and hum then
        if godModeConnection then godModeConnection:Disconnect() end
        
        hum.Health = hum.MaxHealth
        
        -- TrackConn dipasang dengan benar
        godModeConnection = TrackConn(hum.HealthChanged:Connect(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end))
    else
        if godModeConnection then godModeConnection:Disconnect() end
    end
end

-- ===================================================================
-- [[ SPAWN PLATFORM SYSTEM (V7 - SPEED CONTROL READY) ]]
-- ===================================================================

-- Variabel ini HARUS di luar fungsi agar bisa diubah Slider
local platformSpeed = 25      -- Default Speed
local platformEnabled = false
local platformPart = nil
local platformControlLoop = nil 
local platformInputBegan = nil
local platformInputEnded = nil

-- Variabel Kontrol Internal
local targetY = nil           
local moveUp = false          
local moveDown = false        

-- Helper: Hitung tinggi kaki (Support R6 & R15)
local function getLegHeight(hum)
    if not hum then return 3 end 
    if hum.RigType == Enum.HumanoidRigType.R15 then
        return hum.HipHeight + (hum.RootPart and hum.RootPart.Size.Y/2 or 0)
    else
        return 3.0 -- R6 Standard
    end
end

local function createPlatform()
    if platformPart and platformPart.Parent then 
        platformPart:Destroy() 
        platformPart = nil
    end
    
    platformPart = Instance.new("Part")
    platformPart.Name = "AsuHub_Platform"
    platformPart.Size = Vector3.new(6, 1, 6) 
    platformPart.Transparency = 0.5
    platformPart.Color = Color3.fromRGB(0, 255, 255) 
    platformPart.Material = Enum.Material.Neon
    platformPart.CanCollide = true
    platformPart.Anchored = true 
    platformPart.Parent = Workspace

    return platformPart
end

local function togglePlatform(state)
    -- Jika status sama, abaikan untuk mencegah double execute logic
    if platformEnabled == state then return end
    
    platformEnabled = state
    
    -- Bersihkan Event Lama (Safety)
    if platformInputBegan then platformInputBegan:Disconnect(); platformInputBegan = nil end
    if platformInputEnded then platformInputEnded:Disconnect(); platformInputEnded = nil end
    if platformControlLoop then coroutine.close(platformControlLoop); platformControlLoop = nil end
    
    if state then
        -- [[ ANTI-COLLISION ]]
        -- Jika Fly aktif, matikan dulu!
        if flyEnabled then
            stopFly()
            -- Update UI Fly (Penting agar UI sinkron)
            if FlyToggle then FlyToggle:Set(false) end 
        end
        
        -- Buat Part Baru
        createPlatform()
        
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if root and hum then
            targetY = root.Position.Y - getLegHeight(hum) - 0.5
        end

        -- ... (Logika Listener Tombol E/Q SAMA SEPERTI V7 SEBELUMNYA) ...
        -- ... (Copy paste bagian Listener Input V7 di sini) ...
        platformInputBegan = TrackConn(UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.E then moveUp = true end
            if input.KeyCode == Enum.KeyCode.Q then moveDown = true end
        end))
        
        platformInputEnded = TrackConn(UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.E then moveUp = false end
            if input.KeyCode == Enum.KeyCode.Q then moveDown = false end
        end))

        -- Loop Utama
        platformControlLoop = TrackCoroutine(task.spawn(function()
            while platformEnabled and platformPart and platformPart.Parent do
                if SessionStop then break end -- Safety Check Global
                
                local dt = RunService.Heartbeat:Wait()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                
                -- ... (LOGIKA FISIKA V7 SAMA PERSIS SEPERTI SEBELUMNYA) ...
                if root and hum then
                    local legHeight = getLegHeight(hum)
                    local currentFeetY = root.Position.Y - legHeight - 0.5
                    local moveAmount = platformSpeed * dt
                    local distToPlatform = math.abs(currentFeetY - targetY)
                    local isStandingOnPlatform = distToPlatform < 3.5 
                    
                    if moveUp then
                        targetY = targetY + moveAmount
                        if isStandingOnPlatform then
                            root.CFrame = root.CFrame * CFrame.new(0, moveAmount, 0)
                            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                        end
                    elseif moveDown then
                        targetY = targetY - moveAmount
                        if isStandingOnPlatform then
                            root.CFrame = root.CFrame * CFrame.new(0, -moveAmount, 0)
                            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                        end
                    else
                        local state = hum:GetState()
                        local isAirborne = (state == Enum.HumanoidStateType.Freefall) or (state == Enum.HumanoidStateType.Jumping)
                        if isAirborne or (currentFeetY - targetY) > 3 then
                            targetY = currentFeetY
                        end
                    end
                    local finalPos = Vector3.new(root.Position.X, targetY, root.Position.Z)
                    platformPart.CFrame = CFrame.new(finalPos)
                end
            end
            -- Jika loop mati sendiri (misal part hancur), matikan toggle
            if platformEnabled then togglePlatform(false) end
        end))
        
    else
        -- CLEANUP SAAT DIMATIKAN
        if platformPart then platformPart:Destroy(); platformPart = nil end
        moveUp = false; moveDown = false
    end
end

-- ===================================================================
-- [[ CLICK TELEPORT ]]
-- ===================================================================

local clickTeleportEnabled = false
local clickTeleportConnection = nil

local function toggleClickTeleport(state)
    clickTeleportEnabled = state
    if state then
        if clickTeleportConnection then clickTeleportConnection:Disconnect() end
        
        -- TrackConn dipasang dengan benar
        clickTeleportConnection = TrackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                if mouse and player.Character then
                    player.Character:MoveTo(mouse.Hit.Position)
                end
            end
        end))
    else
        if clickTeleportConnection then clickTeleportConnection:Disconnect() end
    end
end

-- ===================================================================
-- [[ FLING SYSTEM ]]
-- ===================================================================

if not getgenv().FPDH then
     getgenv().FPDH = workspace.FallenPartsDestroyHeight
end

local Message = function(_Title, _Text, Time)
    -- Ganti dengan Rayfield:Notify di UI jika diperlukan
end

local SkidFling = function(TargetPlayer)
    local Character = player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end

        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end

        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Occurred", "Random error", 5)
    end
end

-- ===================================================================
-- [[ FITUR ANIMATION (REVISI TOTAL - SYNCED) ]]
-- ===================================================================

-- 1. DEKLARASI GLOBAL (Agar Menu & Sistem R15 saling terhubung)
local Animations -- Variabel Data Animasi
local lastAnimations = {} -- Variabel Memori Penyimpanan
local setAnimation, loadLastAnimations, saveLastAnimations -- Fungsi Utama
local ResetIdle, ResetWalk, ResetRun, ResetJump, ResetFall, ResetSwim, ResetSwimIdle, ResetClimb -- Fungsi Reset

-- 2. LOGIKA R15 (Pengisi Fungsi)
if isR15 then
    local HttpService = game:GetService("HttpService")

    -- Data Animasi (Tanpa 'local' agar masuk ke variabel global di atas)
    Animations = {
        ["Idle"] = {
            ["Wicked Dancing Through Life"] = {"92849173543269", "132238900951109"},
            ["2016 Animation (mm2)"] = {"387947158", "387947464"},
            ["(UGC) Oh Really?"] = {"98004748982532", "98004748982532"},
            ["Astronaut"] = {"891621366", "891633237"},
            ["Adidas Community"] = {"122257458498464", "102357151005774"},
            ["Bold"] = {"16738333868", "16738334710"},
            ["(UGC) Slasher"] = {"140051337061095", "140051337061095"},
            ["(UGC) Retro"] = {"80479383912838", "80479383912838"},
            ["(UGC) Magician"] = {"139433213852503", "139433213852503"},
            ["(UGC) John Doe"] = {"72526127498800", "72526127498800"},
            ["(UGC) Noli"] = {"139360856809483", "139360856809483"},
            ["(UGC) Coolkid"] = {"95203125292023", "95203125292023"},
            ["(UGC) Survivor Injured"] = {"73905365652295", "73905365652295"},
            ["(UGC) Retro Zombie"] = {"90806086002292", "90806086002292"},
            ["(UGC) 1x1x1x1"] = {"76780522821306", "76780522821306"},
            ["Borock"] = {"3293641938", "3293642554"},
            ["Bubbly"] = {"910004836", "910009958"},
            ["Cartoony"] = {"742637544", "742638445"},
            ["Confident"] = {"1069977950", "1069987858"},
            ["Catwalk Glam"] = {"133806214992291","94970088341563"},
            ["Cowboy"] = {"1014390418", "1014398616"},
            ["Drooling Zombie"] = {"3489171152", "3489171152"},
            ["Elder"] = {"10921101664", "10921102574"},
            ["Ghost"] = {"616006778","616008087"},
            ["Knight"] = {"657595757", "657568135"},
            ["Levitation"] = {"616006778", "616008087"},
            ["Mage"] = {"707742142", "707855907"},
            ["MrToilet"] = {"4417977954", "4417978624"},
            ["Ninja"] = {"656117400", "656118341"},
            ["NFL"] = {"92080889861410", "74451233229259"},
            ["OldSchool"] = {"10921230744", "10921232093"},
            ["Patrol"] = {"1149612882", "1150842221"},
            ["Pirate"] = {"750781874", "750782770"},
            ["Default Retarget"] = {"95884606664820", "95884606664820"},
            ["Very Long"] = {"18307781743", "18307781743"},
            ["Sway"] = {"560832030", "560833564"},
            ["Popstar"] = {"1212900985", "1150842221"},
            ["Princess"] = {"941003647", "941013098"},
            ["R6"] = {"12521158637","12521162526"},
            ["R15 Reanimated"] = {"4211217646", "4211218409"},
            ["Realistic"] = {"17172918855", "17173014241"},
            ["Robot"] = {"616088211", "616089559"},
            ["Sneaky"] = {"1132473842", "1132477671"},
            ["Sports (Adidas)"] = {"18537376492", "18537371272"},
            ["Soldier"] = {"3972151362", "3972151362"},
            ["Stylish"] = {"616136790", "616138447"},
            ["Stylized Female"] = {"4708191566", "4708192150"},
            ["Superhero"] = {"10921288909", "10921290167"},
            ["Toy"] = {"782841498", "782845736"},
            ["Udzal"] = {"3303162274", "3303162549"},
            ["Vampire"] = {"1083445855", "1083450166"},
            ["Werewolf"] = {"1083195517", "1083214717"},
            ["Wicked (Popular)"] = {"118832222982049", "76049494037641"},
            ["No Boundaries (Walmart)"] = {"18747067405", "18747063918"},
            ["Zombie"] = {"616158929", "616160636"},
            ["(UGC) Zombie"] = {"77672872857991", "77672872857991"},
            ["(UGC) TailWag"] = {"129026910898635", "129026910898635"}
        },
        ["Walk"] = {
            ["Wicked Dancing Through Life"] = "73718308412641",            
            ["Gojo"] = "95643163365384",
            ["Geto"] = "85811471336028",
            ["Astronaut"] = "891667138",
            ["(UGC) Zombie"] = "113603435314095",
            ["Adidas Community"] = "122150855457006",
            ["Bold"] = "16738340646",
            ["Bubbly"] = "910034870",
            ["(UGC) Smooth"] = "76630051272791",
            ["Cartoony"] = "742640026",
            ["Confident"] = "1070017263",
            ["Cowboy"] = "1014421541",
            ["(UGC) Retro"] = "107806791584829",
            ["(UGC) Retro Zombie"] = "140703855480494",
            ["Catwalk Glam"] = "109168724482748",
            ["Drooling Zombie"] = "3489174223",
            ["Elder"] = "10921111375",
            ["Ghost"] = "616013216",
            ["Knight"] = "10921127095",
            ["Levitation"] = "616013216",
            ["Mage"] = "707897309",
            ["Ninja"] = "656121766",
            ["NFL"] = "110358958299415",
            ["OldSchool"] = "10921244891",
            ["Patrol"] = "1151231493",
            ["Pirate"] = "750785693",
            ["Default Retarget"] = "115825677624788",
            ["Popstar"] = "1212980338",
            ["Princess"] = "941028902",
            ["R6"] = "12518152696",
            ["R15 Reanimated"] = "4211223236",
            ["2016 Animation (mm2)"] = "387947975",
            ["Robot"] = "616095330",
            ["Sneaky"] = "1132510133",
            ["Sports (Adidas)"] = "18537392113",
            ["Stylish"] = "616146177",
            ["Stylized Female"] = "4708193840",
            ["Superhero"] = "10921298616",
            ["Toy"] = "782843345",
            ["Udzal"] = "3303162967",
            ["Vampire"] = "1083473930",
            ["Werewolf"] = "1083178339",
            ["Wicked (Popular)"] = "92072849924640",
            ["No Boundaries (Walmart)"] = "18747074203",
            ["Zombie"] = "616168032"
        },
        ["Run"] = {
            ["Wicked Dancing Through Life"] = "135515454877967",            
            ["2016 Animation (mm2)"] = "387947975",
            ["(UGC) Soccer"] = "116881956670910",
            ["Adidas Community"] = "82598234841035",
            ["Astronaut"] = "10921039308",
            ["Bold"] = "16738337225",
            ["Bubbly"] = "10921057244",
            ["Cartoony"] = "10921076136",
            ["(UGC) Dog"] = "130072963359721",
            ["Confident"] = "1070001516",
            ["(UGC) Pride"] = "116462200642360",
            ["(UGC) Retro"] = "107806791584829",
            ["(UGC) Retro Zombie"] = "140703855480494", 
            ["Cowboy"] = "1014401683",
            ["Catwalk Glam"] = "81024476153754",
            ["Drooling Zombie"] = "3489173414",
            ["Elder"] = "10921104374",
            ["Ghost"] = "616013216",
            ["Heavy Run (Udzal / Borock)"] = "3236836670",
            ["Knight"] = "10921121197",
            ["Levitation"] = "616010382",
            ["Mage"] = "10921148209",
            ["MrToilet"] = "4417979645",
            ["Ninja"] = "656118852",
            ["NFL"] = "117333533048078",
            ["OldSchool"] = "10921240218",
            ["Patrol"] = "1150967949",
            ["Pirate"] = "750783738",
            ["Default Retarget"] = "102294264237491",
            ["Popstar"] = "1212980348",
            ["Princess"] = "941015281",
            ["R6"] = "12518152696",
            ["R15 Reanimated"] = "4211220381",
            ["Robot"] = "10921250460",
            ["Sneaky"] = "1132494274",
            ["Sports (Adidas)"] = "18537384940",
            ["Stylish"] = "10921276116",
            ["Stylized Female"] = "4708192705",
            ["Superhero"] = "10921291831",
            ["Toy"] = "10921306285",
            ["Vampire"] = "10921320299",
            ["Werewolf"] = "10921336997",
            ["Wicked (Popular)"] = "72301599441680",
            ["No Boundaries (Walmart)"] = "18747070484",
            ["Zombie"] = "616163682"
        },
        ["Jump"] = {
            ["Wicked Dancing Through Life"] = "78508480717326",
            ["Astronaut"] = "891627522",
            ["Adidas Community"] = "75290611992385",
            ["Bold"] = "16738336650",
            ["Bubbly"] = "910016857",
            ["Cartoony"] = "742637942",
            ["Catwalk Glam"] = "116936326516985",
            ["Confident"] = "1069984524",
            ["Cowboy"] = "1014394726",
            ["Elder"] = "10921107367",
            ["Ghost"] = "616008936",
            ["Knight"] = "910016857",
            ["Levitation"] = "616008936",
            ["Mage"] = "10921149743",
            ["Ninja"] = "656117878",
            ["NFL"] = "119846112151352",
            ["OldSchool"] = "10921242013",
            ["Patrol"] = "1148811837",
            ["Pirate"] = "750782230",
            ["(UGC) Retro"] = "139390570947836",
            ["Default Retarget"] = "117150377950987",
            ["Popstar"] = "1212954642",
            ["Princess"] = "941008832",
            ["Robot"] = "616090535",
            ["R15 Reanimated"] = "4211219390",
            ["R6"] = "12520880485",
            ["Sneaky"] = "1132489853",
            ["Sports (Adidas)"] = "18537380791",
            ["Stylish"] = "616139451",
            ["Stylized Female"] = "4708188025",
            ["Superhero"] = "10921294559",
            ["Toy"] = "10921308158",
            ["Vampire"] = "1083455352",
            ["Werewolf"] = "1083218792",
            ["Wicked (Popular)"] = "104325245285198",
            ["No Boundaries (Walmart)"] = "18747069148",
            ["Zombie"] = "616161997"
        },
        ["Fall"] = {
            ["Wicked Dancing Through Life"] = "78147885297412",
            ["Astronaut"] = "891617961",
            ["Adidas Community"] = "98600215928904",
            ["Bold"] = "16738333171",
            ["Bubbly"] = "910001910",
            ["Cartoony"] = "742637151",
            ["Catwalk Glam"] = "92294537340807",
            ["Confident"] = "1069973677",
            ["Cowboy"] = "1014384571",
            ["Elder"] = "10921105765",
            ["Knight"] = "10921122579",
            ["Levitation"] = "616005863",
            ["Mage"] = "707829716",
            ["Ninja"] = "656115606",
            ["NFL"] = "129773241321032",
            ["OldSchool"] = "10921241244",
            ["Patrol"] = "1148863382",
            ["Pirate"] = "750780242",
            ["Default Retarget"] = "110205622518029",
            ["Popstar"] = "1212900995",
            ["Princess"] = "941000007",
            ["Robot"] = "616087089",
            ["R15 Reanimated"] = "4211216152",
            ["R6"] = "12520972571",
            ["Sneaky"] = "1132469004",
            ["Sports (Adidas)"] = "18537367238",
            ["Stylish"] = "616134815",
            ["Stylized Female"] = "4708186162",
            ["Superhero"] = "10921293373",
            ["Toy"] = "782846423",
            ["Vampire"] = "1083443587",
            ["Werewolf"] = "1083189019",
            ["Wicked (Popular)"] = "121152442762481",
            ["No Boundaries (Walmart)"] = "18747062535",
            ["Zombie"] = "616157476"
        },
        ["SwimIdle"] = {
            ["Wicked Dancing Through Life"] = "129183123083281",
            ["Astronaut"] = "891663592",
            ["Adidas Community"] = "109346520324160",
            ["Bold"] = "16738339817",
            ["Bubbly"] = "910030921",
            ["Cartoony"] = "10921079380",
            ["Catwalk Glam"] = "98854111361360",
            ["Confident"] = "1070012133",
            ["CowBoy"] = "1014411816",
            ["Elder"] = "10921110146",
            ["Mage"] = "707894699",
            ["Ninja"] = "656118341",
            ["NFL"] = "79090109939093",
            ["Patrol"] = "1151221899",
            ["Knight"] = "10921125935",
            ["OldSchool"] = "10921244018",
            ["Levitation"] = "10921139478",
            ["Popstar"] = "1212998578",
            ["Princess"] = "941025398",
            ["Pirate"] = "750785176",
            ["R6"] = "12518152696",
            ["Robot"] = "10921253767",
            ["Sneaky"] = "1132506407",
            ["Sports (Adidas)"] = "18537387180",
            ["Stylish"] = "10921281964",
            ["Stylized"] = "4708190607",
            ["SuperHero"] = "10921297391",
            ["Toy"] = "10921310341",
            ["Vampire"] = "10921325443",
            ["Werewolf"] = "10921341319",
            ["Wicked (Popular)"] = "113199415118199",
            ["No Boundaries (Walmart)"] = "18747071682"
        },
        ["Swim"] = {
            ["Wicked Dancing Through Life"] = "110657013921774",
            ["Astronaut"] = "891663592",
            ["Adidas Community"] = "133308483266208",
            ["Bubbly"] = "910028158",
            ["Bold"] = "16738339158",
            ["Cartoony"] = "10921079380",
            ["Catwalk Glam"] = "134591743181628",
            ["CowBoy"] = "1014406523",
            ["Confident"] = "1070009914",
            ["Elder"] = "10921108971",
            ["Knight"] = "10921125160",
            ["Mage"] = "707876443",
            ["NFL"] = "132697394189921",
            ["OldSchool"] = "10921243048",
            ["PopStar"] = "1212998578",
            ["Princess"] = "941018893",
            ["Pirate"] = "750784579",
            ["Patrol"] = "1151204998",
            ["R6"] = "12518152696",
            ["Robot"] = "10921253142",
            ["Levitation"] = "10921138209",
            ["Stylish"] = "10921281000",
            ["SuperHero"] = "10921295495",
            ["Sneaky"] = "1132500520",
            ["Sports (Adidas)"] = "18537389531",
            ["Toy"] = "10921309319",
            ["Vampire"] = "10921324408",
            ["Werewolf"] = "10921340419",
            ["Wicked (Popular)"] = "99384245425157",
            ["No Boundaries (Walmart)"] = "18747073181",
            ["Zombie"] = "616165109"
        },
        ["Climb"] = {
            ["Wicked Dancing Through Life"] = "129447497744818",
            ["Astronaut"] = "10921032124",
            ["Adidas Community"] = "88763136693023",
            ["Bold"] = "16738332169",
            ["Cartoony"] = "742636889",
            ["Catwalk Glam"] = "119377220967554",
            ["Confident"] = "1069946257",
            ["CowBoy"] = "1014380606",
            ["Elder"] = "845392038",
            ["Ghost"] = "616003713",
            ["Knight"] = "10921125160",
            ["Levitation"] = "10921132092",
            ["Mage"] = "707826056",
            ["Ninja"] = "656114359",
            ["(UGC) Retro"] = "121075390792786",
            ["NFL"] = "134630013742019",
            ["OldSchool"] = "10921229866",
            ["Patrol"] = "1148811837",
            ["Popstar"] = "1213044953",
            ["Princess"] = "940996062",
            ["R6"] = "12520982150",
            ["Reanimated R15"] = "4211214992",
            ["Robot"] = "616086039",
            ["Sneaky"] = "1132461372",
            ["Sports (Adidas)"] = "18537363391",
            ["Stylish"] = "10921271391",
            ["Stylized Female"] = "4708184253",
            ["SuperHero"] = "10921286911",
            ["Toy"] = "10921300839",
            ["Vampire"] = "1083439238",
            ["WereWolf"] = "10921329322",
            ["Wicked (Popular)"] = "131326830509784",
            ["No Boundaries (Walmart)"] = "18747060903",
            ["Zombie"] = "616156119"
        }
    }
    
    local function freeze()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.PlatformStand = true
        if player and player.Character then
            task.spawn(function()
                for i, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Anchored then
                        part.Anchored = true
                    end
                end
            end)
        end
    end
    
    local function unfreeze()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.PlatformStand = false
        if player and player.Character then
            task.spawn(function()
                for i, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Anchored then
                        part.Anchored = false
                    end
                end
            end)
        end
    end

    function saveLastAnimations(lasyAnimations)
        local data = HttpService:JSONEncode(lastAnimations)
        pcall(function() writefile("AsuHubAnimasiPack.json", data) end)
    end
    
    local function refresh()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:wait(0.1)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
    
    local function refreshswim()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:wait(0.1)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
    end
    
    local function refreshclimb()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:wait(0.1)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
    end
    
    -- Definisi Fungsi Reset (Global)
    function ResetIdle()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
            Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function ResetWalk()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function ResetRun()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function ResetJump()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function ResetFall()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function ResetSwim()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            if Animate.swim then Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0" end
        end)
    end
    
    function ResetSwimIdle()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            if Animate.swimidle then Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0" end
        end)
    end
    
    function ResetClimb()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    -- Definisi Fungsi Set & Load (Global)
    function setAnimation(animationType, animationId)
        if type(animationId) ~= "table" and type(animationId) ~= "string" then return end
        local player = Players.LocalPlayer
        if not player.Character then return end
        local Char = player.Character
        local Animate = Char:FindFirstChild("Animate")
        if not Animate then return end
    
        freeze()
        wait(0.1)
    
        local success, err = pcall(function()
            if animationType == "Idle" then
                lastAnimations.Idle = animationId
                ResetIdle()
                Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
                Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
                refresh()
            elseif animationType == "Walk" then
                lastAnimations.Walk = animationId
                ResetWalk()
                Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Run" then
                lastAnimations.Run = animationId
                ResetRun()
                Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Jump" then
                lastAnimations.Jump = animationId
                ResetJump()
                Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Fall" then
                lastAnimations.Fall = animationId
                ResetFall()
                Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refresh()
            elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
                lastAnimations.Swim = animationId
                ResetSwim()
                Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshswim()
            elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
                lastAnimations.SwimIdle = animationId
                ResetSwimIdle()
                Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshswim()
            elseif animationType == "Climb" then
                lastAnimations.Climb = animationId
                ResetClimb()
                Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                refreshclimb()
            end
            saveLastAnimations(lastAnimations)
        end)
    
        if not success then
            warn("Failed to set animation:", err)
        end
    
        wait(0.1)
        unfreeze()
    end
    
    function loadLastAnimations()
        if isfile("AsuHubAnimasiPack.json") then
            local data = readfile("AsuHubAnimasiPack.json")
            local lastAnimationsData = HttpService:JSONDecode(data)
            Rayfield:Notify({ Title = "Animasi", Content = "Menyiapkan animasi yang tersimpan...", Icon = "play", Duration = 3, Image = 7733964719 })
            
            -- Update variable global dengan data dari file
            lastAnimations = lastAnimationsData 
            
            if lastAnimationsData.Idle then setAnimation("Idle", lastAnimationsData.Idle) end
            if lastAnimationsData.Walk then setAnimation("Walk", lastAnimationsData.Walk) end
            if lastAnimationsData.Run then setAnimation("Run", lastAnimationsData.Run) end
            if lastAnimationsData.Jump then setAnimation("Jump", lastAnimationsData.Jump) end
            if lastAnimationsData.Fall then setAnimation("Fall", lastAnimationsData.Fall) end
            if lastAnimationsData.Climb then setAnimation("Climb", lastAnimationsData.Climb) end
            if lastAnimationsData.Swim then setAnimation("Swim", lastAnimationsData.Swim) end
            if lastAnimationsData.SwimIdle then setAnimation("SwimIdle", lastAnimationsData.SwimIdle) end
        else
            Rayfield:Notify({ Title = "Animasi", Content = "Tidak ada animasi tersimpan.", Duration = 5, Image = 7733964719 })
        end
    end
    
    Players.LocalPlayer.CharacterAdded:Connect(function(character)
        local hum = character:WaitForChild("Humanoid")
        local animate = character:WaitForChild("Animate", 10)
        if not animate then return end
    
        -- Pengecekan aman, hanya load jika ada di lastAnimations
        if lastAnimations.Idle then setAnimation("Idle", lastAnimations.Idle) end
        if lastAnimations.Walk then setAnimation("Walk", lastAnimations.Walk) end
        if lastAnimations.Run then setAnimation("Run", lastAnimations.Run) end
        if lastAnimations.Jump then setAnimation("Jump", lastAnimations.Jump) end
        if lastAnimations.Fall then setAnimation("Fall", lastAnimations.Fall) end
        if lastAnimations.Climb then setAnimation("Climb", lastAnimations.Climb) end
        if lastAnimations.Swim then setAnimation("Swim", lastAnimations.Swim) end
        if lastAnimations.SwimIdle then setAnimation("SwimIdle", lastAnimations.SwimIdle) end
    end)
end

-- ===================================================================
-- [[ FREECAM TOGGLE ]]
-- ===================================================================

local freecamEnabled = false

local function blockJumpAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin and inputObject.KeyCode == Enum.KeyCode.Space then
        return Enum.ContextActionResult.Sink
    end
    return Enum.ContextActionResult.Pass
end

local function toggleFreecam(state)
    -- Jangan lakukan apa-apa jika statusnya sudah sama
    if state == freecamEnabled then return end
    
    if state then
        -- MENYALAKAN FREECAM
        
        -- 1. Matikan Fly jika sedang aktif (biar ga tabrakan)
        if flyEnabled then
            stopFly()
            if FlyToggle then FlyToggle:Set(false) end -- Update UI Fly jadi mati
        end
        
        -- 2. Aktifkan Modul Freecam
        local result = FreecamModule.ToggleFreecam()
        freecamEnabled = true -- Paksa true karena kita ingin menyala
        
        -- 3. Matikan lompat spasi saat freecam (agar karakter tidak lompat2 saat naik ke atas)
        local CAS = game:GetService("ContextActionService")
        CAS:BindActionAtPriority("BlockFreecamJump", function(_, state, _)
            return state == Enum.UserInputState.Begin and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
        end, false, 3000, Enum.KeyCode.Space)
        
        Rayfield:Notify({Title = "Freecam", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
    else
        -- MEMATIKAN FREECAM
        
        -- 1. Nonaktifkan Modul
        FreecamModule.ToggleFreecam()
        freecamEnabled = false
        
        -- 2. Lepas blokir lompat
        game:GetService("ContextActionService"):UnbindAction("BlockFreecamJump")
        
        -- 3. Reset Kamera ke Karakter (PENTING)
        local cam = Workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            cam.CameraSubject = player.Character.Humanoid
        end
        
        -- 4. Kembalikan Kursor Mouse
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        
        Rayfield:Notify({Title = "Freecam", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
    end
end

-- ===================================================================
-- [[ PLAYER LIST HELPER ]] (MANUAL REFRESH ONLY - NO LAG)
-- ===================================================================

local cachedPlayerList = {}
local allPlayerDropdowns = {}

-- Fungsi Helper untuk mendapatkan Username asli
local function getUsernameFromString(text)
    local username = string.match(text, "@(.*)%)")
    return username or text
end

-- Fungsi Update Cache (Hanya scan pemain saat dipanggil)
local function updatePlayerCache()
    cachedPlayerList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then 
            -- Format: DisplayName (@Username)
            local formattedName = p.DisplayName .. " (@" .. p.Name .. ")"
            table.insert(cachedPlayerList, formattedName)
        end
    end
    table.sort(cachedPlayerList)
    return cachedPlayerList
end

-- Jalankan sekali saat script di-inject agar list tidak kosong
updatePlayerCache()

-- Fungsi ini HANYA jalan saat tombol Refresh ditekan
local function refreshAllPlayerDropdowns()
    -- Scan ulang pemain saat ini juga
    local list = updatePlayerCache()
    
    -- Update semua dropdown di UI
    for _, dropdown in ipairs(allPlayerDropdowns) do
        if dropdown and dropdown.Refresh then
            pcall(function() dropdown:Refresh(list, true) end)
        end
    end
end

-- Getter untuk Dropdown
local function getPlayerList()
    return cachedPlayerList
end

local function createNotification(title, content, duration)
    Rayfield:Notify({Title = title, Content = content, Duration = duration or 3, Image = 7733964719})
end

-- ===================================================================
-- [[ MOUNT 1: MIKA LOGIC ]]
-- ===================================================================

local teleportLocations_Mika = {
    Vector3.new(516.6929931640625, 193.8096923828125, -552.5011596679688),
    Vector3.new(646.3467407226562, 177.81179809570312, -635.9164428710938),
    Vector3.new(1106.0369873046875, 217.80970764160156, -360.0383605957031),
    Vector3.new(1181.2825927734375, 221.80970764160156, -568.0306396484375),
    Vector3.new(1328.599365234375, 255.16400146484375, -598.1030883789062),
    Vector3.new(1499.004638671875, 382.2225036621094, -626.5504150390625),
    Vector3.new(1511.6126708984375, 452.14947509765625, -107.55013275146484),
    Vector3.new(1230.667236328125, 430.00970458984375, -114.93517303466797),
    Vector3.new(1120.10498046875, 446.004150390625, 30.018861770629883),
    Vector3.new(678.1668701171875, 598.0096435546875, -249.78890991210938),
    Vector3.new(954.8308715820312, 653.9006958007812, -61.01375961303711),
    Vector3.new(983.392578125, 676.4656982421875, -235.31455993652344),
    Vector3.new(1050.96826171875, 678.0096435546875, -21.644765853881836),
    Vector3.new(472.10546875, 648.8245239257812, 643.0199584960938),
    Vector3.new(432.1709899902344, 818.555908203125, 1194.9698486328125),
    Vector3.new(482.2349853515625, 921.5828247070312, 1838.03857421875),
    Vector3.new(473.0296630859375, 963.4253540039062, 2059.5498046875)
}
local autoTeleportEnabled_Mika = false
local godModeConnection_Mika = nil
local teleportCoroutine_Mika = nil
local teleportDelay_Mika = 1.5
local currentTeleportIndex_Mika = 0

local function activateGodMode_Mika(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Mika then godModeConnection_Mika:Disconnect() end
    -- Menggunakan TrackConn untuk cleanup
    godModeConnection_Mika = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Mika then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Mika then
                godModeConnection_Mika:Disconnect()
                godModeConnection_Mika = nil
            end
        end
    end))
end

local function stopAutoTeleport_Mika()
    autoTeleportEnabled_Mika = false
    if godModeConnection_Mika then
        godModeConnection_Mika:Disconnect()
        godModeConnection_Mika = nil
    end
    -- Tidak perlu close coroutine di sini, karena sudah diurus oleh CleanupSession
end

local function startTeleportLoop_Mika()
    while autoTeleportEnabled_Mika and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        currentTeleportIndex_Mika = currentTeleportIndex_Mika + 1

        if currentTeleportIndex_Mika > #teleportLocations_Mika then
            currentTeleportIndex_Mika = 0
            if godModeConnection_Mika then
                godModeConnection_Mika:Disconnect()
                godModeConnection_Mika = nil
            end
            pcall(function() game:GetService("ReplicatedStorage").CP_DropToStart:FireServer() end)
            task.wait(2.5) 
            continue
        end
        
        activateGodMode_Mika(humanoid)
        local location = teleportLocations_Mika[currentTeleportIndex_Mika]
        teleportCharacter(character, location)
        task.wait(teleportDelay_Mika)
    end
    stopAutoTeleport_Mika()
end


-- ===================================================================
-- [[ MOUNT 2: GEMI LOGIC ]]
-- ===================================================================

local teleportLocations_Gemi = {
    Vector3.new(850.3866577148438, 631.5690307617188, 1144.0350341796875), Vector3.new(645.9818725585938, 631.2415161132812, 1147.972900390625),
    Vector3.new(555.5932006835938, 707.5690307617188, 1125.379638671875), Vector3.new(-199.89993286132812, 771.5690307617188, 1025.2025146484375),
    Vector3.new(-194.77223205566406, 771.5690307617188, 276.277099609375), Vector3.new(-287.89910888671875, 639.5690307617188, 175.0592498779297),
    Vector3.new(-639.2085571289062, 771.5690307617188, 9.303144454956055), Vector3.new(-964.3776245117188, 775.5690307617188, 439.8299255371094),
    Vector3.new(-1513.415771484375, 943.5690307617188, 780.7603149414062), Vector3.new(-1925.3817138671875, 943.5690307617188, 191.7897491455078),
    Vector3.new(-2434.858154296875, 779.5690307617188, -255.02557373046875), Vector3.new(-2079.968017578125, 1051.5689697265625, -381.79815673828125),
    Vector3.new(-1756.7718505859375, 1219.5689697265625, -484.61761474609375), Vector3.new(-1875.0968017578125, 1435.5689697265625, -691.7169189453125),
    Vector3.new(-1435.0040283203125, 1435.5689697265625, -1357.06396484375), Vector3.new(-1374.8426513671875, 1535.5689697265625, -1569.4886474609375),
    Vector3.new(-1305.24658203125, 1707.5689697265625, -1660.0555419921875), Vector3.new(-1879.7392578125, 1707.5689697265625, -2037.0003662109375),
    Vector3.new(-2176.423095703125, 1711.5689697265625, -2045.0057373046875), Vector3.new(-2591.745361328125, 1871.5689697265625, -2399.902587890625),
    Vector3.new(-2916.31494140625, 1735.5689697265625, -2154.502685546875), Vector3.new(-3266.813232421875, 1739.5689697265625, -2409.79150390625),
    Vector3.new(-3399.127197265625, 1935.5689697265625, -2505.082763671875), Vector3.new(-3895.340576171875, 1943.5689697265625, -2220.270751953125),
    Vector3.new(-3967.74560546875, 1755.5689697265625, -2300.5126953125), Vector3.new(-3917.8193359375, 1755.5689697265625, -1710.0574951171875),
    Vector3.new(-4144.79638671875, 1943.5689697265625, -1473.3497314453125), Vector3.new(-4308.4931640625, 1943.5689697265625, -1100.2879638671875),
    Vector3.new(-3713.350830078125, 1943.5689697265625, -535.397705078125), Vector3.new(-3505.2314453125, 1659.5689697265625, 75.0819091796875),
    Vector3.new(-3720.32763671875, 1661.0533447265625, 459.52398681640625), Vector3.new(-4144.39794921875, 1659.5689697265625, 494.5744323730469),
    Vector3.new(-4225.3525390625, 1659.5689697265625, 971.677978515625), Vector3.new(-4566.68505859375, 1657.6314697265625, 645.3320922851562),
    Vector3.new(-4464.8505859375, 1659.5689697265625, 151.4462127685547), Vector3.new(-4488.75244140625, 2059.56884765625, 55.408111572265625),
    Vector3.new(-4890.02197265625, 2059.56884765625, 686.902587890625), Vector3.new(-5395.06689453125, 2061.81884765625, 536.578857421875),
    Vector3.new(-5425.0107421875, 1887.5689697265625, 423.1357421875), Vector3.new(-5318.22265625, 1887.5689697265625, 157.05653381347656),
    Vector3.new(-5264.71142578125, 1887.5689697265625, -175.04971313476562), Vector3.new(-4969.80224609375, 1911.5689697265625, -426.25048828125),
    Vector3.new(-4834.80419921875, 2059.56884765625, -571.4168701171875), Vector3.new(-5001.35595703125, 2059.56884765625, -1229.989501953125),
    Vector3.new(-4919.7099609375, 2067.56884765625, -1569.7496337890625), Vector3.new(-5185.1767578125, 2067.56884765625, -1749.6533203125),
    Vector3.new(-5078.51904296875, 2151.56884765625, -1920.4010009765625), Vector3.new(-5259.5166015625, 2291.56884765625, -2251.442626953125),
    Vector3.new(-5854.296875, 2467.56884765625, -1783.11767578125), Vector3.new(-5917.74365234375, 2707.56884765625, -827.6270141601562),
    Vector3.new(-6630.3056640625, 3151.559814453125, -795.6190795898438)
}
local autoTeleportEnabled_Gemi = false
local godModeConnection_Gemi = nil
local teleportCoroutine_Gemi = nil
local teleportDelay_Gemi = 0.1
local currentTeleportIndex_Gemi = 0 -- Tidak dipakai di Gemi, tapi dideklarasikan untuk konsistensi

local function activateGodMode_Gemi(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Gemi then godModeConnection_Gemi:Disconnect() end
    godModeConnection_Gemi = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Gemi then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Gemi then
                godModeConnection_Gemi:Disconnect()
                godModeConnection_Gemi = nil
            end
        end
    end))
end

local function stopAutoTeleport_Gemi()
    autoTeleportEnabled_Gemi = false
    if godModeConnection_Gemi then
        godModeConnection_Gemi:Disconnect()
        godModeConnection_Gemi = nil
    end
end

local function startTeleportLoop_Gemi()
    local lastLocationIndex = #teleportLocations_Gemi
    while autoTeleportEnabled_Gemi and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        activateGodMode_Gemi(humanoid)
        
        -- Teleport ke lokasi terakhir
        local location = teleportLocations_Gemi[lastLocationIndex]
        teleportCharacter(character, location)
        task.wait(teleportDelay_Gemi)
        
        -- Memicu respawn CP (Asumsi remote "ReqResetCP" valid di game ini)
        if godModeConnection_Gemi then
            godModeConnection_Gemi:Disconnect()
            godModeConnection_Gemi = nil
        end
        pcall(function() game:GetService("ReplicatedStorage").CheckpointSystem.ReqResetCP:FireServer() end)
        
        player.CharacterAdded:Wait()
        task.wait(1)
    end
    stopAutoTeleport_Gemi()
end


-- ===================================================================
-- [[ MOUNT 3: BEAJA LOGIC ]]
-- ===================================================================

local teleportLocations_Beaja = {
    Vector3.new(-1119.64, 148.75, 298.83), Vector3.new(-707.21, 96.63, 491.17), Vector3.new(-724.97, 108.94, 305.90),
    Vector3.new(-662.87, 119.05, 63.17), Vector3.new(-278.28, 97.01, -44.61), Vector3.new(519.56, 136.54, -37.24),
    Vector3.new(586.94, 277.62, -86.65), Vector3.new(746.00, 377.96, -61.52), Vector3.new(760.22, 458.22, -171.74),
    Vector3.new(1133.09, 594.60, 103.22), Vector3.new(1356.79, 722.71, -82.12), Vector3.new(1506.85, 740.15, -138.37),
    Vector3.new(1468.65, 800.56, -212.95), Vector3.new(1543.47, 857.32, -400.81), Vector3.new(1613.72, 876.82, -254.73),
    Vector3.new(1602.30, 969.95, -192.28), Vector3.new(1237.82, 942.79, -371.78), Vector3.new(1525.22, 1009.32, -413.88),
    Vector3.new(1539.78, 1070.33, -578.47), Vector3.new(1663.49, 1178.21, -852.99), Vector3.new(1587.00, 1430.00, -972.54),
    Vector3.new(1375.22, 1429.77, -1090.88), Vector3.new(1141.93, 1450.89, -1185.65), Vector3.new(1394.65, 1494.84, -1252.45),
    Vector3.new(1327.26, 1518.27, -1100.34), Vector3.new(1455.24, 1676.25, -1389.80), Vector3.new(1411.77, 1725.65, -1529.35),
    Vector3.new(1360.62, 1786.64, -1701.38), Vector3.new(1466.71, 1793.74, -1812.34), Vector3.new(1557.33, 1878.00, -1963.26),
    Vector3.new(1344.18, 2053.76, -2267.95), Vector3.new(1525.21, 2178.60, -2454.31), Vector3.new(1503.68, 2238.15, -2597.72),
    Vector3.new(1416.02, 2308.21, -2645.92), Vector3.new(1394.03, 2301.64, -2707.12)
}
local autoTeleportEnabled_Beaja = false
local godModeConnection_Beaja = nil
local teleportCoroutine_Beaja = nil
local teleportDelay_Beaja = 1.5
local currentTeleportIndex_Beaja = 0

local function activateGodMode_Beaja(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Beaja then godModeConnection_Beaja:Disconnect() end
    godModeConnection_Beaja = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Beaja then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Beaja then
                godModeConnection_Beaja:Disconnect()
                godModeConnection_Beaja = nil
            end
        end
    end))
end

local function stopAutoTeleport_Beaja()
    autoTeleportEnabled_Beaja = false
    if godModeConnection_Beaja then
        godModeConnection_Beaja:Disconnect()
        godModeConnection_Beaja = nil
    end
end

local function startTeleportLoop_Beaja()
    while autoTeleportEnabled_Beaja and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        currentTeleportIndex_Beaja = currentTeleportIndex_Beaja + 1

        if currentTeleportIndex_Beaja > #teleportLocations_Beaja then
            currentTeleportIndex_Beaja = 0
            if godModeConnection_Beaja then
                godModeConnection_Beaja:Disconnect()
                godModeConnection_Beaja = nil
            end
            humanoid.Health = 0
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end
        
        activateGodMode_Beaja(humanoid)
        local location = teleportLocations_Beaja[currentTeleportIndex_Beaja]
        teleportCharacter(character, location)
        task.wait(teleportDelay_Beaja)
    end
    stopAutoTeleport_Beaja()
end

-- ===================================================================
-- [[ MOUNT 4: MAAF LOGIC ]]
-- ===================================================================

local teleportLocations_Maaf = {
    Vector3.new(-799.3898315429688, 203.56907653808594, -376.1388854980469), Vector3.new(-829.17236328125, 199.56907653808594, -169.6573486328125),
    Vector3.new(-431.79876708984375, 207.56907653808594, -172.06552124023438), Vector3.new(-715.0905151367188, 323.5690612792969, 30.009061813354492),
    Vector3.new(-315.80755615234375, 323.56903076171875, -5.9478254318237305), Vector3.new(-224.0460662841797, 376.6620178222656, 315.6397705078125),
    Vector3.new(-201.8218536376953, 367.5690612792969, 624.7332763671875), Vector3.new(-196.59983825683594, 283.56903076171875, 897.213134765625),
    Vector3.new(-232.6274871826172, 355.56903076171875, 1345.657958984375), Vector3.new(-237.2722930908203, 593.5689697265625, 2055.876220703125)
}
local autoTeleportEnabled_Maaf = false
local godModeConnection_Maaf = nil
local teleportCoroutine_Maaf = nil
local teleportDelay_Maaf = 0.5
local currentTeleportIndex_Maaf = 0

local function activateGodMode_Maaf(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Maaf then godModeConnection_Maaf:Disconnect() end
    godModeConnection_Maaf = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Maaf then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Maaf then
                godModeConnection_Maaf:Disconnect()
                godModeConnection_Maaf = nil
            end
        end
    end))
end

local function stopAutoTeleport_Maaf()
    autoTeleportEnabled_Maaf = false
    if godModeConnection_Maaf then
        godModeConnection_Maaf:Disconnect()
        godModeConnection_Maaf = nil
    end
end

local function startTeleportLoop_Maaf()
    while autoTeleportEnabled_Maaf and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        currentTeleportIndex_Maaf = currentTeleportIndex_Maaf + 1

        if currentTeleportIndex_Maaf > #teleportLocations_Maaf then
            currentTeleportIndex_Maaf = 0
            if godModeConnection_Maaf then
                godModeConnection_Maaf:Disconnect()
                godModeConnection_Maaf = nil
            end
            humanoid.Health = 0
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end
        
        activateGodMode_Maaf(humanoid)
        local location = teleportLocations_Maaf[currentTeleportIndex_Maaf]
        teleportCharacter(character, location)
        task.wait(teleportDelay_Maaf)
    end
    stopAutoTeleport_Maaf()
end

-- ===================================================================
-- [[ MOUNT 5: KOTA LOGIC ]]
-- ===================================================================

local teleportLocations_Kota = {
	Vector3.new(-455.15972900390625, 112.14170837402344, 53.73706817626953), Vector3.new(-598.843505859375, 111.4283676147461, 242.91510009765625),
	Vector3.new(-554.863037109375, 126.38681030273438, 373.9130859375), Vector3.new(-424.31036376953125, 157.30636596679688, 364.7170104980469),
	Vector3.new(-288.1586608886719, 251.2385711669922, 374.8346252441406), Vector3.new(-92.31280517578125, 190.5758514404297, 354.5635681152344),
	Vector3.new(-56.26321029663086, 99.88958740234375, 66.4233627319336), Vector3.new(138.876220703125, 111.43180847167969, 77.2187271118164),
	Vector3.new(129.5753173828125, 81.49308776855469, 182.6982879638672), Vector3.new(190.3717498779297, 167.67715454101562, 115.52503967285156),
	Vector3.new(282.01995849609375, 210.2179718017578, 263.7448425292969), Vector3.new(346.1614685058594, 291.32342529296875, 282.6249694824219),
	Vector3.new(445.17529296875, 237.3234405517578, 125.45742797851562), Vector3.new(450.37445068359375, 237.3234405517578, 35.843135833740234)    
}
local autoTeleportEnabled_Kota = false
local godModeConnection_Kota = nil
local teleportCoroutine_Kota = nil
local teleportDelay_Kota = 0.5
local FAST_WALK_SPEED_KOTA = 150
local DEFAULT_WALKSPEED_KOTA = 16
local currentTeleportIndex_Kota = 0 -- Index tidak dipakai, tapi untuk konsistensi

local function activateGodMode_Kota(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Kota then godModeConnection_Kota:Disconnect() end
    godModeConnection_Kota = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Kota then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Kota then
                godModeConnection_Kota:Disconnect()
                godModeConnection_Kota = nil
            end
        end
    end))
end

local function stopAutoTeleport_Kota()
    autoTeleportEnabled_Kota = false
    if godModeConnection_Kota then
        godModeConnection_Kota:Disconnect()
        godModeConnection_Kota = nil
    end
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid.WalkSpeed == FAST_WALK_SPEED_KOTA then
                humanoid.WalkSpeed = DEFAULT_WALKSPEED_KOTA
            end
        end
    end)
end

local function startTeleportLoop_Kota()
    while autoTeleportEnabled_Kota and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        activateGodMode_Kota(humanoid)
        
        -- TP ke Lokasi 13
        local location13 = teleportLocations_Kota[13]
        teleportCharacter(character, location13)
        task.wait(teleportDelay_Kota)

        if not autoTeleportEnabled_Kota or not character.Parent then break end

        -- Jalan ke Lokasi 14
        local originalWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = FAST_WALK_SPEED_KOTA

        local location14 = teleportLocations_Kota[14]
        humanoid:MoveTo(location14)
        humanoid.MoveToFinished:Wait()

        humanoid.WalkSpeed = originalWalkSpeed
        task.wait(1)
    end
    stopAutoTeleport_Kota()
end


-- ===================================================================
-- [[ MOUNT 6: YAHAYUK LOGIC ]]
-- ===================================================================

local teleportLocations_Yahayuk = {
	Vector3.new(-417.380126953125, 249.0288543701172, 786.6184692382812), Vector3.new(-325.7160339355469, 388.0288391113281, 526.5806274414062),
	Vector3.new(294.494384765625, 429.7513427734375, 494.60980224609375), Vector3.new(320.7550048828125, 490.0288391113281, 343.9421691894531),
	Vector3.new(232.34165954589844, 314.0288391113281, -144.6268768310547), Vector3.new(-616.29, 907.59, -548.54),
	Vector3.new(-621.73, 907.09, -488.93)
}
local autoTeleportEnabled_Yahayuk = false
local godModeConnection_Yahayuk = nil
local teleportCoroutine_Yahayuk = nil
local teleportDelay_Yahayuk = 50.0
local FAST_WALK_SPEED_YAHAYUK = 150
local DEFAULT_WALKSPEED_YAHAYUK = 16
local currentTeleportIndex_Yahayuk = 0

local function activateGodMode_Yahayuk(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Yahayuk then godModeConnection_Yahayuk:Disconnect() end
    godModeConnection_Yahayuk = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Yahayuk then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Yahayuk then
                godModeConnection_Yahayuk:Disconnect()
                godModeConnection_Yahayuk = nil
            end
        end
    end))
end

local function stopAutoTeleport_Yahayuk()
    autoTeleportEnabled_Yahayuk = false
    if godModeConnection_Yahayuk then
        godModeConnection_Yahayuk:Disconnect()
        godModeConnection_Yahayuk = nil
    end
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid.WalkSpeed == FAST_WALK_SPEED_YAHAYUK then
                humanoid.WalkSpeed = DEFAULT_WALKSPEED_YAHAYUK
            end
        end
    end)
end

local function startTeleportLoop_Yahayuk()
    while autoTeleportEnabled_Yahayuk and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        currentTeleportIndex_Yahayuk = currentTeleportIndex_Yahayuk + 1

        if currentTeleportIndex_Yahayuk > #teleportLocations_Yahayuk then
            currentTeleportIndex_Yahayuk = 0
            task.wait(1)
            continue
        end
        
        activateGodMode_Yahayuk(humanoid)
        local location = teleportLocations_Yahayuk[currentTeleportIndex_Yahayuk]

        if currentTeleportIndex_Yahayuk <= 6 then
            teleportCharacter(character, location)
            task.wait(teleportDelay_Yahayuk)
        
        elseif currentTeleportIndex_Yahayuk == 7 then
            local originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = FAST_WALK_SPEED_YAHAYUK

            humanoid:MoveTo(location)
            humanoid.MoveToFinished:Wait()

            humanoid.WalkSpeed = originalWalkSpeed
            task.wait(1)
        end
    end
    stopAutoTeleport_Yahayuk()
end


-- ===================================================================
-- [[ MOUNT 7: DAUN LOGIC ]]
-- ===================================================================

local teleportLocations_Daun = {
    Vector3.new(-621.80078125, 251.1346435546875, -383.9368591308594), Vector3.new(-1202.6944580078125, 262.4915466308594, -487.06494140625),
    Vector3.new(-1399.2435302734375, 579.22509765625, -949.69482421875), Vector3.new(-1700.4952392578125, 817.47314453125, -1399.55810546875),
    Vector3.new(-3202.830078125, 1724.828369140625, -2612.1083984375)
}
local autoTeleportEnabled_Daun = false
local godModeConnection_Daun = nil
local teleportCoroutine_Daun = nil
local teleportDelay_Daun = 50.0
local currentTeleportIndex_Daun = 0

local function activateGodMode_Daun(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Daun then godModeConnection_Daun:Disconnect() end
    godModeConnection_Daun = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Daun then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Daun then
                godModeConnection_Daun:Disconnect()
                godModeConnection_Daun = nil
            end
        end
    end))
end

local function stopAutoTeleport_Daun()
    autoTeleportEnabled_Daun = false
    if godModeConnection_Daun then
        godModeConnection_Daun:Disconnect()
        godModeConnection_Daun = nil
    end
end

local function startTeleportLoop_Daun()
    while autoTeleportEnabled_Daun and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        currentTeleportIndex_Daun = currentTeleportIndex_Daun + 1

        if currentTeleportIndex_Daun > #teleportLocations_Daun then
            currentTeleportIndex_Daun = 0
            if godModeConnection_Daun then
                godModeConnection_Daun:Disconnect()
                godModeConnection_Daun = nil
            end
            humanoid.Health = 0
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end
        
        activateGodMode_Daun(humanoid)
        local location = teleportLocations_Daun[currentTeleportIndex_Daun]
        teleportCharacter(character, location)
        task.wait(teleportDelay_Daun)
    end
    stopAutoTeleport_Daun()
end


-- ===================================================================
-- [[ MOUNT 8: KOHARU LOGIC ]]
-- ===================================================================

local teleportLocations_Koharu = {
    Vector3.new(-473.33770751953125, 48.22697830200195, 624.3318481445312), Vector3.new(-182.94534301757812, 51.48152160644531, 691.5358276367188),
    Vector3.new(122.13579559326172, 201.13453674316406, 950.2888793945312), Vector3.new(12.115828514099121, 195.8564453125, 339.71588134765625),
    Vector3.new(243.34719848632812, 195.8475341796875, 804.6380615234375), Vector3.new(661.7496948242188, 212.36453247070312, 750.2777709960938),
    Vector3.new(661.3375244140625, 204.32481384277344, 367.4189453125), Vector3.new(522.0333862304688, 215.82542419433594, 282.65411376953125),
    Vector3.new(522.494384765625, 215.8475341796875, -334.7238464355469), Vector3.new(562.6368408203125, 212.69845581054688, -558.5210571289062),
    Vector3.new(567.1116333007812, 284.0202331542969, -923.6049194335938), Vector3.new(112.03789520263672, 287.6818542480469, -655.0603637695312),
    Vector3.new(-307.5657958984375, 411.548828125, -610.6095581054688), Vector3.new(-488.37261962890625, 524.4557495117188, -663.8218383789062),
    Vector3.new(-676.0758056640625, 483.5115051269531, -970.385986328125), Vector3.new(-558.351318359375, 259.8475341796875, -1320.5484619140625),
    Vector3.new(-426.8153076171875, 375.8475036621094, -1514.6676025390625), Vector3.new(-982.8803100585938, 636.988037109375, -1622.2510986328125),
    Vector3.new(-1394.8544921875, 798.93994140625, -1563.697509765625), Vector3.new(-1540.634765625, 922.3053588867188, -2149.600830078125)
}
local autoTeleportEnabled_Koharu = false
local godModeConnection_Koharu = nil
local teleportCoroutine_Koharu = nil
local teleportDelay_Koharu = 1.5
local currentTeleportIndex_Koharu = 0

local function activateGodMode_Koharu(humanoid)
    humanoid.Health = humanoid.MaxHealth
    if godModeConnection_Koharu then godModeConnection_Koharu:Disconnect() end
    godModeConnection_Koharu = TrackConn(humanoid.HealthChanged:Connect(function()
        if autoTeleportEnabled_Koharu then
            humanoid.Health = humanoid.MaxHealth
        else
            if godModeConnection_Koharu then
                godModeConnection_Koharu:Disconnect()
                godModeConnection_Koharu = nil
            end
        end
    end))
end

local function stopAutoTeleport_Koharu()
    autoTeleportEnabled_Koharu = false
    if godModeConnection_Koharu then
        godModeConnection_Koharu:Disconnect()
        godModeConnection_Koharu = nil
    end
end

local function startTeleportLoop_Koharu()
    while autoTeleportEnabled_Koharu and not SessionStop do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if not character.Parent or humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
            task.wait(1)
            continue
        end

        currentTeleportIndex_Koharu = currentTeleportIndex_Koharu + 1

        if currentTeleportIndex_Koharu > #teleportLocations_Koharu then
            currentTeleportIndex_Koharu = 0
            if godModeConnection_Koharu then
                godModeConnection_Koharu:Disconnect()
                godModeConnection_Koharu = nil
            end
            pcall(function() game:GetService("ReplicatedStorage").TeleportToBasecamp:FireServer() end)
            task.wait(2.5) 
            continue
        end
        
        activateGodMode_Koharu(humanoid)
        local location = teleportLocations_Koharu[currentTeleportIndex_Koharu]
        teleportCharacter(character, location)
        task.wait(teleportDelay_Koharu)
    end
    stopAutoTeleport_Koharu()
end

-- ===================================================================
-- [[ FUNGSI PEMBERSIH SEMUA MOUNT (Untuk Dipakai di Toggle) ]]
-- ===================================================================

local function stopAllMountTeleports()
    stopAutoTeleport_Mika()
    stopAutoTeleport_Gemi()
    stopAutoTeleport_Beaja()
    stopAutoTeleport_Maaf()
    stopAutoTeleport_Kota()
    stopAutoTeleport_Yahayuk()
    stopAutoTeleport_Daun()
    stopAutoTeleport_Koharu()
end
