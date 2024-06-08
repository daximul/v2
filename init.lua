if not game:IsLoaded() then game.Loaded:Wait() end
if dxrkj and type(dxrkj) == "function" then return dxrkj() end
local LoadingTick = tick()

Admin = {
	Debug = false,
	Commands = {},
	History = {},
	CommandArgs = {},
	CommandRequirements = {},
	RequirementsNotification = true,
	Whitelisted = {},
	PredictionCases = {"all", "others", "random", "me", "nearest", "farthest", "allies", "enemies", "team", "nonteam", "friends", "nonfriends", "bacons", "nearest", "farthest", "alive", "dead"},
	Prefix = ";"
}

Config = {
	CommandBarPrefix = "Semicolon",
	Prefix = ";",
	DisabledPlugins = {},
	LoweredText = false,
	FlySpeed = 1,
	TweenSpeed = 1,
	KeepAdmin = true,
	StartupNotification = true,
	Widebar = false,
}

MiscConfig = {
    Permissions = {},
    CustomAlias = {},
    Keybinds = {},
    Events = {}
}

cloneref = cloneref or function(...) return ... end
Services = {}
setmetatable(Services, {
	__index = function(tbl, prop)
		local success, service = pcall(function() return game:GetService(prop) end)
		if success then
			Services[prop] = cloneref(service)
			return Services[prop]
		end
		return nil
	end,
	__mode = "v"
})

Players = Services.Players
LocalPlayer = Players.LocalPlayer
Mouse = LocalPlayer:GetMouse()
HttpService = Services.HttpService
ReplicatedStorage = Services.ReplicatedStorage
CoreGui = Services.CoreGui
UserInputService = Services.UserInputService
RunService = Services.RunService
TweenService = Services.TweenService
TeleportService = Services.TeleportService
Lighting = Services.Lighting
lower, gsub, len, sub, find, random, insert = string.lower, string.gsub, string.len, string.sub, string.find, math.random, table.insert
remove, gmatch, match, tfind, cwrap, wait, spawn = table.remove, string.gmatch, string.match, table.find, coroutine.wrap, task.wait, task.spawn
split, format, upper, clamp, round, heartbeat, renderstepped = string.split, string.format, string.upper, math.clamp, math.round, RunService.Heartbeat, RunService.RenderStepped
local getconnections = getconnections or get_signal_cons
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local creatingInstance = Instance.new
local OldGravity, OldFallenPartsDestroyHeight = workspace.Gravity, workspace.FallenPartsDestroyHeight
local OldLightingProperties = {Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows}

RandomString = function() return sub(gsub(HttpService:GenerateGUID(false), "-", ""), 1, random(25, 30)) end

