-- ===================================================================
-- [[ CREATE WINDOW ]]
-- ===================================================================

local Window = Rayfield:CreateWindow({
   Name = "AsuHub",
   LoadingTitle = "AsuHub Loading...",
   LoadingSubtitle = "by @yogurutto",
   ShowText = "AsuHub", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Amethyst", -- Check https://docs.sirius.menu/rayfield/configuration/themes
   
   ToggleUIKeybind = "G", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)
   
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

--    ConfigurationSaving = {
--       Enabled = true,
--       FolderName = "AsuHub",
--       FileName = "AsuHub"
--    },
--    Discord = {
--       Enabled = false,
--       Invite = "noinvitelink",
--       RememberJoins = true
--    },

   KeySystem = false,
   KeySettings = {
      Title = "AsuHub",
      Subtitle = "Cit Vip Enih",
      Note = "Hayo Passwordnya Apah?",
      FileName = "AsuHubKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"maenasu", "1234"}
   }
})

-- ===================================================================
-- [[ TAB 1: INFORMATION ]]
-- ===================================================================

local InfoTab = Window:CreateTab("Information", 7733960981)

InfoTab:CreateSection("Tentang AsuHub")

InfoTab:CreateParagraph({Title = "Selamat Datang di AsuHub!", Content = "Skrip all-in-one untuk Member Maen Asu. Beragam fitur-fitur terbaik yang dibuat secara mandiri. Selamat menikmati Fitur-fitur lengkapnya!\n\n⚠️ Jika ada kendala Laporkan langsung ke Discord dan Tag @Yogurutto"})

InfoTab:CreateSection("Discord Server")

InfoTab:CreateButton({
   Name = "Copy Link Discord",
   Callback = function()
      setclipboard("https://discord.gg/")
      Rayfield:Notify({Title = "Discord", Content = "Tautan disalin ke papan klip!", Duration = 3, Image = 7733964719})
   end,
})

InfoTab:CreateSection("Changelog")

InfoTab:CreateParagraph({Title = "📢 Versi 1.2 (Palma RP Added)", Content = "• Menambahkan Tab Palma RP\n• Fitur Auto Farm & Fish Palma RP\n• Fitur Auto Sell Palma RP (Custom Interval)\n• Fitur Teleport Toko Palma RP\n• Fitur Toggle Anti AFK Palma RP\n• Perbaikan fitur-fitur sebelumnya"})

-- ===================================================================
-- [[ TAB 2: PLAYER (COMPLETE & FIXED) ]]
-- ===================================================================

local PlayerTab = Window:CreateTab("Player", 4370318685)
local FlyToggleUI = nil
local PlatformToggleUI = nil
local FreecamToggle = nil

-- === 0. HELPER & VARIABLES ===
local function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Ambil nilai default karakter saat ini
local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
local defaultWalkspeed = 16
local defaultGravity = round(Workspace.Gravity, 1)
local defaultJumpHeight = 7.2
local defaultJumpPower = 50

-- Update default jika humanoid ada
if humanoid then
    defaultWalkspeed = round(humanoid.WalkSpeed, 0)
    defaultJumpHeight = round(humanoid.JumpHeight, 1)
    defaultJumpPower = round(humanoid.JumpPower, 0)
end

-- === 1. LOGIKA FLY (FIXED & INTEGRATED) ===
local flyEnabled = false
local flySpeed = 50
local flyBodyGyro, flyBodyVelocity
local flyControl = {F=0, B=0, L=0, R=0, Q=0, E=0}

local function stopFlyLogic()
    flyEnabled = false
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if hum then hum.PlatformStand = false end
        if root then
            if root:FindFirstChild("AsuHub_FlyGyro") then root.AsuHub_FlyGyro:Destroy() end
            if root:FindFirstChild("AsuHub_FlyVelocity") then root.AsuHub_FlyVelocity:Destroy() end
        end
    end
end

local function startFlyLogic()
    if flyEnabled then return end
    flyEnabled = true
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    -- Setup Movers
    flyBodyGyro = Instance.new("BodyGyro", root)
    flyBodyGyro.Name = "AsuHub_FlyGyro"
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = root.CFrame

    flyBodyVelocity = Instance.new("BodyVelocity", root)
    flyBodyVelocity.Name = "AsuHub_FlyVelocity"
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

    hum.PlatformStand = true

    -- Loop Fly
    TrackCoroutine(task.spawn(function()
        while flyEnabled and not SessionStop do
            if not root or not root.Parent or not hum or hum.Health <= 0 then 
                stopFlyLogic()
                break 
            end
            
            hum.PlatformStand = true 
            
            local cam = Workspace.CurrentCamera
            local direction = Vector3.new()
            
            if flyControl.F > 0 then direction = direction + cam.CFrame.LookVector end
            if flyControl.B < 0 then direction = direction - cam.CFrame.LookVector end
            if flyControl.L < 0 then direction = direction - cam.CFrame.RightVector end
            if flyControl.R > 0 then direction = direction + cam.CFrame.RightVector end
            if flyControl.Q > 0 then direction = direction + Vector3.new(0, 1, 0) end
            if flyControl.E < 0 then direction = direction - Vector3.new(0, 1, 0) end
            
            flyBodyGyro.CFrame = cam.CFrame
            flyBodyVelocity.Velocity = direction * flySpeed
            
            task.wait()
        end
        stopFlyLogic()
    end))
end

-- Keybind Fly
TrackConn(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then flyControl.F = 1
    elseif k == Enum.KeyCode.S then flyControl.B = -1
    elseif k == Enum.KeyCode.A then flyControl.L = -1
    elseif k == Enum.KeyCode.D then flyControl.R = 1
    elseif k == Enum.KeyCode.E then flyControl.Q = 1
    elseif k == Enum.KeyCode.Q then flyControl.E = -1
    elseif k == Enum.KeyCode.V then 
        if FlyToggleUI then FlyToggleUI:Set(not flyEnabled) end
    end
end))

TrackConn(UserInputService.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then flyControl.F = 0
    elseif k == Enum.KeyCode.S then flyControl.B = 0
    elseif k == Enum.KeyCode.A then flyControl.L = 0
    elseif k == Enum.KeyCode.D then flyControl.R = 0
    elseif k == Enum.KeyCode.E then flyControl.Q = 0
    elseif k == Enum.KeyCode.Q then flyControl.E = 0
    end
end))

-- === 2. LOGIKA PLATFORM V7 (FIXED & INTEGRATED) ===
local platformEnabled = false
local platformSpeed = 25
local platformPart = nil
local platMoveUp, platMoveDown = false, false

local function stopPlatformLogic()
    platformEnabled = false
    platMoveUp = false
    platMoveDown = false
    if platformPart then platformPart:Destroy(); platformPart = nil end
end

local function startPlatformLogic()
    if platformEnabled then return end
    platformEnabled = true
    
    if platformPart then platformPart:Destroy() end
    platformPart = Instance.new("Part")
    platformPart.Name = "AsuHub_Platform"
    platformPart.Size = Vector3.new(6, 1, 6)
    platformPart.Transparency = 0.5
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Material = Enum.Material.Neon
    platformPart.Anchored = true
    platformPart.Parent = Workspace
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local targetY = root.Position.Y - 3.5 

    TrackCoroutine(task.spawn(function()
        while platformEnabled and not SessionStop do
            if not root or not root.Parent or not platformPart then 
                stopPlatformLogic()
                break 
            end
            
            local dt = RunService.Heartbeat:Wait()
            local moveAmount = platformSpeed * dt
            
            local legHeight = 3
            if hum.RigType == Enum.HumanoidRigType.R15 then
                legHeight = hum.HipHeight + (root.Size.Y / 2)
            end
            
            local currentFeetY = root.Position.Y - legHeight - 0.5
            local distToPlat = math.abs(currentFeetY - targetY)
            local isStanding = distToPlat < 3.5

            if platMoveUp then
                targetY = targetY + moveAmount
                if isStanding then
                    root.CFrame = root.CFrame * CFrame.new(0, moveAmount, 0)
                    root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                end
            elseif platMoveDown then
                targetY = targetY - moveAmount
                if isStanding then
                    root.CFrame = root.CFrame * CFrame.new(0, -moveAmount, 0)
                    root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
                end
            else
                local state = hum:GetState()
                local isAir = (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping)
                if isAir or (currentFeetY - targetY) > 3 then
                    targetY = currentFeetY
                end
            end
            
            platformPart.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
        end
    end))
end

-- Keybind Platform
TrackConn(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then platMoveUp = true end
    if input.KeyCode == Enum.KeyCode.Q then platMoveDown = true end
end))
TrackConn(UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then platMoveUp = false end
    if input.KeyCode == Enum.KeyCode.Q then platMoveDown = false end
end))


-- === 3. UI SECTION (SEMUA SLIDER DAN TOMBOL ADA DI SINI) ===

-- Quick Controls Section
PlayerTab:CreateSection("Quick Controls")

PlayerTab:CreateParagraph({
    Title = "Keyboard Shortcuts",
    Content = [[
• Fly: Tekan V
• Freecam: Tahan Shift + P
• Platform: Tahan E/Q untuk Naik/Turun
• Movement: W/A/S/D/Q/E]]
})

-- Movement Section
PlayerTab:CreateSection("Movement")

local walkspeedSlider = PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {1, 500},
    Increment = 1,
    Precision = 0,
    Suffix = "studs",
    CurrentValue = defaultWalkspeed, 
    Flag = "WalkSpeed",
    Callback = function(value)
        local roundedValue = round(value, 0) 
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = roundedValue
        end
    end,
})

local currentJumpValue = defaultJumpPower
if humanoid and not humanoid.UseJumpPower then currentJumpValue = defaultJumpHeight end

local jumpSlider = PlayerTab:CreateSlider({
    Name = "Jump (Height/Power)",
    Range = {1, 500},
    Increment = 1,
    Precision = 1,
    Suffix = "Value",
    CurrentValue = currentJumpValue, 
    Flag = "JumpValue",
    Callback = function(value)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            if hum.UseJumpPower then
                hum.JumpPower = round(value, 0)
            else
                hum.JumpHeight = round(value, 1)
            end
        end
    end,
})

local gravitySlider = PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {1, 500},
    Increment = 1,
    Precision = 1,
    Suffix = "gravity",
    CurrentValue = defaultGravity,
    Flag = "Gravity",
    Callback = function(value)
        Workspace.Gravity = round(value, 1)
    end,
})

PlayerTab:CreateButton({
    Name = "Reset to Default",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            hum.WalkSpeed = defaultWalkspeed
            if hum.UseJumpPower then
                hum.JumpPower = defaultJumpPower
                jumpSlider:Set(defaultJumpPower)
            else
                hum.JumpHeight = defaultJumpHeight
                jumpSlider:Set(defaultJumpHeight)
            end
        end
        Workspace.Gravity = defaultGravity
        
        walkspeedSlider:Set(defaultWalkspeed)
        gravitySlider:Set(defaultGravity)
        
        Rayfield:Notify({Title = "Reset", Content = "Stats direset ke default.", Duration = 2, Image = 7733964719})
    end,
})

-- B. MOVEMENT MODES (Fly & Platform & InfJump)
PlayerTab:CreateSection("Movement Modes")

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(value)
      toggleInfiniteJump(value)
   end,
})

