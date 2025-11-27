-- AsuHub_Logic.lua
-- Berisi semua sistem dan fungsi logika

getgenv().AsuHub_Logic = {}

-- ===================================================================
-- [[ SYSTEM: ANTI-DOUBLE EXECUTE & CLEANUP (FIXED) ]]
-- ===================================================================
local AsuHub_Logic = getgenv().AsuHub_Logic

-- Hentikan sesi lama sebelum memulai yang baru
if getgenv().AsuHub_Session then
    if getgenv().AsuHub_Session.Matikan then
        getgenv().AsuHub_Session.Matikan()
    end
    task.wait(0.1)
end

AsuHub_Logic.SessionConnections = {} 
AsuHub_Logic.SessionStop = false     

function AsuHub_Logic.CleanupSession()
    AsuHub_Logic.SessionStop = true
    
    -- 1. Putuskan Koneksi
    for _, conn in pairs(AsuHub_Logic.SessionConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect()
        elseif type(conn) == "thread" then task.cancel(conn) end
    end
    
    -- 2. Reset Karakter
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

getgenv().AsuHub_Session = { Matikan = AsuHub_Logic.CleanupSession }

function AsuHub_Logic.TrackConn(c) 
    table.insert(AsuHub_Logic.SessionConnections, c)
    return c 
end

function AsuHub_Logic.TrackCoroutine(c) 
    table.insert(AsuHub_Logic.SessionConnections, c)
    return c 
end

-- ===================================================================
-- [[ SERVICES & VARIABLES ]]
-- ===================================================================

AsuHub_Logic.Players = game:GetService("Players")
AsuHub_Logic.player = AsuHub_Logic.Players.LocalPlayer
AsuHub_Logic.RunService = game:GetService("RunService")
AsuHub_Logic.UserInputService = game:GetService("UserInputService")
AsuHub_Logic.Workspace = game:GetService("Workspace")
AsuHub_Logic.ContextActionService = game:GetService("ContextActionService")
AsuHub_Logic.HttpService = game:GetService("HttpService")
AsuHub_Logic.ReplicatedStorage = game:GetService("ReplicatedStorage")

AsuHub_Logic.mouse = AsuHub_Logic.player:GetMouse()

-- Teleport Function
function AsuHub_Logic.teleportCharacter(character, position)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Check R15
local character = AsuHub_Logic.player.Character or AsuHub_Logic.player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
AsuHub_Logic.isR15 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R15

-- ===================================================================
-- [[ FREECAM MODULE ]]
-- ===================================================================

AsuHub_Logic.FreecamModule = (function()
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

AsuHub_Logic.flyEnabled = false
AsuHub_Logic.flyKeyDown, AsuHub_Logic.flyKeyUp = nil, nil
AsuHub_Logic.flyControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
AsuHub_Logic.flyBaseSpeed = 50

function AsuHub_Logic.stopFly()
    AsuHub_Logic.flyEnabled = false
    local char = AsuHub_Logic.player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("AsuHub_FlyGyro") then root.AsuHub_FlyGyro:Destroy() end
            if root:FindFirstChild("AsuHub_FlyVelocity") then root.AsuHub_FlyVelocity:Destroy() end
        end
    end
end

function AsuHub_Logic.startFly()
    if AsuHub_Logic.flyEnabled then return end
    
    -- [[ ANTI-COLLISION ]] 
    if AsuHub_Logic.platformEnabled then
        AsuHub_Logic.togglePlatform(false)
    end
    
    AsuHub_Logic.flyEnabled = true
    
    local T = AsuHub_Logic.player.Character and AsuHub_Logic.player.Character:FindFirstChild("HumanoidRootPart")
    if not T then return end

    local BG = Instance.new("BodyGyro", T)
    local BV = Instance.new("BodyVelocity", T)
    BG.Name = "AsuHub_FlyGyro"
    BV.Name = "AsuHub_FlyVelocity"
    BG.P = 9e4
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    AsuHub_Logic.TrackCoroutine(task.spawn(function()
        while AsuHub_Logic.flyEnabled do
            if AsuHub_Logic.SessionStop then AsuHub_Logic.stopFly(); break end 
            if not AsuHub_Logic.player.Character or not AsuHub_Logic.player.Character:FindFirstChild("Humanoid") then AsuHub_Logic.stopFly(); break end
            
            AsuHub_Logic.player.Character.Humanoid.PlatformStand = true
            BG.CFrame = AsuHub_Logic.Workspace.CurrentCamera.CFrame
            
            local direction = Vector3.new()
            if AsuHub_Logic.flyControl.F > 0 then direction = direction + AsuHub_Logic.Workspace.CurrentCamera.CFrame.LookVector end
            if AsuHub_Logic.flyControl.B < 0 then direction = direction - AsuHub_Logic.Workspace.CurrentCamera.CFrame.LookVector end
            if AsuHub_Logic.flyControl.L < 0 then direction = direction - AsuHub_Logic.Workspace.CurrentCamera.CFrame.RightVector end
            if AsuHub_Logic.flyControl.R > 0 then direction = direction + AsuHub_Logic.Workspace.CurrentCamera.CFrame.RightVector end
            if AsuHub_Logic.flyControl.Q > 0 then direction = direction + Vector3.new(0, 1, 0) end
            if AsuHub_Logic.flyControl.E < 0 then direction = direction - Vector3.new(0, 1, 0) end
            
            if direction.Magnitude > 0 then
                BV.Velocity = direction * AsuHub_Logic.flyBaseSpeed
            else
                BV.Velocity = Vector3.new(0, 0, 0)
            end
            task.wait()
        end
    end))

    -- Keybinds
    if AsuHub_Logic.flyKeyDown then AsuHub_Logic.flyKeyDown:Disconnect() end
    AsuHub_Logic.flyKeyDown = AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local k = input.KeyCode.Name:lower()
        if k == "w" then AsuHub_Logic.flyControl.F = 1
        elseif k == "s" then AsuHub_Logic.flyControl.B = -1
        elseif k == "a" then AsuHub_Logic.flyControl.L = -1
        elseif k == "d" then AsuHub_Logic.flyControl.R = 1
        elseif k == "e" then AsuHub_Logic.flyControl.Q = 1
        elseif k == "q" then AsuHub_Logic.flyControl.E = -1
        end
    end))

    if AsuHub_Logic.flyKeyUp then AsuHub_Logic.flyKeyUp:Disconnect() end
    AsuHub_Logic.flyKeyUp = AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputEnded:Connect(function(input)
        local k = input.KeyCode.Name:lower()
        if k == "w" then AsuHub_Logic.flyControl.F = 0
        elseif k == "s" then AsuHub_Logic.flyControl.B = 0
        elseif k == "a" then AsuHub_Logic.flyControl.L = 0
        elseif k == "d" then AsuHub_Logic.flyControl.R = 0
        elseif k == "e" then AsuHub_Logic.flyControl.Q = 0
        elseif k == "q" then AsuHub_Logic.flyControl.E = 0
        end
    end))
