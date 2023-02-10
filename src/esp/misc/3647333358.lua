--[[
    @ evade - https://www.roblox.com/games/9872472334
    # dax
]]

return function(Container, Section, esp)
    esp.Overrides.GetColor = function(character)
        local player = esp:GetPlrFromChar(character)
        if player and esp.Downed and player.Character:GetAttribute("Downed") == true then
            return esp.Presets.Blue
        end
        return esp.Color
    end
    Section:AddItem("Toggle", {Text = "Downed", Function = function(callback) esp.Downed = callback end})
end