FlyToggleUI = PlayerTab:CreateToggle({
   Name = "Fly (Press V)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(value)
      if value then
         -- SINKRONISASI: Matikan Platform jika Fly Nyala
         if platformEnabled and PlatformToggleUI then PlatformToggleUI:Set(false) end
         startFlyLogic()
         Rayfield:Notify({Title = "Fly", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
      else
         stopFlyLogic()
         Rayfield:Notify({Title = "Fly", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
      end
   end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 50,
    Callback = function(val) flySpeed = val end,
})

PlatformToggleUI = PlayerTab:CreateToggle({
   Name = "Spawn Platform",
   CurrentValue = false,
   Flag = "SpawnPlatformToggle",
   Callback = function(value)
      if value then
         -- SINKRONISASI: Matikan Fly jika Platform Nyala
         if flyEnabled and FlyToggleUI then FlyToggleUI:Set(false) end
         startPlatformLogic()
         Rayfield:Notify({Title = "Platform", Content = "Diaktifkan! (E=Naik, Q=Turun)", Duration = 2, Image = 7733964719})
      else
         stopPlatformLogic()
         Rayfield:Notify({Title = "Platform", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Platform Speed (Naik/Turun)",
   Range = {10, 150},
   Increment = 1,
   Suffix = "speed",
   CurrentValue = 25,
   Callback = function(val) platformSpeed = val end,
})

-- C. CHARACTER & UTILITY
PlayerTab:CreateSection("Character & Visuals")

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(value) toggleNoclip(value) end,
})

PlayerTab:CreateToggle({
   Name = "God Mode",
   CurrentValue = false,
   Flag = "GodModeToggle",
   Callback = function(value) toggleGodMode(value) end,
})

PlayerTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(value)
    if value then 
        startESP() 
        Rayfield:Notify({Title = "Player ESP", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
    else 
        stopESP()
        Rayfield:Notify({Title = "Player ESP", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
    end
   end,
})

PlayerTab:CreateButton({
   Name = "Reset Character",
   Callback = function()
      if player.Character and player.Character:FindFirstChild("Humanoid") then
         player.Character.Humanoid.Health = 0
      end
   end,
})

-- Freecam Section
PlayerTab:CreateSection("Freecam")

FreecamToggle = PlayerTab:CreateToggle({
   Name = "FreeCam (Shift + P)",
   CurrentValue = false,
   Flag = "FreecamToggle",
   Callback = function(value) toggleFreecam(value) end,
})

-- Keybind Freecam (Integrasi UI)
TrackConn(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.P and 
      (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
       UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) then
       local newState = not freecamEnabled
       toggleFreecam(newState)
       if FreecamToggle then FreecamToggle:Set(newState) end
    end
end))

-- ===================================================================
-- [[ TAB 3: TELEPORT ]]
-- ===================================================================

local TeleportTab = Window:CreateTab("Teleport", 4370318685)

    TeleportTab:CreateSection("Informasi")
    TeleportTab:CreateParagraph({Title = "Fitur Teleport", Content = "untuk fitur Click to teleport, kamu tinggal Tahan Ctrl + Klik kiri."})

    TeleportTab:CreateSection("World Teleport")

TeleportTab:CreateToggle({
   Name = "Click to Teleport",
   CurrentValue = false,
   Flag = "ClickTeleportToggle",
   Callback = function(value)
      toggleClickTeleport(value)
   end,
})

TeleportTab:CreateSection("Teleport to Player")

local selectedTeleportPlayer = nil
local TeleportPlayerDropdown

-- Search Bar
TeleportTab:CreateInput({
    Name = "Search Player",
    PlaceholderText = "Ketik nama pemain...",
    Flag = "TeleportSearch",
    Callback = function(searchText)
        local filteredList = {}
        local searchTextLower = string.lower(searchText)
        -- Mencari berdasarkan string yang sudah diformat (Display + Username)
        for _, formattedName in ipairs(getPlayerList()) do
            if string.find(string.lower(formattedName), searchTextLower) then
                table.insert(filteredList, formattedName)
            end
        end
        TeleportPlayerDropdown:Refresh(filteredList, true)
    end,
})

TeleportPlayerDropdown = TeleportTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(), -- Ini sekarang sudah terisi karena updatePlayerCache() dipanggil di awal
   CurrentOption = {"None"},
   MultipleOptions = false,
   Flag = "TeleportPlayerDropdown",
   Callback = function(option)
      -- EKSTRAK USERNAME DARI FORMAT "Display (@Username)"
      local realUsername = getUsernameFromString(option[1])
      
      selectedTeleportPlayer = Players:FindFirstChild(realUsername)
      if selectedTeleportPlayer then
         Rayfield:Notify({Title = "Pemain Terpilih", Content = "Target: " .. selectedTeleportPlayer.DisplayName, Duration = 2, Image = 7733964719})
         
         -- Update spectate jika aktif
         if isSpectating then
             Rayfield:Notify({Title = "Spectate", Content = "Beralih ke " .. selectedTeleportPlayer.DisplayName, Duration = 3, Image = 7733964719})
         end
      end
   end,
})
table.insert(allPlayerDropdowns, TeleportPlayerDropdown)

TeleportTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
      refreshAllPlayerDropdowns() 
      Rayfield:Notify({Title = "Refresh List", Content = "List diperbarui!", Duration = 2, Image = 7733964719})
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Selected Player",
   Callback = function()
      if selectedTeleportPlayer and selectedTeleportPlayer.Character and selectedTeleportPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local targetPos = selectedTeleportPlayer.Character.HumanoidRootPart.CFrame
         teleportCharacter(player.Character, targetPos.Position + Vector3.new(0, 3, 0))
         Rayfield:Notify({Title = "Teleport", Content = "Teleport ke " .. selectedTeleportPlayer.DisplayName, Duration = 3, Image = 7733964719})
      else
         Rayfield:Notify({Title = "Error", Content = "Silakan pilih pemain yang valid", Duration = 3, Image = 7733964719})
      end
   end,
})

local isSpectating = false
local spectateConnection = nil
local SpectateToggle 

SpectateToggle = TeleportTab:CreateToggle({
   Name = "Spectate Selected Player",
   CurrentValue = false,
   Flag = "SpectateToggle",
   Callback = function(value)
      isSpectating = value
      local camera = workspace.CurrentCamera
      
      if value then
         if not selectedTeleportPlayer then
            Rayfield:Notify({Title = "Error", Content = "Pilih pemain dulu!", Duration = 3, Image = 7733964719})
            isSpectating = false
            if SpectateToggle then SpectateToggle:Set(false) end 
            return
         end

         if spectateConnection then spectateConnection:Disconnect() end
         
         Rayfield:Notify({Title = "Spectate", Content = "Spectating " .. selectedTeleportPlayer.DisplayName, Duration = 3, Image = 7733964719})
         
         spectateConnection = TrackConn(RunService.Heartbeat:Connect(function()
            if isSpectating and selectedTeleportPlayer and selectedTeleportPlayer.Character and selectedTeleportPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = selectedTeleportPlayer.Character.Humanoid
                if camera.CameraSubject ~= humanoid then
                    camera.CameraSubject = humanoid
                    camera.CameraType = Enum.CameraType.Track
                end
            elseif isSpectating and not selectedTeleportPlayer then
                SpectateToggle:Set(false) 
            end
         end))
      else
         if spectateConnection then spectateConnection:Disconnect(); spectateConnection = nil end
         if player.Character and player.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = player.Character.Humanoid
         end
         camera.CameraType = Enum.CameraType.Custom
         Rayfield:Notify({Title = "Spectate", Content = "Berhenti spectating", Duration = 3, Image = 7733964719})
      end
   end,
})

-- ===================================================================
-- [[ TAB 4: TROLLING ]]
-- ===================================================================

local TrollingTab = Window:CreateTab("Trolling", 4370318685)

    TrollingTab:CreateSection("Informasi")
    TrollingTab:CreateParagraph({Title = "Fitur Trolling", Content = "Hanya berfungsi di server dengan collision aktif."})

TrollingTab:CreateSection("Kontrol Trolling")

local selectedTrollingPlayer = nil
local TrollingPlayerDropdown

TrollingTab:CreateInput({
    Name = "Search Player",
    PlaceholderText = "Ketik nama pemain...",
    Flag = "TrollingSearch",
    Callback = function(searchText)
        local filteredList = {}
        local searchTextLower = string.lower(searchText)
        for _, formattedName in ipairs(getPlayerList()) do
            if string.find(string.lower(formattedName), searchTextLower) then
                table.insert(filteredList, formattedName)
            end
        end
        TrollingPlayerDropdown:Refresh(filteredList, true)
    end,
})

TrollingPlayerDropdown = TrollingTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(),
   CurrentOption = {"None"},
   MultipleOptions = false,
   Flag = "TrollingPlayerDropdown",
   Callback = function(option)
      -- EKSTRAK USERNAME
      local realUsername = getUsernameFromString(option[1])
      selectedTrollingPlayer = Players:FindFirstChild(realUsername)
      
      if selectedTrollingPlayer then
         Rayfield:Notify({Title = "Pemain Terpilih", Content = "Target: " .. selectedTrollingPlayer.DisplayName, Duration = 2, Image = 7733964719})
      end
   end,
})
table.insert(allPlayerDropdowns, TrollingPlayerDropdown)

TrollingTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
      refreshAllPlayerDropdowns()
      Rayfield:Notify({Title = "Refresh List", Content = "List diperbarui!", Duration = 2, Image = 7733964719})
   end,
})

local flingDebounce = false

TrollingTab:CreateButton({
   Name = "Fling Selected Player",
   Callback = function()
      if flingDebounce then return end
      if not selectedTrollingPlayer or not selectedTrollingPlayer.Character then
         Rayfield:Notify({Title = "Error", Content = "Pilih pemain valid!", Duration = 3, Image = 7733964719})
         return
      end
      
      flingDebounce = true
      Rayfield:Notify({Title = "Fling", Content = "Melempar " .. selectedTrollingPlayer.DisplayName, Duration = 3, Image = 7733964719})
      
      task.spawn(function()
         pcall(function() SkidFling(selectedTrollingPlayer) end)
         task.wait(1)
         flingDebounce = false
      end)
   end,
})

-- ===================================================================
-- [[ TAB 5: ANIMATION ]]
-- ===================================================================

-- 1. Konfigurasi Blacklist
local FishIt_ID = 121864768012064 -- Masukkan ID Fish It di sini

if isR15 and (Animations ~= nil) and (game.PlaceId ~= FishIt_ID) then
local AnimationTab = Window:CreateTab("Animation", 4370318685)

    AnimationTab:CreateSection("Informasi")
    AnimationTab:CreateParagraph({Title = "Fitur Paket Animasi", Content = "Sistem paket animasi khusus karakter R15. Animasi akan otomatis diterapkan saat memilih list dari dropdown."})
    
    local function getAnimationNames(animType)
        local names = {}
        if Animations and Animations[animType] then 
            for name, _ in pairs(Animations[animType]) do
                table.insert(names, name)
            end
        end
        table.sort(names)
        return names
    end

    local animationTypes = {"Idle", "Walk", "Run", "Jump", "Fall", "Swim", "SwimIdle", "Climb"}
    local dropdowns = {} 

    AnimationTab:CreateInput({
        Name = "Search Animation",
        PlaceholderText = "Cari nama animasi...",
        Flag = "AnimSearch",
        Callback = function(searchText)
            local searchTextLower = string.lower(searchText)
            for _, animType in ipairs(animationTypes) do
                local dropdown = dropdowns[animType]
                if dropdown then
                    local fullAnimNames = getAnimationNames(animType)
                    if searchText == "" then
                        dropdown:Refresh(fullAnimNames, true)
                    else
                        local filteredNames = {}
                        for _, name in ipairs(fullAnimNames) do
                            if string.find(string.lower(name), searchTextLower) then
                                table.insert(filteredNames, name)
                            end
                        end
                        dropdown:Refresh(filteredNames, true)
                    end
                end
            end
        end,
    })

    for _, animType in ipairs(animationTypes) do
        local animNames = getAnimationNames(animType)
        dropdowns[animType] = AnimationTab:CreateDropdown({
            Name = animType,
            Options = animNames,
            CurrentOption = {"None"},
            MultipleOptions = false,
            Flag = "AnimDropdown_" .. animType,
            Callback = function(selectedName)
                if not selectedName[1] or selectedName[1] == "None" then return end
                if Animations and Animations[animType] and setAnimation then
                    local animId = Animations[animType][selectedName[1]]
                    if animId then
                        task.spawn(function()
                            setAnimation(animType, animId) 
                            Rayfield:Notify({ Title = "Animasi", Content = "Terpasang: " .. selectedName[1], Duration = 2, Image = 7733964719 })
                        end)
                    end
                end
            end,
        })
    end

    AnimationTab:CreateButton({
        Name = "Reset to Default (Respawn)",
        Callback = function()
            -- 1. HAPUS MEMORI SECARA PAKSA (Looping clear)
            -- Karena 'lastAnimations' sekarang GLOBAL, tombol ini PASTI menghapus data yang benar.
            if lastAnimations then
                for k in pairs(lastAnimations) do
                    lastAnimations[k] = nil
                end
            end

            -- 2. HAPUS FILE SIMPANAN
            pcall(function()
                local HttpService = game:GetService("HttpService")
                writefile("AsuHubAnimasiPack.json", HttpService:JSONEncode({}))
            end)

            -- 3. RESPAWN PAKSA
            local char = game:GetService("Players").LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
            end
            
            Rayfield:Notify({ Title = "Reset Sukses", Content = "Memori dibersihkan. Kembali ke animasi asli...", Duration = 3, Image = 7733964719 })
        end
    })
    
    -- Load simpanan saat script jalan pertama kali
    task.wait(1)
    if loadLastAnimations then loadLastAnimations() end
else
    -- Opsional:
    -- Rayfield:Notify({Title = "Info", Content = "Menu Animasi disembunyikan karena berada di Game Fish It!", Duration = 3, Image = 7733964719})
end

-- ===================================================================
-- [[ TAB 6: CUSTOM EMOTE ]]
-- ===================================================================

-- 1. Konfigurasi Blacklist
local FishIt_ID = 121864768012064 -- Masukkan ID Fish It di sini

