-- AsuHub_UI.lua
-- Berisi semua pembuatan UI dan menu

getgenv().AsuHub_UI = {}

local AsuHub_UI = getgenv().AsuHub_UI

-- Load Rayfield Library
AsuHub_UI.Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

function AsuHub_UI.CreateMainWindow()
    local Window = AsuHub_UI.Rayfield:CreateWindow({
        Name = "AsuHub",
        LoadingTitle = "AsuHub Loading...",
        LoadingSubtitle = "by @yogurutto",
        ShowText = "AsuHub",
        Theme = "Amethyst",
        ToggleUIKeybind = "G",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
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
    
    AsuHub_UI.Window = Window
    return Window
end

function AsuHub_UI.CreateInformationTab(Window)
    local InfoTab = Window:CreateTab("Information", 7733960981)
    
    InfoTab:CreateSection("Tentang AsuHub")
    InfoTab:CreateParagraph({
        Title = "Selamat Datang di AsuHub!", 
        Content = "Skrip all-in-one untuk Member Maen Asu. Beragam fitur-fitur terbaik yang dibuat secara mandiri. Selamat menikmati Fitur-fitur lengkapnya!\n\n⚠️ Jika ada kendala Laporkan langsung ke Discord dan Tag @Yogurutto"
    })
    
    InfoTab:CreateSection("Discord Server")
    InfoTab:CreateButton({
        Name = "Copy Link Discord",
        Callback = function()
            setclipboard("https://discord.gg/")
            AsuHub_UI.Rayfield:Notify({
                Title = "Discord", 
                Content = "Tautan disalin ke papan klip!", 
                Duration = 3, 
                Image = 7733964719
            })
        end,
    })
    
    InfoTab:CreateSection("Changelog")
    InfoTab:CreateParagraph({
        Title = "📢 Versi 1.2 (Palma RP Added)", 
        Content = "• Menambahkan Tab Palma RP\n• Fitur Auto Farm & Fish Palma RP\n• Fitur Auto Sell Palma RP (Custom Interval)\n• Fitur Teleport Toko Palma RP\n• Fitur Toggle Anti AFK Palma RP\n• Perbaikan fitur-fitur sebelumnya"
    })
    
    return InfoTab
end

function AsuHub_UI.CreatePlayerTab(Window)
    local PlayerTab = Window:CreateTab("Player", 4370318685)
    local Logic = getgenv().AsuHub_Logic
    
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
    
    -- Get default values
    local humanoid = Logic.player.Character and Logic.player.Character:FindFirstChild("Humanoid")
    local defaultWalkspeed = 16
    local defaultGravity = 196.2
    local defaultJumpHeight = 7.2
    local defaultJumpPower = 50
    
    if humanoid then
        defaultWalkspeed = humanoid.WalkSpeed
        defaultJumpHeight = humanoid.JumpHeight
        defaultJumpPower = humanoid.JumpPower
    end
    
    -- WalkSpeed Slider
    local walkspeedSlider = PlayerTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {1, 500},
        Increment = 1,
        Precision = 0,
        Suffix = "studs",
        CurrentValue = defaultWalkspeed,
        Flag = "WalkSpeed",
        Callback = function(value)
            if Logic.player.Character and Logic.player.Character:FindFirstChild("Humanoid") then
                Logic.player.Character.Humanoid.WalkSpeed = value
            end
        end,
    })
    
    -- Jump Slider
    local currentJumpValue = defaultJumpPower
    if humanoid and not humanoid.UseJumpPower then 
        currentJumpValue = defaultJumpHeight 
    end
    
    local jumpSlider = PlayerTab:CreateSlider({
        Name = "Jump (Height/Power)",
        Range = {1, 500},
        Increment = 1,
        Precision = 1,
        Suffix = "Value",
        CurrentValue = currentJumpValue,
        Flag = "JumpValue",
        Callback = function(value)
            if Logic.player.Character and Logic.player.Character:FindFirstChild("Humanoid") then
                local hum = Logic.player.Character.Humanoid
                if hum.UseJumpPower then
                    hum.JumpPower = value
                else
                    hum.JumpHeight = value
                end
            end
        end,
    })
    
    -- Gravity Slider
    local gravitySlider = PlayerTab:CreateSlider({
        Name = "Gravity",
        Range = {1, 500},
        Increment = 1,
        Precision = 1,
        Suffix = "gravity",
        CurrentValue = defaultGravity,
        Flag = "Gravity",
        Callback = function(value)
            Logic.Workspace.Gravity = value
        end,
    })
    
    -- Reset Button
    PlayerTab:CreateButton({
        Name = "Reset to Default",
        Callback = function()
            if Logic.player.Character and Logic.player.Character:FindFirstChild("Humanoid") then
                local hum = Logic.player.Character.Humanoid
                hum.WalkSpeed = defaultWalkspeed
                if hum.UseJumpPower then
                    hum.JumpPower = defaultJumpPower
                    jumpSlider:Set(defaultJumpPower)
                else
                    hum.JumpHeight = defaultJumpHeight
                    jumpSlider:Set(defaultJumpHeight)
                end
            end
            Logic.Workspace.Gravity = defaultGravity
            
            walkspeedSlider:Set(defaultWalkspeed)
            gravitySlider:Set(defaultGravity)
            
            AsuHub_UI.Rayfield:Notify({
                Title = "Reset", 
                Content = "Stats direset ke default.", 
                Duration = 2, 
                Image = 7733964719
            })
        end,
    })
    
    -- Movement Modes Section
    PlayerTab:CreateSection("Movement Modes")
    
    -- Infinite Jump Toggle
    PlayerTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJumpToggle",
        Callback = function(value)
            Logic.toggleInfiniteJump(value)
        end,
    })
    
    -- Fly Toggle
    AsuHub_UI.FlyToggleUI = PlayerTab:CreateToggle({
        Name = "Fly (Press V)",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(value)
            if value then
                if Logic.platformEnabled then 
                    -- Update UI Platform jika ada
                    if AsuHub_UI.PlatformToggleUI then 
                        AsuHub_UI.PlatformToggleUI:Set(false) 
                    end
                end
                Logic.startFly()
                AsuHub_UI.Rayfield:Notify({
                    Title = "Fly", 
                    Content = "Diaktifkan!", 
                    Duration = 2, 
                    Image = 7733964719
                })
            else
                Logic.stopFly()
                AsuHub_UI.Rayfield:Notify({
                    Title = "Fly", 
                    Content = "Dimatikan!", 
                    Duration = 2, 
                    Image = 7733964719
                })
            end
        end,
    })
    
    -- Fly Speed Slider
    PlayerTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 300},
        Increment = 1,
        Suffix = "speed",
        CurrentValue = 50,
        Callback = function(val) 
            Logic.flyBaseSpeed = val 
        end,
    })
    
    -- Platform Toggle
    AsuHub_UI.PlatformToggleUI = PlayerTab:CreateToggle({
        Name = "Spawn Platform",
        CurrentValue = false,
        Flag = "SpawnPlatformToggle",
        Callback = function(value)
            if value then
                if Logic.flyEnabled and AsuHub_UI.FlyToggleUI then 
                    AsuHub_UI.FlyToggleUI:Set(false) 
                end
                Logic.togglePlatform(value)
            else
                Logic.togglePlatform(value)
            end
        end,
    })
    
    -- Platform Speed Slider
    PlayerTab:CreateSlider({
        Name = "Platform Speed (Naik/Turun)",
        Range = {10, 150},
        Increment = 1,
        Suffix = "speed",
        CurrentValue = 25,
        Callback = function(val) 
            Logic.platformSpeed = val 
        end,
    })
    
    -- Character & Visuals Section
    PlayerTab:CreateSection("Character & Visuals")
    
    -- Noclip Toggle
    PlayerTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(value)
            Logic.toggleNoclip(value)
        end,
    })
    
    -- God Mode Toggle
    PlayerTab:CreateToggle({
        Name = "God Mode",
        CurrentValue = false,
        Flag = "GodModeToggle",
        Callback = function(value)
            Logic.toggleGodMode(value)
        end,
    })
    
    -- ESP Toggle
    PlayerTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "ESPToggle",
        Callback = function(value)
            if value then 
                Logic.startESP()
                AsuHub_UI.Rayfield:Notify({
                    Title = "Player ESP", 
                    Content = "Diaktifkan!", 
                    Duration = 2, 
                    Image = 7733964719
                })
            else 
                Logic.stopESP()
                AsuHub_UI.Rayfield:Notify({
                    Title = "Player ESP", 
                    Content = "Dimatikan!", 
                    Duration = 2, 
                    Image = 7733964719
                })
            end
        end,
    })
    
    -- Reset Character Button
    PlayerTab:CreateButton({
        Name = "Reset Character",
        Callback = function()
            if Logic.player.Character and Logic.player.Character:FindFirstChild("Humanoid") then
                Logic.player.Character.Humanoid.Health = 0
            end
        end,
    })
    
    -- Freecam Section
    PlayerTab:CreateSection("Freecam")
    
    -- Freecam Toggle
    AsuHub_UI.FreecamToggle = PlayerTab:CreateToggle({
        Name = "FreeCam (Shift + P)",
        CurrentValue = false,
        Flag = "FreecamToggle",
        Callback = function(value)
            Logic.toggleFreecam(value)
        end,
    })
    
    return PlayerTab
