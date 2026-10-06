--[[
    WindUI Hybrid Loader v2

    - Carga WindUI 1.6.66 (release fijo). Si falla, usa la rama main.
    - Activa NewElements por defecto (toggles, sliders y botones nuevos).
    - Reintenta si falla la red y guarda la última copia buena en el
      workspace para usarla cuando GitHub no responda.
    - Acepta Desc como Content en Notify.
    - No cambia la versión ni el código de la librería.

    Uso:
        local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/WindUI-Hybrid.lua"))()

    Configuración opcional (antes de cargar):
        getgenv().WindUIHybrid = {
            Source = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/main.lua", -- tu copia, se prueba primero
            NewElements = true, -- false = estilo clásico por defecto
            Cache = true,       -- false = no guardar copia local
            Retries = 2,        -- intentos por fuente
        }

    Tras cargar, WindUI.HybridInfo indica de dónde salió la librería:
        { Source = "...", FromCache = false }
]]

local env = (getgenv and getgenv() or {}).WindUIHybrid
local opts = type(env) == "table" and env or {}

local NEW_ELEMENTS = opts.NewElements ~= false
local USE_CACHE = opts.Cache ~= false
local RETRIES = math.max(1, tonumber(opts.Retries) or 2)
local CACHE_FILE = "WindUI/HybridCache.lua"

local SOURCES = {}
if type(opts.Source) == "string" and opts.Source ~= "" then
    table.insert(SOURCES, opts.Source)
end
table.insert(SOURCES, "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua")
table.insert(SOURCES, "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")

local function hasFs()
    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

-- Compila el código y comprueba que sea realmente WindUI
local function compile(src)
    if type(src) ~= "string" or #src == 0 then
        return nil
    end

    local fn = loadstring(src)
    if not fn then
        return nil
    end

    local ok, lib = pcall(fn)
    if ok and type(lib) == "table" and type(lib.CreateWindow) == "function" then
        return lib
    end
    return nil
end

-- Reintenta solo si falló la red; un contenido inválido no mejora al repetir
local function download(url)
    for attempt = 1, RETRIES do
        local ok, src = pcall(game.HttpGet, game, url)
        if ok then
            return compile(src), src
        end
        if attempt < RETRIES then
            task.wait(0.5)
        end
    end
    return nil
end

local function saveCache(src)
    if not USE_CACHE or not hasFs() then
        return
    end
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("WindUI") then
            makefolder("WindUI")
        end
        writefile(CACHE_FILE, src)
    end)
end

local function loadCache()
    if not USE_CACHE or not hasFs() then
        return nil
    end
    local ok, src = pcall(function()
        if isfile(CACHE_FILE) then
            return readfile(CACHE_FILE)
        end
    end)
    if ok then
        return compile(src)
    end
    return nil
end

local WindUI, usedSource, fromCache

for _, url in ipairs(SOURCES) do
    local lib, src = download(url)
    if lib then
        WindUI, usedSource = lib, url
        saveCache(src)
        break
    end
    warn("[WindUI Hybrid] No se pudo cargar: " .. url)
end

if not WindUI then
    WindUI = loadCache()
    if WindUI then
        usedSource, fromCache = CACHE_FILE, true
        warn("[WindUI Hybrid] Usando la copia guardada en el workspace")
    end
end

if not WindUI then
    error("[WindUI Hybrid] No se pudo cargar WindUI desde ninguna fuente", 2)
end

WindUI.HybridInfo = { Source = usedSource, FromCache = fromCache == true }

local function shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

-- Evita parchear dos veces si el loader se ejecuta de nuevo
if not WindUI.__HybridPatched then
    WindUI.__HybridPatched = true

    local baseCreateWindow = WindUI.CreateWindow
    function WindUI:CreateWindow(config)
        local cfg = shallowCopy(config or {})
        if cfg.NewElements == nil then
            cfg.NewElements = NEW_ELEMENTS
        end
        return baseCreateWindow(self, cfg)
    end

    local baseNotify = WindUI.Notify
    function WindUI:Notify(data)
        if type(data) == "table" and data.Desc and not data.Content then
            data = shallowCopy(data)
            data.Content = data.Desc
        end
        return baseNotify(self, data)
    end
end

--[[ Ejemplo (cuando uses el loader, quita los corchetes de comentario):

local Window = WindUI:CreateWindow({
    Title = "Mi Hub",
    Folder = "MyHub",
    Theme = "Dark",
})

local Tab = Window:Tab({ Title = "Main", Icon = "house" })

Tab:Toggle({
    Title = "Toggle",
    Type = "Toggle", -- o "Checkbox"
    Value = false,
    Callback = function(v) print(v) end,
})

Tab:Slider({
    Title = "Slider",
    IsTooltip = true,
    IsTextbox = true,
    Step = 1,
    Value = { Min = 0, Max = 200, Default = 100 },
    Callback = function(v) print(v) end,
})

Tab:Button({
    Title = "Botón azul",
    Color = Color3.fromHex("#305dff"),
    Icon = "mouse",
    Callback = function() print("click") end,
})
]]

return WindUI
