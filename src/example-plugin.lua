return {
    Name = "Testing Purposes",
    Description = "Self explanatory",
    Author = "Admin",
    Commands = {
        {
            Name = "findexecutecommand",
            Description = "Prints if the ExecuteCommand function is available.",
            Aliases = {},
            Requirements = {},
            Category = "Test",
            Function = function()
                print("ExecuteCommand is -", ExecuteCommand)
            end
        }
    }
}