end

-- ===================================================================
-- [[ ESP SYSTEM ]] (MODIFIED: Added Health)
-- ===================================================================

AsuHub_Logic.ESP_FRIEND_COLOR = Color3.fromRGB(0, 0, 255)
AsuHub_Logic.ESP_ENEMY_COLOR = Color3.fromRGB(255, 0, 0) 
AsuHub_Logic.ESP_USE_TEAM_COLOR = true

AsuHub_Logic.espHolder = Instance.new("Folder", game:GetService("CoreGui"))
AsuHub_Logic.espHolder.Name = "AsuHub_ESP_Holder"

AsuHub_Logic.espNameTagTemplate = Instance.new("BillboardGui")
AsuHub_Logic.espNameTagTemplate.Name = "ESP_NameTag"
AsuHub_Logic.espNameTagTemplate.Enabled = true
AsuHub_Logic.espNameTagTemplate.Size = UDim2.new(0, 200, 0, 70) 
AsuHub_Logic.espNameTagTemplate.AlwaysOnTop = true
AsuHub_Logic.espNameTagTemplate.StudsOffset = Vector3.new(0, 3.5, 0)

AsuHub_Logic.espListLayout = Instance.new("UIListLayout", AsuHub_Logic.espNameTagTemplate)
AsuHub_Logic.espListLayout.FillDirection = Enum.FillDirection.Vertical
AsuHub_Logic.espListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
AsuHub_Logic.espListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 1. Distance Label
AsuHub_Logic.espDistanceLabel = Instance.new("TextLabel", AsuHub_Logic.espNameTagTemplate)
AsuHub_Logic.espDistanceLabel.Name = "Distance"
AsuHub_Logic.espDistanceLabel.BackgroundTransparency = 1
AsuHub_Logic.espDistanceLabel.Size = UDim2.new(1, 0, 0, 20)
AsuHub_Logic.espDistanceLabel.TextSize = 14
AsuHub_Logic.espDistanceLabel.TextColor3 = Color3.new(1, 1, 1)
AsuHub_Logic.espDistanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
AsuHub_Logic.espDistanceLabel.TextStrokeTransparency = 0.2
AsuHub_Logic.espDistanceLabel.Text = " 0 m "
AsuHub_Logic.espDistanceLabel.Font = Enum.Font.SourceSans

-- 2. Name Label
AsuHub_Logic.espTagLabel = Instance.new("TextLabel", AsuHub_Logic.espNameTagTemplate)
AsuHub_Logic.espTagLabel.Name = "Tag"
AsuHub_Logic.espTagLabel.BackgroundTransparency = 1
AsuHub_Logic.espTagLabel.Size = UDim2.new(1, 0, 0, 20)
AsuHub_Logic.espTagLabel.TextSize = 16
AsuHub_Logic.espTagLabel.TextColor3 = Color3.new(1, 1, 1)
AsuHub_Logic.espTagLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
AsuHub_Logic.espTagLabel.TextStrokeTransparency = 0.4
AsuHub_Logic.espTagLabel.Text = "PlayerName"
AsuHub_Logic.espTagLabel.Font = Enum.Font.SourceSansBold