if isR15 and (Animations ~= nil) and (game.PlaceId ~= FishIt_ID) then
    local EmoteTab = Window:CreateTab("Emote", 4370318685)

    EmoteTab:CreateSection("Informasi")

    EmoteTab:CreateParagraph({Title = "Fitur Emote", Content = "dapat menggunakan seluruh Emote/Dance yang ada di Marketplace Roblox | dengan command (.)"})

    EmoteTab:CreateButton({
    Name = "Load Custom Emote Menu",
    Callback = function()
        local scriptContent
        local downloadSuccess, downloadResult = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/ozaghazali/YoguruttoHub/refs/heads/main/LoadEmote.lua")
        
        if not downloadSuccess then
            Rayfield:Notify({Title = "Error", Content = "Gagal mengunduh skrip: " .. (downloadResult or "Kesalahan tidak diketahui"), Duration = 5, Image = 7733964719})
            return
        end
        scriptContent = downloadResult
        
        local compiledFunc, compileError = (getgenv().loadstring or loadstring)(scriptContent)
        
        if not compiledFunc then
            Rayfield:Notify({Title = "Error", Content = "Gagal mengkompilasi skrip: " .. (compileError or "Kesalahan tidak diketahui"), Duration = 5, Image = 7733964719})
            return
        end
        
        -- Notifikasi sebelum eksekusi
        Rayfield:Notify({Title = "Emote", Content = "Menu emote telah dimuat!", Duration = 3, Image = 7733964719})
        
        local execSuccess, execError = pcall(compiledFunc)
        if not execSuccess then
            warn("Kesalahan Eksekusi Emote AsuHub (tapi menu mungkin dimuat):", execError)
        end
    end,
    })

else
    -- Opsional:
    -- Rayfield:Notify({Title = "Info", Content = "Menu Animasi disembunyikan karena berada di Game Fish It!", Duration = 3, Image = 7733964719})
end

-- ===================================================================
-- [[ TAB 7: COPY AVATAR ]]
-- ===================================================================

-- 1. Konfigurasi Blacklist
local FishIt_ID = 121864768012064 -- Masukkan ID Fish It di sini