end

function AsuHub_UI.CreateTeleportTab(Window)
    local TeleportTab = Window:CreateTab("Teleport", 4370318685)
    local Logic = getgenv().AsuHub_Logic
    
    TeleportTab:CreateSection("Informasi")
    TeleportTab:CreateParagraph({
        Title = "Fitur Teleport", 
        Content = "untuk fitur Click to teleport, kamu tinggal Tahan Ctrl + Klik kiri."
    })
    
    TeleportTab:CreateSection("World Teleport")
    
    -- Click Teleport Toggle
    TeleportTab:CreateToggle({
        Name = "Click to Teleport",
        CurrentValue = false,
        Flag = "ClickTeleportToggle",
        Callback = function(value)
            Logic.toggleClickTeleport(value)
        end,
    })
    
    TeleportTab:CreateSection("Teleport to Player")
    
    -- Player selection variables
    AsuHub_UI.selectedTeleportPlayer = nil
    
    -- Search Input
    TeleportTab:CreateInput({
        Name = "Search Player",
        PlaceholderText = "Ketik nama pemain...",
        Flag = "TeleportSearch",
        Callback = function(searchText)
            local filteredList = {}
            local searchTextLower = string.lower(searchText)
            for _, formattedName in ipairs(Logic.getPlayerList()) do
                if string.find(string.lower(formattedName), searchTextLower) then
                    table.insert(filteredList, formattedName)
                end
            end
            if AsuHub_UI.TeleportPlayerDropdown then
                AsuHub_UI.TeleportPlayerDropdown:Refresh(filteredList, true)
            end
        end,
    })
    
    -- Player Dropdown
    AsuHub_UI.TeleportPlayerDropdown = TeleportTab:CreateDropdown({
        Name = "Select Player",
        Options = Logic.getPlayerList(),
        CurrentOption = {"None"},
        MultipleOptions = false,
        Flag = "TeleportPlayerDropdown",
        Callback = function(option)
            local realUsername = Logic.getUsernameFromString(option[1])
            AsuHub_UI.selectedTeleportPlayer = Logic.Players:FindFirstChild(realUsername)
            if AsuHub_UI.selectedTeleportPlayer then
                AsuHub_UI.Rayfield:Notify({
                    Title = "Pemain Terpilih", 
                    Content = "Target: " .. AsuHub_UI.selectedTeleportPlayer.DisplayName, 
                    Duration = 2, 
                    Image = 7733964719
                })
            end
        end,
    })
    table.insert(Logic.allPlayerDropdowns, AsuHub_UI.TeleportPlayerDropdown)
    
    -- Refresh Button
    TeleportTab:CreateButton({
        Name = "Refresh Player List",
        Callback = function()
            Logic.refreshAllPlayerDropdowns()
            AsuHub_UI.Rayfield:Notify({
                Title = "Refresh List", 
                Content = "List diperbarui!", 
                Duration = 2, 
                Image = 7733964719
            })
        end,
    })
    
    -- Teleport to Player Button
    TeleportTab:CreateButton({
        Name = "Teleport to Selected Player",
        Callback = function()
            if AsuHub_UI.selectedTeleportPlayer and AsuHub_UI.selectedTeleportPlayer.Character and AsuHub_UI.selectedTeleportPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = AsuHub_UI.selectedTeleportPlayer.Character.HumanoidRootPart.CFrame
                Logic.teleportCharacter(Logic.player.Character, targetPos.Position + Vector3.new(0, 3, 0))
                AsuHub_UI.Rayfield:Notify({
                    Title = "Teleport", 
                    Content = "Teleport ke " .. AsuHub_UI.selectedTeleportPlayer.DisplayName, 
                    Duration = 3, 
                    Image = 7733964719
                })
            else
                AsuHub_UI.Rayfield:Notify({
                    Title = "Error", 
                    Content = "Silakan pilih pemain yang valid", 
                    Duration = 3, 
                    Image = 7733964719
                })
            end
        end,
    })
    
    -- Spectate System
    AsuHub_UI.isSpectating = false
    AsuHub_UI.spectateConnection = nil
    
    AsuHub_UI.SpectateToggle = TeleportTab:CreateToggle({
        Name = "Spectate Selected Player",
        CurrentValue = false,
        Flag = "SpectateToggle",
        Callback = function(value)
            AsuHub_UI.isSpectating = value
            local camera = workspace.CurrentCamera
            
            if value then
                if not AsuHub_UI.selectedTeleportPlayer then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Pilih pemain dulu!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                    AsuHub_UI.isSpectating = false
                    if AsuHub_UI.SpectateToggle then 
                        AsuHub_UI.SpectateToggle:Set(false) 
                    end
                    return
                end

                if AsuHub_UI.spectateConnection then 
                    AsuHub_UI.spectateConnection:Disconnect() 
                end
                
                AsuHub_UI.Rayfield:Notify({
                    Title = "Spectate", 
                    Content = "Spectating " .. AsuHub_UI.selectedTeleportPlayer.DisplayName, 
                    Duration = 3, 
                    Image = 7733964719
                })
                
                AsuHub_UI.spectateConnection = Logic.TrackConn(Logic.RunService.Heartbeat:Connect(function()
                    if AsuHub_UI.isSpectating and AsuHub_UI.selectedTeleportPlayer and AsuHub_UI.selectedTeleportPlayer.Character and AsuHub_UI.selectedTeleportPlayer.Character:FindFirstChild("Humanoid") then
                        local humanoid = AsuHub_UI.selectedTeleportPlayer.Character.Humanoid
                        if camera.CameraSubject ~= humanoid then
                            camera.CameraSubject = humanoid
                            camera.CameraType = Enum.CameraType.Track
                        end
                    elseif AsuHub_UI.isSpectating and not AsuHub_UI.selectedTeleportPlayer then
                        AsuHub_UI.SpectateToggle:Set(false)
                    end
                end))
            else
                if AsuHub_UI.spectateConnection then 
                    AsuHub_UI.spectateConnection:Disconnect()
                    AsuHub_UI.spectateConnection = nil 
                end
                if Logic.player.Character and Logic.player.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = Logic.player.Character.Humanoid
                end
                camera.CameraType = Enum.CameraType.Custom
                AsuHub_UI.Rayfield:Notify({
                    Title = "Spectate", 
                    Content = "Berhenti spectating", 
                    Duration = 3, 
                    Image = 7733964719
                })
            end
        end,
    })
    
    return TeleportTab
