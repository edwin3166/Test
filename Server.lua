--!strict
-- Server Hop avanzado (sin interfaz)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ===== Configuración =====
local CONFIG = {
    MAX_PLAYERS = 1,
    MAX_PAGES = 8,
    MAX_HTTP_RETRIES = 4,
    BASE_DELAY = 1.5,
    MAX_DELAY = 20,          -- techo del backoff exponencial
    HOP_RETRY_DELAY = 5,
    MAX_HOP_ATTEMPTS = 0,    -- 0 = infinito
    MIN_REQUEST_GAP = 1.2,   -- separación mínima entre requests HTTP (rate limit propio)
}

-- ===== Estado =====
local isTeleporting = false
local triedServers: {[string]: boolean} = {}
local lastRequestTime = 0

-- ===== Utilidades =====
local function throttledWait()
    local elapsed = os.clock() - lastRequestTime
    if elapsed < CONFIG.MIN_REQUEST_GAP then
        task.wait(CONFIG.MIN_REQUEST_GAP - elapsed)
    end
    lastRequestTime = os.clock()
end

local function httpGetWithRetry(url: string): any?
    for attempt = 1, CONFIG.MAX_HTTP_RETRIES do
        throttledWait()

        local ok, raw = pcall(function()
            return game:HttpGet(url)
        end)

        if ok and raw and raw ~= "" then
            local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and typeof(data) == "table" then
                return data
            else
                warn("Respuesta no es JSON válido")
            end
        else
            warn(("HttpGet falló (intento %d/%d): %s"):format(attempt, CONFIG.MAX_HTTP_RETRIES, tostring(raw)))
        end

        local delay = math.min(CONFIG.BASE_DELAY * (2 ^ (attempt - 1)), CONFIG.MAX_DELAY)
        task.wait(delay)
    end
    return nil
end

-- ===== Búsqueda de servers =====
local function getCandidateServers(): {string}
    local currentId = tostring(game.JobId)
    local candidates = {}
    local cursor = ""
    local pagesChecked = 0

    repeat
        pagesChecked += 1
        local url = "https://games.roblox.com/v1/games/" .. PlaceId
            .. "/servers/Public?sortOrder=Asc&limit=100"
            .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

        local data = httpGetWithRetry(url)
        if not data or not data.data then
            warn("No se pudo obtener la lista de servers (página " .. pagesChecked .. ")")
            break
        end

        for _, s in ipairs(data.data) do
            local id = s.id and tostring(s.id)
            local playing = s.playing or 0
            local maxPlayers = s.maxPlayers or math.huge

            if id
                and id ~= currentId
                and not triedServers[id]
                and playing <= CONFIG.MAX_PLAYERS
                and playing < maxPlayers -- evita servers ya llenos
            then
                table.insert(candidates, id)
            end
        end

        cursor = (data.nextPageCursor and data.nextPageCursor ~= "") and data.nextPageCursor or nil
    until #candidates > 0 or not cursor or pagesChecked >= CONFIG.MAX_PAGES

    return candidates
end

-- ===== Teleport =====
local function tryTeleport(serverId: string): boolean
    if isTeleporting then
        warn("Ya hay un teleport en curso, se ignora esta llamada")
        return false
    end
    isTeleporting = true

    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
    end)

    if not ok then
        warn("Error al teleportar a " .. serverId .. ": " .. tostring(err))
        triedServers[serverId] = true
        isTeleporting = false
        return false
    end

    return true
end

-- Si el teleport fue rechazado por Roblox (evento oficial), lo capturamos también
LocalPlayer.OnTeleport:Connect(function(teleportState: Enum.TeleportState)
    if teleportState == Enum.TeleportState.Failed then
        warn("TeleportState.Failed recibido, liberando estado")
        isTeleporting = false
    end
end)

-- ===== Loop principal =====
local function hop(): boolean
    local currentCount = #Players:GetPlayers()
    if currentCount <= CONFIG.MAX_PLAYERS then
        print(("Ya estás en un server con %d player(s). No se hace hop."):format(currentCount))
        return true
    end

    local attempts = 0
    while CONFIG.MAX_HOP_ATTEMPTS == 0 or attempts < CONFIG.MAX_HOP_ATTEMPTS do
        attempts += 1
        print(("[Intento %d] Buscando server con %d player(s) o menos..."):format(attempts, CONFIG.MAX_PLAYERS))

        local candidates = getCandidateServers()

        if #candidates == 0 then
            warn(("No se encontraron servers disponibles. Reintentando en %ds..."):format(CONFIG.HOP_RETRY_DELAY))
            task.wait(CONFIG.HOP_RETRY_DELAY)
        else
            local serverId = candidates[math.random(1, #candidates)]
            print("Server encontrado (" .. serverId .. "), teleportando...")

            if tryTeleport(serverId) then
                return true -- si tiene éxito, Roblox saca al jugador del server actual
            end
            -- si falló, vuelve a intentar con la siguiente iteración del while
        end
    end

    warn("Se agotaron los intentos de hop (" .. attempts .. ").")
    return false
end

hop()