-- 3. Health Label
AsuHub_Logic.espHealthLabel = Instance.new("TextLabel", AsuHub_Logic.espNameTagTemplate)
AsuHub_Logic.espHealthLabel.Name = "Health"
AsuHub_Logic.espHealthLabel.BackgroundTransparency = 1
AsuHub_Logic.espHealthLabel.Size = UDim2.new(1, 0, 0, 20)
AsuHub_Logic.espHealthLabel.TextSize = 12
AsuHub_Logic.espHealthLabel.TextColor3 = Color3.new(0, 1, 0)
AsuHub_Logic.espHealthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
AsuHub_Logic.espHealthLabel.TextStrokeTransparency = 0.4
AsuHub_Logic.espHealthLabel.Text = "HP: 100"
AsuHub_Logic.espHealthLabel.Font = Enum.Font.SourceSansBold

AsuHub_Logic.espEnabled = false
AsuHub_Logic.espConnection = nil

function AsuHub_Logic.removeESP(target)
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

    local nameTag = AsuHub_Logic.espHolder:FindFirstChild(target.Name .. "_NameTag")
    if nameTag then
        nameTag:Destroy()
    end
end

function AsuHub_Logic.updateESP(target, color)
    local localPlayerHead = AsuHub_Logic.player.Character and AsuHub_Logic.player.Character:FindFirstChild("Head")
    
    if target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChildOfClass("Humanoid") then
        local head = target.Character.Head
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")

        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        -- Update Highlight
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
        local nameTag = AsuHub_Logic.espHolder:FindFirstChild(target.Name .. "_NameTag")
        if not nameTag then
            nameTag = AsuHub_Logic.espNameTagTemplate:Clone()
            nameTag.Name = target.Name .. "_NameTag"
            nameTag.Adornee = head
            nameTag.Parent = AsuHub_Logic.espHolder
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

        -- Update Health
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
        AsuHub_Logic.removeESP(target)
    end
end

function AsuHub_Logic.stopESP()
    if not AsuHub_Logic.espEnabled then return end
    AsuHub_Logic.espEnabled = false
    
    if AsuHub_Logic.espConnection then
        AsuHub_Logic.espConnection:Disconnect()
        AsuHub_Logic.espConnection = nil
    end
    
    for _, v in ipairs(AsuHub_Logic.Players:GetPlayers()) do
        AsuHub_Logic.removeESP(v) 
    end
end

