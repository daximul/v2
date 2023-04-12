return {
    Name = "Draggable Chat",
    Commands = {
        {
            Name = "draggablechat",
            Description = "Makes chat draggable and resizable.",
            Aliases = {"dragchat"},
            Category = "Utility",
            Function = function()
                local ChatSettings = require(Services.Chat.ClientChatModules.ChatSettings)
                local ChatFrame = LocalPlayer:FindFirstChildWhichIsA("PlayerGui").Chat.Frame
                ChatSettings.WindowResizable = true
                ChatSettings.WindowDraggable = true
                ChatFrame.ChatChannelParentFrame.Visible = true
                ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), ChatFrame.ChatChannelParentFrame.Size.Y)
            end
        }
    }
}
