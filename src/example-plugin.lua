return {
    Name = "Example Plugin",
    Description = "Self explanatory",
    Author = "Me",
    Commands = {
        {
            Name = "findexecutecommand",
            Description = "Prints if ExecuteCommand is available.",
            Aliases = {},
            Requirements = {},
            Category = "Testing",
            Function = function()
                print("ExecuteCommand is -", ExecuteCommand)
            end
        }
    }
}