end

function AsuHub_UI.CreateTrollingTab(Window)
    local TrollingTab = Window:CreateTab("Trolling", 4370318685)
    local Logic = getgenv().AsuHub_Logic
    
    TrollingTab:CreateSection("Informasi")
    TrollingTab:CreateParagraph({
        Title = "Fitur Trolling", 
        Content = "Hanya berfungsi di server dengan collision aktif."
    })
    
    TrollingTab:CreateSection("Kontrol Trolling")
    
    -- Player selection variables
    AsuHub_UI.selectedTrollingPlayer = nil
    
    -- Search Input
    TrollingTab:CreateInput({
        Name = "Search Player",
        PlaceholderText = "Ketik nama pemain...",
        Flag = "TrollingSearch",
        Callback = function(searchText)
            local filteredList = {}
            local searchTextLower = string.lower(searchText)
            for _, formattedName in ipairs(Logic.getPlayerList()) do
                if string.find(string.lower(formattedName), searchTextLower) then
                    table.insert(filteredList, formattedName)
                end
            end
            if AsuHub_UI.TrollingPlayerDropdown then
                AsuHub_UI.TrollingPlayerDropdown:Refresh(filteredList, true)
            end
        end,
    })
    
    -- Player Dropdown
    AsuHub_UI.TrollingPlayerDropdown = TrollingTab:CreateDropdown({
        Name = "Select Player",
        Options = Logic.getPlayerList(),
        CurrentOption = {"None"},
        MultipleOptions = false,
        Flag = "TrollingPlayerDropdown",
        Callback = function(option)
            local realUsername = Logic.getUsernameFromString(option[1])
            AsuHub_UI.selectedTrollingPlayer = Logic.Players:FindFirstChild(realUsername)
            
            if AsuHub_UI.selectedTrollingPlayer then
                AsuHub_UI.Rayfield:Notify({
                    Title = "Pemain Terpilih", 
                    Content = "Target: " .. AsuHub_UI.selectedTrollingPlayer.DisplayName, 
                    Duration = 2, 
                    Image = 7733964719
                })
            end
        end,
    })
    table.insert(Logic.allPlayerDropdowns, AsuHub_UI.TrollingPlayerDropdown)
    
    -- Refresh Button
    TrollingTab:CreateButton({
        Name = "Refresh Player List",
        Callback = function()
            Logic.refreshAllPlayerDropdowns()
            AsuHub_UI.Rayfield:Notify({
                Title = "Refresh List", 
                Content = "List diperbarui!", 
                Duration = 2, 
                Image = 7733964719
            })
        end,
    })
    
    -- Fling Button
    AsuHub_UI.flingDebounce = false
    
    TrollingTab:CreateButton({
        Name = "Fling Selected Player",
        Callback = function()
            if AsuHub_UI.flingDebounce then return end
            if not AsuHub_UI.selectedTrollingPlayer or not AsuHub_UI.selectedTrollingPlayer.Character then
                AsuHub_UI.Rayfield:Notify({
                    Title = "Error", 
                    Content = "Pilih pemain valid!", 
                    Duration = 3, 
                    Image = 7733964719
                })
                return
            end
            
            AsuHub_UI.flingDebounce = true
            AsuHub_UI.Rayfield:Notify({
                Title = "Fling", 
                Content = "Melempar " .. AsuHub_UI.selectedTrollingPlayer.DisplayName, 
                Duration = 3, 
                Image = 7733964719
            })
            
            task.spawn(function()
                pcall(function() 
                    Logic.SkidFling(AsuHub_UI.selectedTrollingPlayer) 
                end)
                task.wait(1)
                AsuHub_UI.flingDebounce = false
            end)
        end,
    })
    
    return TrollingTab
end

