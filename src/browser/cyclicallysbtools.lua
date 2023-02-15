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
                        cons.add(Move.Activated, function()
                            Notify(format("Move Tool: %s", Mouse.Target.Name))
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
                        cons.add(Move.Deactivated, function()
                            Notify(format("Move Tool: %s", Mouse.Target.Name))
                            movingpart.CanCollide = true
                            movedetect = false
                            Mouse.TargetFilter = nil
                            movingpart.Transparency = movetransparency
                        end)
                        cons.add(Delete.Activated, function()
                            Notify(format("Delete Tool: %s", Mouse.Target.Name))
                            insert(editedparts, Mouse.Target)
                            insert(parentfix, Mouse.Target.Parent)
                            insert(positionfix, Mouse.Target.CFrame)
                            Mouse.Target.Parent = nil
                        end)
                        cons.add(Undo.Activated, function()
                            Notify(format("Undo Tool: %s", editedparts[#editedparts].Name))
                            editedparts[#editedparts].Parent = parentfix[#parentfix]
                            editedparts[#editedparts].CFrame = positionfix[#positionfix]
                            remove(positionfix, #positionfix)
                            remove(editedparts, #editedparts)
                            remove(parentfix, #parentfix)
                        end)
                        cons.add(Identify.Activated, function()
                            Notify(format("Identify Tool\nInstance: %s\nName: %s", Mouse.Target.ClassName, Mouse.Target.Name))
                        end)
                    end
                end)
            end
        }
    }
}