cons = {connections = {}, loaded = true}
cons.add = function(name, con, func)
	if not func then func, con, name = con, name, RandomString() end
	local cname = type(name) == "table" and RandomString() or name
	cons.connections[cname] = con:Connect(func)
	if type(name) == "table" then name[#name + 1] = function() cons.remove(cname) end end
	return cons.connections[cname]
end
cons.remove = function(name)
	if type(name) == "table" then
		for _, connection in next, name do
			if cons.connections[connection] then
				cons.connections[connection]:Disconnect()
				cons.connections[connection] = nil
			end
		end
	else
		if cons.connections[name] then
			cons.connections[name]:Disconnect()
			cons.connections[name] = nil
		end
	end
end
cons.wipe = function()
	for i, v in next, cons.connections do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
			cons.connections[i] = nil
		end
	end
	cons.loaded = false
end
-- i know
consadd, consremove = cons.add, cons.remove
-- ok hear me out
-- im keeping the bad code above ONLY for plugin compatibility
AddConnection, RemoveConnection = cons.add, cons.remove

NewInstance = function(class, properties)
	local new = creatingInstance(class)
	for property, value in next, (properties or {}) do new[property] = value end
	return new
end

FindInTable = function(tbl, val)
	if not tbl then return false end
	for _, v in pairs(tbl) do if v == val then return true end end
	return false
end

GetCharacter = function(player)
	player = player or LocalPlayer
	return player and player.Character
end

GetHumanoid = function(character)
	character = character or GetCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end

GetBackpack = function(player)
	player = player or LocalPlayer
	return player and player:FindFirstChildOfClass("Backpack")
end

GetRoot = function(character)
	character = character or GetCharacter()
	return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso"))
end

GetMagnitude = function(player)
	local root, root2 = GetRoot(), GetRoot(GetCharacter(player))
	return (player and (root and root2 and (root2.Position - root.Position).magnitude)) or math.huge
end

CheckDistanceAndClear = function(target, distance)
	delay(1, function()
		local character = GetCharacter()
		if character and target and GetMagnitude(target) <= (distance or 10) then character:ClearAllChildren() end
	end)
end

IsKeyDown = {}
LastKey = function(input) return split(tostring(input), ".")[3] end
GetStringFromKeyCode = function(input)
	return filter(Enum.KeyCode:GetEnumItems(), function(_, v)
		return UserInputService:GetStringForKeyCode(v) == input
	end)[1]
end
AddConnection(UserInputService.InputBegan, function(input, processed)
	if not processed then
		if find(tostring(input.UserInputType), "MouseButton") then
			input = LastKey(input.UserInputType)
			IsKeyDown[input] = true
			IsKeyDown[gsub(input, "MouseButton", "MB")] = true
			return
		end
		input = LastKey(input.KeyCode)
		IsKeyDown[input] = true
		for _, v in next, MiscConfig.Keybinds do
			if FindInTable(v.Keys, input) then
				if v.Game == nil or game.PlaceId == v.Game or game.GameId == v.Game then
					if #v.Keys == 2 then
						if IsKeyDown[v.Keys[1]] and IsKeyDown[v.Keys[2]] then
							ExecuteCommand(v.Command)
						end
					else
						ExecuteCommand(v.Command)
					end
				end
			end
		end
	end
end)
AddConnection(UserInputService.InputEnded, function(input, processed)
	if not processed then
		if find(tostring(input.UserInputType), "MouseButton") then
			input = LastKey(input.UserInputType)
			IsKeyDown[input] = false
			IsKeyDown[gsub(input, "MouseButton", "MB")] = false
			return
		end
		IsKeyDown[LastKey(input.KeyCode)] = false
	end
end)

merge = function(...)
    local new = {}
    for i, v in next, {...} do for _, v2 in next, v do new[i] = v2 end end
    return new
end

filter = function(tbl, func)
    local new = {}
    for i, v in next, tbl do if func(i, v) then new[#new + 1] = v end end
    return new
end

map = function(tbl, func)
	local new = {}
	for i, v in next, tbl do
		local k, x = func(i, v)
		new[x or #new + 1] = k
	end
	return new
end

HasTool = function(player)
	player = player or LocalPlayer
	local character, backpack = GetCharacter(player), GetBackpack(player)
	if character and backpack then
		local list = merge(character:GetChildren(), backpack:GetChildren())
		for i = 1, #list do
			if list[i]:IsA("Tool") then
				return true
			end
		end
	end
	return false
end

GetTool = function(player, requiresHandle)
	player = player or LocalPlayer
	local character, backpack = GetCharacter(player), GetBackpack(player)
	if character and backpack and HasTool(player) then
		local tools = filter(merge(character:GetChildren(), backpack:GetChildren()), function(_, v) return v:IsA("Tool") and v end)
		return filter(tools, function(_, v)
			if requiresHandle then
				local handle = v:FindFirstChild("Handle")
				if handle and handle:IsA("Part") then return v end
				return nil
			end
			return v
		end)[1]
	end
	return nil
end

local touchinterest = {}
firerbxtouch = firetouchinterest or function(part, part2, value)
	if part and part2 then
		if value == 0 then
			touchinterest[1] = part.CFrame
			part.CFrame = part2.CFrame
		else
			part.CFrame = touchinterest[1]
			touchinterest[1] = nil
		end
	end
end

GetUsername = function(player)
	player = player or LocalPlayer
	return player.DisplayName or player.Name
end

GetLongUsername = function(player)
	player = player or LocalPlayer
	if player.DisplayName ~= player.Name then
		return format("%s (%s)", player.Name, player.DisplayName)
	else
		return player.Name
	end
end

local clipboardfunc = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
toexecutorclipboard = function(...)
	if clipboardfunc then
		clipboardfunc(...)
		Notify("copied to clipboard")
	else
		print("[Clipboard]", ...)
		Notify("printed to console")
	end
end

WhitelistInfo = function(player)
	player = player or LocalPlayer
	local data = Admin.Whitelisted[tostring(player.UserId)]
	if data and type(data) == "table" then return data end
	return {Player = player, Value = false}
end

ReplaceHumanoid = function()
	local humanoid = GetHumanoid()
	if humanoid then
		local new = humanoid:Clone()
		new.Parent, new.Name = humanoid.Parent, humanoid.Name
		humanoid:Destroy()
	end
end

Attach = function(target)
	if GetTool(LocalPlayer, true) ~= nil and target then
		local tool, character, tcharacter = GetTool(LocalPlayer, true), GetCharacter(), GetCharacter(target)
		if tool and character and tcharacter then
			local humanoid, root, root2 = GetHumanoid(), GetRoot(), GetRoot(tcharacter)
			if humanoid and root and root2 then
				local backpack = GetBackpack()
				if backpack then tool.Parent = backpack end
				ReplaceHumanoid()
				workspace.CurrentCamera.CameraSubject = character
				humanoid.DisplayDistanceType = "None"
				tool.Parent = character
				firerbxtouch(root2, tool.Handle, 0)
				firerbxtouch(root2, tool.Handle, 1)
			end
		end
	end
end

FindCommand = function(cmd)
	cmd = lower(tostring(cmd))
	for _, v in pairs(Admin.Commands) do
		if lower(tostring(v.Name)) == cmd or FindInTable(v.Alias, cmd) then
			return v
		end
	end
	for _, v in next, MiscConfig.CustomAlias do
		if v.Alias == cmd then
			return FindCommand(v.Name)
		end
	end
end

RemoveCommand = function(cmd)
	cmd = lower(tostring(cmd))
	for i, v in pairs(Admin.Commands) do
		if lower(tostring(v.Name)) == cmd or FindInTable(v.Alias, cmd) then
			remove(Admin.Commands, i)
		end
	end
end

GetEnvironment = function(cmd)
	local command = FindCommand(cmd)
	return command and command.Env or {}
end

RunCommandFunctions = function(name, ignore)
	for _, name in next, (type(name) == "table" and name or {name}) do
		local command = FindCommand(name)
		command.Env = command.Env or {}
		for i, v in next, command.Env do
			if type(v) == "function" then
				command.Env[i] = nil
				if ignore then spawn(pcall, v) else v() end
			end
		end
	end
end

SendChatMessage = function(str, channel)
	if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest") then
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, channel or "All")
	end
end

CleanSpecials = function(...)
	return gsub(..., "[*\\?:<>|']+", "")
end

ChatHistory = {}
LogChatMessage = function(player, message)
	insert(ChatHistory, {Player = player, Name = GetLongUsername(player), Message = message})
	local Loaded = GetEnvironment("chatlogs")[1]
	if Loaded and Loaded.Container and Loaded.Section then
		local log = format("[%s]: %s", GetLongUsername(player), message)
		Loaded.Section:AddItem("ButtonText", {Text = log, Function = function() toexecutorclipboard(log) end})
	end
end

JoinHistory = {}
LogJoinMessage = function(player, message)
	insert(JoinHistory, {Player = player, Name = GetLongUsername(player), Message = message})
	local Loaded = GetEnvironment("joinlogs")[1]
	if Loaded and Loaded.Container and Loaded.Section then
		local log = format("[%s] %s", GetLongUsername(player), message)
		Loaded.Section:AddItem("ButtonText", {Text = log, Function = function() toexecutorclipboard(log) end})
	end
end

CapitalizeFirstCharacters = function(str)
	return gsub(str, "%S+", gsub(str, "^%l", upper))
end

SplitString = function(str, delim)
	local broken = {}
	if not delim then delim = "," end
	for w in gmatch(str, "[^" .. delim .. "]+") do insert(broken, w) end
	return broken
end

SpecialPlayerCases = {
	all = function(speaker) return Players:GetPlayers() end,
	others = function(speaker)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker
		end)
	end,
	me = function(speaker) return {speaker} end,
	["#(%d+)"] = function(speaker, args, currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1, randAmount do
			if #players == 0 then break end
			local randIndex = random(1, #players)
			insert(returns, players[randIndex])
			remove(players, randIndex)
		end
		return returns
	end,
	random = function(speaker, args, currentList)
		local players = filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker
		end)
		return {players[random(1, #players)]}
	end,
	["%%(.+)"] = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.Team and sub(lower(v.Team.Name), 1, #args[1]) == lower(args[1])
		end)
	end,
	allies = function(speaker)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.Team and v.Team == speaker.Team
		end)
	end,
	enemies = function(speaker)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.Team and v.Team ~= speaker.Team
		end)
	end,
	team = function(speaker)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.Team and v.Team == speaker.Team
		end)
	end,
	nonteam = function(speaker)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.Team and v.Team ~= speaker.Team
		end)
	end,
	friends = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v:IsFriendsWith(speaker.UserId)
		end)
	end,
	nonfriends = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and not v:IsFriendsWith(speaker.UserId)
		end)
	end,
	guests = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.Guest
		end)
	end,
	bacons = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			local character = GetCharacter(v)
			return v ~= speaker and character and (character:FindFirstChild("Pal Hair") or character:FindFirstChild("Kate Hair"))
		end)
	end,
	["age(%d+)"] = function(speaker, args)
		local age = tonumber(args[1])
		if not age then return {} end
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v.AccountAge <= age
		end)
	end,
	nearest = function(speaker, args, currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not GetRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _, plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(GetRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	farthest = function(speaker, args, currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not GetRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _, plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(GetRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker, args)
		local group = tonumber(args[1])
		if not group then return {} end
		return filter(Players:GetPlayers(), function(_, v)
			return v ~= speaker and v:IsInGroup(group)
		end)
	end,
	alive = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			local humanoid = GetHumanoid(GetCharacter(v))
			return v ~= speaker and humanoid and humanoid.Health > 0
		end)
	end,
	dead = function(speaker, args)
		return filter(Players:GetPlayers(), function(_, v)
			local humanoid = GetHumanoid(GetCharacter(v))
			return v ~= speaker and humanoid and humanoid.Health <= 0
		end)
	end,
	["rad(%d+)"] = function(speaker, args)
		local radius, speakerchar, speakerroot = tonumber(args[1]), GetCharacter(speaker), GetRoot(GetCharacter(speaker))
		if not radius or not speakerchar or not speakerroot then return {} end
		return filter(Players:GetPlayers(), function(_, v)
			local root = GetRoot(GetCharacter(v))
			local magnitude = (root and (root.Position - speakerroot.Position).magnitude) or false
			return v ~= speaker and magnitude and magnitude <= radius
		end)
	end
}

toTokens = function(str)
	local tokens = {}
	for op, name in gmatch(str, "([+-])([^+-]+)") do insert(tokens, {Operator = op, Name = name}) end
	return tokens
end

onlyIncludeInTable = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for _, v in pairs(matches) do matchTable[v.Name] = true end
	for _, v in pairs(tab) do if matchTable[v.Name] then insert(resultTable, v) end end
	return resultTable
end

removeTableMatches = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for _, v in pairs(matches) do matchTable[v.Name] = true end
	for _, v in pairs(tab) do if not matchTable[v.Name] then insert(resultTable, v) end end
	return resultTable
end

getPlayersByName = function(name)
	local name, len, found = string.lower(name), #name, {}
	for _, v in pairs(Players:GetPlayers()) do
		if sub(name, 0, 1) == "@" then
			if sub(string.lower(v.Name), 1, len - 1) == sub(name, 2) then
				insert(found, v)
			end
		else
			if sub(lower(v.Name), 1, len) == name or sub(lower(v.DisplayName), 1, len) == name then
				insert(found, v)
			end
		end
	end
	return found
end

getPlayer = function(list, speaker)
	if not list then return {speaker.Name} end
	local nameList = SplitString(list, ",")
	local foundList = {}
	for _, name in pairs(nameList) do
		if sub(name, 1, 1) ~= "+" and sub(name, 1, 1) ~= "-" then name = "+" .. name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()
		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex, case in pairs(SpecialPlayerCases) do
					local matches = {match(tokenContent, "^" .. regex .. "$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers, case(speaker, matches, initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers, getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex, case in pairs(SpecialPlayerCases) do
					local matches = {match(tokenContent, "^" .. regex .. "$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers, case(speaker, matches, initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers, getPlayersByName(tokenContent))
				end
			end
		end
		for i, v in pairs(initialPlayers) do insert(foundList, v) end
	end
	local foundNames = {}
	for _, v in pairs(foundList) do insert(foundNames, v.Name) end
	return foundNames
end

LastCommands = {}
HistoryCount = 0
LastBreakTime = 0
ExecuteCommand = function(cmdStr, speaker, store)
	cmdStr = gsub(cmdStr, "%s+$", "")
	spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = gsub(cmdStr, "\\\\", "%%BackSlash%%")
		local commandsToRun = SplitString(cmdStr, "\\")
		for _, v in pairs(commandsToRun) do
			v = gsub(v, "%%BackSlash%%", "\\")
			local _, y, num = find(v, "^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false
			if num then
				v = sub(v, y + 1)
				local _, y, del = find(v, "^([%d%.]+)%^")
				if del then
					v = sub(v, y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x, y = find(v, "^inf%^")
				if x then
					infTimes = true
					v = sub(v, y + 1)
					local _, y, del = find(v, "^([%d%.]+)%^")
					if del then
						v = sub(v, y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)
			if sub(v, 1, 1) == "!" then
				local chunks = SplitString(sub(v, 2), " ")
				if chunks[1] and LastCommands[chunks[1]] then v = LastCommands[chunks[1]] end
			end
			local args = SplitString(v, " ")
			local cmdName = args[1]
			local cmd = FindCommand(cmdName)
			if cmd then
				if not speaker then speaker = LocalPlayer end
				if (speaker == LocalPlayer) or ((WhitelistInfo(speaker).Value == true) and cmd.PermissionIndex == 1) or (cmd.PermissionIndex == 0) then
					remove(args, 1)
					Admin.CommandArgs = args
					if store then
						if speaker == LocalPlayer then
							if Admin.History[1] ~= rawCmdStr and sub(rawCmdStr, 1, 11) ~= "lastcommand" then
								insert(Admin.History, 1, rawCmdStr)
							end
						end
						if #Admin.History > 30 then remove(Admin.History) end
						LastCommands[cmdName] = v
					end
                    local runCommand = function()
                        if #args < cmd.ArgsNeeded then
                            if Admin.RequirementsNotification then
                                Notify("insufficient args (you need " .. cmd.ArgsNeeded .. ")")
                            end
                        else
                            local validfunc = cmd.Func()
                            if validfunc then
						        local success, err = pcall(function() validfunc(args, speaker, cmd.Env) end)
						        if not success and Admin.Debug then warn("Command Error:", cmdName .. " -", err) end
                            end
                        end
                    end
					if speaker == LocalPlayer then
						local cmdStartTime = tick()
						if infTimes then
							while LastBreakTime < cmdStartTime do
								runCommand()
								wait(cmdDelay)
							end
						else
							for _ = 1, num do
								if LastBreakTime > cmdStartTime then break end
								runCommand()
								if cmdDelay ~= 0 then wait(cmdDelay) end
							end
						end
					else
                        runCommand()
					end
				end
			end
		end
	end)
end

getstring = function(begin)
	local start = begin - 1
	local AA = ""
	for i, v in pairs(Admin.CommandArgs) do
		if i > start then
			AA = (AA ~= "" and (AA .. " " .. v)) or (AA .. v)
		end
	end
	return AA
end

local getprfx = function(strn)
	if sub(strn, 1, len(Admin.Prefix)) == Admin.Prefix then return {"cmd", len(Admin.Prefix) + 1} end return
end

local do_exec = function(str, plr)
	str = gsub(str, "/e ", "")
	local t = getprfx(str)
	if not t then return end
	str = sub(str, t[2])
	if t[1] == "cmd" then
		ExecuteCommand(str, plr, true)
	end
end

local ListenToCharacter = function(player)
	local Listen = function()
		spawn(function()
			pcall(function()
				local out = 0
				repeat wait(1) out = out + 1 until (GetHumanoid(GetCharacter(player)) ~= nil or out == 10)
				local humanoid = GetHumanoid(GetCharacter(player))
				if humanoid then
					AddConnection(humanoid.Died, function()
						Events.Fire("OnDied", player.Name)
						local killedBy = humanoid:FindFirstChild("Creator")
						if killedBy and killedBy.Value and killedBy.Value.Parent then
							Events.Fire("OnKilled", player.Name, killedBy.Name)
						end
					end)
					local OldHealth = humanoid.Health
					humanoid.HealthChanged:Connect(function(health)
						if OldHealth > health then Events.Fire("OnDamage", player.Name, tonumber(health)) end
						OldHealth = health
					end)
				end
			end)
		end)
	end
	AddConnection(player.CharacterAdded, function(character)
		Events.Fire("OnSpawn", player.Name)
		Listen()
	end)
	Listen()
end

do
	local got = false
	local MainChat = LocalPlayer:FindFirstChildWhichIsA("PlayerGui") and LocalPlayer:FindFirstChildWhichIsA("PlayerGui"):FindFirstChild("Chat")
	if MainChat then
		if MainChat:FindFirstChild("Frame") and MainChat.Frame:FindFirstChild("ChatBarParentFrame") then
			local ChatbarFrame = MainChat.Frame.ChatBarParentFrame
			if ChatbarFrame:FindFirstChild("Frame") and ChatbarFrame.Frame:FindFirstChild("BoxFrame") and ChatbarFrame.Frame.BoxFrame:FindFirstChild("Frame") and ChatbarFrame.Frame.BoxFrame.Frame:FindFirstChild("ChatBar") then
				got = true
				local chatbar = ChatbarFrame.Frame.BoxFrame.Frame.ChatBar
				AddConnection(chatbar.FocusLost, function()
					local message = chatbar.Text
					if message ~= "" then
						spawn(function()
							wait()
							do_exec(message, LocalPlayer)
						end)
						LogChatMessage(LocalPlayer, message)
						Events.Fire("OnChatted", LocalPlayer.Name, message)
					end
				end)
			end
		end
	end
	if not got then
		AddConnection(LocalPlayer.Chatted, function(message)
			spawn(function()
				wait()
				do_exec(message, LocalPlayer)
			end)
			LogChatMessage(LocalPlayer, message)
			Events.Fire("OnChatted", LocalPlayer.Name, message)
		end)
	end
end

for _, player in next, Players:GetPlayers() do
	if player ~= LocalPlayer then
		AddConnection(player.Chatted, function(message)
			spawn(function()
				wait()
				do_exec(message, player)
			end)
			LogChatMessage(player, message)
			Events.Fire("OnChatted", player.Name, message)
		end)
	end
	ListenToCharacter(player)
end

AddConnection(Players.PlayerAdded, function(player)
	Events.Fire("OnJoin", player.Name)
	AddConnection(player.Chatted, function(message)
		spawn(function()
			wait()
			do_exec(message, player)
		end)
		LogChatMessage(player, message)
		Events.Fire("OnChatted", player.Name, message)
	end)
	ListenToCharacter(player)
	LogJoinMessage(player, "has joined the game")
end)

AddConnection(Players.PlayerRemoving, function(player)
    LogJoinMessage(player, "has left the game")
    Events.Fire("OnLeave", player.Name)
end)

Admin.CommandRequirements = {
	spawned = function() return {"you need to be spawned for this command", GetCharacter() ~= nil} end,
	tool = function() return {"you need a tool (with a handle) for this command", GetTool(LocalPlayer, true) ~= nil} end
}

AddCommand = function(name, usage, description, alias, reqs, perm, func, pl)
	local Id = #Admin.Commands + 1
	Admin.Commands[Id] = {
		Name = lower(tostring(name)),
		Usage = usage,
		Description = description,
		Alias = map(alias or {}, function(_, v)
			return lower(tostring(v))
		end),
		Requirements = reqs or {},
		PermissionIndex = perm or 2,
		ArgsNeeded = tonumber(filter(reqs, function(_, v)
			return type(v) == "number"
		end)[1]) or 0,
		Category = filter(reqs, function(_, v)
			return type(v) == "string" and (v == CapitalizeFirstCharacters(v))
		end)[1] or "Misc",
		CustomArgs = filter(reqs, function(_, v)
			return type(v) == "table"
		end)[1] or {},
		Func = function()
			for _, v in next, reqs do
				if type(v) == "function" then
					local action = v()
					action[1] = action[1] or "you are missing something that is needed for this command"
					if action[2] == false and Admin.RequirementsNotification then
						Notify(action[1])
						return false
					end
				elseif type(v) == "string" and Admin.CommandRequirements[v] ~= nil then
					local action = Admin.CommandRequirements[v]()
					action[1] = action[1] or "you are missing something that is needed for this command"
					if action[2] == false and Admin.RequirementsNotification then
						Notify(action[1])
						return false
					end
				end
			end
			return func
		end,
		Env = {},
		Plugin = pl or false
	}
	local InvalidateCommand = function() Admin.Commands[Id] = nil end
	return {Destroy = InvalidateCommand, Remove = InvalidateCommand, Delete = InvalidateCommand, Invalidate = InvalidateCommand}
end

RewriteCommand = function(cmd, func)
	local command = FindCommand(cmd)
	if command then
		command.Func = func
	end
end

ParentObject = function(Gui)
	local success, failure = pcall(function()
		if get_hidden_gui or gethui then
			local hiddenUI = get_hidden_gui or gethui
			Gui.Name = RandomString()
			Gui.Parent = hiddenUI()
		elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
			Gui.Name = RandomString()
			syn.protect_gui(Gui)
			Gui.Parent = CoreGui
		elseif CoreGui:FindFirstChild("RobloxGui") then
			Gui.Name = RandomString()
			Gui.Parent = CoreGui.RobloxGui
		end
	end)
	if not success and failure then
		Gui.Name = RandomString()
		Gui.Parent = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
	end
end

local fakeRequire = (function()
	local cache = {}
	local load
	load = function(module)
		if cache[module] then
			return cache[module]
		end
		local func = loadstring(module.source)
		local env = setmetatable({}, {__index = getgenv and getgenv() or _G})
		env.script = module
		env.require = load
		setfenv(func, env)
		local result = func()
		cache[module] = result
		return result
	end
	return load
end)()

-- Filesystem
local UpdateConfig, UpdateMiscConfig = function() end, function() end
if writefile and readfile and isfolder and makefolder then
	if not isfolder("dark-admin") then
		makefolder("dark-admin")
	end
	if not isfolder("dark-admin/plugins") then
		makefolder("dark-admin/plugins")
	end
	if not isfolder("dark-admin/logs") then
		makefolder("dark-admin/logs")
	end
	local save, save2 = "dark-admin/config.json", "dark-admin/misc.json"
	local cachedconfigs = pcall(readfile, save) and HttpService:JSONDecode(readfile(save))
	if cachedconfigs then
		for setting, value in next, Config do
			if cachedconfigs[setting] == nil then
				cachedconfigs[setting] = value
			end
		end
		Config = cachedconfigs
	end
	UpdateConfig = function()
		if writefile and cons.loaded then
			writefile(save, HttpService:JSONEncode(Config))
		end
	end
	local cachedconfigs2 = pcall(readfile, save2) and HttpService:JSONDecode(readfile(save2))
	if cachedconfigs2 then
		for setting, value in next, MiscConfig do
			if cachedconfigs2[setting] == nil then
				cachedconfigs2[setting] = value
			end
		end
		MiscConfig = cachedconfigs2
	end
	UpdateMiscConfig = function()
		if writefile and cons.loaded then
			writefile(save2, HttpService:JSONEncode(MiscConfig))
		end
	end
	Admin.Prefix = Config.Prefix
end

-- Plugins
LoadedPlugins = {}
PluginExtensions = {".luau", ".lua", ".txt", ".da"}

LoadPlugin = function(path, ignore)
	local Success, Plugin = pcall(function() return loadstring(readfile(format("dark-admin/plugins/%s", path)))() end)
	if not Success then
		Notify(format("plugin error for (%s)\nplease open console (F9) for the error", path))
		for i, v in next, LoadedPlugins do
			if v == path then
				LoadedPlugins[i] = nil
			end
		end
		UpdateConfig()
		warn("Plugin Error", format("(%s) -", path), Plugin)
		warn("Plugin Error", format("(%s) -", path), "Stack Traceback:", tostring(debug.traceback(Plugin)))
		Plugin = nil
		return
	end
	if Plugin ~= nil and type(Plugin) == "table" then
		spawn(function()
			if Plugin.Commands and type(Plugin.Commands) == "table" then
				for _, v in next, Plugin.Commands do
					if v.Name then
						local Requirements = v.Requirements or {}
						local Category = filter(Requirements, function(_, x) return type(x) == "string" and (x == CapitalizeFirstCharacters(x)) end)[1]
						local ArgsNeeded = tonumber(filter(Requirements, function(_, x) return type(x) == "number" end)[1])
						local CustomArgs = filter(Requirements, function(_, x) return type(x) == "table" end)[1]
						if Category == nil then
							if v.Category and type(v.Category) == "string" then
								v.Category = CapitalizeFirstCharacters(v.Category)
								insert(Requirements, v.Category)
							else
								insert(Requirements, "Misc")
							end
						end
						if ArgsNeeded == nil then
							if v.ArgsNeeded and type(v.ArgsNeeded) == "number" then
								insert(Requirements, v.ArgsNeeded)
							else
								insert(Requirements, 0)
							end
						end
						if CustomArgs == nil and v.CustomArgs ~= nil and type(v.CustomArgs) == "table" then
							insert(Requirements, v.CustomArgs)
						end
						AddCommand(v.Name, v.Usage or v.Name, v.Description or "N/A", v.Aliases or {}, Requirements, v.PermissionIndex or v.Permission or v.Perm or 2, v.Function or v.Func or function() end, path)
					end
				end
			end
		end)
		if ignore == false then
			if Plugin.Description then
				Notify((Plugin.Author and format("Author: %s\nName: %s\nDescription: %s", Plugin.Author, Plugin.Name, Plugin.Description)) or format("Name: %s\nDescription: %s", Plugin.Name, Plugin.Description), 10)
			else
				Notify((Plugin.Author and format("Author: %s\nName: %s", Plugin.Author, Plugin.Name)) or format("Name: %s", Plugin.Name))
			end
			UpdateConfig()
		end
	end
end

InstallPlugin = function(name, ignore)
	local file = false
	for _, extension in next, PluginExtensions do
		name = gsub(name, extension, "")
		if pcall(readfile, format("dark-admin/plugins/%s", name .. extension)) then
			file = name .. extension
			break
		end
	end
	if file then
		if not FindInTable(LoadedPlugins, file) then
			for i, v in next, Config.DisabledPlugins do
				if v == file then
					Config.DisabledPlugins[i] = nil
				end
			end
			insert(LoadedPlugins, file)
			LoadPlugin(file, ignore)
		else
			Notify(format("plugin (%s) already loaded", file))
		end
	end
end

UninstallPlugin = function(name)
	local file = false
	for _, extension in next, PluginExtensions do
		name = gsub(name, extension, "")
		if pcall(readfile, format("dark-admin/plugins/%s", name .. extension)) then
			file = name .. extension
			break
		end
	end
	if file then
		for i, v in next, Admin.Commands do
			if v.Plugin and v.Plugin == file then
				Admin.Commands[i] = nil
			end
		end
		for i, v in next, LoadedPlugins do
			if v == file then
				LoadedPlugins[i] = nil
				insert(Config.DisabledPlugins, file)
				UpdateConfig()
				Notify(format("plugin (%s) has been removed", file))
			end
		end
	end
end

-- Gui
Gui = Services.InsertService:LoadLocalAsset("rbxassetid://12252343699"):Clone()
ParentObject(Gui)
Gui.Enabled = true
Gui = fakeRequire(Gui.UI)
Notify = Gui.Message
local CommandBarFrame = Gui.BaseObject.CommandBar
local CommandBar = CommandBarFrame.Input
local Prediction = CommandBar.Predict
CommandBarFrame.Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, 5)
CommandBarFrame.Size = UDim2.new(0, Config.Widebar and 400 or 200, 0, 35)

local MatchSearch = function(str1, str2)
	return str1 == sub(str2, 1, #str1)
end

local StringFind = function(tbl, str)
	if type(tbl) == "table" then
		for _, v in ipairs(tbl) do
			if MatchSearch(str, v) then
				return v
			end
		end
	end
end

local PlayerArgs = function(argument)
	argument = lower(tostring(argument))
	return StringFind(Admin.PredictionCases, argument) or (function()
		for _, v in ipairs(Players:GetPlayers()) do
			local name = lower(tostring(v.Name))
			if MatchSearch(argument, name) then return name end
		end
	end)()
end

AddConnection(CommandBar.FocusLost, function()
	Prediction.Text = ""
	RemoveConnection("tab complete")
end)

AddConnection(CommandBar:GetPropertyChangedSignal("Text"), function()
	if Config.LoweredText then CommandBar.Text = lower(CommandBar.Text) end
	Prediction.Text = ""
	local InputText = CommandBar.Text
	local Args = split(InputText, " ")
	local CmdArgs = Admin.CommandArgs or {}
	if InputText == "" then return end
	for _, v in next, Admin.Commands do
		local FoundAlias = false
		if MatchSearch(Args[1], v.Name) then
			Prediction.Text = v.Name
			Admin.CommandArgs = #v.CustomArgs ~= 0 and v.CustomArgs or {}
			break
		end
		for _, v2 in next, v.Alias do
			if MatchSearch(Args[1], v2) then
				FoundAlias = true
				Prediction.Text = v2
				Admin.CommandArgs = #v.CustomArgs ~= 0 and v.CustomArgs or {}
				break
			end
			if FoundAlias then break end
		end
		for _, v2 in next, MiscConfig.CustomAlias do
			if MatchSearch(Args[1], v2.Alias) then
				FoundAlias = true
				Prediction.Text = v2.Alias
				Admin.CommandArgs = #v.CustomArgs ~= 0 and v.CustomArgs or {}
				break
			end
			if FoundAlias then break end
		end
	end
	for i, v in next, Args do
		if i > 1 and v ~= "" then
			local Predict = ""
			if #Admin.CommandArgs >= 1 then
				for i2, v2 in next, Admin.CommandArgs do
					if lower(tostring(v2)) == "player" then
						Predict = PlayerArgs(v) or Predict
					else
						Predict = MatchSearch(v, v2) and v2 or Predict
					end
				end
			else
				Predict = PlayerArgs(v) or Predict
			end
			Prediction.Text = sub(InputText, 1, #InputText - #Args[#Args]) .. Predict
			local split = split(v, ",")
			if next(split) then
				for i2, v2 in next, split do
					if i2 > 1 and v2 ~= "" then
						Prediction.Text = sub(InputText, 1, #InputText - #split[#split]) .. (PlayerArgs(v2) or "")
					end
				end
			end
		end
	end
end)

AddConnection(CommandBar.Focused, function()
	AddConnection("tab complete", UserInputService.InputBegan, function(input)
		if CommandBar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Tab then
                	if CommandBar.Text == "" or CommandBar.Text == " " then
                    	renderstepped:Wait()
                    	CommandBar.Text = ""
                	end
					if Prediction.Text == "" or Prediction.Text == " " then
                	else
					CommandBar.Text = Prediction.Text .. " "
					wait()
					CommandBar.Text = gsub(CommandBar.Text, "\t", "")
					CommandBar.CursorPosition = #CommandBar.Text + 1
				end
			end
		else
			RemoveConnection("tab complete")
		end
	end)
end)

TweenObj = function(obj, style, direction, cd, goal)
	local tweeninfo = TweenInfo.new(cd, Enum.EasingStyle[style], Enum.EasingDirection[direction])
	local Tween = TweenService:Create(obj, tweeninfo, goal)
	Tween:Play()
	return Tween
end

AddConnection(CommandBar.FocusLost, function(enterPressed)
	if enterPressed then
		local Command = gsub(CommandBar.Text, "^" .. "%" .. Admin.Prefix, "")
		TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, 5)})
		spawn(function() ExecuteCommand(Command, LocalPlayer, true) end)
	end
	wait()
	if not CommandBar:IsFocused() then CommandBar.Text = "" end
end)

AddConnection(UserInputService.InputBegan, function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode[Config.CommandBarPrefix] then
		CommandBar:CaptureFocus()
		spawn(function()
			repeat
				CommandBar.Text = ""
				RunService.RenderStepped:Wait()
			until CommandBar.Text == ""
		end)
		TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, -110)})
	end
end)

AddConnection(UserInputService.InputBegan, function(input, processed)
	if CommandBar:IsFocused() and processed then
		if input.KeyCode == Enum.KeyCode.Up then
			HistoryCount = HistoryCount + 1
			if HistoryCount > #Admin.History then HistoryCount = #Admin.History end
			local command = Admin.History[HistoryCount]
			CommandBar.Text = (command and command .. " ") or ""
			CommandBar.CursorPosition = #CommandBar.Text + 2
		elseif input.KeyCode == Enum.KeyCode.Down then
			HistoryCount = HistoryCount - 1
			if HistoryCount < 0 then HistoryCount = 0 end
			local command = Admin.History[HistoryCount]
			CommandBar.Text = (command and command .. " ") or ""
			CommandBar.CursorPosition = #CommandBar.Text + 2
		end
	end
end)

-- Commands
AddCommand("debug", "debug", "Toggles the script's debug mode for commands.", {}, {"Core"}, 2, function(args, speaker)
	Admin.Debug = not Admin.Debug
	Notify(format("debug %s", Admin.Debug and "enabled" or "disabled"))
end)

AddCommand("killscript", "killscript", "Completely uninjects the script.", {}, {"Core"}, 2, function(args, speaker)
    cons.wipe()
    Gui.BaseObject:Destroy()
    RunCommandFunctions(map(Admin.Commands, function(_, v) return v.Name end), true)
    getgenv().dxrkj = nil
end)

AddCommand("reloadscript", "reloadscript", "Completely uninjects the script and re-executes it.", {}, {"Core"}, 2, function(args, speaker)
	ExecuteCommand("killscript")
	cwrap(function()
		local success, result = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/init.lua") end)
		local file, data = pcall(readfile, "dark-admin/init.lua")
		if file then loadstring(data)() elseif success then loadstring(result)() end
	end)()
end)

AddCommand("helpmenu", "helpmenu", "Get started using the script.", {"help"}, {"Core"}, 2, function()
	local Section = Gui.New("Help"):AddSection("Section")
	Section:AddItem("Text", {Text = "Get started", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	Section:AddItem("Text", {Text = "Run 'cmds' to view all available commands"})
	Section:AddItem("Button", {Text = "(Optional button to open the list)", Function = function() ExecuteCommand("commands") end})
	Section:AddItem("Text", {Text = "See a command's information", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	Section:AddItem("Text", {Text = "Click a command in the command list to view its information."})
	Section:AddItem("Text", {Text = "Optionally, you can run 'cmdinfo name' to view its information."})
	Section:AddItem("Text", {Text = "Change 'name' to the name of the command you want to view."})
	Section:AddItem("Text", {Text = "Open main interface", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	Section:AddItem("Text", {Text = "Run 'ui' to open main interface"})
	Section:AddItem("Button", {Text = "(Optional button to open the ui)", Function = function() ExecuteCommand("ui") end})
	Section:AddItem("Text", {Text = "The main interface has useful shortcuts to some commands like chatlogs, changelogs, etc."})
end)

AddCommand("ui", "ui", "Quick access to most things.", {}, {"Core"}, 2, function()
	local Section = Gui.New("UI"):AddSection("Section")
	Section:AddItem("InputBox", {
		Text = "Prefix",
		Default = Admin.Prefix,
		Function = function(text, object)
			if text == "" or text == " " then object.Back.Input.Text = Admin.Prefix return end
			text = GetStringFromKeyCode(text)
			text = LastKey(text) == "Colon" and Enum.KeyCode.Semicolon or text
			Admin.Prefix = UserInputService:GetStringForKeyCode(text)
			Config.Prefix = UserInputService:GetStringForKeyCode(text)
			Config.CommandBarPrefix = LastKey(text)
			UpdateConfig()
			Notify(format("prefix has been changed to %s (%s)", Config.CommandBarPrefix, Admin.Prefix))
		end,
		Typing = function(text, object)
			if #text <= 2 then object.Back.Input.Text = sub(text, 1, 1) end
			object.Back.Input.Text = upper(object.Back.Input.Text)
		end
	})
	Section:AddItem("Button", {Text = "Commands", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("commands") end})
	Section:AddItem("Button", {Text = "Plugins", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("pluginlist") end})
	Section:AddItem("Button", {Text = "Plugin Browser", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("browser") end})
	Section:AddItem("Button", {Text = "Keybinds", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("keybinds") end})
	Section:AddItem("Button", {Text = "Event Binds", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("eventeditor") end})
	Section:AddItem("Button", {Text = "Chatlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("chatlogs") end})
	Section:AddItem("Button", {Text = "Joinlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("joinlogs") end})
	Section:AddItem("Button", {Text = "Changelogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("changelogs") end})
	Section:AddItem("Toggle", {Text = "Keep Admin", Default = Config.KeepAdmin, Function = function(callback)
		Config.KeepAdmin = callback
		UpdateConfig()
	end})
	Section:AddItem("Toggle", {Text = "Widebar", Default = Config.Widebar, Function = function(callback)
		Config.Widebar = callback
		TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {Position = UDim2.new(0.5, callback and -200 or -100, 1, 5)})
		TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {Size = UDim2.new(0, callback and 400 or 200, 0, 35)})
		UpdateConfig()
	end})
	Section:AddItem("Toggle", {Text = "Lowercased Commandbar Text", Default = Config.LoweredText, Function = function(callback)
		Config.LoweredText = callback
		UpdateConfig()
	end})
	Section:AddItem("Toggle", {Text = "Startup Notification", Default = Config.StartupNotification, Function = function(callback)
		Config.StartupNotification = callback
		UpdateConfig()
	end})
end)

AddCommand("keybinds", "keybinds", "Opens a gui so you can bind commands to certain keys.", {}, {"Core"}, 2, function()
	local Container = Gui.New("Keybinds")
	local Section = Container:AddSection("Section")
	local Current = {nil, nil}
	local Command = Section:AddItem("InputBox", {Text = "Command"})
	local PlaceId = Section:AddItem("InputBox", {Text = "PlaceId or GameId (Optional)", Typing = function(text, object) if not tonumber(text) then object.Back.Input.Text = "" end end})
	Section:AddItem("ButtonText", {Text = "Insert Current PlaceId", Function = function() PlaceId.Object.Back.Input.Text = game.PlaceId end})
	Section:AddItem("ButtonText", {Text = "Insert Current GameId", Function = function() PlaceId.Object.Back.Input.Text = game.GameId end})
	local Key = Section:AddItem("InputKey", {
		Text = "Key",
		Function = function(text, object)
			object.Back.Input.Text = "..."
			local listen, OldShiftLock = nil, LocalPlayer.DevEnableMouseLock
			LocalPlayer.DevEnableMouseLock = false
			listen = AddConnection(UserInputService.InputBegan, function(input, processed)
				if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
					local input2, processed2 = nil, nil
					cwrap(function()
						input2, processed2 = UserInputService.InputBegan:Wait()
					end)()
					UserInputService.InputEnded:Wait()
					if input2 and not processed2 then
						object.Back.Input.Text = format("%s + %s", LastKey(input.KeyCode), LastKey(input2.KeyCode))
						Current[1] = LastKey(input.KeyCode)
						Current[2] = LastKey(input2.KeyCode)
					else
						object.Back.Input.Text = LastKey(input.KeyCode)
						Current[1] = LastKey(input.KeyCode)
						Current[2] = nil
					end
					listen:Disconnect()
					LocalPlayer.DevEnableMouseLock = OldShiftLock
				end
			end)
		end
	})
	Key.Object.Back.Input.Text = "bind"
	Section:AddItem("Button", {Text = "Add Keybind", Function = function()
		local input = Command.Object.Back.Input.Text
		local command = FindCommand(split(input, " ")[1])
		local bind = Key.Object.Back.Input.Text
		if bind == "bind" or bind == "..." then return Notify("missing keybind") end
		if command then
			local place = (PlaceId.Object.Back.Input.Text == "" and nil) or tonumber(PlaceId.Object.Back.Input.Text)
			local key, key2 = Current[1], Current[2]
			if key ~= nil then
				insert(MiscConfig.Keybinds, {Command = input, Game = place, Keys = {key, key2}})
				UpdateMiscConfig()
				if key2 ~= nil then
					Notify(format("binded '%s' to (%s + %s)", command.Name, key, key2))
				else
					Notify(format("binded '%s' to (%s)", command.Name, key))
				end
			else
				Notify("missing a key to bind for keybinds")
			end
		else
			Notify("missing command for keybinds")
		end
	end})
	Section:AddItem("Button", {Text = "Manage Keybinds", Function = function()
		Container.Close()
		Container = Gui.New("Manage Keybinds")
		Section = Container:AddSection("Section")
		Section:AddItem("Button", {Text = "Back to Keybinds", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
			Container.Close()
			ExecuteCommand("keybinds")
		end})
		Section:AddItem("Text", {Text = "Click one of the following to delete it"})
		for _, v in next, MiscConfig.Keybinds do
			local keys = #v.Keys == 2 and format("(%s + %s)", v.Keys[1], v.Keys[2]) or format("(%s)", v.Keys[1])
			Section:AddItem("ButtonText", {
				Text = v.Game ~= nil and format("%s [%s] %s", v.Command, v.Game, keys) or format("%s %s", v.Command, keys),
				Function = function()
					for i2, v2 in next, MiscConfig.Keybinds do
						if v2.Command == v.Command and v2.Game == v.Game then
							if #v2.Keys == 2 then
								if FindInTable(v2.Keys, v.Keys[1]) and FindInTable(v2.Keys, v.Keys[2]) then
									MiscConfig.Keybinds[i2] = nil
									UpdateMiscConfig()
									Notify("unbinded (re-open this window to refresh)")
								end
							else
								if FindInTable(v2.Keys, v.Keys[1]) then
									MiscConfig.Keybinds[i2] = nil
									UpdateMiscConfig()
									Notify("unbinded (re-open this window to refresh)")
								end
							end
						end
					end
				end
			})
		end
	end})
end)

AddCommand("addplugin", "addplugin [name]", "Adds a plugin. A plugin is a file in the admin's plugins folder (dark-admin -> plugins) located in your executor's workspace folder. The provided argument is the file name with or without the file extension.", {}, {"Core", 1}, 2, function(args, speaker)
	InstallPlugin(getstring(1), false)
end)

AddCommand("removeplugin", "removeplugin [name]", "Removes a plugin. A plugin is a file in the admin's plugins folder (dark-admin -> plugins) located in your executor's workspace folder. The provided argument is the file name with or without the file extension.", {}, {"Core", 1}, 2, function(args, speaker)
	UninstallPlugin(getstring(1))
end)

AddCommand("commands", "commands", "Opens the command list.", {"cmds"}, {"Core"}, 2, function()
    local list = {}
    for _, command in next, Admin.Commands do
        local category = command.Category or "Misc"
        if not list[category] then list[category] = {} end
        list[category][command.Name] = {
            Name = lower(tostring(command.Usage)),
            Function = function()
                ExecuteCommand(format("commandinfo %s", lower(tostring(command.Name))))
            end
        }
    end
    Gui.DisplayTable("Commands", list)
end)

AddCommand("commandinfo", "commandinfo [command]", "Opens more information about [command].", {"cmdinfo", "cinfo"}, {"Core", 1}, 2, function(args)
	local command = FindCommand(lower(tostring(args[1])))
	if command then
		Gui.DisplayTable("Command Info", {
			format("Name: %s", command.Name or "command"),
			format("Category: %s", command.Category or "Misc"),
			format("Permission Index: %d", command.PermissionIndex or 2),
			format("Usage: %s", command.Usage or command.Name),
			format("This command requires %d argument(s)", command.ArgsNeeded or 0),
			#command.Alias > 0 and {"Aliases", unpack(command.Alias)} or "This command has no aliases",
			(command.Description == "N/A" and "No description provided") or (command.Description and {"Description", command.Description}) or "No description provided",
			{"Permission Index", "2 - Only you can run the command\n1 - Only you and whitelisted players can run the command\n0 - Everyone in the server can run the command"}
		})
	end
end)

AddCommand("changelogs", "changelogs", "Opens a list of the script changelogs.", {"changelog"}, {"Core"}, 2, function()
	Gui.DisplayTable("Changelog", HttpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/changelog.json")))
end)

AddCommand("editpermissions", "editpermissions [command] [number]", "Changes the permission index of [command] to [number].", {"editperms"}, {"Core", 2}, 2, function(args)
	local command, perm = FindCommand(lower(tostring(args[1]))), tonumber(args[1])
	if command and perm then
		if perm >= 2 then perm = 2 end
		command.PermissionIndex = perm
		MiscConfig.Permissions[command.Name] = perm
		UpdateMiscConfig()
		Notify(format("set permission of %s to %d", command.Name, perm))
	end
end)

AddCommand("whitelist", "whitelist [player]", "Whitelists [player] to use permission index 1 commands.", {}, {"Core", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			Admin.Whitelisted[tostring(target.UserId)] = {Player = target, Value = true}
			Notify(format("whitelisted %s", GetLongUsername(target)))
		end
	end
end)

AddCommand("unwhitelist", "unwhitelist [player]", "Un-whitelists [player] from using permission index 1 commands.", {}, {"Core", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			Admin.Whitelisted[tostring(target.UserId)] = nil
			Notify(format("removed the whitelist for %s", GetLongUsername(target)))
		end
	end
end)

AddCommand("whitelisted", "whitelisted", "Opens a list of the current players that can use permission index 1 commands.", {}, {"Core"}, 2, function()
	local list = map(Admin.Whitelisted, function(_, v) return GetLongUsername(v.Player) end)
	if #list == 0 then Notify("no players are currently whitelisted") else Gui.DisplayTable("Whitelisted", list) end
end)

AddCommand("lowercasedcommandbar", "lowercasedcommandbar", "Makes all future text in the command bar lowercased.", {}, {"Core"}, 2, function()
	Config.LoweredText = true
	UpdateConfig()
end)

AddCommand("unlowercasedcommandbar", "unlowercasedcommandbar", "Undoes lowercasedcommandbar.", {}, {"Core"}, 2, function()
	Config.LoweredText = false
	UpdateConfig()
end)

AddCommand("chatlogs", "chatlogs", "Opens a list to view the server's chat history.", {"clogs"}, {"Core"}, 2, function(_, _, env)
	local Loaded = GetEnvironment("chatlogs")[1]
	if Loaded and Loaded.Container and Loaded.Section then Loaded.Container.Close() end
	local Container = Gui.Log("Chatlogs", function() env[1] = nil end, true)
	local Section = Container:AddSection("Section")
	Section:AddItem("Button", {Text = "Save Chatlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("savechatlogs") end})
	Section:AddItem("Button", {Text = "Clear Chatlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("clearchatlogs") end})
	spawn(function()
		for _, v in next, ChatHistory do
			local log = format("[%s]: %s", v.Name, v.Message)
			Section:AddItem("ButtonText", {Text = log, Function = function() toexecutorclipboard(log) end})
		end
	end)
	env[1] = {Container = Container, Section = Section}
	wait()
	Container.SectionContainer.CanvasPosition = Vector2.new(0, Container.SectionContainer.CanvasSize.Y.Offset + 1000)
end)

AddCommand("savechatlogs", "savechatlogs", "If you don't want to scroll up in the chatlogs to save it, this exists.", {}, {"Core"}, 2, function()
	if #ChatHistory == 0 then return Notify("no chat history available") end
	local os = os.date("*t")
	local date = os.hour .. " " .. os.min .. " " .. os.sec .. " " .. os.day .. "." .. os.month .. "." .. os.year
	local name = CleanSpecials(Services.MarketplaceService:GetProductInfo(game.PlaceId).Name)
	local data = format("Chatlogs for \"%s\"\n\n\n\n", name)
	for _, v in next, ChatHistory do data = data .. format("[%s]: %s\n", v.Name, v.Message) end
	local success, result = pcall(function() writefile(format("dark-admin/logs/%s - %s.txt", name, date), data) end)
	if success then
		Notify("successfully saved chatlogs")
	else
		warn("Save Error:", result)
		Notify("failed to save chatlogs, check console for more info")
	end
end)

AddCommand("clearchatlogs", "clearchatlogs", "Clears the chatlogs.", {}, {"Core"}, 2, function()
	for log in next, ChatHistory do ChatHistory[log] = nil end
	local Loaded = GetEnvironment("chatlogs")[1]
	if Loaded and Loaded.Container and Loaded.Section then
		Loaded.Container.Close()
		ExecuteCommand("chatlogs")
	end
end)

AddCommand("joinlogs", "joinlogs", "Opens a list to view the server's join history.", {"jlogs"}, {"Core"}, 2, function(_, _, env)
	local Loaded = GetEnvironment("joinlogs")[1]
	if Loaded and Loaded.Container and Loaded.Section then Loaded.Container.Close() end
	local Container = Gui.Log("Joinlogs", function() env[1] = nil end, true)
	local Section = Container:AddSection("Section")
	Section:AddItem("Button", {Text = "Save Joinlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("savejoinlogs") end})
	Section:AddItem("Button", {Text = "Clear Joinlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function() ExecuteCommand("clearjoinlogs") end})
	spawn(function()
		for _, v in next, JoinHistory do
			local log = format("[%s] %s", v.Name, v.Message)
			Section:AddItem("ButtonText", {Text = log, Function = function() toexecutorclipboard(log) end})
		end
	end)
	env[1] = {Container = Container, Section = Section}
	wait()
	Container.SectionContainer.CanvasPosition = Vector2.new(0, Container.SectionContainer.CanvasSize.Y.Offset + 1000)
end)

AddCommand("savejoinlogs", "savejoinlogs", "If you don't want to scroll up in the joinlogs to save it, this exists.", {}, {"Core"}, 2, function()
	if #JoinHistory == 0 then return Notify("no chat history available") end
	local os = os.date("*t")
	local date = os.hour .. " " .. os.min .. " " .. os.sec .. " " .. os.day .. "." .. os.month .. "." .. os.year
	local name = CleanSpecials(Services.MarketplaceService:GetProductInfo(game.PlaceId).Name)
	local data = format("Joinlogs for \"%s\"\n\n\n\n", name)
	for _, v in next, JoinHistory do data = data .. format("[%s] %s\n", v.Name, v.Message) end
	local success, result = pcall(function() writefile(format("dark-admin/logs/%s - %s.txt", name, date), data) end)
	if success then
		Notify("successfully saved joinlogs")
	else
		warn("Save Error:", result)
		Notify("failed to save joinlogs, check console for more info")
	end
end)

AddCommand("clearjoinlogs", "clearjoinlogs", "Clears the joinlogs.", {}, {"Core"}, 2, function()
	for log in next, JoinHistory do JoinHistory[log] = nil end
	local Loaded = GetEnvironment("joinlogs")[1]
	if Loaded and Loaded.Container and Loaded.Section then
		Loaded.Container.Close()
		ExecuteCommand("joinlogs")
	end
end)

AddConnection(LocalPlayer.OnTeleport, function()
	if Config.KeepAdmin and queue_on_teleport then
		queue_on_teleport([[local success, result = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/init.lua") end)
local file, data = pcall(readfile, "dark-admin/init.lua")
if file then loadstring(data)() elseif success then loadstring(result)() end]])
	end
end)
AddCommand("keepadmin", "keepadmin", "Makes it so the script re-executes upon teleporting. This is a toggle and saves.", {}, {"Core"}, 2, function()
	Config.KeepAdmin = not Config.KeepAdmin
	UpdateConfig()
	Notify(format("keep admin has been %s", Config.KeepAdmin and "enabled\nthe script will execute when you teleport" or "disabled"))
end)

AddCommand("startupnotification", "startupnotification", "Toggles if the script does the loaded notification. This is a toggle and saves.", {}, {"Core"}, 2, function()
	Config.StartupNotification = not Config.StartupNotification
	UpdateConfig()
	Notify(format("startup notification has been %s", Config.StartupNotification and "enabled" or "disabled"))
end)

AddCommand("widebar", "widebar", "Widens the command bar. This is a toggle and saves.", {}, {"Core"}, 2, function()
	Config.Widebar = not Config.Widebar
	TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, 5)})
	TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {Size = UDim2.new(0, Config.Widebar and 400 or 200, 0, 35)})
	UpdateConfig()
end)

AddCommand("breakloops", "breakloops", "Stops all command loops (inf^1^kill).", {}, {"Core"}, 2, function()
	LastBreakTime = tick()
end)

AddCommand("pluginlist", "pluginlist", "Opens a list of your plugins.", {"plugins"}, {"Core"}, 2, function()
	local Container = Gui.New("Plugins")
	local Section = Container:AddSection("Section")
	local View = function(name)
		Container.Close()
		Container = Gui.New("Plugin Info")
		Section = Container:AddSection("Section")
		Section:AddItem("Button", {Text = "Back to Plugins", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
			Container.Close()
			ExecuteCommand("pluginlist")
		end})
		Section:AddItem("Text", {Text = format("Name: %s", name)})
		Section:AddItem("Button", {Text = "Enable Plugin", Function = function() InstallPlugin(name, false) end})
		Section:AddItem("Button", {Text = "Disable Plugin", Function = function() UninstallPlugin(name) end})
	end
	Section:AddItem("Text", {Text = "Enabled Plugins", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	if #LoadedPlugins > 0 then
		for _, v in next, LoadedPlugins do Section:AddItem("ButtonText", {Text = v, Function = function() View(v) end}) end
	else
		Section:AddItem("Text", {Text = "None"})
	end
	Section:AddItem("Text", {Text = "Disabled Plugins", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	if #Config.DisabledPlugins > 0 then
		for _, v in next, Config.DisabledPlugins do Section:AddItem("ButtonText", {Text = v, Function = function() View(v) end}) end
	else
		Section:AddItem("Text", {Text = "None"})
	end
end)

AddCommand("addalias", "addalias [alias] [command]", "Makes [alias] an alias of [command].", {}, {"Core", 2}, 2, function(args)
	local alias, command = lower(tostring(args[1])), FindCommand(args[2])
	if alias and command then
		insert(MiscConfig.CustomAlias, {Alias = alias, Name = command.Name})
		UpdateMiscConfig()
		Notify(format("added alias (%s) to command (%s)", alias, command.Name))
	else
		Notify("command does not exist")
	end
end)

AddCommand("removealias", "removealias [alias]", "Removes the custom alias [alias].", {}, {"Core", 1}, 2, function(args)
	local alias = lower(tostring(args[1]))
	for i, v in next, MiscConfig.CustomAlias do
		if v.Alias == alias then
			MiscConfig.CustomAlias[i] = nil
			Notify(format("removed alias (%s) from command (%s)", alias, v.Name))
		end
	end
	UpdateMiscConfig()
end)

AddCommand("customaliases", "customaliases", "Opens a list of your custom alaises.", {"aliases"}, {"Core"}, 2, function()
	if #MiscConfig.CustomAlias == 0 then
		Notify("you have no custom aliases")
	else
		local new = {}
		for _, v in next, MiscConfig.CustomAlias do
			local tab = v.Name
			if not new[tab] then new[tab] = {} end
			new[tab][v.Alias] = v.Alias
		end
		Gui.DisplayTable("Custom Aliases", new)
	end
end)

AddCommand("browser", "browser", "Opens the pre-provided plugin browser.", {}, {"Core"}, 2, function()
	local success, list = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/browser-plugins.json") end)
	if success then
		list = HttpService:JSONDecode(list)
		local Container = Gui.New("Plugin Browser")
		local Section = Container:AddSection("Section")
		local View = function(name, description, ext)
			Container.Close()
			Container = Gui.New("Plugin Info")
			Section = Container:AddSection("Section")
			Section:AddItem("Button", {Text = "Back to Browser", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
				Container.Close()
				ExecuteCommand("browser")
			end})
			local file = format("browser-%s.lua", gsub(CleanSpecials(lower(tostring(name))), " ", ""))
			Section:AddItem("Text", {Text = format("Name: %s", name)})
			Section:AddItem("Button", {Text = "Enable Plugin", Function = function()
				local exists = pcall(readfile, format("dark-admin/plugins/browser/%s", file))
				if exists then
					InstallPlugin(file, false)
				else
					writefile(format("dark-admin/plugins/%s", file), format("return loadstring(game:HttpGet(\"https://raw.githubusercontent.com/daximul/v2/main/src/browser/%s\"))()", ext))
					wait(0.1)
					InstallPlugin(file, false)
				end
			end})
			Section:AddItem("Button", {Text = "Disable Plugin", Function = function()
				UninstallPlugin(file)
				wait(0.1)
				pcall(delfile, format("dark-admin/plugins/%s", file))
				for i, v in next, Config.DisabledPlugins do
					if v == file then
						Config.DisabledPlugins[i] = nil
					end
				end
				UpdateConfig()
			end})
			if description then
				Container:AddSection("Description", "Dropdown"):AddElement(nil, description)
			else
				Section:AddItem("Text", {Text = "No description provided"})
			end
		end
		for _, v in next, list do
			Section:AddItem("ButtonText", {Text = v.Name, Function = function()
				View(v.Name, v.Description, v.Ext)
			end})
		end
	end
end)

Events = (function()
	local events = {}
	local register = function(name, sets) events[name] = {commands = {}, sets = sets or {}} end
	local fire = function(name, ...)
		local args = {...}
		local event = events[name]
		if event then
			for _, command in next, event.commands do
				local valid = true
				for i, set in next, event.sets do
					local val = args[i]
					local stype = set.Type
					set = command[2][i]
					if stype == "Player" then
						if set == 0 then
							valid = valid and (LocalPlayer.Name == val)
						elseif set ~= 1 then
							valid = valid and tfind(getPlayer(set, LocalPlayer), val)
						end
					elseif stype == "String" then
						if set ~= 0 then
							valid = valid and find(lower(val), lower(set))
						end
					elseif stype == "Number" then
						if set ~= 0 then
							valid = valid and (tonumber(val) <= tonumber(set))
						end
					end
					if not valid then break end
				end
				if valid then
					pcall(coroutine.wrap(function()
						local str = command[1]
						for num, arg in next, args do str = gsub(str, "%$" .. num, arg) end
						wait(command[3] or 0)
						ExecuteCommand(str)
					end))
				end
			end
		end
	end
	local save = function()
		for i, v in next, events do
			MiscConfig.Events[i] = v.commands
		end
	end
	local load = function(str)
		for i, v in pairs(MiscConfig.Events) do
			if events[i] then
				events[i].commands = v
			end
		end
	end
	local default = function(ev)
		local res = {}
		for _, v in next, ev.sets do
			if v.Type == "Player" then
				res[#res + 1] = v.Default or 0
			elseif v.Type == "String" then
				res[#res + 1] = v.Default or 0
			elseif v.Type == "Number" then
				res[#res + 1] = v.Default or 0
			end
		end
		return res
	end
	AddCommand("eventeditor", "eventeditor", "Handle events that run when a specific action is performed.", {"eventbinds"}, {"Core"}, 2, function(_, _, env)
		local Loaded = GetEnvironment("eventeditor")[1]
		if Loaded and Loaded.Container and Loaded.Section then Loaded.Container.Close() end
		local Container = Gui.New("Events", function() env[1] = nil end)
		local Section = Container:AddSection("Section")
		env[1] = {Container = Container, Section = Section}
		for name, event in next, events do
			Section:AddItem("ButtonText", {Text = name .. (#event.commands > 0 and " (" .. #event.commands .. ")" or ""), TextXAlignment = Enum.TextXAlignment.Center, Function = function()
				Container.Close()
				Container = Gui.New(name, function() env[1] = nil end)
				Section = Container:AddSection("Section")
				Section:AddItem("ButtonText", {Text = "Back to Event Editor", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
					Container.Close()
					ExecuteCommand("eventeditor")
				end})
				local input = Section:AddItem("InputBox", {Text = "Command"})
				Section:AddItem("Button", {Text = "Add Above Event", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
					local text = tostring(input.Object.Back.Input.Text)
					if text ~= "" and text ~= " " then
						event.commands[#event.commands + 1] = {text, default(event), 0}
						save()
						UpdateMiscConfig()
						Notify(format("added event (%s)\nre-open (%s) to refresh list", text, name))
					else
						input.Object.Back.Input.Text = ""
					end
				end})
				if #event.commands > 0 then Section:AddItem("Text", {Text = "Events", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1}) end
				for i, command in next, event.commands do
					Section:AddItem("ButtonText", {Text = command[1], Function = function()
						Container.Close()
						Container = Gui.New(name, function() env[1] = nil end)
						Section = Container:AddSection("Section")
						Section:AddItem("Button", {Text = "Back to Event Editor", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
							Container.Close()
							ExecuteCommand("eventeditor")
						end})
						local preview = Section:AddItem("InputBox", {Text = "Command", Function = function(text) command[1] = text end})
						preview.Object.Back.Input.Text = command[1]
						local delayed = Section:AddItem("InputBox", {Text = "Delay (s)", Function = function(text)
							command[3] = tonumber(text)
						end, Typing = function(text, object) if not tonumber(text) then object.Back.Input.Text = sub(text, 1, 1) end end})
						delayed.Object.Back.Input.Text = tostring(command[3])
						for _, x in next, event.sets do
							local stype = x.Type
							if stype == "Player" then
								Section:AddItem("Text", {Text = x.Name or "Player", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
								Section:AddItem("Button", {Text = "Me Only", Function = function()
									command[2][i] = 0
									Notify("updated")
								end})
								Section:AddItem("Button", {Text = "Any Player", Function = function()
									command[2][i] = 1
									Notify("updated")
								end})
								local custom = Section:AddItem("InputBox", {Text = "Custom Player", Function = function(text, object)
									command[2][i] = text
									Notify("updated")
								end})
								local val = command[2][1]
								if val ~= 0 and val ~= 1 then custom.Object.Back.Input.Text = val end
							elseif stype == "String" then
								Section:AddItem("Text", {Text = x.Name or "String", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
								Section:AddItem("Button", {Text = "Any String", Function = function()
									command[2][i] = 0
									Notify("updated")
								end})
								local custom = Section:AddItem("InputBox", {Text = "Custom String", Function = function(text)
									command[2][i] = text
									Notify("updated")
								end})
								local val = command[2][1]
								if val ~= 0 and val ~= 1 then custom.Object.Back.Input.Text = val end
							elseif stype == "Number" then
								Section:AddItem("Text", {Text = x.Name or "Number", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
								Section:AddItem("Button", {Text = "Any Number", Function = function()
									command[2][i] = 0
									Notify("updated")
								end})
								local custom = Section:AddItem("InputBox", {Text = "Custom Number", Function = function(text)
									command[2][i] = tonumber(text)
									Notify("updated")
								end, Typing = function(text, object) if not tonumber(text) then object.Back.Input.Text = sub(text, 1, 1) end end})
								if val ~= 0 then custom.Object.Back.Input.Text = val end
							end
						end
						Section:AddItem("Text", {Text = "Event", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
						Section:AddItem("ButtonText", {Text = "Remove", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
							remove(event.commands, i)
							save()
							UpdateMiscConfig()
							Container.Close()
							ExecuteCommand("eventeditor")
							Notify("removed event")
						end})
						Section:AddItem("ButtonText", {Text = "Update", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
							save()
							UpdateMiscConfig()
							Notify("updated event and saved")
						end})
					end})
				end
			end})
		end
	end)
	return {Register = register, Fire = fire, Save = save, Load = load}
end)()
Events.Register("OnExecute")
Events.Register("OnChatted", {{Type = "Player", Name = "Player Filter ($1)", Default = 1}, {Type = "String", Name = "Message Filter ($2)"}})
Events.Register("OnSpawn", {{Type = "Player", Name = "Player Filter ($1)"}})
Events.Register("OnDied", {{Type = "Player", Name = "Player Filter ($1)"}})
Events.Register("OnDamage", {{Type = "Player", Name = "Player Filter ($1)"}, {Type = "Number", Name = "Below Health ($2)"}})
Events.Register("OnKilled", {{Type = "Player", Name = "Victim Player ($1)"}, {Type = "String", Name = "Killer Player ($2)", Default = 1}})
Events.Register("OnJoin", {{Type = "Player", Name = "Player Filter ($1)", Default = 1}})
Events.Register("OnLeave", {{Type = "Player", Name = "Player Filter ($1)", Default = 1}})

AddCommand("toggle", "toggle [command 1] [command 2]", "Runs [command 1]. When ran again, runs [command 2]. Recommended that command 1 is something like fly and command 2 is like unfly.", {}, {"Toggle", 2}, 2, function(args)
	ExecuteCommand(#GetEnvironment(args[1]) == 0 and args[1] or args[2])
end)

AddCommand("viewtools", "viewtools [player]", "Views the tools of [player].", {}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			local backpack, tools = GetBackpack(target), {}
			if backpack then Gui.DisplayTable(format("Tools (%s)", GetUsername(target)), map(filter(backpack:GetChildren(), function(_, v) return v:IsA("Tool") or v:IsA("HopperBin") end), function(_, v) return v.Name end)) end
		end
	end
end)

AddCommand("fly", "fly", "Makes your character able to fly. Tap [Space] to go up. Tap [LeftControl] to go down.", {}, {"Utility", "spawned"}, 2, function(_, _, env)
	ExecuteCommand("unfly")
	local character, humanoid, root = GetCharacter(), GetHumanoid(), GetRoot()
	if not character or not humanoid or not root then return end
	local BodyGyroName, BodyVelocityName, MaxSpeed = RandomString(), RandomString(), function() return Config.FlySpeed * 50 end
	local Controls = {Front = 0, Back = 0, Left = 0, Right = 0, Down = 0, Up = 0}
	local Keys = {
		W = function(t)
			Controls.Front = clamp(Controls.Front + (t and 1 or -1), 0, MaxSpeed())
		end,
		A = function(t)
			Controls.Left = clamp(Controls.Left + (t and -1 or 1), -MaxSpeed(), 0)
		end,
		S = function(t)
			Controls.Back = clamp(Controls.Back + (t and -1 or 1), -MaxSpeed(), 0)
		end,
		D = function(t)
			Controls.Right = clamp(Controls.Right + (t and 1 or -1), 0, MaxSpeed())
		end,
		Space = function(t)
			Controls.Up = clamp(Controls.Up + (t and 1 or -1), 0, MaxSpeed() * 2)
		end,
		LeftControl = function(t)
			Controls.Down = clamp(Controls.Down + (t and -1 or 1), -(MaxSpeed() * 2), 0)
		end
	}
	if root:FindFirstChild(BodyGyroName) then root:FindFirstChild(BodyGyroName):Destroy() end
	if root:FindFirstChild(BodyVelocityName) then root:FindFirstChild(BodyVelocityName):Destroy() end
	local BodyGyro = NewInstance("BodyGyro", {Name = BodyGyroName, P = 9e4, MaxTorque = Vector3.new(9e9, 9e9, 9e9), CFrame = root.CFrame, Parent = root})
	local BodyVelocity = NewInstance("BodyVelocity", {Name = BodyVelocityName, Velocity = Vector3.new(0, 0, 0), MaxForce = Vector3.new(9e9, 9e9, 9e9), Parent = root})
	env[1] = function()
		RemoveConnection({"fly", "fly2"})
		if BodyGyro then BodyGyro:Destroy() end
		if BodyVelocity then BodyVelocity:Destroy() end
		if GetHumanoid() then GetHumanoid().PlatformStand = false end
	end
	cwrap(function()
		AddConnection("fly", RunService.Stepped, function()
			if not GetCharacter() or not GetHumanoid() then ExecuteCommand("unfly") end
			humanoid.PlatformStand = true
			for i, v in next, Keys do v(IsKeyDown[i]) end
			BodyGyro.CFrame = workspace.CurrentCamera.CoordinateFrame
			BodyVelocity.Velocity = ((workspace.CurrentCamera.CoordinateFrame.LookVector * (Controls.Front + Controls.Back)) + (workspace.CurrentCamera.CoordinateFrame * CFrame.new(Controls.Left + Controls.Right, (Controls.Front + Controls.Back + Controls.Up + Controls.Down) * 0.2, 0).Position) - workspace.CurrentCamera.CoordinateFrame.p)
		end)
	end)()
	AddConnection("fly2", humanoid.Died, function() ExecuteCommand("unfly") end)
end)

AddCommand("unfly", "unfly", "Disable fly.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("fly")
end)

AddCommand("togglefly", "togglefly", "Toggles fly.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("fly") == 0 and "fly" or "unfly")
end)

AddCommand("flyspeed", "flyspeed [number]", "Changes your fly speed to [number].", {}, {"Utility", 1}, 2, function(args)
	if tonumber(args[1]) then
		Config.FlySpeed = tonumber(args[1])
		UpdateConfig()
	end
end)

AddCommand("walkspeed", "walkspeed [number]", "Changes your character's walkspeed to [number].", {"speed", "ws"}, {"Utility", "spawned", 1}, 2, function(args)
	local humanoid, speed = GetHumanoid(), tonumber(args[1])
	if humanoid and speed then GetHumanoid().WalkSpeed = speed end
end)

AddCommand("loopwalkspeed", "loopwalkspeed [number]", "Loop changes your character's walkspeed to [number].", {"loopspeed", "loopws"}, {"Utility", 1}, 2, function(args, _, env)
	ExecuteCommand("unloopwalkspeed")
	local speed = tonumber(args[1])
	if speed then AddConnection(env, RunService.PostSimulation, function() pcall(function() GetHumanoid().WalkSpeed = speed end) end) end
end)

AddCommand("unloopwalkspeed", "unloopwalkspeed", "Disables loopwalkspeed.", {"unloopspeed", "unloopws"}, {"Utility"}, 2, function()
	RunCommandFunctions("loopwalkspeed")
end)

AddCommand("jumppower", "jumppower [number]", "Changes your character's jump power to [number].", {"jp"}, {"Utility", "spawned", 1}, 2, function(args)
	local humanoid, power = GetHumanoid(), tonumber(args[1])
	if humanoid and power then GetHumanoid().JumpPower = power end
end)

AddCommand("loopjumppower", "loopwalkspeed [number]", "Loop changes your character's jump power to [number].", {"loopjumppower", "loopjp"}, {"Utility", 1}, 2, function(args, _, env)
	ExecuteCommand("unloopjumppower")
	local speed = tonumber(args[1])
	if speed then AddConnection(env, RunService.PostSimulation, function() pcall(function() GetHumanoid().JumpPower = speed end) end) end
end)

AddCommand("unloopjumppower", "unloopjumppower", "Disables loopjumppower.", {"unloopjumppower", "unloopjp"}, {"Utility"}, 2, function()
	RunCommandFunctions("loopjumppower")
end)

AddCommand("rejoin", "rejoin", "Rejoins the game.", {"rj"}, {"Utility"}, 2, function()
	if #Players:GetPlayers() <= 1 then
		LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

AddCommand("clearerrors", "clearerrors", "Removes the annoying box and blur that happens when a game kicks you.", {}, {}, 2, function()
	Services.GuiService:ClearError()
end)

AddCommand("net", "net", "N/A", {}, {}, 2, function()
	LocalPlayer.MaximumSimulationRadius = math.huge
end)

AddCommand("esp", "esp", "Views all players in the server.", {"tracers", "chams"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unesp")
	local success, result = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/daximul/sense/main/init.lua") end)
	if success then
		local esp = loadstring(result)()
		local Container = Gui.New("Visuals", function() esp:Kill() end)
		local Section = Container:AddSection("Section")
		esp:Toggle(true)
		Section:AddItem("Toggle", {Text = "Players", Default = true, Function = function(callback) esp.Players = callback end})
		Section:AddItem("Toggle", {Text = "Show Teammates", Default = true, Function = function(callback) esp.TeamMates = callback end})
		Section:AddItem("Toggle", {Text = "Team Color", Default = true, Function = function(callback) esp.TeamColor = callback end})
		Section:AddItem("Toggle", {Text = "Distance", Default = true, Function = function(callback) esp.Distance = callback end})
		Section:AddItem("Toggle", {Text = "Names", Default = true, Function = function(callback) esp.Names = callback end})
		Section:AddItem("Toggle", {Text = "Boxes", Function = function(callback) esp.Boxes = callback end})
		Section:AddItem("Toggle", {Text = "Tracers", Function = function(callback) esp.Tracers = callback end})
		Section:AddItem("Toggle", {Text = "Health", Function = function(callback) esp.Health = callback end})
		Section:AddItem("Toggle", {Text = "Face Camera", Function = function(callback) esp.FaceCamera = callback end})
		Section:AddItem("Toggle", {Text = "Chams", Function = function(callback) esp:Chams(callback) end})
		env[1] = function() if Container and Container.Close then Container.Close() else esp:Kill() end end
		local PlaceExists, PlaceResult = pcall(function() return game:HttpGet(format("https://raw.githubusercontent.com/daximul/sense/main/supported/%d.lua", game.PlaceId)) end)
		local GameExists, GameResult = pcall(function() return game:HttpGet(format("https://raw.githubusercontent.com/daximul/sense/main/supported/%d.lua", game.GameId)) end)
		if PlaceExists or GameExists then Section:AddItem("Text", {Text = "Supported", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1}) end
		if PlaceExists then loadstring(PlaceResult)()(Container, Section, esp) elseif GameExists then loadstring(GameResult)()(Container, Section, esp) end
	end
end)

AddCommand("unesp", "unesp", "Disables esp.", {"untracers", "unchams"}, {"Utility"}, 2, function()
	RunCommandFunctions("esp")
end)

AddCommand("noclip", "noclip", "Makes your character able to walk through walls.", {}, {"Utility", "spawned"}, 2, function(_, _, env)
	ExecuteCommand("unnoclip")
	AddConnection(env, RunService.Stepped, function()
		pcall(function()
			for _, v in next, GetCharacter():GetChildren() do
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
				end
			end
		end)
	end)
	AddConnection(env, GetHumanoid().Died, function() ExecuteCommand("unnoclip") end)
end)

AddCommand("unnoclip", "unnoclip", "Disables noclip.", {"clip"}, {"Utility"}, 2, function()
	RunCommandFunctions("noclip")
end)

AddCommand("togglenoclip", "togglenoclip", "Toggles noclip.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("noclip") == 0 and "noclip" or "unnoclip")
end)

AddCommand("goto", "goto [player] [distance]", "Teleports your character to [player]. [distance] is an optional argument.", {"to"}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target and target.Character then
			local root, root2, humanoid = GetRoot(), GetRoot(target.Character), GetHumanoid()
			if root and root2 then
				if humanoid and humanoid.SeatPart then
					humanoid.Sit = false
					wait(0.1)
				end
				root.CFrame = root2.CFrame + Vector3.new(tonumber(args[2]) or 3, 1, 0)
			end
		end
	end
end)

AddCommand("antivoid", "antivoid", "Makes it so you can't die from falling in the void.", {}, {"Utility"}, 2, function()
	workspace.FallenPartsDestroyHeight = 0/1/0
end)

AddCommand("unantivoid", "unantivoid", "Sets the FallenPartsDestroyHeight back to before antivoid was ran.", {}, {"Utility"}, 2, function()
	workspace.FallenPartsDestroyHeight = OldFallenPartsDestroyHeight
end)

AddCommand("fakeout", "fakeout", "Teleports your character into the void and then back to your original position. Useful for getting rid of players that are attached to your character.", {}, {"Fun"}, 2, function()
	ExecuteCommand("antivoid")
	local root = GetRoot()
	if root then
		local oldpos = root.CFrame
		root.CFrame = CFrame.new(Vector3.new(0, -694, 0))
		wait(1)
		root.CFrame = oldpos
	end
end)

AddCommand("car", "car [speed]", "Makes you some form of a car. The car's speed is [speed]. [speed] is an optional argument.", {}, {"Fun"}, 2, function(args)
	local character, humanoid, animate = GetCharacter(), GetHumanoid(), GetCharacter():FindFirstChild("Animate")
	if character and humanoid and animate then
		local speed = tonumber(args[1]) or 70
		humanoid.WalkSpeed = speed
		humanoid.JumpPower = 15
		local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
		local AnimationId = isR15 and "rbxassetid://3360694441" or "rbxassetid://129342287"
		animate.walk.WalkAnim.AnimationId = AnimationId
		animate.run.RunAnim.AnimationId = AnimationId
		animate.fall.FallAnim.AnimationId = AnimationId
		animate.idle.Animation1.AnimationId = AnimationId
		animate.idle.Animation2.AnimationId = AnimationId
		animate.jump.JumpAnim.AnimationId = AnimationId
		for _, obj in next, character:GetDescendants() do
			if obj:IsA("Part") or obj:IsA("MeshPart") then
				obj.CustomPhysicalProperties = PhysicalProperties.new(0.025, 0, 0)
			end
		end
		humanoid.HipHeight = isR15 and 0.56 or -1.03
	end
end)

AddCommand("gravitygun", "gravitygun", "Oh yeah, maximum trolling capabilities. Kind of cringe since it relies on your network ownership of a part. Tap [E] to push the part away. Tap [Q] to bring the part closer.", {"gravgun", "telekinesis", "tel"}, {"Fun"}, 2, function()
	ExecuteCommand("net")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/gravitygun.lua"))()
end)

AddCommand("tweenspeed", "tweenspeed [number]", "Changes the number of how fast tween commands are to [number]. [number] is an optional argument.", {}, {"Utility"}, 2, function(args)
	Config.TweenSpeed = tonumber(args[1]) or 1
	UpdateConfig()
end)

AddCommand("gotocamera", "gotocamera", "Teleports your character to your camera.", {"tocamera", "gotocam", "tocam"}, {"Utility"}, 2, function()
	local root, camera = GetRoot(), workspace.CurrentCamera
	if root and camera then
		root.CFrame = camera.CFrame
	end
end)

AddCommand("tweengotocamera", "tweengotocamera", "Teleports your character to your camera.", {"tweentocamera", "tweengotocam", "tweentocam"}, {"Utility"}, 2, function()
	local root, camera = GetRoot(), workspace.CurrentCamera
	if root and camera then
		TweenService:Create(root, TweenInfo.new(Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = camera.CFrame}):Play()
	end
end)

AddCommand("fieldofview", "fieldofview [number]", "Changes your camera's field of view to [number]. [number] is an optional argument.", {"fov"}, {"Utility"}, 2, function(args)
	workspace.CurrentCamera.FieldOfView = tonumber(args[1]) or 70
end)

AddCommand("fixcamera", "fixcamera", "Attempts to fix your player camera.", {"fixcam"}, {"Utility", "spawned"}, 2, function()
	ExecuteCommand("unfreecam")
	ExecuteCommand("unview")
	workspace.CurrentCamera:Remove()
	wait(0.1)
	repeat wait() until GetCharacter() ~= nil
	workspace.CurrentCamera.CameraSubject = GetHumanoid()
	workspace.CurrentCamera.CameraType = "Custom"
	LocalPlayer.CameraMaxZoomDistance = 400
	LocalPlayer.CameraMinZoomDistance = 0.5
	LocalPlayer.CameraMode = "Classic"
	LocalPlayer.Character.Head.Anchored = false
end)

AddCommand("enableshiftlock", "enableshiftlock", "Enables shift lock.", {"enablesl"}, {"Utility"}, 2, function()
	LocalPlayer.DevEnableMouseLock = true
end)

AddCommand("disableshiftlock", "disableshiftlock", "Disables shift lock.", {"disablesl"}, {"Utility"}, 2, function()
	LocalPlayer.DevEnableMouseLock = false
end)

AddCommand("firstperson", "firstperson", "Forces your player camera into first person.", {}, {"Utility"}, 2, function()
	LocalPlayer.CameraMode = "LockFirstPerson"
end)

AddCommand("thirdperson", "thirdperson", "Allows your player camera to go into third person.", {}, {"Utility"}, 2, function()
	LocalPlayer.CameraMode = "Classic"
end)

AddCommand("minimumzoom", "minimumzoom [number]", "Changes your player camera minimum zoom distance to [number].", {"minzoom"}, {"Utility", 1}, 2, function(args)
	if tonumber(args[1]) then
		LocalPlayer.CameraMinZoomDistance = tonumber(args[1])
	end
end)

AddCommand("maximumzoom", "maximumzoom [number]", "Changes your player camera maximum zoom distance to [number].", {"maxzoom"}, {"Utility", 1}, 2, function(args)
	if tonumber(args[1]) then
		LocalPlayer.CameraMaxZoomDistance = tonumber(args[1])
	end
end)

AddCommand("unlockworkspace", "unlockworkspace", "Unlocks workspace.", {"unlockws"}, {"Utility"}, 2, function()
	for _, v in next, workspace:GetDescendants() do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

AddCommand("lockworkspace", "lockworkspace", "Locks workspace.", {"lockws"}, {"Utility"}, 2, function()
	for _, v in next, workspace:GetDescendants() do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

AddCommand("exitroblox", "exitroblox", "Closes the Roblox program.", {"exit"}, {"Utility"}, 2, function()
	game:Shutdown()
end)

AddCommand("btools", "btools", "Gives yourself basic building tools. Other players can not see what is done with this command since it is only visible on your client.", {}, {"Utility"}, 2, function()
	local backpack = GetBackpack()
	if backpack then
		for i = 1, 4 do
			NewInstance("HopperBin", {BinType = i, Parent = backpack})
		end
	end
end)

AddCommand("reset", "reset", "Death.", {}, {"Utility"}, 2, function()
	local character = GetCharacter()
	if character then
		character:BreakJoints()
	end
end)

AddCommand("sit", "sit", "It makes you sit. What did you expect?", {}, {"Utility"}, 2, function()
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.Sit = true
	end
end)

AddCommand("jump", "jump", "It makes you jump. What did you expect?", {}, {"Utility"}, 2, function()
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.Jump = true
	end
end)

AddCommand("stun", "stun", "Enables PlatformStand.", {}, {"Utility"}, 2, function()
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.PlatformStand = true
	end
end)

AddCommand("unstun", "unstun", "Disables PlatformStand.", {}, {"Utility"}, 2, function()
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.PlatformStand = false
	end
end)

AddCommand("ping", "ping", "Notifies your ping.", {}, {"Utility"}, 2, function(_, speaker)
	Notify("your ping is " .. round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

AddCommand("memory", "memory", "Notifies your memory usage.", {}, {"Utility"}, 2, function()
	Notify("your memory usage is " .. round(Services.Stats:GetTotalMemoryUsageMb()) .. " mb")
end)

AddCommand("infinitejump", "infinitejump", "Makes your character able to jump with no cooldown.", {}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("uninfinitejump")
	local debounce = false
	AddConnection("infinitejump", UserInputService.JumpRequest, function()
		if not debounce then
			debounce = true
			local humanoid = GetHumanoid()
			if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
			wait(0.11)
			debounce = false
		end
	end)
	env[1] = function() RemoveConnection("infinitejump") end
end)

AddCommand("uninfinitejump", "uninfinitejump", "Disables infinitejump.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("infinitejump")
end)

AddCommand("flyjump", "flyjump", "Makes your character able to infinitely jump upwards with no cooldown.", {}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("uninfinitejump")
	AddConnection("flyjump", UserInputService.JumpRequest, function()
		local humanoid = GetHumanoid()
		if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
	env[1] = function() RemoveConnection("flyjump") end
end)

AddCommand("unflyjump", "unflyjump", "Disables flyjump.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("flyjump")
end)

AddCommand("antiafk", "antiafk", "Prevents yourself from being kicked after being idle for 20 minutes.", {"antiidle"}, {"Utility"}, 2, function()
	if getconnections then
		for _, v in next, getconnections(LocalPlayer.Idled, true) do
			if v["Disable"] then
				v["Disable"](v)
			elseif v["Disconnect"] then
				v["Disconnect"](v)
			end
		end
	else
		local VirtualUser = Services.VirtualUser
		LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

AddCommand("view", "view [player]", "Views [player].", {"spectate"}, {"Utility", "spawned", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unview")
	local target = Players[getPlayer(args[1], speaker)[1]]
	local character = GetCharacter(target)
	if target and character then
		workspace.CurrentCamera.CameraSubject = character
		AddConnection("spectate1", target.CharacterAdded, function()
			wait(0.2)
			workspace.CurrentCamera.CameraSubject = GetCharacter(target)
		end)
		AddConnection("spectate2", LocalPlayer.CharacterAdded, function()
			wait(0.2)
			workspace.CurrentCamera.CameraSubject = GetCharacter(target)
		end)
		env[1] = function()
			RemoveConnection({"spectate1", "spectate2"})
			if GetCharacter() then
				workspace.CurrentCamera.CameraSubject = GetCharacter()
			end
		end
		Notify(format("now viewing %s", GetLongUsername(target)))
	end
end)

AddCommand("unview", "unview", "Disables view.", {"unspectate"}, {"Utility"}, 2, function()
	RunCommandFunctions("view")
end)

AddCommand("respawn", "respawn", "Attempts to respawn.", {}, {"Utility"}, 2, function()
	GetCharacter():ClearAllChildren()
end)

AddCommand("refresh", "refresh", "Refreshes your character. Once you respawn you will be teleported back to your previous spot.", {"re"}, {"Utility"}, 2, function()
	local character, root = GetCharacter(), GetRoot()
	if character and root then
		local oldpos = root.CFrame
		AddConnection("refresh", LocalPlayer.CharacterAdded, function()
			wait(0.2)
			RemoveConnection("refresh")
			root = GetRoot()
			if root then root.CFrame = oldpos end
		end)
		character:ClearAllChildren()
	end
end)

AddCommand("copyusername", "copyusername [player]", "Copies the full username of [player].", {"copyname"}, {"Utility", 1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target then toexecutorclipboard(tostring(target.Name)) end
end)

AddCommand("copyuserid", "copyuserid [player]", "Copies the user id of [player].", {}, {"Utility", 1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target then toexecutorclipboard(tostring(target.UserId)) end
end)

AddCommand("reach", "reach [number]", "Changes the distance your tool can reach to [number].", {}, {"Utility", 1}, 2, function(args, speaker, env)
	local distance, character, backpack = tonumber(args[1]), GetCharacter(), GetBackpack()
	if distance and character and backpack then
		local tool = GetTool(LocalPlayer, true)
		local handle = tool.Handle
		if tool and handle then
			local box, old = NewInstance("SelectionBox", {Name = RandomString(), Parent = handle, Adornee = handle}), handle.Size
			insert(env, function() if tool and handle then handle.Size = old end if box then box:Destroy() end end)
			handle.Size, handle.Massless = Vector3.new(handle.Size.X, handle.Size.Y, distance), true
		end
	end
end)

AddCommand("boxreach", "boxreach [number]", "Changes the distance your tool can reach to [number] all around you.", {}, {"Utility", 1}, 2, function(args, speaker, env)
	local distance, character, backpack = tonumber(args[1]), GetCharacter(), GetBackpack()
	if distance and character and backpack then
		local tool = GetTool(LocalPlayer, true)
		local handle = tool.Handle
		if tool and handle then
			local box, old = NewInstance("SelectionBox", {Name = RandomString(), Parent = handle, Adornee = handle}), handle.Size
			insert(env, function() if tool and handle then handle.Size = old end if box then box:Destroy() end end)
			handle.Size, handle.Massless = Vector3.new(distance, distance, distance), true
		end
	end
end)

AddCommand("unreach", "unreach", "Disables reach.", {"unboxreach"}, {"Utility"}, 2, function()
	RunCommandFunctions({"reach", "boxreach"})
end)

AddCommand("teleporttool", "teleporttool", "Gives you a tool that teleports your character where you click.", {"tweenteleporttool", "tptool", "tweentptool", "clicktp"}, {"Utility"}, 2, function()
	local backpack = GetBackpack()
	if backpack then
		local tool = NewInstance("Tool", {Name = "Click TP", RequiresHandle = false, Parent = backpack})
		AddConnection(tool.Activated, function()
			local root, pos = GetRoot(), Mouse.Hit
			if root and pos then root.CFrame = pos + Vector3.new(3, 1, 0) end
		end)
		local tool2 = NewInstance("Tool", {Name = "Click TweenTP", RequiresHandle = false, Parent = backpack})
		AddConnection(tool2.Activated, function()
			local root, pos = GetRoot(), Mouse.Hit
			if root and pos then TweenObj(root, "Sine", "Out", 0.5, {CFrame = pos + Vector3.new(3, 1, 0)}) end
		end)
	end
end)

AddCommand("attach", "attach [player]", "Attach yourself to [player].", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do Attach(Players[available]) end
end)

AddCommand("kill", "kill [player]", "Kill [player].", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target, tool, character = Players[available], GetTool(LocalPlayer, true), GetCharacter()
		if target and target.Character and tool then
			local root, root2 = GetRoot(), GetRoot(GetCharacter(target))
			if root and root2 then
				local oldpos = root.CFrame
				Attach(target)
				wait(0.2)
				CheckDistanceAndClear(target)
				spawn(function() repeat wait() root.CFrame = CFrame.new(999999, OldFallenPartsDestroyHeight + 5, 999999) until not root or not root2 end)
				LocalPlayer.CharacterAdded:Wait()
				wait(0.2)
				root = GetRoot()
				if root then root.CFrame = oldpos end
			end
		end
	end
end)

AddCommand("spawnpoint", "spawnpoint", "Place a spawn point where you are currently standing.", {"setspawn"}, {"Utility"}, 2, function(_, speaker, env)
	ExecuteCommand("unspawnpoint")
	env[1] = function() RemoveConnection("spawnpoint") end
	local root = GetRoot()
	if root then
		local saved, pos = root.CFrame, root.Position
		Notify(format("set a spawn point at (%d, %d, %d)", round(pos.X), round(pos.Y), round(pos.Z)))
		AddConnection("spawnpoint", speaker.CharacterAdded, function()
			wait(0.2)
			root = GetRoot()
			if root then root.CFrame = saved end
		end)
	end
end)

AddCommand("unspawnpoint", "unspawnpoint", "Remove your placed spawn point.", {"removespawn", "unsetspawn"}, {"Utility"}, 2, function(_, speaker)
	RunCommandFunctions("spawnpoint")
end)

local lastdeath = false
AddConnection(LocalPlayer.CharacterAdded, function()
	repeat wait(1) until GetHumanoid() ~= nil
	AddConnection(GetHumanoid().Died, function()
		local root = GetRoot()
		if root then lastdeath = root.CFrame end
	end)
end)
spawn(function()
	repeat wait(1) until GetHumanoid() ~= nil
	AddConnection(GetHumanoid().Died, function()
		local root = GetRoot()
		if root then lastdeath = root.CFrame end
	end)
end)
AddCommand("diedtp", "diedtp", "Teleport to your last position before you died.", {"flashback"}, {"Utility"}, 2, function(_, speaker)
	local root = GetRoot()
	if root and lastdeath then lastdeath = root.CFrame end
end)

AddCommand("control", "control [player]", "Control [player] for a few seconds.", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target and target.Character then
			ExecuteCommand("sit")
			Attach(target)
			AddConnection("control", UserInputService.InputBegan, function(input, processed) if not processed and input.KeyCode == Enum.KeyCode.Space then ExecuteCommand("jump") end end)
			speaker.CharacterAdded:Wait()
			RemoveConnection("control")
		end
	end
end)

AddCommand("skydive", "skydive [player]", "Teleport yourself into and the sky and bring [player].", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	local target, root = Players[getPlayer(args[1], speaker)[1]], GetRoot()
	if target and GetCharacter(target) and root then
		local oldpos = root.CFrame
		root.CFrame = CFrame.new(Vector3.new(0, 694200, 0))
		wait(0.33)
		Attach(target)
		CheckDistanceAndClear(target)
		speaker.CharacterAdded:Wait()
		wait(0.33)
		root = GetRoot()
		if root then root.CFrame = oldpos end
	end
end)

AddCommand("handlekill", "handlekill [player]", "Kill [player] with tool damage.", {"hkill"}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target and target.Character then
			local tool = GetTool(LocalPlayer, true)
			local handle = tool.Handle
			if tool and handle then
				tool.Parent = GetCharacter()
				spawn(function()
					while tool and handle and GetCharacter() and GetCharacter(target) and tool.Parent == GetCharacter() do
						local humanoid = GetHumanoid(GetCharacter(target))
						if not humanoid or humanoid.Health <= 0 then break end
						for _, obj in next, GetCharacter(target):GetChildren() do obj = ((obj:IsA("BasePart") and firerbxtouch(handle, obj, 1, (renderstepped:Wait() and nil) or firerbxtouch(handle, obj, 0)) and nil) or obj) or obj end
					end
					Notify(format("%s has either died or left, or you unequipped the tool", GetLongUsername(target)))
				end)
			end
		end
	end
end)

AddCommand("invisible", "invisible", "Become invisible to other players.", {"invis"}, {"Utility", "spawned"}, 2, function(_, _, env)
	ExecuteCommand("uninvisible")
	local character, root = GetCharacter(), GetRoot()
	if character and root then
		local oldpos = root.CFrame
		root.CFrame = CFrame.new(9e9, 9e9, 9e9)
		wait(0.2)
		root.Anchored = true
		local seat = NewInstance("Seat", {Name = RandomString(), Parent = workspace, CFrame = root.CFrame, Anchored = false, Transparency = 1, CanCollide = false})
		local weld = NewInstance("Weld", {Name = RandomString(), Parent = seat, Part0 = seat, Part1 = root})
		root.Anchored = false
		seat.CFrame = oldpos
		local modified = {}
		for _, v in next, character:GetChildren() do
			if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") then
				insert(modified, {Object = v, Transparency = v.Transparency})
				v.Transparency = v.Transparency <= 0.3 and 0.4 or v.Transparency
			elseif v:IsA("Accessory") then
				local handle = v:FindFirstChildWhichIsA("MeshPart") or v:FindFirstChildWhichIsA("Part")
				if handle then
					insert(modified, {Object = handle, Transparency = handle.Transparency})
					handle.Transparency = handle.Transparency <= 0.3 and 0.4 or handle.Transparency
				end
			end
		end
		env[1] = function()
			if weld then
				weld.Part0, weld.Part1 = nil, nil
				weld:Destroy()
			end
			if seat then seat:Destroy() end
			for _, v in next, modified do if v.Object and v.Transparency then v.Object.Transparency = v.Transparency end end
		end
	end
end)

AddCommand("toolinvisible", "toolinvisible", "Become invisible to other players and be able to use tools.", {"toolinvis", "tinvis"}, {"Utility", "spawned"}, 2, function(_, _, env)
	ExecuteCommand("uninvisible")
	local character, root = GetCharacter(), GetRoot()
	if character and character:FindFirstChild("Head") and root then
		local oldpos = root.CFrame
		root.CFrame = CFrame.new(9e9, 9e9, 9e9)
		wait(0.2)
		AddConnection(env, heartbeat, function()
			if not character or not character:FindFirstChild("Head") or not root then ExecuteCommand("uninvisible") end
			local old = character.Head.Size
			character.Head.Size = Vector3.new(0, 0, 0)
			RunService.RenderStepped:Wait()
			character.Head.Size = old
		end)
		wait(0.2)
		root.CFrame = oldpos
	end
end)

AddCommand("uninvisible", "uninvisible", "Stop being invisible.", {"uninvis", "visible", "vis", "untoolinvisible", "untoolinvis", "untinvis"}, {"Utility"}, 2, function()
	RunCommandFunctions({"invisible", "toolinvisible"})
end)

AddCommand("toggleinvisible", "toggleinvisible", "Toggles invisible.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("invisible") == 0 and "invisible" or "uninvisible")
end)

AddCommand("teleportwalk", "teleportwalk [speed]", "Teleport to your move direction. [speed] is optional.", {"tpwalk"}, {"Utility"}, 2, function(args, _, env)
	ExecuteCommand("unteleportwalk")
	local character, humanoid = GetCharacter(), GetHumanoid()
	if character and humanoid then
		env[1] = function() end
		while env[1] and character and humanoid do
			local delta = heartbeat:Wait()
			if humanoid.MoveDirection.Magnitude > 0 then
				if tonumber(args[1]) then
					character:TranslateBy(humanoid.MoveDirection * tonumber(args[1]) * delta * 10)
				else
					character:TranslateBy(humanoid.MoveDirection * delta * 10)
				end
			end
		end
	end
end)

AddCommand("unteleportwalk", "unteleportwalk", "Stop teleport walk.", {"untpwalk"}, {"Utility"}, 2, function()
	RunCommandFunctions("teleportwalk")
end)

AddCommand("f3x", "f3x", "Most known clientsided funny building tool yessir.", {}, {"Fun"}, 2, function()
	loadstring(Services.InsertService:LoadLocalAsset("rbxassetid://6695644299"):Clone().Source)()
end)

AddCommand("swim", "swim", "Makes your character able to swim while not being in water. Tap [Space] to go up. Tap [LeftControl] to go down.", {}, {"Utility"}, 2, function(_, speaker, env)
	ExecuteCommand("unswim")
	local character, humanoid, root = GetCharacter(), GetHumanoid(), GetRoot()
	if character and humanoid and root then
		workspace.Gravity = 0
		local enums, v3, v0 = Enum.HumanoidStateType:GetEnumItems(), Vector3.new, Vector3.zero
		remove(enums, tfind(enums, Enum.HumanoidStateType.None))
		for _, state in next, enums do humanoid:SetStateEnabled(state, false) end
		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		AddConnection(env, heartbeat, function()
			local rootvelo, moving = root.Velocity, humanoid.MoveDirection ~= v3()
			local vertical = (IsKeyDown.Space and 50) or (IsKeyDown.LeftControl and -50)
			root.Velocity = ((moving or IsKeyDown.Space or IsKeyDown.LeftControl) and v3(moving and rootvelo.X or 0, vertical or rootvelo.Y, moving and rootvelo.Z or 0) or v0)
		end)
		env[#env + 1] = function()
			workspace.Gravity = OldGravity
			humanoid = GetHumanoid()
			if humanoid then for _, state in next, enums do humanoid:SetStateEnabled(state, true) end end
		end
		speaker.CharacterAdded:Wait()
		heartbeat:Wait()
		ExecuteCommand("unswim")
	end
end)

AddCommand("unswim", "unswim", "Stop swimming.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("swim")
end)

AddCommand("toggleswim", "toggleswim", "Toggles swim.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("swim") == 0 and "swim" or "unswim")
end)

AddCommand("notifyposition", "notifyposition", "Notify yourself your character's current position (x, y, z).", {"notifypos"}, {"Utility"}, 2, function()
	local root = GetRoot()
	if root then Notify(format("%s, %s, %s", tostring(round(root.Position.X)), tostring(round(root.Position.Y)), tostring(round(root.Position.Z)))) end
end)

AddCommand("copyposition", "copyposition", "Copy your character's current position (x, y, z).", {"copypos"}, {"Utility"}, 2, function()
	local root = GetRoot()
	if root then toexecutorclipboard(format("%s, %s, %s", tostring(round(root.Position.X)), tostring(round(root.Position.Y)), tostring(round(root.Position.Z)))) end
end)

AddCommand("serverhop", "serverhop [min / max]", "Join a different server. Optional arguments of min or max, max is the default.", {"shop"}, {"Utility", {"min", "max"}}, 2, function(args)
	local opt = lower(tostring(args[1]))
	opt = (opt == "min" and "Asc") or (opt == "max" and "Desc") or "Desc"
	local list = HttpService:JSONDecode(httprequest({Url = format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100", game.PlaceId, opt)}).Body)
	local servers = filter(list and list.data or {}, function(_, v) return type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.maxPlayers > v.playing and v.id ~= game.JobId end)
	if #servers ~= 0 then
		local server = servers[math.random(1, #servers)]
		Notify(format("joining server (%d/%d players)", server.playing, server.maxPlayers))
		TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
	else
		Notify("no servers available")
	end
end)

AddCommand("dex", "dex", "Opens a debugging suite similar to the one in Roblox Studio.", {"explorer"}, {"Utility"}, 2, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

AddCommand("settime", "settime [number / day / dawn / night]", "Changes the time of day to [number]. Optional arguments of day, dawn, or night.", {"time"}, {"Utility", {"day", "dawn", "night"}, 1}, 2, function(args)
	if tonumber(args[1]) then
		Lighting.ClockTime = tonumber(args[1])
	else
		local opt = lower(tostring(args[1]))
		Lighting.ClockTime = (opt == "day" and 14) or (opt == "dawn" and 6) or (opt == "night" and 0) or 14
	end
end)

AddCommand("fullbright", "fullbright", "Makes everything brighter.", {"fb"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unfullbright")
	local modified = {}
	Lighting.GlobalShadows = false
	for _, v in next, game:GetDescendants() do
		if v:IsA("SpotLight") or v:IsA("PointLight") or v:IsA("SurfaceLight") then
			insert(modified, {Object = v, Range = v.Range, Shadows = v.Shadows, Enabled = v.Enabled})
			v.Range = math.huge
			v.Shadows = false
			v.Enabled = true
		end
	end
	env[1] = function()
		Lighting.GlobalShadows = OldLightingProperties.GlobalShadows
		for _, v in next, modified do
			if v.Object then
				v.Object.Range = v.Range
				v.Object.Shadows = v.Shadows
				v.Object.Enabled = v.Enabled
			end
		end
	end
end)

AddCommand("unfullbright", "unfullbright", "Disables fullbright.", {"unfb"}, {"Utility"}, 2, function()
	RunCommandFunctions("fullbright")
end)

AddCommand("togglefullbright", "togglefullbright", "Toggles fullbright.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("fullbright") == 0 and "fullbright" or "unfullbright")
end)

AddCommand("enable", "enable [inventory / backpack / playerlist / leaderboard / chat / reset / emotes / all]", "Enable the visibility of CoreGui items. Arguments needed are listed in usage.", {}, {"Utility", 1}, 2, function(args)
	local opt, coretypes = lower(tostring(args[1])), {inventory = Enum.CoreGuiType.Backpack, backpack = Enum.CoreGuiType.Backpack, playerlist = Enum.CoreGuiType.PlayerList, leaderboard = Enum.CoreGuiType.PlayerList, emotes = Enum.CoreGuiType.EmotesMenu, chat = Enum.CoreGuiType.Chat, all = Enum.CoreGuiType.All}
	if opt == "reset" then Services.StarterGui:SetCore("ResetButtonCallback", true) elseif coretypes[opt] then Services.StarterGui:SetCoreGuiEnabled(coretypes[opt], true) end
end)

AddCommand("disable", "disable [inventory / backpack / playerlist / leaderboard / chat / reset / emotes / all]", "Disable the visibility of CoreGui items. Arguments needed are listed in usage.", {}, {"Utility", 1}, 2, function(args)
	local opt, coretypes = lower(tostring(args[1])), {inventory = Enum.CoreGuiType.Backpack, backpack = Enum.CoreGuiType.Backpack, playerlist = Enum.CoreGuiType.PlayerList, leaderboard = Enum.CoreGuiType.PlayerList, emotes = Enum.CoreGuiType.EmotesMenu, chat = Enum.CoreGuiType.Chat, all = Enum.CoreGuiType.All}
	if opt == "reset" then Services.StarterGui:SetCore("ResetButtonCallback", false) elseif coretypes[opt] then Services.StarterGui:SetCoreGuiEnabled(coretypes[opt], false) end
end)

AddCommand("invisiblecamera", "invisiblecamera", "Makes it so you can put your camera through walls.", {"inviscamera", "inviscam"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("uninvisiblecamera")
	local OldCameraMaxZoomDistance, OldDevCameraOcclusionMode = LocalPlayer.CameraMaxZoomDistance, LocalPlayer.DevCameraOcclusionMode
	LocalPlayer.CameraMaxZoomDistance, LocalPlayer.DevCameraOcclusionMode = 600, "Invisicam"
	env[1] = function() LocalPlayer.CameraMaxZoomDistance, LocalPlayer.DevCameraOcclusionMode = OldCameraMaxZoomDistance, OldDevCameraOcclusionMode end
end)

AddCommand("uninvisiblecamera", "uninvisiblecamera", "Disables invisiblecamera.", {"uninviscamera", "uninviscam"}, {"Utility"}, 2, function()
	RunCommandFunctions("invisiblecamera")
end)

AddCommand("volume", "volume [number]", "Set your volume to [number].", {}, {1}, 2, function(args)
	if tonumber(args[1]) then UserSettings():GetService("UserGameSettings").MasterVolume = tonumber(args[1]) end
end)

AddCommand("age", "age [player]", "Checks the account age of [player].", {}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			local age = tonumber(target.AccountAge)
			local t =  os.date("*t", os.time())
			t.day = t.day - age
			local creation = os.date("%m/%d/%y", os.time(t))
			Notify(format("%s's age is %d days (%s)", GetLongUsername(target), age, creation), 10)
		end
	end
end)

AddCommand("purchaseprompts", "purchaseprompts", "Enables Roblox's purchase prompts.", {"prompts", "sales"}, {"Utility"}, 2, function()
	CoreGui.PurchasePrompt.Enabled = true
end)

AddCommand("nopurchaseprompts", "nopurchaseprompts", "Disables Roblox's purchase prompts.", {"noprompts", "nosales"}, {"Utility"}, 2, function()
	CoreGui.PurchasePrompt.Enabled = false
end)

AddCommand("float", "float", "Creates a floating platform beneath you. Hold [E] to go up. Hold [Q] to go down.", {}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unfloat")
	local character, root, humanoid = GetCharacter(), GetRoot(), GetHumanoid()
	if character and root then
		local obj = NewInstance("Part", {Name = RandomString(), CFrame = CFrame.new(0, -6942, 0), Parent = character, Transparency = 1, Size = Vector3.new(2, 0.2, 1.5), Anchored = true})
		env[1] = function() if obj then obj:Destroy() end end
		cwrap(function()
			AddConnection(env, heartbeat, function()
				if not obj or not GetCharacter() or not GetRoot() then ExecuteCommand("unfloat") end
				if IsKeyDown.E then GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, 0.025, 0) elseif IsKeyDown.Q then GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, -0.025, 0) end
				obj.CFrame = GetRoot().CFrame * CFrame.new(0, -3.1, 0)
			end)
		end)()
		if humanoid then AddConnection(env, humanoid.Died, function() ExecuteCommand("unfloat") end) end
	end
end)

AddCommand("unfloat", "unfloat", "Disables float.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("float")
end)

AddCommand("togglefloat", "togglefloat", "Toggles float.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("float") == 0 and "float" or "unfloat")
end)

AddCommand("teleportposition", "teleportposition [x, y, z]", "Teleports you to the provided coordinates.", {"tpposition", "tppos"}, {"Utility", 3}, 2, function(args)
	local root, x, y, z = GetRoot(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
	if root and x and y and z then root.CFrame = CFrame.new(x, y, z) end
end)

AddCommand("spin", "spin [speed]", "Spins your character with a speed of [speed]. [speed] is an optional argument.", {}, {"Utility"}, 2, function(args, _, env)
	ExecuteCommand("unspin")
	local root = GetRoot()
	if root then
		local speed = tonumber(args[1]) or 20
		local obj = NewInstance("BodyAngularVelocity", {Name = RandomString(), Parent = root, MaxTorque = Vector3.new(0, math.huge, 0), AngularVelocity = Vector3.new(0, speed, 0)})
		env[1] = function() if obj then obj:Destroy() end end
	end
end)

AddCommand("unspin", "unspin", "Disables spin.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("spin")
end)

AddCommand("screenshot", "screenshot", "Takes a screenshot.", {}, {}, 2, function()
	CoreGui:TakeScreenshot()
end)

AddCommand("record", "record", "Activates Roblox's recorder.", {}, {}, 2, function()
	CoreGui:ToggleRecording()
end)

AddCommand("togglefullscreen", "togglefullscreen", "Toggles fullscreen.", {"fullscreen"}, {}, 2, function()
	Services.GuiService:ToggleFullscreen()
end)

AddCommand("inspect", "inspect [player]", "Opens the player inspect menu for [player].", {}, {1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target then
		Services.GuiService:CloseInspectMenu()
		Services.GuiService:InspectPlayerFromUserId(target.UserId)
	end
end)

local Freecam = {Active = false}
do
	local Camera, NAV_KEYBOARD_SPEED, cameraRot, cameraPos, cameraFov = workspace.CurrentCamera, Vector3.new(1, 1, 1), Vector2.new(), Vector3.new(), nil
	AddConnection(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		if workspace.CurrentCamera then Camera = workspace.CurrentCamera end
	end)
	local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
	local Spring, Input, PlayerState = {}, {}, {}
	Spring.__index = Spring
	Spring.new = function(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos * 0
		return self
	end
	function Spring:Update(dt, goal)
		local f = self.f * 2 * math.pi
		local p0 = self.p
		local v0 = self.v
		local offset = goal - p0
		local decay = math.exp(-f * dt)
		local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
		local v1 = (f * dt * (offset * f - v0) + v0) * decay
		self.p = p1
		self.v = v1
		return p1
	end
	function Spring:Reset(pos)
		self.p = pos
		self.v = pos * 0
	end
	local velSpring, panSpring = Spring.new(5, Vector3.new()), Spring.new(5, Vector2.new())
	local keyboard = {W = 0, A = 0, S = 0, D = 0, E = 0, Q = 0, Up = 0, Down = 0, LeftShift = 0}
	local mouse = {Delta = Vector2.new()}
	local PAN_MOUSE_SPEED = Vector2.new(1, 1) * (math.pi / 64)
	local NAV_ADJ_SPEED, NAV_SHIFT_MUL, navSpeed = 0.75, 0.25, 1
	Input.Vel = function(dt)
		navSpeed = clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)
		local kKeyboard = Vector3.new(keyboard.D - keyboard.A, keyboard.E - keyboard.Q, keyboard.S - keyboard.W) * NAV_KEYBOARD_SPEED
		local shift = IsKeyDown.LeftShift
		return (kKeyboard) * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
	end
	Input.Pan = function()
		local kMouse = mouse.Delta * PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end
	local Keypress = function(action, state, input)
		keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
		return Enum.ContextActionResult.Sink
	end
	local MousePan = function(action, state, input)
		local delta = input.Delta
		mouse.Delta = Vector2.new(-delta.y, -delta.x)
		return Enum.ContextActionResult.Sink
	end
	local Zero = function(t)
		for k, v in pairs(t) do
			t[k] = v * 0
		end
	end
	Input.StartCapture = function()
		Services.ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D,
			Enum.KeyCode.E,
			Enum.KeyCode.Q,
			Enum.KeyCode.Up,
			Enum.KeyCode.Down
		)
		Services.ContextActionService:BindActionAtPriority("FreecamMousePan", MousePan, false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
	end
	Input.StopCapture = function()
		navSpeed = 1
		Zero(keyboard)
		Zero(mouse)
		Services.ContextActionService:UnbindAction("FreecamKeyboard")
		Services.ContextActionService:UnbindAction("FreecamMousePan")
	end
	local GetFocusDistance = function(cameraFrame)
		local znear = 0.1
		local viewport = Camera.ViewportSize
		local projy = 2 * math.tan(cameraFov / 2)
		local projx = viewport.x / viewport.y * projy
		local fx = cameraFrame.rightVector
		local fy = cameraFrame.upVector
		local fz = cameraFrame.lookVector
		local minVect = Vector3.new()
		local minDist = 512
		for x = 0, 1, 0.5 do
			for y = 0, 1, 0.5 do
				local cx = (x - 0.5) * projx
				local cy = (y - 0.5) * projy
				local offset = fx * cx - fy * cy + fz
				local origin = cameraFrame.p + offset * znear
				local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit * minDist))
				local dist = (hit - origin).magnitude
				if minDist > dist then
					minDist = dist
					minVect = offset.unit
				end
			end
		end
		return fz:Dot(minVect) * minDist
	end
	local StepFreecam = function(dt)
		local vel = velSpring:Update(dt, Input.Vel(dt))
		local pan = panSpring:Update(dt, Input.Pan())
		local zoomFactor = math.sqrt(math.tan(math.rad(70 / 2)) / math.tan(math.rad(cameraFov / 2)))
		cameraRot = cameraRot + pan * Vector2.new(0.75, 1) * 8 * (dt / zoomFactor)
		cameraRot = Vector2.new(clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2 * math.pi))
		local cameraCFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0) * CFrame.new(vel * Vector3.new(1, 1, 1) * 64 * dt)
		cameraPos = cameraCFrame.p
		Camera.CFrame = cameraCFrame
		Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
		Camera.FieldOfView = cameraFov
	end
	local mouseBehavior, mouseIconEnabled, cameraType, cameraFocus, cameraCFrame, cameraFieldOfView = "", "", "", "", "", ""
	PlayerState.Push = function()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70
		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom
		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus
		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true
		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
	PlayerState.Pop = function()
		Camera.FieldOfView = 70
		Camera.CameraType = cameraType
		cameraType = nil
		Camera.CFrame = cameraCFrame
		cameraCFrame = nil
		Camera.Focus = cameraFocus
		cameraFocus = nil
		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil
		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
	Freecam.Stop = function()
		if not Freecam.Active then return end
		Input.StopCapture()
		RunService:UnbindFromRenderStep("Freecam")
		PlayerState.Pop()
		Camera.FieldOfView = 70
		Freecam.Active = false
	end
	Freecam.Start = function(pos)
		if Freecam.Active then Freecam.Stop() end
		local cameraCFrame = pos and pos or Camera.CFrame
		cameraRot, cameraPos, cameraFov = Vector2.new(), cameraCFrame.p, Camera.FieldOfView
		velSpring:Reset(Vector3.new())
		panSpring:Reset(Vector2.new())
		PlayerState.Push()
		RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
		Input.StartCapture()
		Freecam.Active = true
	end
	Freecam.Adjust = function(sp) NAV_KEYBOARD_SPEED = Vector3.new(sp, sp, sp) end
end

AddCommand("freecam", "freecam", "Allows you to move your camera freely in the game.", {"fc"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unfreecam")
	Freecam.Start()
	env[1] = function() Freecam.Stop() end
end)

AddCommand("unfreecam", "unfreecam", "Disables freecam.", {"unfc"}, {"Utility"}, 2, function()
	RunCommandFunctions("freecam")
end)

AddCommand("freecamgoto", "freecamgoto [player]", "Starts freecam at [player].", {"fcgoto"}, {"Utility", 1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target and GetCharacter(target) and GetRoot(GetCharacter(target)) then
		ExecuteCommand("unfreecam")
		FindCommand("freecam").Env[1] = function() Freecam.Stop() end
		Freecam.Start(GetRoot(GetCharacter(target)).CFrame * CFrame.new(0, 5, 5))
	end
end)

AddCommand("freecamspeed", "freecamspeed [speed]", "Sets the freecam speed to [speed]. [speed] is an optional argument.", {"fcspeed"}, {"Utility"}, 2, function(args)
	Freecam.Adjust(tonumber(args[1]) or 1)
end)

AddCommand("freecamposition", "freecamposition [x, y, z]", "Starts freecam at the provided coordinates.", {"fcpos"}, {"Utility", 3}, 2, function(args)
	local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
	if x and y and z then
		ExecuteCommand("unfreecam")
		FindCommand("freecam").Env[1] = function() Freecam.Stop() end
		Freecam.Start(CFrame.new(x, y, z))
	end
end)

AddCommand("replicationlag", "replicationlag [number]", "Sets IncomingReplicationLag to [number]. [number] is an optional argument.", {"backtrack"}, {}, 2, function(args)
	UserSettings():GetService("NetworkSettings").IncomingReplicationLag = tonumber(args[1]) or 0
end)

AddCommand("xray", "xray", "Allows you to see through walls.", {}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("noxray")
	local modified = {}
	for _, v in next, workspace:GetDescendants() do
		if v:IsA("Part") and v.Transparency <= 0.3 then
			insert(modified, {Part = v, Transparency = v.Transparency})
			v.Transparency = 0.3
		end
	end
	insert(env, function()
		for _, v in next, modified do
			if v.Part and v.Transparency then
				v.Part.Transparency = v.Transparency
			end
		end
	end)
end)

AddCommand("noxray", "noxray", "Disables xray.", {"unxray"}, {"Utility"}, 2, function()
	RunCommandFunctions("xray")
end)

AddCommand("togglexray", "togglexray", "Toggles xray.", {}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("xray") == 0 and "xray" or "noxray")
end)

AddCommand("restorelighting", "restorelighting", "Restores Lighting's original properties.", {}, {"Utility"}, 2, function()
	for name, property in next, OldLightingProperties do Lighting[name] = property end
end)

AddCommand("bring", "bring [player]", "Brings [player] to you.", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target, character = Players[available], GetCharacter()
		if target and target.Character and LocalPlayer and character then
			local root, root2, humanoid2, tool = GetRoot(), GetRoot(GetCharacter(target)), GetHumanoid(GetCharacter(target)), GetTool(LocalPlayer, true)
			if root and root2 and humanoid2 and not humanoid2.Sit and tool then
				ReplaceHumanoid()
				tool.Parent = character
				tool.Handle.Size = Vector3.new(4, 4, 4)
				local arm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightLowerArm")
				local pos = arm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0)
				tool.Grip = CFrame.new().Inverse(CFrame.new().toObjectSpace(pos, root.CFrame + Vector3.new(3, 1, 0)))
				for _ = 1, 3 do
					firerbxtouch(root2, tool.Handle, 0)
					wait()
					firerbxtouch(root2, tool.Handle, 1)
				end
				wait(0.2)
				ExecuteCommand("refresh")
			end
		end
	end
end)

local _ValidTeams = map(Services.Teams:GetChildren(), function(_, v) return lower(tostring(v.Name)) end)
AddCommand("switchteam", "switchteam [name]", "Switches to the team of [name].", {"changeteam", "team"}, {"Utility", _ValidTeams, 1}, 2, function()
	local root, team = GetRoot(), filter(Services.Teams:GetChildren(), function(_, v) return lower(tostring(v.Name)) == lower(tostring(getstring(1))) end)[1]
	if root and team then
		for _, v in next, workspace:GetDescendants() do
			if v:IsA("SpawnLocation") and v.TeamColor == team.TeamColor then
				firerbxtouch(v, root, 0)
				firerbxtouch(v, root, 1)
				break
			end
		end
	end
end)

AddCommand("equiptools", "equiptools", "Equips all your tools.", {}, {"Utility"}, 2, function()
	local character, backpack = GetCharacter(), GetBackpack()
	if character and backpack then for _, v in next, backpack:GetChildren() do if v:IsA("Tool") then v.Parent = character end end end
end)

AddCommand("activatetools", "activatetools", "Equips and activates all your tools.", {}, {"Utility"}, 2, function()
	local character = GetCharacter()
	if character then
		ExecuteCommand("equiptools")
		local tools = filter(character:GetChildren(), function(_, v) return v:IsA("Tool") end)
		for _, v in next, tools do v:Activate() end
		Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, #tools)
	end
end)

AddCommand("lastcommand", "lastcommand", "Runs the previous command.", {}, {}, 2, function()
	local recent = Admin.History[1]
	if recent then ExecuteCommand(lower(tostring(recent))) end
end)

AddCommand("noclickdetectorlimits", "noclickdetectorlimits", "Removes the distance limit on all click detectors.", {"nocdlimits"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("clickdetectorlimits")
	local modify = function(v)
		local old = v.MaxActivationDistance
		insert(env, function() if v and v.MaxActivationDistance then v.MaxActivationDistance = old end end)
	end
	for _, v in next, workspace:GetDescendants() do
		if v:IsA("ClickDetector") and v.MaxActivationDistance ~= math.huge then
			modify(v)
			v.MaxActivationDistance = math.huge
		end
	end
	AddConnection(env, workspace.DescendantAdded, function(v)
		if v:IsA("ClickDetector") and v.MaxActivationDistance ~= math.huge then
			modify(v)
			v.MaxActivationDistance = math.huge
		end
	end)
end)

AddCommand("clickdetectorlimits", "clickdetectorlimits", "Adds back the distance limit to all click detectors affected by the noclickdetectorlimits command.", {"cdlimits"}, {"Utility"}, 2, function()
	RunCommandFunctions("noclickdetectorlimits")
end)

AddCommand("fireclickdetectors", "fireclickdetectors", "Activates all click detectors.", {"firecds"}, {"Utility"}, 2, function()
	for _, v in next, workspace:GetDescendants() do if v:IsA("ClickDetector") then fireclickdetector(v) end end
end)

AddCommand("firetouchinterests", "firetouchinterests", "Activates all touch interests.", {}, {"Utility"}, 2, function()
	local root = GetRoot()
	if root then
		for _, v in next, workspace:GetDescendants() do
			if v:IsA("TouchTransmitter") then
				firerbxtouch(root, v.Parent, 0)
				wait()
				firerbxtouch(root, v.Parent, 1)
			end
		end
	end
end)

AddCommand("noproximitypromptlimits", "noproximitypromptlimits", "Removes the distance limit on all proximity prompts.", {"nopplimits"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("proximitypromptlimits")
	local modify = function(v)
		local old = v.MaxActivationDistance
		insert(env, function() if v and v.MaxActivationDistance then v.MaxActivationDistance = old end end)
	end
	for _, v in next, workspace:GetDescendants() do
		if v:IsA("ProximityPrompt") and v.MaxActivationDistance ~= math.huge then
			modify(v)
			v.MaxActivationDistance = math.huge
		end
	end
	AddConnection(env, workspace.DescendantAdded, function(v)
		if v:IsA("ProximityPrompt") and v.MaxActivationDistance ~= math.huge then
			modify(v)
			v.MaxActivationDistance = math.huge
		end
	end)
end)

AddCommand("proximitypromptlimits", "proximitypromptlimits", "Adds back the distance limit to all proximity prompts affected by the noproximitypromptlimits command.", {"pplimits"}, {"Utility"}, 2, function()
	RunCommandFunctions("noproximitypromptlimits")
end)

AddCommand("fireproximityprompts", "fireproximityprompts", "Activates all proximity prompts.", {}, {"Utility"}, 2, function()
	for _, v in next, workspace:GetDescendants() do if v:IsA("ProximityPrompt") then fireproximityprompt(v) end end
end)

AddCommand("instantproximityprompts", "instantproximityprompts", "Removes the cooldown for all proximity prompts.", {}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("uninstantproximityprompts")
	AddConnection(env, Services.ProximityPromptService.PromptButtonHoldBegan, fireproximityprompt)
end)

AddCommand("uninstantproximityprompts", "uninstantproximityprompts", "Disables instantproximityprompts.", {"noinstantproximityprompts"}, {"Utility"}, 2, function()
	RunCommandFunctions("instantproximityprompts")
end)

AddCommand("clientantikick", "clientantikick", "Prevents any LocalScripts from kicking you.", {"antikick"}, {"Utility"}, 2, function(_, _, env)
	RunCommandFunctions("clientantikick")
	insert(env, function() end)
	local old, old2, getnamecallmethod = nil, nil, getnamecallmethod or get_namecall_method or function() return "" end
	old = hookmetamethod(game, "__index", function(self, method)
		if next(GetEnvironment("clientantikick")) and self == LocalPlayer and lower(method) == "kick" then return error("Expected ':' not '.' calling member function Kick", 2) end
		return old(self, method)
	end)
	old2 = hookmetamethod(game, "__namecall", function(self, ...)
		if next(GetEnvironment("clientantikick")) and self == LocalPlayer and lower(getnamecallmethod()) == "kick" then return end
		return old2(self, ...)
	end)
end)

AddCommand("unclientantikick", "unclientantikick", "Disables clientantikick.", {"unantikick"}, {"Utility"}, 2, function()
	RunCommandFunctions("clientantikick")
end)

AddCommand("remotespy", "remotespy", "Run a penetration testing tool.", {"simplespy", "rspy"}, {"Utility"}, 2, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

AddCommand("breadcrumbs", "breadcrumbs", "Leaves a trail behind you.", {}, {}, 2, function(_, _, env)
	ExecuteCommand("nobreadcrumbs")
	local attachment = NewInstance("Attachment", {Name = RandomString(), Position = Vector3.new(0, 0.07 - 2.7, 0)})
	local attachment2 = NewInstance("Attachment", {Name = RandomString(), Position = Vector3.new(0, -0.07 - 2.7, 0)})
	local trail = NewInstance("Trail", {Name = RandomString(), Attachment0 = attachment, Attachment1 = attachment2, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1), Color3.new(1, 1, 1)), FaceCamera = true, Lifetime = math.huge, Enabled = true})
	insert(env, function()
		if attachment then attachment:Destroy() end
		if attachment2 then attachment2:Destroy() end
		if trail then trail:Destroy() end
	end)
	AddConnection(env, heartbeat, function()
		local root, camera = GetRoot(), workspace.CurrentCamera
		if root and camera then
			local success, _ = pcall(function() attachment.Parent, attachment2.Parent, trail.Parent = root, root, camera end)
			if not success then ExecuteCommand("nobreadcrumbs") end
		end
	end)
end)

AddCommand("nobreadcrumbs", "nobreadcrumbs", "Disables breadcrumbs.", {"unbreadcrumbs"}, {}, 2, function()
	RunCommandFunctions("breadcrumbs")
end)

AddCommand("crosshair", "crosshair", "Enables and changes your mouse icon.", {}, {}, 2, function(_, _, env)
	ExecuteCommand("nocrosshair")
	local OldMouseIconEnabled, Icon, u2 = UserInputService.MouseIconEnabled, Gui.BaseObject.Crosshair, UDim2.new
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	insert(env, function() UserInputService.MouseIconEnabled, Icon.Visible = OldMouseIconEnabled, false end)
	AddConnection(env, heartbeat, function() UserInputService.MouseIconEnabled, Icon.Position, Icon.Visible = false, u2(0, Mouse.X, 0, Mouse.Y), true end)
end)

AddCommand("nocrosshair", "nocrosshair", "Disables crosshair.", {"uncrosshair"}, {}, 2, function()
	RunCommandFunctions("crosshair")
end)

AddCommand("chat", "chat [message]", "Makes you say [message].", {"say"}, {1}, 2, function()
	SendChatMessage(getstring(1))
end)

AddCommand("trip", "trip", "Makes your character fall over.", {}, {}, 2, function()
	local humanoid, root = GetHumanoid(), GetRoot()
	if humanoid and root then
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		root.Velocity = root.CFrame.LookVector * 30
	end
end)

AddCommand("strengthen", "strengthen [number]", "Makes your character more dense by setting CustomPhysicalProperties to [number]. [number] is an optional argument.", {}, {"Utility"}, 2, function(args)
	for _, v in next, GetCharacter():GetDescendants() do
		if v:IsA("Part") then
			v.CustomPhysicalProperties = PhysicalProperties.new(tonumber(args[1]) or 100, 0.3, 0.5)
		end
	end
end)

AddCommand("weaken", "weaken [number]", "Makes your character less dense by setting CustomPhysicalProperties to [number]. [number] is an optional argument.", {}, {"Utility"}, 2, function(args)
	for _, v in next, GetCharacter():GetDescendants() do
		if v:IsA("Part") then
			v.CustomPhysicalProperties = PhysicalProperties.new(-tonumber(args[1]) or 0, 0.3, 0.5)
		end
	end
end)

AddCommand("unstrengthen", "unstrengthen", "description.", {"unweaken"}, {"Utility"}, 2, function()
	for _, v in next, GetCharacter():GetDescendants() do
		if v:IsA("Part") then
			v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

AddCommand("bang", "bang [player] [speed]", "Bangs [player] with a speed of [speed]. [speed] is an optional argument.\n\n\"Prank 'em John.\" - CalebCity", {}, {"Utility", "spawned", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unbang")
	local humanoid = GetHumanoid()
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target and target.Character and GetRoot(GetCharacter(target)) and GetRoot() and humanoid then
			local id = NewInstance("Animation", {AnimationId = (humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://5918726674") or "rbxassetid://148840371"})
			local anim = humanoid:LoadAnimation(id)
			anim:Play(0.1, 1, 1)
			anim:AdjustSpeed(tonumber(args[2]) or 3)
			insert(env, function()
				if anim then anim:Stop() end
				if id then id:Destroy() end
			end)
			AddConnection(env, RunService.Stepped, function() pcall(function() GetRoot().CFrame = GetRoot(GetCharacter(target)).CFrame * CFrame.new(0, 0, 1.1) end) end)
			AddConnection(env, humanoid.Died, function() ExecuteCommand("unbang") end)
		end
	end
end)

AddCommand("unbang", "unbang", "Stop being sus in a lego game.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("bang")
end)

AddCommand("loopgoto", "loopgoto [player] [distance]", "Loop goto [player]. [distance] is an optional argument.", {}, {"Utility", "spawned", 1}, 2, function(args, _, env)
	ExecuteCommand("unloopgoto")
	insert(env, function() end)
	repeat heartbeat:Wait()
		ExecuteCommand(format("goto %s %d", args[1], tonumber(args[2]) or 5.8))
	until not next(GetEnvironment("loopgoto"))
end)

AddCommand("unloopgoto", "unloopgoto", "Disables loopgoto.", {}, {"Utility"}, 2, function()
	RunCommandFunctions("loopgoto")
end)

AddCommand("hidename", "hidename", "Removes billboards from your character.", {"nobillboardgui"}, {"Utility"}, 2, function()
	for _, v in next, GetCharacter():GetDescendants() do if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v:Destroy() end end
end)

AddCommand("loophidename", "loophidename", "Constantly removes billboards from your character.", {"loopnobillboardgui"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unloophidename")
	local character = GetCharacter()
	for _, v in next, character:GetDescendants() do if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v:Destroy() end end
	AddConnection(env, character.DescendantAdded, function(v) if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v:Destroy() end end)
end)

AddCommand("unloophidename", "unloophidename", "Disables loophidename.", {"unloopnobillboardgui"}, {"Utility"}, 2, function()
	RunCommandFunctions("loophidename")
end)

AddCommand("gravity", "gravity [number]", "Changes the workspace gravity to [number]. [number] is an optional argument.", {}, {"Utility"}, 2, function(args)
	workspace.Gravity = tonumber(args[1]) or OldGravity
end)

AddCommand("mousetp", "mousetp", "Teleports your character to your mouse. This is recommended as a keybind.", {}, {"Utility"}, 2, function()
	local root, pos = GetRoot(), Mouse.Hit
	if root and pos then root.CFrame = pos + Vector3.new(3, 1, 0) end
end)

AddCommand("light", "light [radius] [brightness]", "Gives your character dynamic light. [radius] and [brightness] are optional arguments.", {}, {"Utility"}, 2, function(args, _, env)
	ExecuteCommand("nolight")
	local root = GetRoot()
	if root then
		local light = NewInstance("PointLight", {Name = RandomString(), Range = tonumber(args[1]) or 30, Brightness = tonumber(args[2]) or 5, Parent = root})
		insert(env, function() if light then light:Destroy() end end)
	end
end)

AddCommand("nolight", "nolight", "Disables light.", {"unlight"}, {"Utility"}, 2, function()
	RunCommandFunctions("light")
end)

AddCommand("hipheight", "hipheight [number]", "Changes your character's hip height to [number]. [number] is an optional argument.", {}, {"Utility"}, 2, function(args)
	local humanoid = GetHumanoid()
	if humanoid then humanoid.HipHeight = humanoid.RigType == Enum.HumanoidRigType.R15 and (tonumber(args[1]) or 2.1) or (tonumber(args[1]) or 0) end
end)

AddCommand("rocketconnect", "rocketconnect [player]", "Uses a rocket (RocketPropulsion) to make your character follow [player].", {}, {"Fun", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unrocketconnect")
	local target, root, humanoid = Players[getPlayer(args[1], speaker)[1]], GetRoot(), GetHumanoid()
	if target and GetCharacter(target) and GetRoot(GetCharacter(target)) and root and humanoid then
		humanoid.Sit = true
		local rocket = NewInstance("RocketPropulsion", {Name = RandomString(), CartoonFactor = 1, MaxThrust = 5000, MaxSpeed = 100, ThrustP = 5000, Target = GetRoot(GetCharacter(target)), Parent = root})
		rocket:Fire()
		insert(env, function() if rocket then rocket:Destroy() end end)
		AddConnection(env, humanoid.Died, function() ExecuteCommand("unrocketconnect") end)
		AddConnection(env, humanoid.Seated, function(value) if not value then ExecuteCommand("unrocketconnect") end end)
	end
end)

AddCommand("unrocketconnect", "unrocketconnect", "Disables rocketconnect.", {}, {"Fun"}, 2, function()
	RunCommandFunctions("rocketconnect")
end)

AddCommand("orbit", "orbit [player] [speed] [distance]", "Makes your character orbit around [player] with a speed of [speed] and a distance of [distance]. [speed] and [distance] are optional arguments.", {}, {"Fun", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unorbit")
	local target, root, humanoid = Players[getPlayer(args[1], speaker)[1]], GetRoot(), GetHumanoid()
	if target and GetCharacter(target) and GetRoot(GetCharacter(target)) and root and humanoid then
		local rotation, speed, distance = 0, (tonumber(args[2]) or 0.2), (tonumber(args[3]) or 6)
		AddConnection(env, heartbeat, function()
			pcall(function()
				rotation = rotation + speed
				root.CFrame = CFrame.new(GetRoot(GetCharacter(target)).Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)
			end)
		end)
		AddConnection(env, RunService.RenderStepped, function() pcall(function() root.CFrame = CFrame.new(root.Position, GetRoot(GetCharacter(target)).Position) end) end)
		AddConnection(env, humanoid.Died, function() ExecuteCommand("unorbit") end)
		AddConnection(env, humanoid.Seated, function(value) if value then ExecuteCommand("unorbit") end end)
	end
end)

AddCommand("unorbit", "unorbit", "Disables orbit.", {}, {"Fun"}, 2, function()
	RunCommandFunctions("orbit")
end)

AddCommand("stareat", "stareat [player]", "Makes your character stare at [player].", {}, {"Fun", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unstareat")
	local target, root, humanoid = Players[getPlayer(args[1], speaker)[1]], GetRoot(), GetHumanoid()
	if target and GetCharacter(target) and GetRoot(GetCharacter(target)) and root and humanoid then
		AddConnection(env, RunService.RenderStepped, function() pcall(function() root.CFrame = CFrame.new(root.Position, GetRoot(GetCharacter(target)).Position) end) end)
		AddConnection(env, humanoid.Died, function() ExecuteCommand("unorbit") end)
		AddConnection(env, humanoid.Seated, function(value) if value then ExecuteCommand("unorbit") end end)
	end
end)

AddCommand("unstareat", "unstareat", "Disables stareat.", {}, {"Fun"}, 2, function()
	RunCommandFunctions("stareat")
end)

AddCommand("wallteleport", "wallteleport", "Makes your character stare at [player].", {"walltp"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unwallteleport")
	local root, humanoid = GetRoot(), GetHumanoid()
	if root and humanoid then
		AddConnection(env, root.Touched, function(hit)
			root, humanoid = GetRoot(), GetHumanoid()
			if root and humanoid and hit:IsA("BasePart") and hit.Position.Y > root.Position.Y - humanoid.HipHeight then
				local hitRoot = GetRoot(hit.Parent)
				if hitRoot ~= nil then
					root.CFrame = hit.CFrame * CFrame.new(root.CFrame.lookVector.X, hitRoot.Size.Z / 2 + humanoid.HipHeight, root.CFrame.lookVector.Z)
				elseif hitRoot == nil then
					root.CFrame = hit.CFrame * CFrame.new(root.CFrame.lookVector.X, hit.Size.Y / 2 + humanoid.HipHeight, root.CFrame.lookVector.Z)
				end
			end
		end)
		AddConnection(env, humanoid.Died, function() ExecuteCommand("unwallteleport") end)
	end
end)

AddCommand("unwallteleport", "unwallteleport", "Disables wallteleport.", {"unwalltp"}, {"Utility"}, 2, function()
	RunCommandFunctions("wallteleport")
end)

AddCommand("togglewallteleport", "togglewallteleport", "Toggles wallteleport.", {"togglewalltp"}, {"Toggle"}, 2, function()
	ExecuteCommand(#GetEnvironment("wallteleport") == 0 and "wallteleport" or "unwallteleport")
end)

AddCommand("offset", "offset [x, y, z]", "Offsets you by the provided coordinates.", {}, {"Utility", 3}, 2, function(args)
	local character, x, y, z = GetCharacter(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
	if character and x and y and z then character:TranslateBy(Vector3.new(x, y, z)) end
end)

AddCommand("tweenoffset", "tweenoffset [x, y, z]", "Tween offsets you by the provided coordinates.", {}, {"Utility", 3}, 2, function(args)
	local root, x, y, z = GetRoot(), tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
	if root and x and y and z then TweenObj(root, "Sine", "Out", Config.TweenSpeed, {CFrame = CFrame.new(x, y, z)}) end
end)

AddCommand("grabtools", "grabtools", "Gives yourself tools that are in workspace.", {}, {"Utility"}, 2, function()
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid:UnequipTools()
		for _, v in next, workspace:GetDescendants() do if v:IsA("Tool") and v:FindFirstChild("Handle") then humanoid:EquipTool(v) end end
		wait(0.25)
		humanoid:UnequipTools()
	end
end)

AddCommand("listento", "listento [player]", "\"Listens to the area around the player (cool with vc).\" - 1Shawn1", {"listen"}, {"Fun", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unlistento")
	local target = Players[getPlayer(args[1], speaker)[1]]
	local root = GetRoot(GetCharacter(target))
	if root then
		env[1] = function() Services.SoundService:SetListener(Enum.ListenerType.Camera) end
		Services.SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
		AddConnection(env, target.CharacterRemoving, function() Services.SoundService:SetListener(Enum.ListenerType.Camera) end)
	end
end)

AddCommand("unlistento", "unlistento", "Disables listento.", {"unlisten"}, {"Fun", 1}, 2, function()
	RunCommandFunctions("listento")
end)

AddCommand("ignore", "ignore [player]", "Ignores [player] by putting them in Lighting.", {"forget"}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			local tracker = format("ignore-%s", target.Name)
			RemoveConnection(tracker)
			target.Character.Parent = Lighting
			AddConnection(tracker, target.CharacterAdded, function() target.Character.Parent = Lighting end)
			Notify("i forgor 💀")
		end
	end
end)

AddCommand("unignore", "unignore [player]", "Stops ignoring [player].", {"remember"}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			RemoveConnection(format("ignore-%s", target.Name))
			target.Character.Parent = workspace
			Notify("i rember!!! 😄 💡")
		end
	end
end)

-- load toast
pcall(function()
    getgenv().dxrkj = function()
        Notify(format("script already loaded\nyour prefix is %s (%s)\nrun 'killscript' to kill the script", Config.CommandBarPrefix, Admin.Prefix), 10)
    end
end)

-- inaccurate loading time because funny
if Config.StartupNotification then
    Notify(format("prefix is %s (%s)\nloaded in %.3f seconds\nrun 'help' for help", Config.CommandBarPrefix, Admin.Prefix, tick() - LoadingTick), 10)
end

if listfiles and type(listfiles) == "function" then
    for _, v in next, filter(map(filter(listfiles("dark-admin/plugins"), function(_, v)
        return FindInTable(PluginExtensions, "." .. lower(split(v, ".")[#split(v, ".")]))
    end), function(_, v)
        return tostring(split(v, "\\")[2])
    end),
    function(_, v)
        return not FindInTable(Config.DisabledPlugins, v)
    end) do
        InstallPlugin(v, true)
    end
end

for name, permission in next, MiscConfig.Permissions do
	local command = FindCommand(name)
	if command then if command.PermissionIndex == permission then MiscConfig.Permissions[name] = nil else command.PermissionIndex = permission end end
end

UpdateMiscConfig()
Events.Load()
Events.Fire("OnExecute")
