return {
    Name = "Cyclically's Btools",
    Commands = {
        {
            Name = "cycbtools",
            Description = "Better btools with Undo & Identify.",
            Function = function()
                pcall(function()
                    local backpack = GetBackpack()
                    if backpack then
                        local Move = NewInstance("Tool", {Name = "Move", CanBeDropped = false, RequiresHandle = false, Parent = backpack})
                        local Delete = NewInstance("Tool", {Name = "Delete", CanBeDropped = false, RequiresHandle = false, Parent = backpack})
                        local Undo = NewInstance("Tool", {Name = "Undo", CanBeDropped = false, RequiresHandle = false, Parent = backpack})
                        local Identify = NewInstance("Tool", {Name = "Identify", CanBeDropped = false, RequiresHandle = false, Parent = backpack})
                        local movedetect, movingpart, movetransparency = false, nil, 0
                        local editedparts, parentfix, positionfix = {}, {}, {}
                        consadd(Move.Activated, function()
                            movingpart = Mouse.Target
                            movedetect = true
                            movingpart.CanCollide = false
                            movetransparency = movingpart.Transparency
                            movingpart.Transparency = 0.5
                            Mouse.TargetFilter = movingpart
                            insert(editedparts, movingpart)
                            insert(parentfix, movingpart.Parent)
                            insert(positionfix, movingpart.CFrame)
                            movingpart.Transparency = movingpart.Transparency / 2
                            repeat
                                Mouse.Move:Wait()
                                movingpart.CFrame = CFrame.new(Mouse.Hit.p)
                            until movedetect == false
                        end)
                        consadd(Move.Deactivated, function()
                            movingpart.CanCollide = true
                            movedetect = false
                            Mouse.TargetFilter = nil
                            movingpart.Transparency = movetransparency
                        end)
                        consadd(Delete.Activated, function()
                            insert(editedparts, Mouse.Target)
                            insert(parentfix, Mouse.Target.Parent)
                            insert(positionfix, Mouse.Target.CFrame)
                            Mouse.Target.Parent = nil
                        end)
                        consadd(Undo.Activated, function()
                            editedparts[#editedparts].Parent = parentfix[#parentfix]
                            editedparts[#editedparts].CFrame = positionfix[#positionfix]
                            remove(positionfix, #positionfix)
                            remove(editedparts, #editedparts)
                            remove(parentfix, #parentfix)
                        end)
                        consadd(Identify.Activated, function()
                            Notify(format("Identify Tool\nInstance: %s\nName: %s\nPath: %s", Mouse.Target.ClassName, Mouse.Target.Name, Mouse.Target:GetFullName()))
                        end)
                    end
                end)
            end
        }
    }
}