function AsuHub_UI.CreateAnimationTab(Window)
    local Logic = getgenv().AsuHub_Logic
    
    if Logic.isR15 and Logic.Animations ~= nil and game.PlaceId ~= 121864768012064 then
        local AnimationTab = Window:CreateTab("Animation", 4370318685)
        
        AnimationTab:CreateSection("Informasi")
        AnimationTab:CreateParagraph({
            Title = "Fitur Paket Animasi", 
            Content = "Sistem paket animasi khusus karakter R15. Animasi akan otomatis diterapkan saat memilih list dari dropdown."
        })
        
        -- Helper function to get animation names
        local function getAnimationNames(animType)
            local names = {}
            if Logic.Animations and Logic.Animations[animType] then 
                for name, _ in pairs(Logic.Animations[animType]) do
                    table.insert(names, name)
                end
            end
            table.sort(names)
            return names
        end

        local animationTypes = {"Idle", "Walk", "Run", "Jump", "Fall", "Swim", "SwimIdle", "Climb"}
        AsuHub_UI.animationDropdowns = {} 

        -- Search Input
        AnimationTab:CreateInput({
            Name = "Search Animation",
            PlaceholderText = "Cari nama animasi...",
            Flag = "AnimSearch",
            Callback = function(searchText)
                local searchTextLower = string.lower(searchText)
                for _, animType in ipairs(animationTypes) do
                    local dropdown = AsuHub_UI.animationDropdowns[animType]
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

        -- Create dropdowns for each animation type
        for _, animType in ipairs(animationTypes) do
            local animNames = getAnimationNames(animType)
            AsuHub_UI.animationDropdowns[animType] = AnimationTab:CreateDropdown({
                Name = animType,
                Options = animNames,
                CurrentOption = {"None"},
                MultipleOptions = false,
                Flag = "AnimDropdown_" .. animType,
                Callback = function(selectedName)
                    if not selectedName[1] or selectedName[1] == "None" then return end
                    if Logic.Animations and Logic.Animations[animType] and Logic.setAnimation then
                        local animId = Logic.Animations[animType][selectedName[1]]
                        if animId then
                            task.spawn(function()
                                Logic.setAnimation(animType, animId)
                                AsuHub_UI.Rayfield:Notify({ 
                                    Title = "Animasi", 
                                    Content = "Terpasang: " .. selectedName[1], 
                                    Duration = 2, 
                                    Image = 7733964719 
                                })
                            end)
                        end
                    end
                end,
            })
        end

        -- Reset Button
        AnimationTab:CreateButton({
            Name = "Reset to Default (Respawn)",
            Callback = function()
                if Logic.lastAnimations then
                    for k in pairs(Logic.lastAnimations) do
                        Logic.lastAnimations[k] = nil
                    end
                end

                pcall(function()
                    local HttpService = game:GetService("HttpService")
                    writefile("AsuHubAnimasiPack.json", HttpService:JSONEncode({}))
                end)

                local char = game:GetService("Players").LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = 0
                end
                
                AsuHub_UI.Rayfield:Notify({ 
                    Title = "Reset Sukses", 
                    Content = "Memori dibersihkan. Kembali ke animasi asli...", 
                    Duration = 3, 
                    Image = 7733964719 
                })
            end
        })
        
        -- Load saved animations
        task.wait(1)
        if Logic.loadLastAnimations then 
            Logic.loadLastAnimations() 
        end
        
        return AnimationTab
    end
    return nil
end

function AsuHub_UI.CreateEmoteTab(Window)
    local Logic = getgenv().AsuHub_Logic
    
    if Logic.isR15 and Logic.Animations ~= nil and game.PlaceId ~= 121864768012064 then
        local EmoteTab = Window:CreateTab("Emote", 4370318685)

        EmoteTab:CreateSection("Informasi")
        EmoteTab:CreateParagraph({
            Title = "Fitur Emote", 
            Content = "dapat menggunakan seluruh Emote/Dance yang ada di Marketplace Roblox | dengan command (.)"
        })

        EmoteTab:CreateButton({
            Name = "Load Custom Emote Menu",
            Callback = function()
                local scriptContent
                local downloadSuccess, downloadResult = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/ozaghazali/YoguruttoHub/refs/heads/main/LoadEmote.lua")
                
                if not downloadSuccess then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Gagal mengunduh skrip: " .. (downloadResult or "Kesalahan tidak diketahui"), 
                        Duration = 5, 
                        Image = 7733964719
                    })
                    return
                end
                scriptContent = downloadResult
                
                local compiledFunc, compileError = (getgenv().loadstring or loadstring)(scriptContent)
                
                if not compiledFunc then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Gagal mengkompilasi skrip: " .. (compileError or "Kesalahan tidak diketahui"), 
                        Duration = 5, 
                        Image = 7733964719
                    })
                    return
                end
                
                AsuHub_UI.Rayfield:Notify({
                    Title = "Emote", 
                    Content = "Menu emote telah dimuat!", 
                    Duration = 3, 
                    Image = 7733964719
                })
                
                local execSuccess, execError = pcall(compiledFunc)
                if not execSuccess then
                    warn("Kesalahan Eksekusi Emote AsuHub (tapi menu mungkin dimuat):", execError)
                end
            end,
        })

        return EmoteTab
    end
    return nil
end

function AsuHub_UI.CreateCopyAvatarTab(Window)
    local Logic = getgenv().AsuHub_Logic
    
    if Logic.isR15 and Logic.Animations ~= nil and game.PlaceId ~= 121864768012064 then
        local MorphingTab = Window:CreateTab("Copy Avatar", 4370318685)

        MorphingTab:CreateSection("Informasi")
        MorphingTab:CreateParagraph({
            Title = "Fitur Copy Avatar", 
            Content = "Hanya berfungsi pada server dengan Plugin Popmall/Catalog."
        })

        MorphingTab:CreateSection("Kontrol Avatar Copy")

        -- Player selection variables
        AsuHub_UI.selectedMorphPlayer = nil

        -- Search Input
        MorphingTab:CreateInput({
            Name = "Search Player",
            PlaceholderText = "Ketik nama pemain...",
            Flag = "MorphSearch",
            Callback = function(searchText)
                local filteredList = {}
                local searchTextLower = string.lower(searchText)
                for _, formattedName in ipairs(Logic.getPlayerList()) do
                    if string.find(string.lower(formattedName), searchTextLower) then
                        table.insert(filteredList, formattedName)
                    end
                end
                if AsuHub_UI.MorphPlayerDropdown then
                    AsuHub_UI.MorphPlayerDropdown:Refresh(filteredList, true)
                end
            end,
        })

        -- Player Dropdown
        AsuHub_UI.MorphPlayerDropdown = MorphingTab:CreateDropdown({
            Name = "Select Player",
            Options = Logic.getPlayerList(),
            CurrentOption = {"None"},
            MultipleOptions = false,
            Flag = "MorphPlayerDropdown",
            Callback = function(option)
                local realUsername = Logic.getUsernameFromString(option[1])
                AsuHub_UI.selectedMorphPlayer = Logic.Players:FindFirstChild(realUsername)
                
                if AsuHub_UI.selectedMorphPlayer then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Pemain Terpilih", 
                        Content = "Target: " .. AsuHub_UI.selectedMorphPlayer.DisplayName, 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })
        table.insert(Logic.allPlayerDropdowns, AsuHub_UI.MorphPlayerDropdown)

        -- Refresh Button
        MorphingTab:CreateButton({
            Name = "Refresh Player List",
            Callback = function()
                Logic.refreshAllPlayerDropdowns()
                AsuHub_UI.Rayfield:Notify({
                    Title = "Refresh List", 
                    Content = "List diperbarui!", 
                    Duration = 2, 
                    Image = 7733964719
                })
            end,
        })

        -- Copy Current Avatar Button
        MorphingTab:CreateButton({
            Name = "Copy Current Avatar",
            Callback = function()
                if not AsuHub_UI.selectedMorphPlayer or not AsuHub_UI.selectedMorphPlayer.Character then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Pilih pemain dulu!", 
                        Duration = 5, 
                        Image = 7733964719
                    })
                    return
                end

                local targetCharacter = AsuHub_UI.selectedMorphPlayer.Character
                local targetName = AsuHub_UI.selectedMorphPlayer.Name
                
                task.spawn(function()
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Copy Avatar", 
                        Content = "Menyalin dari " .. AsuHub_UI.selectedMorphPlayer.DisplayName .. "...", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                    
                    -- Copy avatar logic would go here
                    -- ... (kode copy avatar dari script asli)
                end)
            end,
        })

        -- Copy Original Avatar Button
        MorphingTab:CreateButton({
            Name = "Copy Original Avatar",
            Callback = function()
                if not AsuHub_UI.selectedMorphPlayer or not AsuHub_UI.selectedMorphPlayer.Character then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Pilih pemain yang valid dari menu dropdown!", 
                        Duration = 5, 
                        Image = 7733964719
                    })
                    return
                end

                local targetUserId = AsuHub_UI.selectedMorphPlayer.UserId
                local targetName = AsuHub_UI.selectedMorphPlayer.Name
                
                task.spawn(function()
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Copy Avatar", 
                        Content = "Mengambil data untuk " .. targetName .. "...", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                    
                    -- Copy original avatar logic would go here
                    -- ... (kode copy original avatar dari script asli)
                end)
            end,
        })

        -- Reset Avatar Button
        MorphingTab:CreateButton({
            Name = "Reset to Default Avatar",
            Callback = function()
                task.spawn(function()
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Reset", 
                        Content = "Mereset avatar ke default...", 
                        Duration = 3, 
                        Image = 7733964719
                    })

                    -- Reset avatar logic would go here
                    -- ... (kode reset avatar dari script asli)
                end)
            end
        })

        return MorphingTab
    end
    return nil
