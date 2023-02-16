local wait, foreach, AllBool = task.wait, table.foreach, false
return function(Player, TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = os.clock()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, -1.5, 0) +
                                THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(2.25, 1.5, -2.25) +
                                THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(-2.25, -1.5, 2.25) +
                                THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,
                            CFrame.Angles(math.rad(Angle), 0, 0)
                        )
                        wait()
                    else
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, THumanoid.WalkSpeed),
                            CFrame.Angles(math.rad(90), 0, 0)
                        )
                        wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, THumanoid.WalkSpeed),
                            CFrame.Angles(math.rad(90), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25),
                            CFrame.Angles(math.rad(90), 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25),
                            CFrame.Angles(0, 0, 0)
                        )
                        wait()
                        FPos(
                            BasePart,
                            CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25),
                            CFrame.Angles(math.rad(90), 0, 0)
                        )
                        wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or
                TargetPlayer.Parent ~= Players or
                not TargetPlayer.Character == TCharacter or
                THumanoid.Sit or
                Humanoid.Health <= 0 or
                os.clock() > Time + TimeToWait
        end
        workspace.FallenPartsDestroyHeight = 0 / 0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return
        end
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        repeat
            RootPart.CFrame = OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            foreach(
                Character:GetChildren(),
                function(_, x)
                    if x:IsA("BasePart") then
                        x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
            )
            wait()
        until (RootPart.Position - OldPos.p).Magnitude < 25
    else
        return
    end
end
