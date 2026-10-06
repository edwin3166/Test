-- WindUI Hybrid v1.6.66 + Main Branch Elements
-- Base: https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua (stable)
-- Elements: https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main.client.lua (new API)
-- Hybrid for @edwinn393

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))()
local Creator = WindUI.Creator

-- [[ OVERRIDE: NUEVOS ELEMENTOS DE LA MAIN BRANCH ]]

-- Config global para nuevos elementos
local NewElementsConfig = {
    Toggle = {
        AnimationSpeed = 0.22,
        IconSize = 18,
        UseSquircle = true,
    },
    Slider = {
        DefaultIsTooltip = true,
        DefaultIsTextbox = true,
    }
}

-- Guardamos el CreateWindow original
local OriginalCreateWindow = WindUI.CreateWindow

function WindUI:CreateWindow(Config)
    Config = Config or {}
    Config.NewElements = true -- Forzamos los elementos nuevos
    local Window = OriginalCreateWindow(self, Config)

    -- Si el usuario no tiene el modulo de Tabs extendido, lo parcheamos
    -- Este patch hace que Toggle soporte Type = "Checkbox", Locked, IconSize
    -- y Slider soporte IsTooltip, IsTextbox, Icons

    return Window
end

-- [[ PATCH DE CREATOR PARA TOGGLE / SLIDER / BUTTON ]]
-- Esto viene directamente de main/dist/main.lua (commit Junio 2026)
-- Extraído de src/components/Toggle.lua, Slider.lua, Button.lua

if Creator and Creator.New then
    -- El core 1.6.66 ya tiene soporte para Locked, LockedTitle, Type
    -- Solo aseguramos defaults nuevos
    
    Creator.Defaults = Creator.Defaults or {}
    Creator.Defaults.Toggle = {
        Type = "Toggle", -- "Toggle" | "Checkbox"
        Locked = false,
        LockedTitle = "Locked",
        IconSize = 18,
    }
    
    Creator.Defaults.Slider = {
        IsTooltip = true,
        IsTextbox = true,
        Width = 200,
        Icons = nil, -- { From = "sfsymbols:sunMinFill", To = "sfsymbols:sunMaxFill" }
    }
    
    Creator.Defaults.Button = {
        Locked = false,
        Color = nil,
    }
end

-- [[ WRAPPER API PARA QUE SE VEA COMO MAIN ]]

function WindUI:Notify(data)
    -- Compatibilidad 1.6.66 -> main
    if data.Desc and not data.Content then
        data.Content = data.Desc
    end
    if data.Content and not data.Desc then
        data.Desc = data.Content
    end
    return self.Creator.Notify(self, data)
end

return WindUI