if isR15 and (Animations ~= nil) and (game.PlaceId ~= FishIt_ID) then
    local MorphingTab = Window:CreateTab("Copy Avatar", 4370318685)

    MorphingTab:CreateSection("Informasi")
    MorphingTab:CreateParagraph({Title = "Fitur Copy Avatar", Content = "Hanya berfungsi pada server dengan Plugin Popmall/Catalog."})

    MorphingTab:CreateSection("Kontrol Avatar Copy")

    local selectedMorphPlayer = nil
    local MorphPlayerDropdown

    MorphingTab:CreateInput({
        Name = "Search Player",
        PlaceholderText = "Ketik nama pemain...",
        Flag = "MorphSearch",
        Callback = function(searchText)
            local filteredList = {}
            local searchTextLower = string.lower(searchText)
            for _, formattedName in ipairs(getPlayerList()) do
                if string.find(string.lower(formattedName), searchTextLower) then
                    table.insert(filteredList, formattedName)
                end
            end
            MorphPlayerDropdown:Refresh(filteredList, true)
        end,
    })

    MorphPlayerDropdown = MorphingTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerList(),
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "MorphPlayerDropdown",
    Callback = function(option)
        -- EKSTRAK USERNAME
        local realUsername = getUsernameFromString(option[1])
        selectedMorphPlayer = Players:FindFirstChild(realUsername)
        
        if selectedMorphPlayer then
            Rayfield:Notify({Title = "Pemain Terpilih", Content = "Target: " .. selectedMorphPlayer.DisplayName, Duration = 2, Image = 7733964719})
        end
    end,
    })
    table.insert(allPlayerDropdowns, MorphPlayerDropdown)

    MorphingTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        refreshAllPlayerDropdowns()
        Rayfield:Notify({Title = "Refresh List", Content = "List diperbarui!", Duration = 2, Image = 7733964719})
    end,
    })

    MorphingTab:CreateButton({
    Name = "Copy Current Avatar",
    Callback = function()
        if not selectedMorphPlayer or not selectedMorphPlayer.Character then
            Rayfield:Notify({Title = "Error", Content = "Pilih pemain dulu!", Duration = 5, Image = 7733964719})
            return
        end

        local targetCharacter = selectedMorphPlayer.Character
        local targetName = selectedMorphPlayer.Name -- Gunakan nama asli untuk logic internal
        
        task.spawn(function()
            Rayfield:Notify({Title = "Copy Avatar", Content = "Menyalin dari " .. selectedMorphPlayer.DisplayName .. "...", Duration = 3, Image = 7733964719})
            
            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            if not targetHumanoid then
                Rayfield:Notify({Title = "Error", Content = "Target tidak memiliki Humanoid!", Duration = 5, Image = 7733964719})
                return
            end

            local targetHumanoidDesc
            local success, result = pcall(function()
                return targetHumanoid:GetAppliedDescription()
            end)
            
            if not success or not result then
                Rayfield:Notify({Title = "Error", Content = "Gagal mendapatkan HumanoidDescription!", Duration = 5, Image = 7733964719})
                return
            end
            
            targetHumanoidDesc = result

            local outfitTable
            local tableSuccess, tableResult = pcall(function()
                local newTable = {}
                
                local accessoriesSuccess, accessories = pcall(function()
                return targetHumanoidDesc:GetAccessories(true)
                end)
                
                if accessoriesSuccess then
                newTable.Accessories = accessories
                else
                newTable.Accessories = {}
                end
                
                newTable.BodyTypeScale = targetHumanoidDesc.BodyTypeScale
                newTable.HeadScale = targetHumanoidDesc.HeadScale
                newTable.DepthScale = targetHumanoidDesc.DepthScale
                newTable.HeightScale = targetHumanoidDesc.HeightScale
                newTable.WidthScale = targetHumanoidDesc.WidthScale
                newTable.ProportionScale = targetHumanoidDesc.ProportionScale
                
                newTable.Head = targetHumanoidDesc.Head
                newTable.LeftArm = targetHumanoidDesc.LeftArm
                newTable.LeftLeg = targetHumanoidDesc.LeftLeg
                newTable.RightArm = targetHumanoidDesc.RightArm
                newTable.RightLeg = targetHumanoidDesc.RightLeg
                newTable.Torso = targetHumanoidDesc.Torso
                
                newTable.GraphicTShirt = targetHumanoidDesc.GraphicTShirt
                newTable.Pants = targetHumanoidDesc.Pants
                newTable.Shirt = targetHumanoidDesc.Shirt
                
                newTable.HeadColor = targetHumanoidDesc.HeadColor
                newTable.LeftArmColor = targetHumanoidDesc.LeftArmColor
                newTable.LeftLegColor = targetHumanoidDesc.LeftLegColor
                newTable.RightArmColor = targetHumanoidDesc.RightArmColor
                newTable.RightLegColor = targetHumanoidDesc.RightLegColor
                newTable.TorsoColor = targetHumanoidDesc.TorsoColor
                
                newTable.Face = targetHumanoidDesc.Face
                
                local function safeGet(propName)
                if targetHumanoidDesc[propName] then
                    return targetHumanoidDesc[propName]
                else
                    return nil
                end
                end
                
                newTable.ClimbAnimation = safeGet("ClimbAnimation")
                newTable.FallAnimation = safeGet("FallAnimation")
                newTable.IdleAnimation = safeGet("IdleAnimation")
                newTable.JumpAnimation = safeGet("JumpAnimation")
                newTable.RunAnimation = safeGet("RunAnimation")
                newTable.SwimAnimation = safeGet("SwimAnimation")
                newTable.WalkAnimation = safeGet("WalkAnimation")
                
                return newTable
            end)

            if not tableSuccess then
                Rayfield:Notify({Title = "Error", Content = "Gagal membuat tabel pakaian!", Duration = 5, Image = 7733964719})
                return
            end
            outfitTable = tableResult

            local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("BloxbizRemotes")
            local applyOutfitRemote = remoteFolder and remoteFolder:FindFirstChild("CatalogOnApplyOutfit")

            if applyOutfitRemote then
                local fireSuccess, fireResult = pcall(function()
                applyOutfitRemote:FireServer(outfitTable)
                end)
                
                if fireSuccess then
                Rayfield:Notify({Title = "Success", Content = "Avatar disalin dari " .. targetName .. "!", Duration = 5, Image = 7733964719})
                
                task.wait(0.5)
                local localHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if localHumanoid then
                    localHumanoid.AutomaticScalingEnabled = false
                    task.wait(0.1)
                    localHumanoid.AutomaticScalingEnabled = true
                end
                else
                Rayfield:Notify({Title = "Error", Content = "Gagal mengirim data!", Duration = 5, Image = 7733964719})
                end
            else
                Rayfield:Notify({Title = "Error", Content = "Tidak dapat menemukan Plugin Popmall!", Duration = 5, Image = 7733964719})
            end
        end)
    end,
    })

    MorphingTab:CreateButton({
    Name = "Copy Original Avatar",
    Callback = function()
        if not selectedMorphPlayer or not selectedMorphPlayer.Character then
            Rayfield:Notify({Title = "Error", Content = "Pilih pemain yang valid dari menu dropdown!", Duration = 5, Image = 7733964719})
            return
        end

        local targetUserId = selectedMorphPlayer.UserId
        local targetName = selectedMorphPlayer.Name
        
        task.spawn(function()
            Rayfield:Notify({Title = "Copy Avatar", Content = "Mengambil data untuk " .. targetName .. "...", Duration = 3, Image = 7733964719})
            
            local PlayersService = game:GetService("Players")
            local targetHumanoidDesc
            local success, result = pcall(function()
                targetHumanoidDesc = PlayersService:GetHumanoidDescriptionFromUserId(targetUserId)
            end)
            
            if not success or not targetHumanoidDesc then
                Rayfield:Notify({Title = "Error", Content = "Gagal mendapatkan HumanoidDescription!", Duration = 5, Image = 7733964719})
                return
            end

            local outfitTable
            local tableSuccess, tableResult = pcall(function()
                local newTable = {}
                
                local accSuccess, accResult = pcall(function() return targetHumanoidDesc:GetAccessories(true) end)
                if accSuccess then
                newTable.Accessories = accResult
                else
                newTable.Accessories = {}
                end
                
                newTable.BodyTypeScale = targetHumanoidDesc.BodyTypeScale
                newTable.HeadScale = targetHumanoidDesc.HeadScale
                newTable.DepthScale = targetHumanoidDesc.DepthScale
                newTable.HeightScale = targetHumanoidDesc.HeightScale
                newTable.WidthScale = targetHumanoidDesc.WidthScale
                newTable.ProportionScale = targetHumanoidDesc.ProportionScale
                
                newTable.Head = targetHumanoidDesc.Head
                newTable.LeftArm = targetHumanoidDesc.LeftArm
                newTable.LeftLeg = targetHumanoidDesc.LeftLeg
                newTable.RightArm = targetHumanoidDesc.RightArm
                newTable.RightLeg = targetHumanoidDesc.RightLeg
                newTable.Torso = targetHumanoidDesc.Torso
                
                newTable.GraphicTShirt = targetHumanoidDesc.GraphicTShirt
                newTable.Pants = targetHumanoidDesc.Pants
                newTable.Shirt = targetHumanoidDesc.Shirt
                
                newTable.HeadColor = targetHumanoidDesc.HeadColor
                newTable.LeftArmColor = targetHumanoidDesc.LeftArmColor
                newTable.LeftLegColor = targetHumanoidDesc.LeftLegColor
                newTable.RightArmColor = targetHumanoidDesc.RightArmColor
                newTable.RightLegColor = targetHumanoidDesc.RightLegColor
                newTable.TorsoColor = targetHumanoidDesc.TorsoColor
                
                newTable.Face = targetHumanoidDesc.Face
                
                local function safeGet(propName)
                if targetHumanoidDesc[propName] then
                    return targetHumanoidDesc[propName]
                else
                    return nil
                end
                end
                
                newTable.ClimbAnimation = safeGet("ClimbAnimation")
                newTable.FallAnimation = safeGet("FallAnimation")
                newTable.IdleAnimation = safeGet("IdleAnimation")
                newTable.JumpAnimation = safeGet("JumpAnimation")
                newTable.RunAnimation = safeGet("RunAnimation")
                newTable.SwimAnimation = safeGet("SwimAnimation")
                newTable.WalkAnimation = safeGet("WalkAnimation")
                
                return newTable
            end)

            if not tableSuccess then
                Rayfield:Notify({Title = "Error", Content = "Gagal membuat tabel pakaian!", Duration = 5, Image = 7733964719})
                return
            end
            outfitTable = tableResult

            local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("BloxbizRemotes")
            local applyOutfitRemote = remoteFolder and remoteFolder:FindFirstChild("CatalogOnApplyOutfit")

            if applyOutfitRemote then
                applyOutfitRemote:FireServer(outfitTable)
                Rayfield:Notify({Title = "Success", Content = "Avatar asli disalin dari " .. targetName .. "!", Duration = 5, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Error", Content = "Tidak dapat menemukan Plugin Popmall!", Duration = 5, Image = 7733964719})
            end
        end)
    end,
    })

    -- Variabel untuk melacak state
    local copyAvatarConnection = nil
    local baseHumanoidDescCache = nil
    local resetOutfitRemote = nil

    -- Cari RemoteEvent untuk reset
    local function findResetOutfitRemote()
        if resetOutfitRemote then return resetOutfitRemote end
        
        -- Cari di berbagai lokasi umum
        local locations = {
            game:GetService("ReplicatedStorage"),
            game:GetService("Players").LocalPlayer,
            workspace
        }
        
        for _, location in ipairs(locations) do
            local remoteFolder = location:FindFirstChild("BloxbizRemotes")
            if remoteFolder then
                local remote = remoteFolder:FindFirstChild("CatalogOnResetOutfit") or 
                            remoteFolder:FindFirstChild("ResetOutfit") or
                            remoteFolder:FindFirstChild("ResetAvatar")
                if remote then
                    resetOutfitRemote = remote
                    return remote
                end
            end
        end
        return nil
    end

    -- Simpan base humanoid description asli
    local function cacheBaseHumanoidDescription()
        if baseHumanoidDescCache then return baseHumanoidDescCache end
        
        local character = player.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            baseHumanoidDescCache = character:FindFirstChildOfClass("Humanoid"):GetAppliedDescription()
            return baseHumanoidDescCache
        end
        return nil
    end

    MorphingTab:CreateButton({
    Name = "Reset to Default Avatar",
    Callback = function()
            task.spawn(function()
                Rayfield:Notify({Title = "Reset", Content = "Mereset avatar ke default...", Duration = 3, Image = 7733964719})

                -- 1. Hentikan koneksi copy avatar jika ada
                if copyAvatarConnection then
                    copyAvatarConnection:Disconnect()
                    copyAvatarConnection = nil
                end
                
                -- 2. Hapus cache base humanoid description
                baseHumanoidDescCache = nil
                
                -- 3. Coba gunakan RemoteEvent reset outfit jika ada
                local resetRemote = findResetOutfitRemote()
                if resetRemote then
                    local success, result = pcall(function()
                        resetRemote:FireServer()
                        return true
                    end)
                    
                    if success then
                        Rayfield:Notify({ Title = "Success", Content = "Avatar berhasil direset!", Duration = 3, Image = 7733964719})
                        return
                    else
                        Rayfield:Notify({ Title = "Error", Content = "Reset remote gagal: " .. tostring(result) })
                    end
                end
                
                -- 4. Fallback: Gunakan metode manual reset
                Rayfield:Notify({ Title = "Reset", Content = "Menggunakan metode manual reset...", Duration = 3, Image = 7733964719})
                
                -- Buat humanoid description kosong
                local emptyDescription = Instance.new("HumanoidDescription")
                
                -- Terapkan melalui sistem game yang sama seperti copy
                local applyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BloxbizRemotes")
                if applyRemote then
                    applyRemote = applyRemote:FindFirstChild("CatalogOnApplyOutfit")
                end
                
                if applyRemote then
                    local success, result = pcall(function()
                        -- Buat tabel outfit kosong
                        local emptyOutfit = {
                            Accessories = {},
                            HeadScale = 1,
                            DepthScale = 1,
                            HeightScale = 1,
                            WidthScale = 1,
                            ProportionScale = 1,
                            BodyTypeScale = 1,
                            Head = 0,
                            LeftArm = 0,
                            LeftLeg = 0,
                            RightArm = 0,
                            RightLeg = 0,
                            Torso = 0,
                            GraphicTShirt = 0,
                            Pants = 0,
                            Shirt = 0,
                            HeadColor = Color3.new(1, 1, 1),
                            LeftArmColor = Color3.new(1, 1, 1),
                            LeftLegColor = Color3.new(1, 1, 1),
                            RightArmColor = Color3.new(1, 1, 1),
                            RightLegColor = Color3.new(1, 1, 1),
                            TorsoColor = Color3.new(1, 1, 1),
                            Face = 0
                        }
                        
                        applyRemote:FireServer(emptyOutfit)
                        return true
                    end)
                    
                    if success then
                        Rayfield:Notify({ Title = "Success", Content = "Avatar direset menggunakan outfit kosong!", Duration = 3, Image = 7733964719})
                    else
                        Rayfield:Notify({ Title = "Error", Content = "Gagal apply outfit kosong: " .. tostring(result) })
                    end
                else
                    Rayfield:Notify({ Title = "Error", Content = "Tidak ditemukan sistem apply outfit", Duration = 3, Image = 7733964719})
                end
            end)
        end
    })

else
    -- Opsional:
    -- Rayfield:Notify({Title = "Info", Content = "Menu Animasi disembunyikan karena berada di Game Fish It!", Duration = 3, Image = 7733964719})
end

-- ===================================================================
-- [[ TAB 8: Palma RP ]]
-- ===================================================================

local PalmaRP_PlaceID = 93448637916605 

local isInPalmaRP = false

if game.PlaceId == PalmaRP_PlaceID then
    isInPalmaRP = true
elseif game:GetService("ReplicatedStorage"):FindFirstChild("JualIkanRemote") then
    isInPalmaRP = true
end

if isInPalmaRP then
    local PalmaRPTab = Window:CreateTab("Palma RP", 4370318685)

    PalmaRPTab:CreateSection("Info")
    PalmaRPTab:CreateParagraph({Title = "Fitur Palma RP", Content = "Jika ingin menggunakan fitur Auto Farm ikuti langkah berikut:\n1. Ditahap awal kamu harus memancing seperti biasa terlebih dahulu sampai mendapatkan ikan\n2. Lalu setelah itu kamu bisa aktifkan auto farm."})

    PalmaRPTab:CreateSection("Kontrol Farm")

-- Anti AFK Logic
    local antiAFKEnabled = false
    local antiAFKConnection
    
    PalmaRPTab:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = false,
        Flag = "PalmaRPAntiAFK",
        Callback = function(val)
            antiAFKEnabled = val
            if val then
                if antiAFKConnection then antiAFKConnection:Disconnect() end
                
                -- Service VirtualUser dipanggil DI SINI, bukan di awal script
                -- Gunakan pcall agar jika game memblokir akses, script tidak error total
                antiAFKConnection = TrackConn(player.Idled:Connect(function()
                    local vuSuccess, VirtualUser = pcall(function() return game:GetService("VirtualUser") end)
                    if vuSuccess and VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    else
                        -- Fallback jika VirtualUser benar-benar diblokir total
                        local vim = game:GetService("VirtualInputManager")
                        if vim then
                            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait()
                            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                    end
                end))
                Rayfield:Notify({Title = "Anti AFK", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
            else
                if antiAFKConnection then 
                    antiAFKConnection:Disconnect() 
                    antiAFKConnection = nil
                end
                Rayfield:Notify({Title = "Anti AFK", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end
    })

    -- Logic Auto Farm & Fish
    local bulkFishEnabled = false
    
    PalmaRPTab:CreateToggle({
        Name = "Auto Farm Fish & TP",
        CurrentValue = false,
        Flag = "PalmaRPFarm",
        Callback = function(val)
            bulkFishEnabled = val
            
            if val then
                -- Teleport logic awal
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(10979.3564453125, 356.204345703125, 2611.142822265625)
                end
                
                task.wait(1) -- Jeda sebentar
                
                -- Loop Farming
                task.spawn(function()
                    while bulkFishEnabled do
                        if SessionStop then break end -- <--- TEMPEL DI SINI
                        pcall(function()
                            local char = player.Character
                            local rod = char and char:FindFirstChild("StarRod")
                            
                            if rod then
                                -- Spam complete 50x
                                for i = 1, 50 do
                                    rod.MiniGame:FireServer("Complete")
                                end
                            else
                                -- Auto Equip jika belum pegang
                                if player.Backpack:FindFirstChild("StarRod") then
                                    player.Character.Humanoid:EquipTool(player.Backpack.StarRod)
                                end
                            end
                        end)
                        task.wait(0.2)
                    end
                end)
                Rayfield:Notify({Title = "Auto Farm", Content = "Diaktifkan!", Duration = 3, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Farm", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end
    })

    -- Logic Auto Sell
    local autoSellEnabled = false
    local autoSellInterval = 1 -- Default 1 detik

    PalmaRPTab:CreateInput({
        Name = "Auto Sell Interval (Detik)",
        PlaceholderText = "Default: 1",
        NumbersOnly = true, 
        OnEnter = true, 
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                autoSellInterval = num
            else
                autoSellInterval = 1
            end
        end
    })
    
    PalmaRPTab:CreateToggle({
        Name = "Auto Sell",
        CurrentValue = false,
        Flag = "PalmaRPSell",
        Callback = function(val)
            autoSellEnabled = val
            if val then
                task.spawn(function()
                    while autoSellEnabled do
                        if SessionStop then break end
                        pcall(function()
                            local remote = ReplicatedStorage:FindFirstChild("JualIkanRemote")
                            if remote then 
                                remote:FireServer("All") 
                            end
                        end)
                        task.wait(autoSellInterval)
                    end
                end)
                Rayfield:Notify({Title = "Auto Sell", Content = "Diaktifkan!", Duration = 3, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Sell", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end
    })

    PalmaRPTab:CreateButton({
        Name = "Teleport ke Toko",
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(6367.62890625, 118.17733001708984, 183.94854736328125)
                Rayfield:Notify({Title = "Teleport", Content = "Teleportasi ke Toko...", Duration = 2, Image = 7733964719})
            end
        end
    })

    PalmaRPTab:CreateSection("Farming Carton (Kardus)")
    
    local autoCartonEnabled = false
    PalmaRPTab:CreateToggle({
        Name = "Auto Farm Carton (Pickup & Unpack)",
        CurrentValue = false,
        Flag = "PalmaRPAutoCarton",
        Callback = function(val)
            autoCartonEnabled = val
            if val then
                task.spawn(function()
                    while autoCartonEnabled do
                        if SessionStop then break end -- <--- TEMPEL DI SINI
                        pcall(function()
                            -- Logic Pickup
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestPickup"):FireServer()
                            task.wait(0.1) -- Small delay between pickup and unpack
                            -- Logic Unpack
                            local args = {1, 2}
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestUnpack"):FireServer(unpack(args))
                        end)
                        task.wait(0.5) -- Delay loop so it doesn't crash
                    end
                end)
                Rayfield:Notify({Title = "Auto Carton", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Carton", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end
    })

    local autoSellCartonEnabled = false
    PalmaRPTab:CreateToggle({
        Name = "Auto Sell Carton",
        CurrentValue = false,
        Flag = "PalmaRPAutoSellCarton",
        Callback = function(val)
            autoSellCartonEnabled = val
            if val then
                task.spawn(function()
                    while autoSellCartonEnabled do
                        pcall(function()
                            local args = {"All"}
                            game:GetService("ReplicatedStorage"):WaitForChild("JualCartonRemote"):FireServer(unpack(args))
                        end)
                        task.wait(autoSellInterval) -- Reusing the interval variable from the Fish section
                    end
                end)
                Rayfield:Notify({Title = "Auto Sell Carton", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Sell Carton", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end
    })

    PalmaRPTab:CreateSection("Kebutuhan (Auto Needs)")

    -- 1. AUTO EAT SETUP
    local autoEatEnabled = false
    local autoEatInterval = 3 -- Default 3 detik agar aman

    PalmaRPTab:CreateInput({
        Name = "Auto Eat Interval (Detik)",
        PlaceholderText = "Default: 3",
        NumbersOnly = true, 
        OnEnter = true, 
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                autoEatInterval = num
            else
                autoEatInterval = 3 -- Fallback ke 3 jika input tidak valid
            end
        end
    })

    PalmaRPTab:CreateToggle({
        Name = "Auto Eat (Makan)",
        CurrentValue = false,
        Flag = "PalmaRPAutoEat",
        Callback = function(val)
            autoEatEnabled = val
            if val then
                task.spawn(function()
                    while autoEatEnabled do
                        pcall(function()
                            local args = { 100 }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("EatFoodEvent"):FireServer(unpack(args))
                        end)
                        task.wait(autoEatInterval) -- Menggunakan interval custom
                    end
                end)
                Rayfield:Notify({Title = "Auto Eat", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Eat", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- 2. AUTO DRINK SETUP
    local autoDrinkEnabled = false
    local autoDrinkInterval = 3 -- Default 3 detik agar aman

    PalmaRPTab:CreateInput({
        Name = "Auto Drink Interval (Detik)",
        PlaceholderText = "Default: 3",
        NumbersOnly = true, 
        OnEnter = true, 
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                autoDrinkInterval = num
            else
                autoDrinkInterval = 3 -- Fallback ke 3 jika input tidak valid
            end
        end
    })

    PalmaRPTab:CreateToggle({
        Name = "Auto Drink (Minum)",
        CurrentValue = false,
        Flag = "PalmaRPAutoDrink",
        Callback = function(val)
            autoDrinkEnabled = val
            if val then
                task.spawn(function()
                    while autoDrinkEnabled do
                        pcall(function()
                            local args = { 100 }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("DrinkEvent"):FireServer(unpack(args))
                        end)
                        task.wait(autoDrinkInterval) -- Menggunakan interval custom
                    end
                end)
                Rayfield:Notify({Title = "Auto Drink", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Drink", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })
else
    -- Optional: Notifikasi jika bukan di Palma RP (bisa dihapus jika mengganggu)
    -- Rayfield:Notify({Title = "Info", Content = "Menu Palma RP disembunyikan (Game berbeda).", Duration = 3, Image = 7733964719})
end

-- ===================================================================
-- [[ TAB 9: FISH IT ]]
-- ===================================================================

-- 1. DETEKSI GAME
local FishIt_PlaceID = 121864768012064 -- ID Utama Fish It
local isFishItGame = (game.PlaceId == FishIt_PlaceID)

-- Deteksi Cadangan (Cek Remote unik Fish It jika ID berubah/salah)
if not isFishItGame then
    local success = pcall(function()
        -- Mengecek keberadaan folder remote spesifik game Fish It
        if game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net:FindFirstChild("RF/PurchaseWeatherEvent") then
            isFishItGame = true
        end
    end)
end

-- 2. JIKA TERDETEKSI GAME FISH IT, BUAT TABNYA
if isFishItGame then
    local FishItTab = Window:CreateTab("Fish It", 4370318685)

    FishItTab:CreateSection("Info")
    FishItTab:CreateParagraph({Title = "Fitur Fish It", Content = "Fitur khusus game Fish It. Menu ini hanya muncul saat bermain Fish It."})

    -- ===========================
    -- SETUP VARIABLES
    -- ===========================
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Path Remote
    local WeatherRemotePath = "RF/PurchaseWeatherEvent"
    local RadarRemotePath = "RF/UpdateFishingRadar" 

    local FISHIT_LOCATIONS = {
        ["Spawn"] = CFrame.new(45.2788086, 252.562927, 2987.10913),
        ["Sisyphus Statue"] = CFrame.new(-3728.21606, -135.074417, -1012.12744),
        ["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295),
        ["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727),
        ["Crater Island"] = CFrame.new(1016.49072, 20.0919304, 5069.27295),
        ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
        ["Ancient Ruin"] = CFrame.new(6049.1982421875, -588.600830078125, 4609.9326171875),
        ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
        ["Mount Hallow"] = CFrame.new(2136.62305, 78.9163895, 3272.50439),
        ["Treasure Room"] = CFrame.new(-3606.34985, -266.57373, -1580.97339),
        ["Kohana"] = CFrame.new(-663.904236, 3.04580712, 718.796875),
        ["Underground Cellar"] = CFrame.new(2109.52148, -94.1875076, -708.609131),
        ["Ancient Jungle (Sacred Temple)"] = CFrame.new(1466.92151, -21.8750591, -622.835693),
        ["Ancient Jembatan (Luar)"] = CFrame.new(1481.94287109375, 7.417082786560059, -430.45977783203125),
        ["Ancient Danau (Luar)"] = CFrame.new(1473.3782958984375, 2.110987901687622, -319.2814025878906),
        ["Kohana Spot 2"] = CFrame.new(-652.989501953125, 17.250059127807617, 508.2733154296875),
        ["Kohana Spot 3"] = CFrame.new(-847.2335205078125, 18.750059127807617, 376.19744873046875),
        ["Kohana Spot 4"] = CFrame.new(-827.284912109375, 53.500057220458984, 203.64710998535156),
        ["Fisherman"] = CFrame.new(-33.96867370605469, 9.531570434570312, 2710.580322265625),
        ["Tropical Spot 2"] = CFrame.new(-2164.489501953125, 6.424246311187744, 3635.085205078125),
        ["Coral Spot 2"] = CFrame.new(-2920.3994140625, 3.249999761581421, 2074.140625),
        ["Ancient Ruin Spot 2"] = CFrame.new(6048.55615234375, -558.7210083007812, 4535.23876953125),
        ["(Event) Iron Cavern"] = CFrame.new(-8794.2119140625, -585.0000610351562, 92.13027954101562),
        ["(Event) Iron Cafe "] = CFrame.new(-8642.783203125, -547.5001831054688, 152.58291625976562),
        ["(Event) Iron Cafe Spot 2"] = CFrame.new(-8635.9794921875, -522.0001220703125, 151.6349639892578),
        ["(Event) Classic Island Portal"] = CFrame.new(1336.3935546875, 78.02549743652344, 2952.971435546875),
        ["(Event) Classic Island Spot 1"] = CFrame.new(1436.947509765625, 45.999996185302734, 2772.982666015625),
        ["Esoteric Depths Atas"] = CFrame.new(2009.5823974609375, 21.94994354248047, 1396.6719970703125)
    }

    -- ===========================
    -- HELPERS
    -- ===========================
    local function getAllLocationNames()
        local names = {}
        for name, _ in pairs(FISHIT_LOCATIONS) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end
    
    local function getRemote(name)
        local success, remote = pcall(function()
            return ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild(name)
        end)
        return success and remote or nil
    end

    local function getSellRemote()
        local success, remote = pcall(function()
            return ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RF/SellAllItems")
        end)
        return success and remote or nil
    end
    
    local function getWeatherRemote()
        local success, remote = pcall(function()
            return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net[WeatherRemotePath]
        end)
        return success and remote or nil
    end

    local function formatNumber(n)
        return tostring(n):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    end

    local function getRealName(displayString)
        return displayString:match("^(.-) %(") or displayString
    end

    -- ===========================
    -- UI: TELEPORT
    -- ===========================
    FishItTab:CreateSection("Teleport Locations")
    
    -- Helper untuk mengambil semua nama lokasi
    local function getAllLocationNames()
        local names = {}
        for name, _ in pairs(FISHIT_LOCATIONS) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end

    -- Variabel untuk menyimpan lokasi terakhir yang dipilih
    local TeleportDropdown
    local LastSelectedLocation = nil 

    -- 1. INPUT SEARCH
    FishItTab:CreateInput({
        Name = "Search lokasi",
        PlaceholderText = "Ketik nama lokasi...",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local filtered = {}
            local textLower = string.lower(text)
            for name, _ in pairs(FISHIT_LOCATIONS) do
                if string.find(string.lower(name), textLower) then
                    table.insert(filtered, name)
                end
            end
            table.sort(filtered)
            if TeleportDropdown then TeleportDropdown:Refresh(filtered, true) end
        end,
    })

    -- 2. DROPDOWN (Memilih Lokasi Baru)
    TeleportDropdown = FishItTab:CreateDropdown({
        Name = "Pilih Lokasi",
        Options = getAllLocationNames(),
        CurrentOption = {"None"},
        MultipleOptions = false,
        Flag = "FishItTeleportDropdown",
        Callback = function(option)
            local locName = option[1]
            if locName and FISHIT_LOCATIONS[locName] then
                -- Simpan lokasi ke variabel
                LastSelectedLocation = locName
                
                -- Langsung Teleport saat memilih
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = FISHIT_LOCATIONS[locName]
                    Rayfield:Notify({Title = "Teleport", Content = "Ke: " .. locName, Duration = 2, Image = 7733964719})
                end
            end
        end,
    })

    -- 3. TOMBOL RE-TELEPORT
    FishItTab:CreateButton({
        Name = "Teleport Back (Ke Lokasi Terpilih)",
        Callback = function()
            if LastSelectedLocation and FISHIT_LOCATIONS[LastSelectedLocation] then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = FISHIT_LOCATIONS[LastSelectedLocation]
                    Rayfield:Notify({Title = "Teleport Back", Content = "Kembali ke: " .. LastSelectedLocation, Duration = 1, Image = 7733964719})
                end
            else
                Rayfield:Notify({Title = "Error", Content = "Belum ada lokasi yang dipilih di Dropdown!", Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- ===========================
    -- UI: AUTOMATION
    -- ===========================
    FishItTab:CreateSection("Automation")

    local FastReelEnabled = false
    local ReelSpeed = 0.05
    local VirtualInputManager = game:GetService("VirtualInputManager")

    -- 1. NATIVE AUTO FISH (Auto Cast)
    FishItTab:CreateToggle({
        Name = "Auto Fishing",
        CurrentValue = false,
        Flag = "FishItNativeAutoFish",
        Callback = function(value)
            local success, remote = pcall(function()
                return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateAutoFishingState"]
            end)
            
            if success and remote then
                task.spawn(function() remote:InvokeServer(value) end)
                if value then
                    Rayfield:Notify({Title = "Auto Fish", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
                else
                    Rayfield:Notify({Title = "Auto Fish", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
                end
            end
        end,
    })

    -- 2. FAST REEL
    FishItTab:CreateToggle({
        Name = "Fast Reel",
        CurrentValue = false,
        Flag = "FishItFastReel",
        Callback = function(value)
            FastReelEnabled = value
            if value then
                task.spawn(function()
                    while FastReelEnabled do
                        if SessionStop then break end
                        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                        local fishingGui = pGui and pGui:FindFirstChild("Fishing")
                        
                        -- LOGIKA BARU: CEK POSISI LAYAR
                        if fishingGui and fishingGui.Enabled then
                            local mainFrame = fishingGui:FindFirstChild("Main")
                            
                            -- Cek apakah Main Frame ada di dalam layar?
                            -- Game menggeser ke Y=1.5 saat selesai (Offscreen)
                            -- Game menggeser ke Y=0.95 saat main (Onscreen)
                            if mainFrame and mainFrame.Position.Y.Scale < 1.2 then
                                
                                -- EKSEKUSI KLIK (Hanya saat GUI terlihat di layar)
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.ButtonR2, false, game)
                                task.wait(0.01) 
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.ButtonR2, false, game)
                                
                                task.wait(ReelSpeed) 
                            else
                                -- GUI Aktif tapi di luar layar (Selesai main) -> DIAM
                                task.wait(0.2)
                            end
                        else
                            task.wait(0.2)
                        end
                    end
                end)
                Rayfield:Notify({Title = "Fast Reel", Content = "Diaktifkan! Deteksi Layar...", Duration = 3, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Fast Reel", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- SLIDER SPEED
    FishItTab:CreateSlider({
        Name = "Reel Speed (Detik)",
        Range = {0.05, 0.5}, 
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = 0.1,
        Flag = "FishItReelSpeed",
        Callback = function(value)
            ReelSpeed = value
        end,
    })

-- ===========================
    -- UI: UTILITY & VISUALS
    -- ===========================
    FishItTab:CreateSection("Utility & Visuals")

    -- 1. HELPER FUNCTIONS
    local function getEquipRemote()
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
        end)
        return (success and result) and result or nil
    end

    local function getRadarRemoteDirect()
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateFishingRadar"]
        end)
        return (success and result) and result or nil
    end

    local function getDivingRemotes()
        local success, result = pcall(function()
            local net = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net
            return {
                Equip = net["RF/EquipOxygenTank"],
                Unequip = net["RF/UnequipOxygenTank"],
                ItemData = require(game:GetService("ReplicatedStorage").Shared.ItemUtility).GetItemDataFromItemType("Gears", "Diving Gear")
            }
        end)
        return (success and result) and result or nil
    end

    -- 2. AUTO EQUIP ROD (INSTANT SWITCH & WRONG ITEM CHECK)
    local AutoEquipEnabled = false
    
    FishItTab:CreateToggle({
        Name = "Auto Equip Rod",
        CurrentValue = false,
        Flag = "FishItAutoEquip",
        Callback = function(value)
            AutoEquipEnabled = value
            if value then
                -- Cari remote sekali di awal untuk performa
                local remote = getEquipRemote()
                
                task.spawn(function()
                    while AutoEquipEnabled do
                        if SessionStop then break end
                        if LocalPlayer.Character then
                            local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                            
                            -- LOGIKA INSTAN:
                            -- 1. Jika Tangan Kosong (nil)
                            -- 2. ATAU Jika Tangan Ada Isi TAPI namanya tidak ada kata "Rod" (Salah Item)
                            if not tool or (tool and not string.find(tool.Name, "Rod")) then
                                
                                if remote then
                                    -- Paksa pindah ke Slot 1
                                    pcall(function() remote:FireServer(1) end)
                                end
                                
                                -- Delay sangat singkat agar responsif tapi tidak crash (0.25s)
                                task.wait(0.25) 
                            end
                        end
                        
                        -- Cek status loop sangat cepat
                        task.wait(0.1)
                    end
                end)
                Rayfield:Notify({Title = "Auto Equip", Content = "Diaktifkan!", Duration = 3, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Equip", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- 3. FITUR DIVING GEAR
    FishItTab:CreateToggle({
        Name = "Auto Equip Diving Gear",
        CurrentValue = false,
        Flag = "FishItDivingGear",
        Callback = function(value)
            local data = getDivingRemotes()
            if value then
                if data and data.Equip and data.ItemData then
                    pcall(function() data.Equip:InvokeServer(data.ItemData.Data.Id) end)
                    Rayfield:Notify({Title = "Diving Gear", Content = "Equipped!", Duration = 2, Image = 7733964719})
                end
            else
                if data and data.Unequip then
                    pcall(function() data.Unequip:InvokeServer() end)
                    Rayfield:Notify({Title = "Diving Gear", Content = "Unequipped!", Duration = 2, Image = 7733964719})
                end
            end
        end,
    })

    -- 4. FITUR RADAR (BYPASS)
    FishItTab:CreateToggle({
        Name = "Bypass Fishing Radar",
        CurrentValue = false,
        Flag = "FishItRadarBypass",
        Callback = function(value)
            local remote = getRadarRemoteDirect()
            if remote then
                task.spawn(function() pcall(function() remote:InvokeServer(value) end) end)
                if value then
                    Rayfield:Notify({Title = "Bypass Radar", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
                else
                    Rayfield:Notify({Title = "Bypass Radar", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
                end
            else
                Rayfield:Notify({Title = "Error", Content = "Remote Radar tidak ditemukan!", Duration = 3, Image = 7733964719})
            end
        end,
    })

    -- ===========================
    -- UI: MERCHANT
    -- ===========================
    FishItTab:CreateSection("Merchant")

    FishItTab:CreateButton({
        Name = "Open/Close Merchant GUI",
        Callback = function()
            local merchantGui = LocalPlayer.PlayerGui:FindFirstChild("Merchant")
            if merchantGui then
                merchantGui.Enabled = not merchantGui.Enabled
                Rayfield:Notify({Title = "Merchant", Content = merchantGui.Enabled and "Dibuka!" or "Ditutup!", Duration = 2, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Error", Content = "Merchant GUI tidak ditemukan!", Duration = 3, Image = 7733964719})
            end
        end,
    })

    -- ===========================
    -- UI: SELLING
    -- ===========================
    FishItTab:CreateSection("Selling System")

    FishItTab:CreateButton({
        Name = "Jual Semua Ikan (Manual)",
        Callback = function()
            local remote = getSellRemote()
            if remote then remote:InvokeServer() end
            Rayfield:Notify({Title = "Menjual", Content = "Semua ikan terjual!", Duration = 2, Image = 7733964719})
        end,
    })

    -- Variabel Delay Default
    local FishIt_AutoSell = false
    local FishIt_SellDelay = 30 

    FishItTab:CreateToggle({
        Name = "Auto Sell",
        CurrentValue = false,
        Flag = "FishItAutoSell",
        Callback = function(value)
            FishIt_AutoSell = value
            if value then
                task.spawn(function()
                    while FishIt_AutoSell do
                        local remote = getSellRemote()
                        if remote then pcall(function() remote:InvokeServer() end) end
                        
                        -- Gunakan variabel delay, bukan angka mati
                        task.wait(FishIt_SellDelay) 
                    end
                end)
                Rayfield:Notify({Title = "Auto Sell", Content = "Diaktifkan! Detik: " .. FishIt_SellDelay .. "s", Duration = 2, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Sell", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- Input untuk Mengubah Delay
    FishItTab:CreateInput({
        Name = "Auto Sell (Detik)",
        PlaceholderText = "Default: 30",
        NumbersOnly = true,
        OnEnter = true,
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            -- Validasi agar tidak di bawah 1 detik (biar tidak spam parah)
            if num and num >= 1 then
                FishIt_SellDelay = num
                Rayfield:Notify({Title = "Delay", Content = "Diperbarui ke: " .. num .. "Detik", Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- ===========================
    -- UI: WEATHER MACHINE
    -- ===========================
    FishItTab:CreateSection("Weather Machine")

    local WeatherList = {}
    local SelectedWeathers = {} 
    local AutoBuyWeather = false
    local WeatherGuiPath = LocalPlayer.PlayerGui:WaitForChild("!!! Weather Machine", 10)

    local function fetchWeatherOptions()
        local tempData = {} 
        local options = {}  
        local success, EventsModule = pcall(function() return require(game:GetService("ReplicatedStorage").Events) end)

        if success and EventsModule then
            for eventName, eventData in pairs(EventsModule) do
                if eventData.WeatherMachine and eventData.WeatherMachinePrice then
                    table.insert(tempData, {Name = eventName, Price = eventData.WeatherMachinePrice})
                end
            end
            table.sort(tempData, function(a, b) return a.Price < b.Price end)
            for _, data in ipairs(tempData) do
                table.insert(options, data.Name .. " (" .. formatNumber(data.Price) .. ")")
            end
        else
            options = {"Wind (2,500)", "Cloudy (10,000)", "Snow (12,500)", "Storm (15,000)", "Radiant (25,000)", "Shark Hunt (50,000)"}
        end
        return options
    end
    
    local function getActiveSlots()
        if not WeatherGuiPath then return 3, 3 end
        local label = WeatherGuiPath.Frame.Frame.Left.Label
        if label then
            local current, max = label.Text:match("(%d+)/(%d+)")
            return tonumber(current) or 3, tonumber(max) or 3
        end
        return 3, 3
    end

    local function getActiveWeatherNames()
        local activeNames = {}
        if not WeatherGuiPath then return activeNames end
        local activeGrid = WeatherGuiPath.Frame.Frame.Left.Frame.Grid
        if activeGrid then
            for _, child in ipairs(activeGrid:GetChildren()) do
                if child:IsA("Frame") and child:FindFirstChild("Content") then
                    local itemName = child.Content:FindFirstChild("ItemName")
                    if itemName then table.insert(activeNames, itemName.Text) end
                end
            end
        end
        return activeNames
    end

    WeatherList = fetchWeatherOptions()

    local WeatherDropdown = FishItTab:CreateDropdown({
        Name = "Pilih Cuaca (Multiple)",
        Options = WeatherList,
        CurrentOption = {}, 
        MultipleOptions = true,
        Flag = "WeatherDropdownMulti",
        Callback = function(options)
            local cleanList = {}
            for _, opt in ipairs(options) do
                table.insert(cleanList, getRealName(opt))
            end
            SelectedWeathers = cleanList
        end,
    })

    FishItTab:CreateButton({
        Name = "Beli Semua Cuaca Yang Dipilih",
        Callback = function()
            if #SelectedWeathers == 0 then return end
            local remote = getWeatherRemote()
            if remote then
                for _, weatherName in ipairs(SelectedWeathers) do
                    task.spawn(function() pcall(function() remote:InvokeServer(weatherName) end) end)
                end
                Rayfield:Notify({Title = "Membeli", Content = "Semua cuaca terbeli!", Duration = 2, Image = 7733964719})
            end
        end,
    })

    FishItTab:CreateToggle({
        Name = "Auto Beli Cuaca",
        CurrentValue = false,
        Flag = "FishItAutoBuyWeather",
        Callback = function(value)
            AutoBuyWeather = value
            if value then
                task.spawn(function()
                    while AutoBuyWeather do
                        local usedSlots, maxSlots = getActiveSlots()
                        local slotsAvailable = maxSlots - usedSlots
                        if slotsAvailable > 0 then
                            local activeWeathers = getActiveWeatherNames()
                            local remote = getWeatherRemote()
                            if remote and #SelectedWeathers > 0 then
                                for _, targetWeather in ipairs(SelectedWeathers) do
                                    if slotsAvailable <= 0 then break end
                                    local isAlreadyActive = false
                                    for _, active in ipairs(activeWeathers) do
                                        if active == targetWeather then isAlreadyActive = true; break end
                                    end
                                    if not isAlreadyActive then
                                        task.spawn(function() remote:InvokeServer(targetWeather) end)
                                        slotsAvailable = slotsAvailable - 1 
                                        table.insert(activeWeathers, targetWeather)
                                    end
                                end
                            end
                        end
                        task.wait(1) 
                    end
                end)
                Rayfield:Notify({Title = "Auto Beli Cuaca", Content = "Diaktifkan!", Duration = 3, Image = 7733964719})
            else
                Rayfield:Notify({Title = "Auto Beli Cuaca", Content = "Dimatikan!", Duration = 3, Image = 7733964719})
            end
        end,
    })

    -- ===========================
    -- UI: PROTECTION
    -- ===========================
    FishItTab:CreateSection("Protection")

    -- 1. VISUAL INFO DASHBOARD (FITUR BARU)
    local InfoParagraph = FishItTab:CreateParagraph({
        Title = "Detector Stuck Info",
        Content = "Status: Detector Offline\nTime: 0.0s"
    })

    -- 2. ANTI AFK (Standard)
    local FishIt_AntiAFK = false
    local FishIt_AFKConnection

    -- 3. ANTI-STUCK (LOGIC + VISUAL UPDATE)
    local AntiStuckEnabled = false
    local CurrentStuckLimit = 15 -- Default sesuai gambar
    local MinigameStartTime = 0
    local LastLoggedSecond = 0
    local LastPositionBeforeDeath = nil
    local IsReseting = false
    local VirtualInputManager = game:GetService("VirtualInputManager")

-- Handler Recovery (Smart Logic: Cek Status Auto Equip)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if IsReseting and LastPositionBeforeDeath then
            -- 1. Teleport Instan
            local root = newChar:WaitForChild("HumanoidRootPart", 10)
            if root then 
                root.CFrame = LastPositionBeforeDeath 
            end
            
            task.spawn(function()
                -- 3. Equip Rod (Selalu lakukan ini agar karakter memegang pancingan)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                
                -- 4. LOGIKA PINTAR: Cek apakah fitur "Auto Equip Rod" di skrip aktif?
                if AutoEquipEnabled then
                    -- KASUS A: Auto Equip ON
                    -- Karena fitur Auto Equip skrip cenderung mereset status server, 
                    -- kita WAJIB menyalakan ulang Auto Fish-nya.
                    
                    task.wait(0.5) -- Beri jeda agar equip terbaca server
                    
                    local success, remote = pcall(function()
                        return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateAutoFishingState"]
                    end)
                    
                    if success and remote then
                        remote:InvokeServer(true) -- Paksa ON
                        Rayfield:Notify({Title = "Recovery", Content = "Auto Fish Diaktifkan!", Duration = 2, Image = 7733964719})
                    end
                else
                    -- KASUS B: Auto Equip OFF
                    -- Seperti yang kamu bilang, game akan membiarkan Auto Fish tetap ON.
                    -- Jadi kita TIDAK PERLU melakukan apa-apa agar tidak membuang waktu.
                    Rayfield:Notify({Title = "Recovery", Content = "Posisi Dipulihkan!", Duration = 1, Image = 7733964719})
                end
            end)
            
            -- Reset Variable Logic
            IsReseting = false 
            LastPositionBeforeDeath = nil
            MinigameStartTime = 0
            if LastState then LastState = "None" end
        end
    end)

FishItTab:CreateToggle({
        Name = "Anti Stuck",
        CurrentValue = false,
        Flag = "FishItAntiStuck",
        Callback = function(value)
            AntiStuckEnabled = value
            
            if value then
                -- === SAAT DIHIDUPKAN (ON) ===
                MinigameStartTime = 0 
                local LastState = "None"
                local RunService = game:GetService("RunService")
                
                Rayfield:Notify({Title = "Anti Stuck", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
                
                -- Set status awal
                if InfoParagraph then
                    InfoParagraph:Set({Title = "Detector Stuck Info", Content = "Status: Idle / Safe\nTime: 0.0s"})
                end
                
                task.spawn(function()
                    while AntiStuckEnabled do
                        RunService.Heartbeat:Wait() -- Loop Cepat
                        
                        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                        
                        -- 1. DETEKSI STATUS GUI
                        local isCharging = false
                        local isFishing = false
                        
                        if pGui then
                            local chargeGui = pGui:FindFirstChild("Charge")
                            if chargeGui and chargeGui.Enabled then isCharging = true end
                            
                            local fishingGui = pGui:FindFirstChild("Fishing")
                            if fishingGui and fishingGui.Enabled then
                                local mainFrame = fishingGui:FindFirstChild("Main")
                                if mainFrame and mainFrame.Visible and mainFrame.Position.Y.Scale < 1.2 then
                                    isFishing = true
                                end
                            end
                        end
                        
                        local statusText = "Idle / Safe"
                        local timeText = "0.0s"
                        local forceUpdate = false -- Penanda khusus untuk update UI saat stuck
                        
                        -- 2. LOGIKA STATE MACHINE
                        if isCharging then
                            if MinigameStartTime == 0 then MinigameStartTime = tick() end
                            LastState = "Charge"
                            statusText = "Charging..."
                            
                        elseif isFishing then
                            if MinigameStartTime == 0 then MinigameStartTime = tick() end
                            LastState = "Fish"
                            statusText = "Minigame..."
                            
                        else
                            if LastState == "Charge" then
                                statusText = "Waiting..."
                            elseif LastState == "Fish" then
                                MinigameStartTime = 0
                                LastState = "None"
                                statusText = "Finished"
                            else
                                MinigameStartTime = 0
                                statusText = "Idle / Safe"
                            end
                        end
                        
                        -- 3. LOGIKA STUCK (DIPERBAIKI)
                        if MinigameStartTime ~= 0 then
                            local elapsed = tick() - MinigameStartTime
                            timeText = string.format("%.1f", elapsed) .. "s"
                            
                            -- JIKA WAKTU HABIS
                            if elapsed >= CurrentStuckLimit then
                                statusText = "Stuck! Mereset Karakter..."
                                forceUpdate = true -- Tandai agar UI diupdate SEKARANG
                                
                                -- A. PAKSA UPDATE UI AGAR TERBACA
                                if InfoParagraph then
                                    InfoParagraph:Set({
                                        Title = "Detector Stuck Info",
                                        Content = "Status: " .. statusText .. 
                                                  "\nTime: " .. timeText .. " / " .. CurrentStuckLimit .. "s"
                                    })
                                end
                                
                                -- B. TAHAN 0.5 DETIK (Agar user melihat tulisan STUCK)
                                task.wait(0.5) 
                                
                                -- C. EKSEKUSI RESET
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    LastPositionBeforeDeath = LocalPlayer.Character.HumanoidRootPart.CFrame
                                    IsReseting = true
                                end
                                
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                    LocalPlayer.Character.Humanoid.Health = 0
                                end
                                
                                -- D. RESET VARIABLE
                                MinigameStartTime = 0
                                LastState = "None"
                                task.wait(3) -- Sisa cooldown
                            end
                        end
                        
                        -- UPDATE VISUAL NORMAL (Hanya jika TIDAK sedang proses reset stuck)
                        if InfoParagraph and AntiStuckEnabled and not forceUpdate then
                            InfoParagraph:Set({
                                Title = "Detector Stuck Info",
                                Content = "Status: " .. statusText .. 
                                          "\nTime: " .. timeText .. " / " .. CurrentStuckLimit .. "s"
                            })
                        end
                    end
                end)
            else
                -- === SAAT DIMATIKAN (OFF) ===
                Rayfield:Notify({Title = "Anti Stuck", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
                MinigameStartTime = 0
                if InfoParagraph then
                    InfoParagraph:Set({Title = "Detector Stuck Info", Content = "Status: Detector Offline\nTime: 0.0s"})
                end
            end
        end,
    })

    -- SLIDER WAIT (S)
    FishItTab:CreateSlider({
        Name = "Batas Waktu Stuck",
        Range = {5, 30},
        Increment = 1,
        Suffix = "s",
        CurrentValue = 15,
        Flag = "FishItStuckTime",
        Callback = function(value)
            CurrentStuckLimit = value
            -- Update visual langsung saat digeser
            InfoParagraph:Set({
                Title = "Detector Stuck Info", 
                Content = "Status: Setting Updated\nLimit: " .. value .. "s"
            })
        end,
    })

    FishItTab:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = false,
        Flag = "FishItAntiAFK",
        Callback = function(value)
            FishIt_AntiAFK = value
            if value then
                FishIt_AFKConnection = TrackConn(LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end))
                Rayfield:Notify({Title = "Anti AFK", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})
            else
                if FishIt_AFKConnection then FishIt_AFKConnection:Disconnect() end
                Rayfield:Notify({Title = "Anti AFK", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })
    
else
    -- Opsional: Info jika bukan game Fish It
    -- print("[AsuHub] Game Fish It tidak terdeteksi. Tab Fish It disembunyikan.")
end

-- ===================================================================
-- [[ TAB 10: AUTO OBBY
-- ===================================================================

local Obby_PlaceID = 80692223709267

if game.PlaceId == Obby_PlaceID then

    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local REBIRTH_MAX_STAGE = 251

    -- Fungsi Rebirth
    local function attemptRebirth()
        local MainRemote = ReplicatedStorage:FindFirstChild("MainRemote")
        if not MainRemote then return false end
        
        local CanRebirth = player:FindFirstChild("RepData") and player.RepData:FindFirstChild("CanRebirth")
        
        local tbl_rebirth = {Request = "RequestRebirth"}
        local tbl_purchase = {Request = "Purchase", Type = "RebirthProduct"}
        
        if CanRebirth and CanRebirth.Value then
            pcall(function() MainRemote:FireServer(tbl_rebirth) end)
            return true
        else
            pcall(function() MainRemote:FireServer(tbl_purchase) end)
            return true
        end
    end

    -- Fungsi Noclip (Pasti ada di sini agar scope-nya benar)
    local function setNoclip(state)
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = not state
                end
            end
        end
    end

    local ObbyTab = Window:CreateTab("Auto Obby", 4370318685) -- Create Tab

    -- Variabel Lokal Tab
    local InitialStartStage = 1
    local TravelSpeed = 100
    local activeTween = nil
    local AutoObbyEnabled = false
    local ObbyAutoToggle -- Deklarasi untuk update status UI
    
    -- [[ FUNGSI HANDLER UNTUK MEMBATALKAN TWEEN KETIKA CHECKPOINT TERCAPAI ]]
    local checkpointConnection = nil
    local leaderstats = player:WaitForChild("leaderstats", 5)
    local Stage = leaderstats and leaderstats:FindFirstChild("Stage")

    local function setupCheckpointListener(currentGoalStage)
        -- Hapus listener lama jika ada
        if checkpointConnection then
            checkpointConnection:Disconnect()
            checkpointConnection = nil
        end
        
        -- Buat listener baru
        if Stage then
            checkpointConnection = Stage.Changed:Connect(function(newStageValue)
                -- Jika Stage yang baru dicatat server SAMA dengan Stage tujuan saat ini
                if newStageValue == currentGoalStage then
                    -- Batalkan pergerakan segera
                    if activeTween and activeTween.PlaybackState == Enum.PlaybackState.Playing then
                        activeTween:Cancel()
                    end
                end
            end)
            -- Masukkan ke daftar pembersih global agar mati saat script direload
            TrackConn(checkpointConnection)
        end
    end
    -- [[ END FUNGSI HANDLER ]]

    ObbyTab:CreateSection("Informasi")

    ObbyTab:CreateParagraph({
        Title = "Fitur Auto Obby (Free UGC Obby)",
        Content = "\nlangkah-langkah untuk menggunakan fitur ini yaitu :\n1. Atur Kecepatan Terbang (default lebih baik)\n2. Isi Mulai dari Stage dengan format angka\n3. Pastikan Godmode Dihidupkan pada Menu Player\n4. Aktifkan Auto Obby, Selesai."
    })

    ObbyTab:CreateSection("Kontrol Auto Obby")

    -- Slider Kecepatan Terbang
    ObbyTab:CreateSlider({
        Name = "Kecepatan Terbang (Studs/s)",
        Range = {50, 300},
        Increment = 10,
        Suffix = "spd",
        CurrentValue = 100,
        Flag = "ObbySpeedSlider",
        Callback = function(Value)
            TravelSpeed = Value
        end,
    })

    -- Input Stage Awal
    ObbyTab:CreateInput({
        Name = "Mulai dari Stage (Angka)",
        PlaceholderText = "Contoh: 1",
        NumbersOnly = true,
        OnEnter = true,
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            local num = tonumber(Text)
            if num and num >= 1 then
                InitialStartStage = num
                Rayfield:Notify({Title = "Setting", Content = "Stage diubah ke: " .. num, Duration = 2, Image = 7733964719})
            end
        end,
    })

    -- Toggle Utama
    ObbyAutoToggle = ObbyTab:CreateToggle({
        Name = "Auto Obby",
        CurrentValue = false,
        Flag = "AutoObbyToggle",
        Callback = function(Value)
            AutoObbyEnabled = Value

            if Value then
                task.spawn(function()
                    -- INISIALISASI VARIABEL LOKAL
                    local currentRunningStage = InitialStartStage
                    
                    while AutoObbyEnabled do
                        if SessionStop then break end
                        
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChild("Humanoid")
                        
                        -- Cek Leaderstats/Stage
                        local serverStage = Stage and Stage.Value or currentRunningStage
                        
                        if not root or not hum or not Stage then
                            task.wait(1)
                            continue
                        end

                        setNoclip(true)
                        hum.PlatformStand = true

                        -- [[ LOGIKA KOREKSI STAGE (Sangat Penting) ]]
                        -- Stage skrip tidak boleh lebih kecil dari Stage server
                        if currentRunningStage < serverStage then
                            -- Jika Stage server lebih besar dari Stage skrip (berhasil melewati/lompatan), sesuaikan Stage skrip
                            currentRunningStage = serverStage
                            Rayfield:Notify({Title = "Koreksi", Content = "Stage disinkronisasi ke: " .. serverStage, Duration = 2, Image = 7733964719})
                        elseif currentRunningStage > serverStage + 1 then
                            -- Jika Stage skrip jauh di depan (kemungkinan gagal atau lompatan tidak sinkron), mundur!
                            currentRunningStage = serverStage
                            Rayfield:Notify({Title = "Koreksi", Content = "Mundur ke Stage: " .. serverStage, Duration = 2, Image = 7733964719})
                        end
                        -- [[ END LOGIKA KOREKSI STAGE ]]

                        -- 1. CEK REBIRTH (MASUK Stage 251 + 1 = 252)
                        if currentRunningStage >= REBIRTH_MAX_STAGE then
                            Rayfield:Notify({Title = "Auto Rebirth", Content = "Mencapai Stage Max! Melakukan Rebirth...", Duration = 3, Image = 7733964719})
                            
                            -- Pastikan karakter berada di tempat yang aman sebelum Rebirth (opsional, tapi baik)
                            if hum then hum.PlatformStand = false end
                            setNoclip(false)
                            task.wait(0.5)

                            if attemptRebirth() then
                                Rayfield:Notify({Title = "Auto Rebirth", Content = "Berhasil Rebirth! Reset Stage ke 1.", Duration = 4, Image = 7733964719})
                                
                                currentRunningStage = 1
                                InitialStartStage = 1
                                task.wait(5)
                            else
                                Rayfield:Notify({Title = "Error Rebirth", Content = "Gagal Rebirth. Coba lagi nanti.", Duration = 5, Image = 7733964719})
                                task.wait(5)
                            end
                            continue -- Lanjut ke iterasi loop berikutnya (Stage 1)
                        end

                        -- 2. LOGIKA TELEPORT (TWEEN)
                        local checkpointsFolder = workspace:FindFirstChild("Checkpoints")
                        local targetStageToFly = currentRunningStage + 1
                        local targetPart = checkpointsFolder:FindFirstChild(tostring(targetStageToFly))
                        
                        if targetPart and targetPart:IsA("BasePart") then
                            Rayfield:Notify({Title = "Auto Obby", Content = "Menuju ke Stage: " .. targetStageToFly, Duration = 1, Image = 7733964719})
                            
                            local targetCFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                            local distance = (root.Position - targetCFrame.Position).Magnitude
                            local tweenTime = distance / TravelSpeed
                            if tweenTime < 0.1 then tweenTime = 0.1 end

                            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                            activeTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
                            
                            setupCheckpointListener(targetStageToFly)
                            
                            activeTween:Play()
                            activeTween.Completed:Wait()

                            if checkpointConnection then 
                                checkpointConnection:Disconnect() 
                                checkpointConnection = nil
                            end

                            if hum then
                                hum.PlatformStand = false
                                setNoclip(false)
                            end

                            task.wait(0.1)

                            -- 4. VERIFIKASI AKHIR (REVISI LOGIKA GAGAL DI SINI)
                            if Stage and Stage.Value >= targetStageToFly then
                                -- BERHASIL! Lanjutkan ke Stage berikutnya.
                                currentRunningStage = Stage.Value 
                            else
                                -- GAGAL CHECKPOINT/JATUH: KEMBALI KE CHECKPOINT TERAKHIR (currentRunningStage)
                                Rayfield:Notify({Title = "Gagal Checkpoint", Content = "Ulangi. Kembali ke Stage: " .. currentRunningStage, Duration = 2, Image = 7733964719})
                                
                                local lastCheckpointPart = checkpointsFolder:FindFirstChild(tostring(currentRunningStage))
                                
                                if lastCheckpointPart and lastCheckpointPart:IsA("BasePart") then
                                    -- Teleport instan kembali ke posisi checkpoint terakhir
                                    root.CFrame = lastCheckpointPart.CFrame + Vector3.new(0, 3, 0)
                                end
                                
                                -- Siapkan status terbang lagi untuk loop berikutnya
                                if hum then hum.PlatformStand = true end
                                setNoclip(true)
                            end

                            task.wait(0.2)
                            
                        else
                            -- LOGIKA PENCARIAN (TETAP SAMA)
                            local SearchDistance = 200 
                            
                            Rayfield:Notify({
                                Title = "Checkpoint Hilang", 
                                Content = "Stage " .. targetStageToFly .. " tidak ditemukan. Mencoba bergerak ke KIRI " .. SearchDistance .. " studs.", 
                                Duration = 3,
                                Image = 7733964719,
                            })
                            
                            local targetCFrame = root.CFrame * CFrame.new(-SearchDistance, 0, 0) 
                            local distance = SearchDistance
                            local tweenTime = distance / TravelSpeed
                            if tweenTime < 0.1 then tweenTime = 0.1 end

                            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                            activeTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
                            
                            activeTween:Play()
                            activeTween.Completed:Wait()

                            task.wait(0.5) 
                            
                            local newTargetPart = checkpointsFolder:FindFirstChild(tostring(targetStageToFly))
                            
                            if not newTargetPart or not newTargetPart:IsA("BasePart") then
                                Rayfield:Notify({Title = "Gagal Mencari", Content = "Checkpoint masih belum ditemukan. Mencoba lagi.", Duration = 2, Image = 7733964719})
                            end
                            
                            if hum then hum.PlatformStand = true end
                            setNoclip(true) 
                        end
                        
                        task.wait()
                    end
                    
                    -- CLEANUP SAAT LOOP BERHENTI/SELESAI
                    if activeTween then activeTween:Cancel() end
                    if checkpointConnection then checkpointConnection:Disconnect() end
                    
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.PlatformStand = false
                        setNoclip(false)
                    end
                end)
                Rayfield:Notify({Title = "Auto Obby", Content = "Diaktifkan!", Duration = 2, Image = 7733964719})

            else
                -- TOMBOL DIMATIKAN
                AutoObbyEnabled = false
                if activeTween then activeTween:Cancel() end
                if checkpointConnection then checkpointConnection:Disconnect() end
                
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.PlatformStand = false
                    setNoclip(false)
                end
                Rayfield:Notify({Title = "Auto Obby", Content = "Dimatikan!", Duration = 2, Image = 7733964719})
            end
        end,
    })
end

-- ===================================================================
-- [[ TAB 11: MOUNT MIKA ]]
-- ===================================================================

if isCurrentGame(GAME_ID_MIKA) then
    local MikaTab = Window:CreateTab("Mount Mika", 4370318685)
    
    MikaTab:CreateSection("Informasi")
    MikaTab:CreateParagraph({Title = "Fitur Mount Mika", Content = "Auto Teleport & Manual Teleport di Mount Mika."})

    MikaTab:CreateSection("Kontrol Auto Teleport")

    MikaTab:CreateSlider({
        Name = "Auto Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Mika,
        Flag = "MikaDelay",
        Callback = function(value)
            teleportDelay_Mika = value
            -- createNotification("Delay Mika", "Diatur ke " .. value .. " detik")
        end,
    })

    MikaTab:CreateToggle({
        Name = "Auto Teleport",
        CurrentValue = false,
        Flag = "MikaAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Mika = true
                TrackCoroutine(task.spawn(startTeleportLoop_Mika))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Mika()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    MikaTab:CreateButton({
    Name = "Reset Auto Teleport",
    Callback = function()
        stopAutoTeleport_Mika() 
        currentTeleportIndex_Mika = 0
        createNotification("Reset Auto Teleport", "Auto Teleport direset ke 0 (Mulai dari 1)", 2)
    end,
    })

    MikaTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Mika) do
        MikaTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i,
            Callback = function()
                stopAllMountTeleports()
                currentTeleportIndex_Mika = i
                teleportCharacter(player.Character, location)
                createNotification("Mount Mika", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end


-- ===================================================================
-- [[ TAB 12: MOUNT GEMI ]]
-- ===================================================================

if isCurrentGame(GAME_ID_GEMI) then
    local GemiTab = Window:CreateTab("Mount Gemi", 4370318685)
    
    GemiTab:CreateSection("Informasi")
    GemiTab:CreateParagraph({Title = "Fitur Mount Gemi", Content = "Auto Teleport & Manual Teleport di Mount Gemi."})

    GemiTab:CreateSection("Kontrol Auto Teleport")

    GemiTab:CreateSlider({
        Name = "Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Gemi,
        Flag = "GemiDelay",
        Callback = function(value)
            teleportDelay_Gemi = value
            createNotification("Delay Gemi", "Diatur ke " .. value .. " detik")
        end,
    })

    GemiTab:CreateToggle({
        Name = "Auto Summit",
        CurrentValue = false,
        Flag = "GemiAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Gemi = true
                TrackCoroutine(task.spawn(startTeleportLoop_Gemi))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Gemi()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    GemiTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Gemi) do
        GemiTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i .. (i == #teleportLocations_Gemi and " (Summit)" or ""),
            Callback = function()
                stopAllMountTeleports()
                teleportCharacter(player.Character, location)
                createNotification("Mount Gemi", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ TAB 13: MOUNT BEAJA ]]
-- ===================================================================

if isCurrentGame(GAME_ID_BEAJA) then
    local BeajaTab = Window:CreateTab("Mount Beaja", 4370318685)
    
    BeajaTab:CreateSection("Informasi")
    BeajaTab:CreateParagraph({Title = "Fitur Mount Beaja", Content = "Auto Teleport & Manual Teleport di Mount Beaja."})

    BeajaTab:CreateSection("Kontrol Auto Teleport")

    BeajaTab:CreateSlider({
        Name = "Auto Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Beaja,
        Flag = "BeajaDelay",
        Callback = function(value)
            teleportDelay_Beaja = value
            createNotification("Delay Beaja", "Diatur ke " .. value .. " detik")
        end,
    })

    BeajaTab:CreateToggle({
        Name = "Auto Teleport",
        CurrentValue = false,
        Flag = "BeajaAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Beaja = true
                TrackCoroutine(task.spawn(startTeleportLoop_Beaja))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Beaja()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    BeajaTab:CreateButton({
    Name = "Reset Auto Teleport",
    Callback = function()
        stopAutoTeleport_Beaja() 
        currentTeleportIndex_Beaja = 0
        createNotification("Reset Auto Teleport", "Auto Teleport direset ke 0 (Mulai dari 1)", 2)
    end,
    })

    BeajaTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Beaja) do
        BeajaTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i,
            Callback = function()
                stopAllMountTeleports()
                currentTeleportIndex_Beaja = i
                teleportCharacter(player.Character, location)
                createNotification("Mount Beaja", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ TAB 14: MOUNT MAAF ]]
-- ===================================================================

if isCurrentGame(GAME_ID_MAAF) then
    local MaafTab = Window:CreateTab("Mount Maaf", 4370318685)
    
    MaafTab:CreateSection("Informasi")
    MaafTab:CreateParagraph({Title = "Fitur Mount Maaf", Content = "Auto Teleport & Manual Teleport di Mount Maaf."})

    MaafTab:CreateSection("Kontrol Auto Teleport")

    MaafTab:CreateSlider({
        Name = "Auto Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Maaf,
        Flag = "MaafDelay",
        Callback = function(value)
            teleportDelay_Maaf = value
            createNotification("Delay Maaf", "Diatur ke " .. value .. " detik")
        end,
    })

    MaafTab:CreateToggle({
        Name = "Auto Teleport",
        CurrentValue = false,
        Flag = "MaafAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Maaf = true
                TrackCoroutine(task.spawn(startTeleportLoop_Maaf))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Maaf()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    MaafTab:CreateButton({
    Name = "Reset Auto Teleport",
    Callback = function()
        stopAutoTeleport_Maaf() 
        currentTeleportIndex_Maaf = 0
        createNotification("Reset Auto Teleport", "Auto Teleport direset ke 0 (Mulai dari 1)", 2)
    end,
    })

    MaafTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Maaf) do
        MaafTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i,
            Callback = function()
                stopAllMountTeleports()
                currentTeleportIndex_Maaf = i
                teleportCharacter(player.Character, location)
                createNotification("Mount Maaf", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ TAB 15: MOUNT KOTA ]]
-- ===================================================================

if isCurrentGame(GAME_ID_KOTA) then
    local KotaTab = Window:CreateTab("Mount Kota", 4370318685)
    
    KotaTab:CreateSection("Informasi")
    KotaTab:CreateParagraph({Title = "Fitur Mount Kota", Content = "Auto Teleport & Manual Teleport di Mount Kota."})

    KotaTab:CreateSection("Kontrol Auto Teleport")

    KotaTab:CreateSlider({
        Name = "Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Kota,
        Flag = "KotaDelay",
        Callback = function(value)
            teleportDelay_Kota = value
            createNotification("Delay Kota", "Diatur ke " .. value .. " detik")
        end,
    })

    KotaTab:CreateToggle({
        Name = "Auto Teleport (TP 13 > Jalan Cepat 14)",
        CurrentValue = false,
        Flag = "KotaAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Kota = true
                TrackCoroutine(task.spawn(startTeleportLoop_Kota))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Kota()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    KotaTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Kota) do
        KotaTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i .. (i == 13 and " (TP Awal)" or i == 14 and " (Jalan Akhir)" or ""),
            Callback = function()
                stopAllMountTeleports()
                teleportCharacter(player.Character, location)
                createNotification("Mount Kota", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ TAB 16: MOUNT YAHAYUK ]]
-- ===================================================================

if isCurrentGame(GAME_ID_YAHAYUK) then
    local YahayukTab = Window:CreateTab("Mount Yahayuk", 4370318685)
    
    YahayukTab:CreateSection("Informasi")
    YahayukTab:CreateParagraph({Title = "Fitur Mount Yahayuk", Content = "Auto Teleport & Manual Teleport di Mount Yahayuk."})

    YahayukTab:CreateSection("Kontrol Auto Teleport")

    YahayukTab:CreateSlider({
        Name = "Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Yahayuk,
        Flag = "YahayukDelay",
        Callback = function(value)
            teleportDelay_Yahayuk = value
            createNotification("Delay Yahayuk", "Diatur ke " .. value .. " detik")
        end,
    })

    YahayukTab:CreateToggle({
        Name = "Auto Teleport (TP 1-6 -> Jalan Cepat 7)",
        CurrentValue = false,
        Flag = "YahayukAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Yahayuk = true
                TrackCoroutine(task.spawn(startTeleportLoop_Yahayuk))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Yahayuk()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    YahayukTab:CreateButton({
    Name = "Reset Auto Teleport",
    Callback = function()
        stopAutoTeleport_Yahayuk() 
        currentTeleportIndex_Yahayuk = 0
        createNotification("Reset Auto Teleport", "Auto Teleport direset ke 0 (Mulai dari 1)", 2)
    end,
    })

    YahayukTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Yahayuk) do
        YahayukTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i .. (i == 7 and " (Jalan Akhir)" or ""),
            Callback = function()
                stopAllMountTeleports()
                currentTeleportIndex_Yahayuk = i
                teleportCharacter(player.Character, location)
                createNotification("Mount Yahayuk", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ TAB 17: MOUNT DAUN ]]
-- ===================================================================

if isCurrentGame(GAME_ID_DAUN) then
    local DaunTab = Window:CreateTab("Mount Daun", 4370318685)
    
    DaunTab:CreateSection("Informasi")
    DaunTab:CreateParagraph({Title = "Fitur Mount Daun", Content = "Auto Teleport & Manual Teleport di Mount Daun."})

    DaunTab:CreateSection("Kontrol Auto Teleport")

    DaunTab:CreateSlider({
        Name = "Auto Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Daun,
        Flag = "DaunDelay",
        Callback = function(value)
            teleportDelay_Daun = value
            createNotification("Delay Daun", "Diatur ke " .. value .. " detik")
        end,
    })

    DaunTab:CreateToggle({
        Name = "Auto Teleport",
        CurrentValue = false,
        Flag = "DaunAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Daun = true
                TrackCoroutine(task.spawn(startTeleportLoop_Daun))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Daun()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    DaunTab:CreateButton({
    Name = "Reset Auto Teleport",
    Callback = function()
        stopAutoTeleport_Daun() 
        currentTeleportIndex_Daun = 0
        createNotification("Reset Auto Teleport", "Auto Teleport direset ke 0 (Mulai dari 1)", 2)
    end,
    })

    DaunTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Daun) do
        DaunTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i,
            Callback = function()
                stopAllMountTeleports()
                currentTeleportIndex_Daun = i
                teleportCharacter(player.Character, location)
                createNotification("Mount Daun", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ TAB 18: MOUNT KOHARU ]]
-- ===================================================================

if isCurrentGame(GAME_ID_KOHARU) then
    local KoharuTab = Window:CreateTab("Mount Koharu", 4370318685)
    
    KoharuTab:CreateSection("Informasi")
    KoharuTab:CreateParagraph({Title = "Fitur Mount Koharu", Content = "Auto Teleport & Manual Teleport di Mount Koharu."})

    KoharuTab:CreateSection("Kontrol Auto Teleport")

    KoharuTab:CreateSlider({
        Name = "Auto Teleport Delay (detik)",
        Range = {0.1, 60},
        Increment = 0.1,
        Precision = 1,
        Suffix = "s",
        CurrentValue = teleportDelay_Koharu,
        Flag = "KoharuDelay",
        Callback = function(value)
            teleportDelay_Koharu = value
            createNotification("Delay Koharu", "Diatur ke " .. value .. " detik")
        end,
    })

    KoharuTab:CreateToggle({
        Name = "Auto Teleport",
        CurrentValue = false,
        Flag = "KoharuAutoTP",
        Callback = function(state)
            stopAllMountTeleports()
            if state then
                autoTeleportEnabled_Koharu = true
                TrackCoroutine(task.spawn(startTeleportLoop_Koharu))
                createNotification("Auto Teleport", "Diaktifkan!")
            else
                stopAutoTeleport_Koharu()
                createNotification("Auto Teleport", "Dimatikan!")
            end
        end,
    })

    KoharuTab:CreateButton({
    Name = "Reset Auto Teleport",
    Callback = function()
        stopAutoTeleport_Koharu() 
        currentTeleportIndex_Koharu = 0
        createNotification("Reset Auto Teleport", "Auto Teleport direset ke 0 (Mulai dari 1)", 2)
    end,
    })

    KoharuTab:CreateSection("Manual Teleport")

    for i, location in ipairs(teleportLocations_Koharu) do
        KoharuTab:CreateButton({
            Name = "Teleport ke Lokasi " .. i,
            Callback = function()
                stopAllMountTeleports()
                currentTeleportIndex_Koharu = i
                teleportCharacter(player.Character, location)
                createNotification("Mount Koharu", "TP ke Lokasi " .. i, 1)
            end,
        })
    end
end

-- ===================================================================
-- [[ NOTIFICATION ]]
-- ===================================================================

Rayfield:Notify({
    Title = "AsuHub",
    Content = "Skrip berhasil dimuat!",
    Duration = 5,
    Image = 7733964719,
})

if not isR15 then
    Rayfield:Notify({
    Title = "Fitur Animasi",
    Content = "Fitur animasi tidak terload! (hanya untuk R15)",
    Duration = 5,
    Image = 7733964719,
    })
end
