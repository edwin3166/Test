-- Server Hop simple (sin interfaz)
-- Se ejecuta solo y te teletransporta

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local MAX_PLAYERS = 1 -- Cambia este número si quieres (1 = servidores con 1 persona o menos)

local function getRandomServer()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, raw = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not ok or not raw or raw == "" then
        return nil
    end

    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or not data or not data.data or #data.data == 0 then
        return nil
    end

    local currentId = tostring(game.JobId)
    local candidates = {}

    for _, s in ipairs(data.data) do
        if s.id and tostring(s.id) ~= currentId and (s.playing or 0) <= MAX_PLAYERS then
            table.insert(candidates, tostring(s.id))
        end
    end

    if #candidates == 0 then
        return nil
    end

    return candidates[math.random(1, #candidates)]
end

local function hop()
    local currentCount = #Players:GetPlayers()

    if currentCount <= MAX_PLAYERS then
        print("Ya estás en un server con " .. currentCount .. " player(s). No se hace hop.")
        return
    end

    print("Buscando server con " .. MAX_PLAYERS .. " player(s) o menos...")

    local serverId = getRandomServer()
    
    if not serverId then
        print("No se encontró ningún server con pocos jugadores.")
        return
    end

    print("Teleportando...")

    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
    end)

    if not ok then
        print("Error al teleportar:", err)
    end
end

-- Ejecutar el hop
hop()