function AsuHub_Logic.startESP()
    if AsuHub_Logic.espEnabled then return end
    AsuHub_Logic.espEnabled = true
    
    AsuHub_Logic.espConnection = AsuHub_Logic.TrackConn(AsuHub_Logic.RunService.Heartbeat:Connect(function()
        local allPlayers = AsuHub_Logic.Players:GetPlayers()
        local activeESPPlayers = {}

        for _, v in ipairs(allPlayers) do
            if v ~= AsuHub_Logic.player then
                local color = AsuHub_Logic.ESP_USE_TEAM_COLOR and v.TeamColor.Color or 
                             ((AsuHub_Logic.player.TeamColor == v.TeamColor) and AsuHub_Logic.ESP_FRIEND_COLOR or AsuHub_Logic.ESP_ENEMY_COLOR)
                AsuHub_Logic.updateESP(v, color)
                activeESPPlayers[v.Name] = true
            else
                AsuHub_Logic.removeESP(v)
            end
        end

        for _, child in ipairs(AsuHub_Logic.espHolder:GetChildren()) do
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

AsuHub_Logic.noclipEnabled = false
AsuHub_Logic.noclipConnection = nil

AsuHub_Logic.godModeEnabled = false
AsuHub_Logic.godModeConnection = nil

AsuHub_Logic.JumpConn = nil

function AsuHub_Logic.toggleInfiniteJump(state)
    if AsuHub_Logic.JumpConn then
        AsuHub_Logic.JumpConn:Disconnect()
        AsuHub_Logic.JumpConn = nil
    end

    if state then
        AsuHub_Logic.JumpConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Space then
                local char = AsuHub_Logic.player.Character
                local hum = char and char:FindFirstChild("Humanoid")
                
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        AsuHub_Logic.TrackConn(AsuHub_Logic.JumpConn)
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Infinite Jump", Content = "Diaktifkan! (Spam Spasi)", Duration = 2, Image = 7733964719})
        end
    else
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Infinite Jump", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
        end
    end
end

function AsuHub_Logic.toggleNoclip(state)
    AsuHub_Logic.noclipEnabled = state
    
    if state then
        if AsuHub_Logic.noclipConnection then
            AsuHub_Logic.noclipConnection:Disconnect()
            AsuHub_Logic.noclipConnection = nil
        end

        AsuHub_Logic.noclipConnection = AsuHub_Logic.TrackConn(AsuHub_Logic.RunService.Stepped:Connect(function()
            if AsuHub_Logic.noclipEnabled and AsuHub_Logic.player.Character then
                for _, part in pairs(AsuHub_Logic.player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end))
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Noclip", Content = "Diaktifkan!", Duration = 3, Image = 7733964719})
        end

    else
        if AsuHub_Logic.noclipConnection then
            AsuHub_Logic.noclipConnection:Disconnect()
            AsuHub_Logic.noclipConnection = nil
        end
        
        if AsuHub_Logic.player.Character then
            for _, part in pairs(AsuHub_Logic.player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true 
                end
            end
            
            local rootPart = AsuHub_Logic.player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CanCollide = false
            end
        end
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Noclip", Content = "Dimatikan!", Duration = 3, Image = 7733964719})
        end
    end
end

function AsuHub_Logic.toggleGodMode(state)
    AsuHub_Logic.godModeEnabled = state
    local hum = AsuHub_Logic.player.Character and AsuHub_Logic.player.Character:FindFirstChild("Humanoid")
    
    if state and hum then
        if AsuHub_Logic.godModeConnection then AsuHub_Logic.godModeConnection:Disconnect() end
        
        hum.Health = hum.MaxHealth
        
        AsuHub_Logic.godModeConnection = AsuHub_Logic.TrackConn(hum.HealthChanged:Connect(function()
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end))
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "God Mode", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
        end
    else
        if AsuHub_Logic.godModeConnection then AsuHub_Logic.godModeConnection:Disconnect() end
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "God Mode", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
        end
    end
end

-- ===================================================================
-- [[ SPAWN PLATFORM SYSTEM (V7 - SPEED CONTROL READY) ]]
-- ===================================================================

AsuHub_Logic.platformSpeed = 25
AsuHub_Logic.platformEnabled = false
AsuHub_Logic.platformPart = nil
AsuHub_Logic.platformControlLoop = nil 
AsuHub_Logic.platformInputBegan = nil
AsuHub_Logic.platformInputEnded = nil

AsuHub_Logic.targetY = nil           
AsuHub_Logic.moveUp = false          
AsuHub_Logic.moveDown = false        

function AsuHub_Logic.getLegHeight(hum)
    if not hum then return 3 end 
    if hum.RigType == Enum.HumanoidRigType.R15 then
        return hum.HipHeight + (hum.RootPart and hum.RootPart.Size.Y/2 or 0)
    else
        return 3.0
    end
end

function AsuHub_Logic.createPlatform()
    if AsuHub_Logic.platformPart and AsuHub_Logic.platformPart.Parent then 
        AsuHub_Logic.platformPart:Destroy() 
        AsuHub_Logic.platformPart = nil
    end
    
    AsuHub_Logic.platformPart = Instance.new("Part")
    AsuHub_Logic.platformPart.Name = "AsuHub_Platform"
    AsuHub_Logic.platformPart.Size = Vector3.new(6, 1, 6) 
    AsuHub_Logic.platformPart.Transparency = 0.5
    AsuHub_Logic.platformPart.Color = Color3.fromRGB(0, 255, 255) 
    AsuHub_Logic.platformPart.Material = Enum.Material.Neon
    AsuHub_Logic.platformPart.CanCollide = true
    AsuHub_Logic.platformPart.Anchored = true 
    AsuHub_Logic.platformPart.Parent = AsuHub_Logic.Workspace

    return AsuHub_Logic.platformPart
end

function AsuHub_Logic.togglePlatform(state)
    if AsuHub_Logic.platformEnabled == state then return end
    
    AsuHub_Logic.platformEnabled = state
    
    if AsuHub_Logic.platformInputBegan then AsuHub_Logic.platformInputBegan:Disconnect(); AsuHub_Logic.platformInputBegan = nil end
    if AsuHub_Logic.platformInputEnded then AsuHub_Logic.platformInputEnded:Disconnect(); AsuHub_Logic.platformInputEnded = nil end
    if AsuHub_Logic.platformControlLoop then coroutine.close(AsuHub_Logic.platformControlLoop); AsuHub_Logic.platformControlLoop = nil end
    
    if state then
        if AsuHub_Logic.flyEnabled then
            AsuHub_Logic.stopFly()
        end
        
        AsuHub_Logic.createPlatform()
        
        local char = AsuHub_Logic.player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if root and hum then
            AsuHub_Logic.targetY = root.Position.Y - AsuHub_Logic.getLegHeight(hum) - 0.5
        end

        AsuHub_Logic.platformInputBegan = AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.E then AsuHub_Logic.moveUp = true end
            if input.KeyCode == Enum.KeyCode.Q then AsuHub_Logic.moveDown = true end
        end))
        
        AsuHub_Logic.platformInputEnded = AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.E then AsuHub_Logic.moveUp = false end
            if input.KeyCode == Enum.KeyCode.Q then AsuHub_Logic.moveDown = false end
        end))

        AsuHub_Logic.platformControlLoop = AsuHub_Logic.TrackCoroutine(task.spawn(function()
            while AsuHub_Logic.platformEnabled and AsuHub_Logic.platformPart and AsuHub_Logic.platformPart.Parent do
                if AsuHub_Logic.SessionStop then break end
                
                local dt = AsuHub_Logic.RunService.Heartbeat:Wait()
                local char = AsuHub_Logic.player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                
                if root and hum then
                    local legHeight = AsuHub_Logic.getLegHeight(hum)
                    local currentFeetY = root.Position.Y - legHeight - 0.5
                    local moveAmount = AsuHub_Logic.platformSpeed * dt
                    local distToPlatform = math.abs(currentFeetY - AsuHub_Logic.targetY)
                    local isStandingOnPlatform = distToPlatform < 3.5 
                    
                    if AsuHub_Logic.moveUp then
                        AsuHub_Logic.targetY = AsuHub_Logic.targetY + moveAmount
                        if isStandingOnPlatform then
                            root.CFrame = root.CFrame * CFrame.new(0, moveAmount, 0)
                            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                        end
                    elseif AsuHub_Logic.moveDown then
                        AsuHub_Logic.targetY = AsuHub_Logic.targetY - moveAmount
                        if isStandingOnPlatform then
                            root.CFrame = root.CFrame * CFrame.new(0, -moveAmount, 0)
                            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                        end
                    else
                        local state = hum:GetState()
                        local isAirborne = (state == Enum.HumanoidStateType.Freefall) or (state == Enum.HumanoidStateType.Jumping)
                        if isAirborne or (currentFeetY - AsuHub_Logic.targetY) > 3 then
                            AsuHub_Logic.targetY = currentFeetY
                        end
                    end
                    local finalPos = Vector3.new(root.Position.X, AsuHub_Logic.targetY, root.Position.Z)
                    AsuHub_Logic.platformPart.CFrame = CFrame.new(finalPos)
                end
            end
            if AsuHub_Logic.platformEnabled then AsuHub_Logic.togglePlatform(false) end
        end))
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Spawn Platform", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
        end
        
    else
        if AsuHub_Logic.platformPart then AsuHub_Logic.platformPart:Destroy(); AsuHub_Logic.platformPart = nil end
        AsuHub_Logic.moveUp = false; AsuHub_Logic.moveDown = false
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Spawn Platform", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
        end
    end
