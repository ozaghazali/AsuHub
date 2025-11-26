-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Export to global if needed
getgenv().Rayfield = Rayfield

-- Current Place ID (for game-specific checks)
local CurrentPlaceId = game.PlaceId

-- Game ID constants (from your original script)
local GAME_ID_MIKA    = 18304551777
local GAME_ID_GEMI    = 177882408
local GAME_ID_BEAJA   = 140042712387550
local GAME_ID_MAAF    = 137711865214502
local GAME_ID_KOTA    = 108523862114142
local GAME_ID_YAHAYUK = 76964310785698
local GAME_ID_DAUN    = 102234703920418
local GAME_ID_KOHARU  = 94261028489288

local function isCurrentGame(targetId)
    return CurrentPlaceId == targetId
end

-- Load Core.lua first (replace with your GitHub raw URL)
loadstring(game:HttpGet("https://raw.githubusercontent.com/ozaghazali/AsuHub/refs/heads/main/AsuHub_Core.lua"))()

-- Wait briefly to ensure Core is fully loaded and player is ready
task.wait(0.5)

-- Load UI.lua next (replace with your GitHub raw URL)
loadstring(game:HttpGet("https://raw.githubusercontent.com/ozaghazali/AsuHub/refs/heads/main/AsuHub_UI.lua"))()
