-- Auto Grab - Agarra el más cercano
-- Ejecutar en tu executor

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local GRAB_DISTANCE = 50 -- Distancia máxima para agarrar
local SPEED = 0.1 -- Velocidad del loop (más bajo = más rápido)

local function getClosest()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local root = character.HumanoidRootPart
    local closest = nil
    local closestDist = GRAB_DISTANCE

    for _, obj in pairs(workspace:GetDescendants()) do
        -- Cambia esta condición según lo que quieras agarrar
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (parent.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end
    end

    return closest
end

-- Loop principal
while true do
    local prompt = getClosest()
    
    if prompt then
        -- Intenta activar el ProximityPrompt
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
    
    task.wait(SPEED)
end