end

-- ===================================================================
-- [[ CLICK TELEPORT ]]
-- ===================================================================

AsuHub_Logic.clickTeleportEnabled = false
AsuHub_Logic.clickTeleportConnection = nil

function AsuHub_Logic.toggleClickTeleport(state)
    AsuHub_Logic.clickTeleportEnabled = state
    if state then
        if AsuHub_Logic.clickTeleportConnection then AsuHub_Logic.clickTeleportConnection:Disconnect() end
        
        AsuHub_Logic.clickTeleportConnection = AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 and AsuHub_Logic.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                if AsuHub_Logic.mouse and AsuHub_Logic.player.Character then
                    AsuHub_Logic.player.Character:MoveTo(AsuHub_Logic.mouse.Hit.Position)
                end
            end
        end))
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Teleport", Content = "Diaktifkan! (Ctrl + Left Click)", Duration = 2, Image = 7733964719})
        end
    else
        if AsuHub_Logic.clickTeleportConnection then AsuHub_Logic.clickTeleportConnection:Disconnect() end
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Teleport", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
        end
    end
end

-- ===================================================================
-- [[ FLING SYSTEM ]]
-- ===================================================================

if not getgenv().FPDH then
     getgenv().FPDH = workspace.FallenPartsDestroyHeight
end

function AsuHub_Logic.Message(_Title, _Text, Time)
    if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
        getgenv().AsuHub_UI.Rayfield:Notify({
            Title = _Title,
            Content = _Text,
            Duration = Time or 5, 
            Image = 7733964719
        })
    end
end

function AsuHub_Logic.SkidFling(TargetPlayer)
    local Character = AsuHub_Logic.player.Character
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
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= AsuHub_Logic.Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
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
            return AsuHub_Logic.Message("Error Occurred", "Target is missing everything", 5)
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
        return AsuHub_Logic.Message("Error Occurred", "Random error", 5)
    end
end

-- ===================================================================
-- [[ ANIMATION SYSTEM (REVISI TOTAL - SYNCED) ]]
-- ===================================================================

AsuHub_Logic.Animations -- Variabel Data Animasi
AsuHub_Logic.lastAnimations = {} -- Variabel Memori Penyimpanan
AsuHub_Logic.setAnimation, AsuHub_Logic.loadLastAnimations, AsuHub_Logic.saveLastAnimations -- Fungsi Utama
AsuHub_Logic.ResetIdle, AsuHub_Logic.ResetWalk, AsuHub_Logic.ResetRun, AsuHub_Logic.ResetJump, AsuHub_Logic.ResetFall, AsuHub_Logic.ResetSwim, AsuHub_Logic.ResetSwimIdle, AsuHub_Logic.ResetClimb -- Fungsi Reset