end

function AsuHub_UI.CreatePalmaRPTab(Window)
    local Logic = getgenv().AsuHub_Logic
    
    if game.PlaceId == Logic.PalmaRP_PlaceID or Logic.ReplicatedStorage:FindFirstChild("JualIkanRemote") then
        local PalmaRPTab = Window:CreateTab("Palma RP", 4370318685)

        PalmaRPTab:CreateSection("Info")
        PalmaRPTab:CreateParagraph({
            Title = "Fitur Palma RP", 
            Content = "Jika ingin menggunakan fitur Auto Farm ikuti langkah berikut:\n1. Ditahap awal kamu harus memancing seperti biasa terlebih dahulu sampai mendapatkan ikan\n2. Lalu setelah itu kamu bisa aktifkan auto farm."
        })

        PalmaRPTab:CreateSection("Kontrol Farm")

        -- Anti AFK Toggle
        PalmaRPTab:CreateToggle({
            Name = "Anti AFK",
            CurrentValue = false,
            Flag = "PalmaRPAntiAFK",
            Callback = function(val)
                Logic.antiAFKEnabled = val
                if val then
                    if Logic.antiAFKConnection then 
                        Logic.antiAFKConnection:Disconnect() 
                    end
                    
                    Logic.antiAFKConnection = Logic.TrackConn(Logic.player.Idled:Connect(function()
                        local vuSuccess, VirtualUser = pcall(function() 
                            return game:GetService("VirtualUser") 
                        end)
                        if vuSuccess and VirtualUser then
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                        else
                            local vim = game:GetService("VirtualInputManager")
                            if vim then
                                vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                task.wait()
                                vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                            end
                        end
                    end))
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Anti AFK", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    if Logic.antiAFKConnection then 
                        Logic.antiAFKConnection:Disconnect() 
                        Logic.antiAFKConnection = nil
                    end
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Anti AFK", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end
        })

        -- Auto Farm Toggle
        PalmaRPTab:CreateToggle({
            Name = "Auto Farm Fish & TP",
            CurrentValue = false,
            Flag = "PalmaRPFarm",
            Callback = function(val)
                Logic.bulkFishEnabled = val
                
                if val then
                    local char = Logic.player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.new(10979.3564453125, 356.204345703125, 2611.142822265625)
                    end
                    
                    task.wait(1)
                    
                    task.spawn(function()
                        while Logic.bulkFishEnabled do
                            if Logic.SessionStop then break end
                            pcall(function()
                                local char = Logic.player.Character
                                local rod = char and char:FindFirstChild("StarRod")
                                
                                if rod then
                                    for i = 1, 50 do
                                        rod.MiniGame:FireServer("Complete")
                                    end
                                else
                                    if Logic.player.Backpack:FindFirstChild("StarRod") then
                                        Logic.player.Character.Humanoid:EquipTool(Logic.player.Backpack.StarRod)
                                    end
                                end
                            end)
                            task.wait(0.2)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Farm", 
                        Content = "Diaktifkan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Farm", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end
        })

        -- Auto Sell System
        PalmaRPTab:CreateInput({
            Name = "Auto Sell Interval (Detik)",
            PlaceholderText = "Default: 1",
            NumbersOnly = true, 
            OnEnter = true, 
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                local num = tonumber(text)
                if num and num > 0 then
                    Logic.autoSellInterval = num
                else
                    Logic.autoSellInterval = 1
                end
            end
        })
        
        PalmaRPTab:CreateToggle({
            Name = "Auto Sell",
            CurrentValue = false,
            Flag = "PalmaRPSell",
            Callback = function(val)
                Logic.autoSellEnabled = val
                if val then
                    task.spawn(function()
                        while Logic.autoSellEnabled do
                            if Logic.SessionStop then break end
                            pcall(function()
                                local remote = Logic.ReplicatedStorage:FindFirstChild("JualIkanRemote")
                                if remote then 
                                    remote:FireServer("All") 
                                end
                            end)
                            task.wait(Logic.autoSellInterval)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Sell", 
                        Content = "Diaktifkan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Sell", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end
        })

        -- Teleport to Shop Button
        PalmaRPTab:CreateButton({
            Name = "Teleport ke Toko",
            Callback = function()
                if Logic.player.Character and Logic.player.Character:FindFirstChild("HumanoidRootPart") then
                    Logic.player.Character.HumanoidRootPart.CFrame = CFrame.new(6367.62890625, 118.17733001708984, 183.94854736328125)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Teleport", 
                        Content = "Teleportasi ke Toko...", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end
        })

        -- Carton Farming Section
        PalmaRPTab:CreateSection("Farming Carton (Kardus)")
        
        PalmaRPTab:CreateToggle({
            Name = "Auto Farm Carton (Pickup & Unpack)",
            CurrentValue = false,
            Flag = "PalmaRPAutoCarton",
            Callback = function(val)
                Logic.autoCartonEnabled = val
                if val then
                    task.spawn(function()
                        while Logic.autoCartonEnabled do
                            if Logic.SessionStop then break end
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestPickup"):FireServer()
                                task.wait(0.1)
                                local args = {1, 2}
                                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestUnpack"):FireServer(unpack(args))
                            end)
                            task.wait(0.5)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Carton", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Carton", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end
        })

        PalmaRPTab:CreateToggle({
            Name = "Auto Sell Carton",
            CurrentValue = false,
            Flag = "PalmaRPAutoSellCarton",
            Callback = function(val)
                Logic.autoSellCartonEnabled = val
                if val then
                    task.spawn(function()
                        while Logic.autoSellCartonEnabled do
                            pcall(function()
                                local args = {"All"}
                                game:GetService("ReplicatedStorage"):WaitForChild("JualCartonRemote"):FireServer(unpack(args))
                            end)
                            task.wait(Logic.autoSellInterval)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Sell Carton", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Sell Carton", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end
        })

        -- Needs Section
        PalmaRPTab:CreateSection("Kebutuhan (Auto Needs)")

        -- Auto Eat
        PalmaRPTab:CreateInput({
            Name = "Auto Eat Interval (Detik)",
            PlaceholderText = "Default: 3",
            NumbersOnly = true, 
            OnEnter = true, 
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                local num = tonumber(text)
                if num and num > 0 then
                    Logic.autoEatInterval = num
                else
                    Logic.autoEatInterval = 3
                end
            end
        })

        PalmaRPTab:CreateToggle({
            Name = "Auto Eat (Makan)",
            CurrentValue = false,
            Flag = "PalmaRPAutoEat",
            Callback = function(val)
                Logic.autoEatEnabled = val
                if val then
                    task.spawn(function()
                        while Logic.autoEatEnabled do
                            pcall(function()
                                local args = { 100 }
                                game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("EatFoodEvent"):FireServer(unpack(args))
                            end)
                            task.wait(Logic.autoEatInterval)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Eat", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Eat", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Auto Drink
        PalmaRPTab:CreateInput({
            Name = "Auto Drink Interval (Detik)",
            PlaceholderText = "Default: 3",
            NumbersOnly = true, 
            OnEnter = true, 
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                local num = tonumber(text)
                if num and num > 0 then
                    Logic.autoDrinkInterval = num
                else
                    Logic.autoDrinkInterval = 3
                end
            end
        })

        PalmaRPTab:CreateToggle({
            Name = "Auto Drink (Minum)",
            CurrentValue = false,
            Flag = "PalmaRPAutoDrink",
            Callback = function(val)
                Logic.autoDrinkEnabled = val
                if val then
                    task.spawn(function()
                        while Logic.autoDrinkEnabled do
                            pcall(function()
                                local args = { 100 }
                                game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("DrinkEvent"):FireServer(unpack(args))
                            end)
                            task.wait(Logic.autoDrinkInterval)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Drink", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Drink", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })
        
        return PalmaRPTab
    end
    return nil
end

function AsuHub_UI.CreateFishItTab(Window)
    local Logic = getgenv().AsuHub_Logic
    
    if game.PlaceId == Logic.FishIt_PlaceID then
        local FishItTab = Window:CreateTab("Fish It", 4370318685)

        FishItTab:CreateSection("Info")
        FishItTab:CreateParagraph({
            Title = "Fitur Fish It", 
            Content = "Fitur khusus game Fish It. Menu ini hanya muncul saat bermain Fish It."
        })

        -- Teleport Locations Section
        FishItTab:CreateSection("Teleport Locations")
        
        -- Helper untuk mengambil semua nama lokasi
        local function getAllLocationNames()
            local names = {}
            for name, _ in pairs(Logic.FISHIT_LOCATIONS) do
                table.insert(names, name)
            end
            table.sort(names)
            return names
        end

        -- Variabel untuk menyimpan lokasi terakhir
        AsuHub_UI.LastSelectedLocation = nil 

        -- Search Input
        FishItTab:CreateInput({
            Name = "Search lokasi",
            PlaceholderText = "Ketik nama lokasi...",
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                local filtered = {}
                local textLower = string.lower(text)
                for name, _ in pairs(Logic.FISHIT_LOCATIONS) do
                    if string.find(string.lower(name), textLower) then
                        table.insert(filtered, name)
                    end
                end
                table.sort(filtered)
                if AsuHub_UI.TeleportDropdown then 
                    AsuHub_UI.TeleportDropdown:Refresh(filtered, true) 
                end
            end,
        })

        -- Location Dropdown
        AsuHub_UI.TeleportDropdown = FishItTab:CreateDropdown({
            Name = "Pilih Lokasi",
            Options = getAllLocationNames(),
            CurrentOption = {"None"},
            MultipleOptions = false,
            Flag = "FishItTeleportDropdown",
            Callback = function(option)
                local locName = option[1]
                if locName and Logic.FISHIT_LOCATIONS[locName] then
                    AsuHub_UI.LastSelectedLocation = locName
                    
                    if Logic.player.Character and Logic.player.Character:FindFirstChild("HumanoidRootPart") then
                        Logic.player.Character.HumanoidRootPart.CFrame = Logic.FISHIT_LOCATIONS[locName]
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Teleport", 
                            Content = "Ke: " .. locName, 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    end
                end
            end,
        })

        -- Re-teleport Button
        FishItTab:CreateButton({
            Name = "Teleport Back (Ke Lokasi Terpilih)",
            Callback = function()
                if AsuHub_UI.LastSelectedLocation and Logic.FISHIT_LOCATIONS[AsuHub_UI.LastSelectedLocation] then
                    if Logic.player.Character and Logic.player.Character:FindFirstChild("HumanoidRootPart") then
                        Logic.player.Character.HumanoidRootPart.CFrame = Logic.FISHIT_LOCATIONS[AsuHub_UI.LastSelectedLocation]
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Teleport Back", 
                            Content = "Kembali ke: " .. AsuHub_UI.LastSelectedLocation, 
                            Duration = 1, 
                            Image = 7733964719
                        })
                    end
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Belum ada lokasi yang dipilih di Dropdown!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Automation Section
        FishItTab:CreateSection("Automation")

        -- Auto Fishing Toggle
        FishItTab:CreateToggle({
            Name = "Auto Fishing",
            CurrentValue = false,
            Flag = "FishItNativeAutoFish",
            Callback = function(value)
                local success, remote = pcall(function()
                    return game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateAutoFishingState"]
                end)
                
                if success and remote then
                    task.spawn(function() 
                        remote:InvokeServer(value) 
                    end)
                    if value then
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Auto Fish", 
                            Content = "Diaktifkan!", 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    else
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Auto Fish", 
                            Content = "Dimatikan!", 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    end
                end
            end,
        })

        -- Fast Reel Toggle
        FishItTab:CreateToggle({
            Name = "Fast Reel",
            CurrentValue = false,
            Flag = "FishItFastReel",
            Callback = function(value)
                Logic.FastReelEnabled = value
                if value then
                    task.spawn(function()
                        while Logic.FastReelEnabled do
                            if Logic.SessionStop then break end
                            local pGui = Logic.player:FindFirstChild("PlayerGui")
                            local fishingGui = pGui and pGui:FindFirstChild("Fishing")
                            
                            if fishingGui and fishingGui.Enabled then
                                local mainFrame = fishingGui:FindFirstChild("Main")
                                
                                if mainFrame and mainFrame.Position.Y.Scale < 1.2 then
                                    Logic.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.ButtonR2, false, game)
                                    task.wait(0.01) 
                                    Logic.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.ButtonR2, false, game)
                                    
                                    task.wait(Logic.ReelSpeed) 
                                else
                                    task.wait(0.2)
                                end
                            else
                                task.wait(0.2)
                            end
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Fast Reel", 
                        Content = "Diaktifkan! Deteksi Layar...", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Fast Reel", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Reel Speed Slider
        FishItTab:CreateSlider({
            Name = "Reel Speed (Detik)",
            Range = {0.05, 0.5}, 
            Increment = 0.1,
            Suffix = "s",
            CurrentValue = 0.1,
            Flag = "FishItReelSpeed",
            Callback = function(value)
                Logic.ReelSpeed = value
            end,
        })

        -- Utility & Visuals Section
        FishItTab:CreateSection("Utility & Visuals")

        -- Auto Equip Rod Toggle
        FishItTab:CreateToggle({
            Name = "Auto Equip Rod",
            CurrentValue = false,
            Flag = "FishItAutoEquip",
            Callback = function(value)
                Logic.AutoEquipEnabled = value
                if value then
                    task.spawn(function()
                        while Logic.AutoEquipEnabled do
                            if Logic.SessionStop then break end
                            if Logic.player.Character then
                                local tool = Logic.player.Character:FindFirstChildWhichIsA("Tool")
                                
                                if not tool or (tool and not string.find(tool.Name, "Rod")) then
                                    local remote = Logic.getEquipRemote()
                                    if remote then
                                        pcall(function() 
                                            remote:FireServer(1) 
                                        end)
                                    end
                                    task.wait(0.25)
                                end
                            end
                            task.wait(0.1)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Equip", 
                        Content = "Diaktifkan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Equip", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Diving Gear Toggle
        FishItTab:CreateToggle({
            Name = "Auto Equip Diving Gear",
            CurrentValue = false,
            Flag = "FishItDivingGear",
            Callback = function(value)
                local data = Logic.getDivingRemotes()
                if value then
                    if data and data.Equip and data.ItemData then
                        pcall(function() 
                            data.Equip:InvokeServer(data.ItemData.Data.Id) 
                        end)
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Diving Gear", 
                            Content = "Equipped!", 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    end
                else
                    if data and data.Unequip then
                        pcall(function() 
                            data.Unequip:InvokeServer() 
                        end)
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Diving Gear", 
                            Content = "Unequipped!", 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    end
                end
            end,
        })

        -- Radar Bypass Toggle
        FishItTab:CreateToggle({
            Name = "Bypass Fishing Radar",
            CurrentValue = false,
            Flag = "FishItRadarBypass",
            Callback = function(value)
                local remote = Logic.getRadarRemoteDirect()
                if remote then
                    task.spawn(function() 
                        pcall(function() 
                            remote:InvokeServer(value) 
                        end) 
                    end)
                    if value then
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Bypass Radar", 
                            Content = "Diaktifkan!", 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    else
                        AsuHub_UI.Rayfield:Notify({
                            Title = "Bypass Radar", 
                            Content = "Dimatikan!", 
                            Duration = 2, 
                            Image = 7733964719
                        })
                    end
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Remote Radar tidak ditemukan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Merchant Section
        FishItTab:CreateSection("Merchant")

        FishItTab:CreateButton({
            Name = "Open/Close Merchant GUI",
            Callback = function()
                local merchantGui = Logic.player.PlayerGui:FindFirstChild("Merchant")
                if merchantGui then
                    merchantGui.Enabled = not merchantGui.Enabled
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Merchant", 
                        Content = merchantGui.Enabled and "Dibuka!" or "Ditutup!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Error", 
                        Content = "Merchant GUI tidak ditemukan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Selling System Section
        FishItTab:CreateSection("Selling System")

        -- Manual Sell Button
        FishItTab:CreateButton({
            Name = "Jual Semua Ikan (Manual)",
            Callback = function()
                local remote = Logic.getSellRemote()
                if remote then 
                    remote:InvokeServer() 
                end
                AsuHub_UI.Rayfield:Notify({
                    Title = "Menjual", 
                    Content = "Semua ikan terjual!", 
                    Duration = 2, 
                    Image = 7733964719
                })
            end,
        })

        -- Auto Sell Toggle
        FishItTab:CreateToggle({
            Name = "Auto Sell",
            CurrentValue = false,
            Flag = "FishItAutoSell",
            Callback = function(value)
                Logic.FishIt_AutoSell = value
                if value then
                    task.spawn(function()
                        while Logic.FishIt_AutoSell do
                            local remote = Logic.getSellRemote()
                            if remote then 
                                pcall(function() 
                                    remote:InvokeServer() 
                                end) 
                            end
                            task.wait(Logic.FishIt_SellDelay)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Sell", 
                        Content = "Diaktifkan! Detik: " .. Logic.FishIt_SellDelay .. "s", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Sell", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Auto Sell Delay Input
        FishItTab:CreateInput({
            Name = "Auto Sell (Detik)",
            PlaceholderText = "Default: 30",
            NumbersOnly = true,
            OnEnter = true,
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                local num = tonumber(text)
                if num and num >= 1 then
                    Logic.FishIt_SellDelay = num
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Delay", 
                        Content = "Diperbarui ke: " .. num .. "Detik", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Weather Machine Section
        FishItTab:CreateSection("Weather Machine")

        -- Weather Dropdown
        local WeatherDropdown = FishItTab:CreateDropdown({
            Name = "Pilih Cuaca (Multiple)",
            Options = Logic.WeatherList or {},
            CurrentOption = {}, 
            MultipleOptions = true,
            Flag = "WeatherDropdownMulti",
            Callback = function(options)
                local cleanList = {}
                for _, opt in ipairs(options) do
                    table.insert(cleanList, Logic.getRealName(opt))
                end
                Logic.SelectedWeathers = cleanList
            end,
        })

        -- Buy Weather Button
        FishItTab:CreateButton({
            Name = "Beli Semua Cuaca Yang Dipilih",
            Callback = function()
                if #Logic.SelectedWeathers == 0 then return end
                local remote = Logic.getWeatherRemote()
                if remote then
                    for _, weatherName in ipairs(Logic.SelectedWeathers) do
                        task.spawn(function() 
                            pcall(function() 
                                remote:InvokeServer(weatherName) 
                            end) 
                        end)
                    end
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Membeli", 
                        Content = "Semua cuaca terbeli!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Auto Buy Weather Toggle
        FishItTab:CreateToggle({
            Name = "Auto Beli Cuaca",
            CurrentValue = false,
            Flag = "FishItAutoBuyWeather",
            Callback = function(value)
                Logic.AutoBuyWeather = value
                if value then
                    task.spawn(function()
                        while Logic.AutoBuyWeather do
                            -- Auto buy weather logic would go here
                            task.wait(1)
                        end
                    end)
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Beli Cuaca", 
                        Content = "Diaktifkan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Beli Cuaca", 
                        Content = "Dimatikan!", 
                        Duration = 3, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Protection Section
        FishItTab:CreateSection("Protection")

        -- Info Dashboard
        local InfoParagraph = FishItTab:CreateParagraph({
            Title = "Detector Stuck Info",
            Content = "Status: Detector Offline\nTime: 0.0s"
        })

        -- Anti Stuck Toggle
        FishItTab:CreateToggle({
            Name = "Anti Stuck",
            CurrentValue = false,
            Flag = "FishItAntiStuck",
            Callback = function(value)
                Logic.AntiStuckEnabled = value
                
                if value then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Anti Stuck", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                    
                    -- Anti-stuck logic would be implemented here
                else
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Anti Stuck", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Stuck Time Slider
        FishItTab:CreateSlider({
            Name = "Batas Waktu Stuck",
            Range = {5, 30},
            Increment = 1,
            Suffix = "s",
            CurrentValue = 15,
            Flag = "FishItStuckTime",
            Callback = function(value)
                Logic.CurrentStuckLimit = value
                InfoParagraph:Set({
                    Title = "Detector Stuck Info", 
                    Content = "Status: Setting Updated\nLimit: " .. value .. "s"
                })
            end,
        })

        -- Anti AFK Toggle
        FishItTab:CreateToggle({
            Name = "Anti AFK",
            CurrentValue = false,
            Flag = "FishItAntiAFK",
            Callback = function(value)
                Logic.FishIt_AntiAFK = value
                if value then
                    Logic.FishIt_AFKConnection = Logic.TrackConn(Logic.player.Idled:Connect(function()
                        if game:GetService("VirtualUser") then
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                        end
                    end))
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Anti AFK", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                else
                    if Logic.FishIt_AFKConnection then 
                        Logic.FishIt_AFKConnection:Disconnect() 
                    end
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Anti AFK", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })
        
        return FishItTab
    end
    return nil
end

function AsuHub_UI.CreateAutoObbyTab(Window)
    local Logic = getgenv().AsuHub_Logic
    
    if game.PlaceId == Logic.Obby_PlaceID then
        local ObbyTab = Window:CreateTab("Auto Obby", 4370318685)

        ObbyTab:CreateSection("Informasi")
        ObbyTab:CreateParagraph({
            Title = "Fitur Auto Obby (Free UGC Obby)",
            Content = "\nlangkah-langkah untuk menggunakan fitur ini yaitu :\n1. Atur Kecepatan Terbang (default lebih baik)\n2. Isi Mulai dari Stage dengan format angka\n3. Pastikan Godmode Dihidupkan pada Menu Player\n4. Aktifkan Auto Obby, Selesai."
        })

        ObbyTab:CreateSection("Kontrol Auto Obby")

        -- Speed Slider
        ObbyTab:CreateSlider({
            Name = "Kecepatan Terbang (Studs/s)",
            Range = {50, 300},
            Increment = 10,
            Suffix = "spd",
            CurrentValue = 100,
            Flag = "ObbySpeedSlider",
            Callback = function(Value)
                Logic.TravelSpeed = Value
            end,
        })

        -- Start Stage Input
        ObbyTab:CreateInput({
            Name = "Mulai dari Stage (Angka)",
            PlaceholderText = "Contoh: 1",
            NumbersOnly = true,
            OnEnter = true,
            RemoveTextAfterFocusLost = false,
            Callback = function(Text)
                local num = tonumber(Text)
                if num and num >= 1 then
                    Logic.InitialStartStage = num
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Setting", 
                        Content = "Stage diubah ke: " .. num, 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })

        -- Auto Obby Toggle
        AsuHub_UI.ObbyAutoToggle = ObbyTab:CreateToggle({
            Name = "Auto Obby",
            CurrentValue = false,
            Flag = "AutoObbyToggle",
            Callback = function(Value)
                Logic.AutoObbyEnabled = Value

                if Value then
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Obby", 
                        Content = "Diaktifkan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                    -- Auto obby logic would start here
                else
                    Logic.AutoObbyEnabled = false
                    AsuHub_UI.Rayfield:Notify({
                        Title = "Auto Obby", 
                        Content = "Dimatikan!", 
                        Duration = 2, 
                        Image = 7733964719
                    })
                end
            end,
        })
        
        return ObbyTab
    end
    return nil
end

function AsuHub_UI.InitializeAllTabs()
    local Window = AsuHub_UI.CreateMainWindow()
    
    -- Create all tabs
    AsuHub_UI.CreateInformationTab(Window)
    AsuHub_UI.CreatePlayerTab(Window)
    AsuHub_UI.CreateTeleportTab(Window)
    AsuHub_UI.CreateTrollingTab(Window)
    
    -- Conditional tabs
    local animationTab = AsuHub_UI.CreateAnimationTab(Window)
    local emoteTab = AsuHub_UI.CreateEmoteTab(Window)
    local copyAvatarTab = AsuHub_UI.CreateCopyAvatarTab(Window)
    local palmaRPTab = AsuHub_UI.CreatePalmaRPTab(Window)
    local fishItTab = AsuHub_UI.CreateFishItTab(Window)
    local autoObbyTab = AsuHub_UI.CreateAutoObbyTab(Window)
    
    -- Success notification
    AsuHub_UI.Rayfield:Notify({
        Title = "AsuHub Loaded", 
        Content = "Semua tab berhasil dimuat!", 
        Duration = 3, 
        Image = 7733964719
    })
    
    return true
end

return AsuHub_UI
