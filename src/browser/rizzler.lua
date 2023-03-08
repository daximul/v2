local lines = loadstring(game:HttpGet("https://raw.githubusercontent.com/ligmajohn/backups/main/rizz_lines.lua"))()
return {
    Name = "Rizz",
    Commands = {
        {
            Name = "rizz",
            Description = "Opens the rizzler gui.",
            Function = function()
                local Section = Gui.New("Rizzler"):AddSection("Section")
                local method = false
                local send = function(str) if method then SendChatMessage("/byp " .. lower(str)) else SendChatMessage(str) end end
                Section:AddItem("Button", {Text = "Random Rizz", Function = function() send(lines[math.random(1, #lines)]) end})
                Section:AddItem("Toggle", {Text = "/byp (hi atp)", Function = function(callback) method = callback end})
                Section:AddItem("Text", {Text = "Specific Lines", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
                for _, v in next, lines do Section:AddItem("ButtonText", {Text = tostring(v), Function = function() send(tostring(v)) end}) end
            end
        }
    }
}