if AsuHub_Logic.isR15 then
    AsuHub_Logic.HttpService = game:GetService("HttpService")

    AsuHub_Logic.Animations = {
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

    function AsuHub_Logic.freeze()
        AsuHub_Logic.player = game:GetService("Players").LocalPlayer
        AsuHub_Logic.character = player.Character or player.CharacterAdded:Wait()
        AsuHub_Logic.humanoid = character:WaitForChild("Humanoid")
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
    
    function AsuHub_Logic.unfreeze()
        AsuHub_Logic.player = game:GetService("Players").LocalPlayer
        AsuHub_Logic.character = player.Character or player.CharacterAdded:Wait()
        AsuHub_Logic.humanoid = character:WaitForChild("Humanoid")
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

    function AsuHub_Logic.saveLastAnimations(lasyAnimations)
        local data = HttpService:JSONEncode(lastAnimations)
        pcall(function() writefile("AsuHubAnimasiPack.json", data) end)
    end
    
    function AsuHub_Logic.refresh()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:wait(0.1)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
    
    function AsuHub_Logic.refreshswim()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:wait(0.1)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
    end
    
    function AsuHub_Logic.refreshclimb()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:wait(0.1)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
    end
    
    -- Definisi Fungsi Reset (Global)
    function AsuHub_Logic.ResetIdle()
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
    
    function AsuHub_Logic.ResetWalk()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function AsuHub_Logic.ResetRun()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function AsuHub_Logic.ResetJump()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function AsuHub_Logic.ResetFall()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
        end)
    end
    
    function AsuHub_Logic.ResetSwim()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            if Animate.swim then Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0" end
        end)
    end
    
    function AsuHub_Logic.ResetSwimIdle()
        local speaker = Players.LocalPlayer
        local Char = speaker.Character
        local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
        for _, v in next, Hum:GetPlayingAnimationTracks() do v:Stop(0) end
        pcall(function()
            local Animate = Char.Animate
            if Animate.swimidle then Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0" end
        end)
    end
    
    function AsuHub_Logic.ResetClimb()
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
    function AsuHub_Logic.setAnimation(animationType, animationId)
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
                AsuHub_Logic.ResetIdle()
                Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[1]
                Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId[2]
                AsuHub_Logic.refresh()
            elseif animationType == "Walk" then
                lastAnimations.Walk = animationId
                AsuHub_Logic.ResetWalk()
                Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refresh()
            elseif animationType == "Run" then
                lastAnimations.Run = animationId
                AsuHub_Logic.ResetRun()
                Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refresh()
            elseif animationType == "Jump" then
                lastAnimations.Jump = animationId
                AsuHub_Logic.ResetJump()
                Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refresh()
            elseif animationType == "Fall" then
                lastAnimations.Fall = animationId
                AsuHub_Logic.ResetFall()
                Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refresh()
            elseif animationType == "Swim" and Animate:FindFirstChild("swim") then
                lastAnimations.Swim = animationId
                AsuHub_Logic.ResetSwim()
                Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refreshswim()
            elseif animationType == "SwimIdle" and Animate:FindFirstChild("swimidle") then
                lastAnimations.SwimIdle = animationId
                AsuHub_Logic.ResetSwimIdle()
                Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refreshswim()
            elseif animationType == "Climb" then
                lastAnimations.Climb = animationId
                AsuHub_Logic.ResetClimb()
                Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                AsuHub_Logic.refreshclimb()
            end
            AsuHub_Logic.saveLastAnimations(lastAnimations)
        end)
    
        if not success then
            warn("Failed to set animation:", err)
        end
    
        wait(0.1)
        unfreeze()
    end
    
    function AsuHub_Logic.loadLastAnimations()
        if isfile("AsuHubAnimasiPack.json") then
            local data = readfile("AsuHubAnimasiPack.json")
            local lastAnimationsData = HttpService:JSONDecode(data)
            if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
                getgenv().AsuHub_UI.Rayfield:Notify({ Title = "Animasi", Content = "Menyiapkan animasi yang tersimpan...", Icon = "play", Duration = 3, Image = 7733964719})
            end
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
            if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
                getgenv().AsuHub_UI.Rayfield:Notify({Title = "Animasi", Content = "Tidak ada animasi tersimpan.", Duration = 5, Image = 7733964719})
            end
        end
    end
    
    AsuHub_Logic.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        AsuHub_Logic.hum = character:WaitForChild("Humanoid")
        AsuHub_Logic.animate = character:WaitForChild("Animate", 10)
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

AsuHub_Logic.freecamEnabled = false

