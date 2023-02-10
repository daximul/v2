--[[
    @ evade - https://www.roblox.com/games/9872472334
    # dax
]]

return function(Container, Section, esp)
    esp:AddObjectListener(workspace, {
        Type = "Model",
        Recursive = true,
        PrimaryPart = "HumanoidRootPart",
        CustomName = function(obj)
            return "[AI] " .. tostring(obj.Name)
        end,
        Color = esp.Presets.Red,
        Validator = function(obj)
            return obj:GetAttribute("AI") == true
        end,
        IsEnabled = "Nextbots"
    })
    esp.Overrides.GetColor = function(character)
        local player = esp:GetPlrFromChar(character)
        if player and esp.Downed and player.Character:GetAttribute("Downed") == true then
            return esp.Presets.Blue
        end
        return esp.Color
    end
    Section:AddItem("Toggle", {Text = "Nextbots", Function = function(callback) esp.Nextbots = callback end})
    Section:AddItem("Toggle", {Text = "Downed", Function = function(callback) esp.Downed = callback end})
end
