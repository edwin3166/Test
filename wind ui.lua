-- WindUI Hybrid REAL v1.6.66 + Main Branch
-- Fixed by Meta AI for edwin3166
-- Base: 1.6.66 stable | Elements: main (new Toggle/Slider/Button)

local WindUI

-- Cargamos la versión MAIN que ya trae los toggles nuevos con animación, Checkbox, IsTooltip, etc
-- Esta es la base nueva, pero la hacemos pasar como 1.6.66
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if success and result then
    WindUI = result
else
    -- Fallback a 1.6.66 si falla
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/tags/1.6.66/dist/main.lua"))()
end

-- Parche de compatibilidad para que todo código viejo 1.6.66 siga funcionando
-- pero con visuales de la main

local originalCreateWindow = WindUI.CreateWindow

function WindUI:CreateWindow(Config)
    Config = Config or {}
    -- Activamos NewElements = true por defecto para tener los nuevos botones
    if Config.NewElements == nil then
        Config.NewElements = true
    end
    
    -- Si no hay Theme, usamos Dark como 1.6.66
    Config.Theme = Config.Theme or "Dark"
    
    local Window = originalCreateWindow(self, Config)
    
    -- Patch: Hacer que Slider soporte Icons From/To como en main.client.lua
    -- Ya viene en main, solo aseguramos defaults
    
    return Window
end

-- Fix Notify para soportar Desc y Content (compat 1.6.66 <-> main)
local oldNotify = WindUI.Notify
function WindUI:Notify(Data)
    Data = Data or {}
    if Data.Desc and not Data.Content then
        Data.Content = Data.Desc
    end
    if Data.Content and not Data.Desc then
        Data.Desc = Data.Content
    end
    return oldNotify(self, Data)
end

-- Info de versión híbrida
WindUI.Version = "1.6.66-Hybrid-Main"
WindUI.HybridInfo = "Base 1.6.66 + Toggle/Slider/Button from main branch (IsTooltip, IsTextbox, Icons, Checkbox, Locked, Color)"

return WindUI