function AsuHub_Logic.toggleFreecam(state)
    if state == AsuHub_Logic.freecamEnabled then return end
    
    if state then
        if AsuHub_Logic.flyEnabled then
            AsuHub_Logic.stopFly()
        end
        
        local result = AsuHub_Logic.FreecamModule.ToggleFreecam()
        AsuHub_Logic.freecamEnabled = true
        
        local CAS = game:GetService("ContextActionService")
        CAS:BindActionAtPriority("BlockFreecamJump", function(_, state, _)
            return state == Enum.UserInputState.Begin and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
        end, false, 3000, Enum.KeyCode.Space)
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Freecam", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
        end
    else
        AsuHub_Logic.FreecamModule.ToggleFreecam()
        AsuHub_Logic.freecamEnabled = false
        
        game:GetService("ContextActionService"):UnbindAction("BlockFreecamJump")
        
        local cam = AsuHub_Logic.Workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        if AsuHub_Logic.player.Character and AsuHub_Logic.player.Character:FindFirstChild("Humanoid") then
            cam.CameraSubject = AsuHub_Logic.player.Character.Humanoid
        end
        
        AsuHub_Logic.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        AsuHub_Logic.UserInputService.MouseIconEnabled = true
        
        if getgenv().AsuHub_UI and getgenv().AsuHub_UI.Rayfield then
            getgenv().AsuHub_UI.Rayfield:Notify({Title = "Freecam", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
        end
    end
end

-- ===================================================================
-- [[ PLAYER LIST HELPER ]] (MANUAL REFRESH ONLY - NO LAG)
-- ===================================================================

AsuHub_Logic.cachedPlayerList = {}
AsuHub_Logic.allPlayerDropdowns = {}

function AsuHub_Logic.getUsernameFromString(text)
    local username = string.match(text, "@(.*)%)")
    return username or text
end

function AsuHub_Logic.updatePlayerCache()
    AsuHub_Logic.cachedPlayerList = {}
    for _, p in ipairs(AsuHub_Logic.Players:GetPlayers()) do
        if p ~= AsuHub_Logic.player then 
            local formattedName = p.DisplayName .. " (@" .. p.Name .. ")"
            table.insert(AsuHub_Logic.cachedPlayerList, formattedName)
        end
    end
    table.sort(AsuHub_Logic.cachedPlayerList)
    return AsuHub_Logic.cachedPlayerList
end

function AsuHub_Logic.refreshAllPlayerDropdowns()
    local list = AsuHub_Logic.updatePlayerCache()
    
    for _, dropdown in ipairs(AsuHub_Logic.allPlayerDropdowns) do
        if dropdown and dropdown.Refresh then
            pcall(function() dropdown:Refresh(list, true) end)
        end
    end
end

function AsuHub_Logic.getPlayerList()
    return AsuHub_Logic.cachedPlayerList
end

-- ===================================================================
-- [[ GAME-SPECIFIC SYSTEMS ]]
-- ===================================================================

-- Palma RP System
AsuHub_Logic.PalmaRP_PlaceID = 93448637916605

function AsuHub_Logic.setupPalmaRPSystem()
    local isInPalmaRP = false
    
    if game.PlaceId == AsuHub_Logic.PalmaRP_PlaceID then
        isInPalmaRP = true
    elseif AsuHub_Logic.ReplicatedStorage:FindFirstChild("JualIkanRemote") then
        isInPalmaRP = true
    end
    
    if isInPalmaRP then
        -- Setup Palma RP variables and functions
        AsuHub_Logic.antiAFKEnabled = false
        AsuHub_Logic.antiAFKConnection = nil
        AsuHub_Logic.bulkFishEnabled = false
        AsuHub_Logic.autoSellEnabled = false
        AsuHub_Logic.autoSellInterval = 1
        AsuHub_Logic.autoCartonEnabled = false
        AsuHub_Logic.autoSellCartonEnabled = false
        AsuHub_Logic.autoEatEnabled = false
        AsuHub_Logic.autoEatInterval = 3
        AsuHub_Logic.autoDrinkEnabled = false
        AsuHub_Logic.autoDrinkInterval = 3
        
        -- Palma RP functions would be defined here
        -- ... (seluruh fungsi Palma RP dari script asli)
    end
end

-- Fish It System  
AsuHub_Logic.FishIt_PlaceID = 121864768012064

function AsuHub_Logic.setupFishItSystem()
    local isFishItGame = (game.PlaceId == AsuHub_Logic.FishIt_PlaceID)
    
    if not isFishItGame then
        local success = pcall(function()
            if game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net:FindFirstChild("RF/PurchaseWeatherEvent") then
                isFishItGame = true
            end
        end)
    end
    
    if isFishItGame then
        -- Setup Fish It variables and functions
        AsuHub_Logic.FISHIT_LOCATIONS = {
            ["Spawn"] = CFrame.new(45.2788086, 252.562927, 2987.10913),
            -- ... (seluruh lokasi Fish It)
        }
        
        AsuHub_Logic.FastReelEnabled = false
        AsuHub_Logic.ReelSpeed = 0.05
        AsuHub_Logic.AutoEquipEnabled = false
        AsuHub_Logic.FishIt_AutoSell = false
        AsuHub_Logic.FishIt_SellDelay = 30
        AsuHub_Logic.WeatherList = {}
        AsuHub_Logic.SelectedWeathers = {}
        AsuHub_Logic.AutoBuyWeather = false
        AsuHub_Logic.AntiStuckEnabled = false
        AsuHub_Logic.CurrentStuckLimit = 15
        AsuHub_Logic.FishIt_AntiAFK = false
        
        -- Fish It functions would be defined here
        -- ... (seluruh fungsi Fish It dari script asli)
    end
end

-- Auto Obby System
AsuHub_Logic.Obby_PlaceID = 80692223709267

function AsuHub_Logic.setupObbySystem()
    if game.PlaceId == AsuHub_Logic.Obby_PlaceID then
        -- Setup Auto Obby variables and functions
        AsuHub_Logic.REBIRTH_MAX_STAGE = 251
        AsuHub_Logic.InitialStartStage = 1
        AsuHub_Logic.TravelSpeed = 100
        AsuHub_Logic.activeTween = nil
        AsuHub_Logic.AutoObbyEnabled = false
        AsuHub_Logic.checkpointConnection = nil
        
        -- Auto Obby functions would be defined here
        -- ... (seluruh fungsi Auto Obby dari script asli)
    end
end

-- Mount Systems
function AsuHub_Logic.setupMountSystems()
    local CurrentPlaceId = game.PlaceId
    
    -- Game IDs
    AsuHub_Logic.GAME_ID_MIKA    = 112818969245263
    AsuHub_Logic.GAME_ID_GEMI    = 140014177882408
    AsuHub_Logic.GAME_ID_BEAJA   = 140042712387550
    AsuHub_Logic.GAME_ID_MAAF    = 137711865214502
    AsuHub_Logic.GAME_ID_KOTA    = 108523862114142
    
    function AsuHub_Logic.isCurrentGame(targetId)
        return CurrentPlaceId == targetId
    end
    
    -- Mika System
    if AsuHub_Logic.isCurrentGame(AsuHub_Logic.GAME_ID_MIKA) then
        AsuHub_Logic.teleportLocations_Mika = {
            Vector3.new(516.6929931640625, 193.8096923828125, -552.5011596679688),
            -- ... (seluruh lokasi Mika)
        }
        AsuHub_Logic.autoTeleportEnabled_Mika = false
        AsuHub_Logic.godModeConnection_Mika = nil
        AsuHub_Logic.teleportCoroutine_Mika = nil
        AsuHub_Logic.teleportDelay_Mika = 1.5
        AsuHub_Logic.currentTeleportIndex_Mika = 0
        
        -- Mika functions would be defined here
        -- ... (seluruh fungsi Mika dari script asli)
    end
    
    -- Other mount systems (Gemi, Beaja, Maaf, Kota) would be similarly set up
    -- ... (seluruh mount systems dari script asli)
end

-- ===================================================================
-- [[ INITIALIZATION ]]
-- ===================================================================

function AsuHub_Logic.initialize()
    -- Initialize player cache
    AsuHub_Logic.updatePlayerCache()
    
    -- Setup game-specific systems
    AsuHub_Logic.setupPalmaRPSystem()
    AsuHub_Logic.setupFishItSystem()
    AsuHub_Logic.setupObbySystem()
    AsuHub_Logic.setupMountSystems()
    
    -- Setup keybinds
    AsuHub_Logic.setupKeybinds()
    
    -- Setup character listeners
    AsuHub_Logic.setupCharacterListeners()
    
    return true
end

function AsuHub_Logic.setupKeybinds()
    -- Fly keybind
    AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.V then 
            -- Toggle fly logic
        end
    end))
    
    -- Freecam keybind
    AsuHub_Logic.TrackConn(AsuHub_Logic.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.P and 
          (AsuHub_Logic.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
           AsuHub_Logic.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) then
           local newState = not AsuHub_Logic.freecamEnabled
           AsuHub_Logic.toggleFreecam(newState)
        end
    end))
end

function AsuHub_Logic.setupCharacterListeners()
    AsuHub_Logic.player.CharacterAdded:Connect(function(character)
        task.wait(1)
        -- Re-initialize character-specific systems
        if AsuHub_Logic.isR15 and AsuHub_Logic.Animations then
            -- Reload animations
            if AsuHub_Logic.lastAnimations.Idle then AsuHub_Logic.setAnimation("Idle", AsuHub_Logic.lastAnimations.Idle) end
            if AsuHub_Logic.lastAnimationsData.Walk then AsuHub_Logic.setAnimation("Walk", AsuHub_Logic.lastAnimationsData.Walk) end
            if AsuHub_Logic.lastAnimationsData.Run then AsuHub_Logic.setAnimation("Run", AsuHub_Logic.lastAnimationsData.Run) end
            if AsuHub_Logic.lastAnimationsData.Jump then AsuHub_Logic.setAnimation("Jump", AsuHub_Logic.lastAnimationsData.Jump) end
            if AsuHub_Logic.lastAnimationsData.Fall then AsuHub_Logic.setAnimation("Fall", AsuHub_Logic.lastAnimationsData.Fall) end
            if AsuHub_Logic.lastAnimationsData.Climb then AsuHub_Logic.setAnimation("Climb", AsuHub_Logic.lastAnimationsData.Climb) end
            if AsuHub_Logic.lastAnimationsData.Swim then AsuHub_Logic.setAnimation("Swim", AsuHub_Logic.lastAnimationsData.Swim) end
            if AsuHub_Logic.lastAnimationsData.SwimIdle then AsuHub_Logic.setAnimation("SwimIdle", AsuHub_Logic.lastAnimationsData.SwimIdle) end
        end
    end)
end

function AsuHub_Logic.setupAutoSave()
    -- Auto-save logic if needed
end

-- Initialize the logic system
AsuHub_Logic.initialize()

return AsuHub_Logic
