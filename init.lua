if not game:IsLoaded() then
	game.Loaded:Wait()
end

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

local cloneref = cloneref or function(...) return ... end
local Services = {}
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
remove, gmatch, match, tfind, wait, spawn = table.remove, string.gmatch, string.match, table.find, task.wait, task.spawn
split, format, upper, clamp, round, heartbeat, renderstepped = string.split, string.format, string.upper, math.clamp, math.round, RunService.Heartbeat, RunService.RenderStepped
local getconnections = getconnections or get_signal_cons
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local creatingInstance = Instance.new
local OldFallenPartsDestroyHeight = workspace.FallenPartsDestroyHeight
local OldGravity = workspace.Gravity
local OldLightingProperties = {Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, GlobalShadows = Lighting.GlobalShadows}

RandomString = function() return sub(gsub(HttpService:GenerateGUID(false), "-", ""), 1, random(25, 30)) end

--[[
Prote = (function()
	local success, result = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/prote.lua")
	end)
	return success and loadstring(result)() or {ProtectObject = function() end, SpoofObject = function() end, SpoofProperty = function() end, UnSpoofObject = function() end, FocusedBox = function() end, Hook = function() end}
end)()
]]

cons = {connections = {}, loaded = true}
cons.add = function(name, con, func)
	if not func then
		func = con
		con = name
		name = RandomString()
	end
	cons.connections[name] = con:Connect(func)
	return cons.connections[name]
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

isNumber = function(str) if tonumber(str) ~= nil or str == "inf" then return true end end

NewInstance = function(class, props)
	local inst = creatingInstance(class)
	for prop, value in pairs(props) do
		inst[prop] = value
	end
	return inst
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
	return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
end

IsKeyDown = function(...)
	return UserInputService:IsKeyDown(...)
end

merge_table = function(...)
	local new = {}
	for i, v in next, {...} do
		for _, v2 in next, v do
			new[i] = v2
		end
	end
	return new
end

HasTool = function(player)
	player = player or LocalPlayer
	local character, backpack = GetCharacter(player), GetBackpack(player)
	if character and backpack then
		local list = merge_table(character:GetChildren(), backpack:GetChildren())
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
		local tool = character:FindFirstChildWhichIsA("Tool") or backpack:FindFirstChildWhichIsA("Tool")
		if requiresHandle then
			local handle = tool:FindFirstChild("Handle")
			if handle and handle:IsA("Part") then
				return tool
			end
			return nil
		end
		return tool
	end
	return nil
end

local touchedcache = {}
firerbxtouch = (getgenv and type(getgenv) == "function" and getgenv().firetouchinterest) or function(part, part2, value)
	if part and part2 then
		if value == 0 then
			touchedcache[1] = part.CFrame
			part.CFrame = part2.CFrame
		else
			part.CFrame = touchedcache[1]
			touchedcache[1] = nil
		end
	end
end

GetUsername = function(player)
	player = player or LocalPlayer
	return player.DisplayName and player.DisplayName or player.Name
end

GetLongUsername = function(player)
	player = player or LocalPlayer
	return player.DisplayName and format("%s (%s)", player.Name, player.DisplayName) or player.Name
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
	if data and type(data) == "table" then
		return data
	end
	return {Player = player, Value = false}
end

ReplaceHumanoid = function()
	local humanoid = GetHumanoid()
	if humanoid then
		local new = humanoid:Clone()
		new.Parent = humanoid.Parent
		new.Name = humanoid.Name
		humanoid:Destroy()
	end
end

Attach = function(target)
	if HasTool(LocalPlayer) and target then
		local tool, character, tcharacter = GetTool(LocalPlayer, true), GetCharacter(), GetCharacter(target)
		if tool and character and tcharacter then
			local humanoid, root, root2 = GetHumanoid(), GetRoot(), GetRoot(tcharacter)
			if humanoid and root and root2 then
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
end

GetEnvironment = function(...)
	local command = FindCommand(...)
	return command and command.Env or {}
end

RemoveCommand = function(cmd)
	cmd = lower(tostring(cmd))
	for i, v in pairs(Admin.Commands) do
		if lower(tostring(v.Name)) == cmd or FindInTable(v.Alias, cmd) then
			remove(Admin.Commands, i)
		end
	end
end

SendChatMessage = function(str, channel)
	if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest") then
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, channel or "All")
	end
end

local ChatHistory = {}
local LogChatMessage = function(player, message)
	insert(ChatHistory, {Player = player, Name = GetLongUsername(player), Message = message})
	local Container = GetEnvironment("chatlogs")[1]
	if Container and Container.UI and Container.Section then
		local log = format("[%s]: %s", GetLongUsername(player), message)
		Container.Section:AddItem("ButtonText", {Text = log, Function = function() toexecutorclipboard(log) end})
	end
end

local CapitalizeFirstCharacter = function(str)
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
		local plrs = {}
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				insert(plrs, v)
			end
		end
		return plrs
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
        local players = Players:GetPlayers()
		remove(players, tfind(players, LocalPlayer))
		return {players[random(1, #players)]}
	end,
	["%%(.+)"] = function(speaker, args)
		local returns = {}
		local team = args[1]
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Team and sub(lower(plr.Team.Name), 1, #team) == lower(team) then
				insert(returns, plr)
			end
		end
		return returns
	end,
	allies = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				insert(returns, plr)
			end
		end
		return returns
	end,
	enemies = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				insert(returns, plr)
			end
		end
		return returns
	end,
	team = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				insert(returns, plr)
			end
		end
		return returns
	end,
	nonteam = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				insert(returns, plr)
			end
		end
		return returns
	end,
	friends = function(speaker, args)
		local returns = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				insert(returns, plr)
			end
		end
		return returns
	end,
	nonfriends = function(speaker, args)
		local returns = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				insert(returns, plr)
			end
		end
		return returns
	end,
	guests = function(speaker, args)
		local returns = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				insert(returns, plr)
			end
		end
		return returns
	end,
	bacons = function(speaker, args)
		local returns = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild("Pal Hair") or plr.Character:FindFirstChild("Kate Hair") then
				insert(returns, plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker, args)
		local returns = {}
		local age = tonumber(args[1])
		if not age then return end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				insert(returns, plr)
			end
		end
		return returns
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
		local returns = {}
		local groupID = tonumber(args[1])
		for _, plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then
				insert(returns, plr)
			end
		end
		return returns
	end,
	alive = function(speaker, args)
		local returns = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				insert(returns, plr)
			end
		end
		return returns
	end,
	dead = function(speaker, args)
		local returns = {}
		for _, plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				insert(returns, plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker, args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not GetRoot(speakerChar) then return end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character and GetRoot(plr.Character) then
				local magnitude = (GetRoot(plr.Character).Position - GetRoot(speakerChar).Position).magnitude
				if magnitude <= radius then insert(returns, plr) end
			end
		end
		return returns
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

lastCmds = {}
lastBreakTime = 0
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
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
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
							if Admin.History[1] ~= rawCmdStr and sub(rawCmdStr, 1, 11) ~= "lastcommand" and sub(rawCmdStr, 1, 7) ~= "lastcmd" then
								insert(Admin.History, 1, rawCmdStr)
							end
						end
						if #Admin.History > 30 then remove(Admin.History) end
						lastCmds[cmdName] = v
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
							while lastBreakTime < cmdStartTime do
								runCommand()
								wait(cmdDelay)
							end
						else
							for _ = 1, num do
								if lastBreakTime > cmdStartTime then break end
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

cons.add(LocalPlayer.Chatted, function(message)
	spawn(function()
		wait()
		do_exec(tostring(message), LocalPlayer)
	end)
	LogChatMessage(LocalPlayer, message)
end)

for _, player in next, Players:GetPlayers() do
	if player ~= LocalPlayer then
		cons.add(player.Chatted, function(message)
			spawn(function()
				wait()
				do_exec(message, player)
			end)
			LogChatMessage(player, message)
		end)
	end
end

cons.add(Players.PlayerAdded, function(player)
	cons.add(player.Chatted, function(message)
		spawn(function()
			wait()
			do_exec(message, player)
		end)
		LogChatMessage(player, message)
	end)
end)

filterthrough = function(tbl, ret)
	if type(tbl) == "table" then
		local new = {}
		for i, v in next, tbl do
			if ret(i, v) then
				new[#new + 1] = v
			end
		end
		return new
	end
end

Admin.CommandRequirements = {
	spawned = {
		func = function() return GetCharacter() ~= nil end,
		warning = "you need to be spawned for this command"
	},
	tool = {
		func = HasTool,
		warning = "you need a tool for this command"
	}
}

AddCommand = function(name, usage, description, alias, reqs, perm, func, pl)
	local Id = #Admin.Commands + 1
	Admin.Commands[Id] = {
		Name = lower(tostring(name)),
		Usage = usage,
		Description = description,
		Alias = alias or {},
		Requirements = reqs or {},
		PermissionIndex = perm or 2,
		ArgsNeeded = tonumber(filterthrough(reqs, function(_, v)
			return type(v) == "number"
		end)[1]) or 0,
		Category = filterthrough(reqs, function(_, v)
			return type(v) == "string" and (v == CapitalizeFirstCharacter(v))
		end)[1] or "Misc",
		CustomArgs = filterthrough(reqs, function(_, v)
			return type(v) == "table"
		end)[1] or {},
		Func = function()
			for _, v in next, reqs do
				if type(v) == "function" and v() == false then
					if Admin.RequirementsNotification then
						Notify("you are missing something that is needed for this command")
					end
					return false
				elseif type(v) == "string" and Admin.CommandRequirements[v] ~= nil and Admin.CommandRequirements[v].func() == false then
					if Admin.RequirementsNotification then
						Notify(Admin.CommandRequirements[v].warning)
					end
					return false
				end
			end
			return func
		end,
		Env = {},
		Plugin = pl or false
	}
	local DestroyFunc = function() Admin.Commands[Id] = nil end
	return {Destroy = DestroyFunc, Remove = DestroyFunc, Delete = DestroyFunc}
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
		local env = setmetatable({}, {__index = getgenv()})
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
local Config = {
	Prefix = ";",
	Plugins = {},
	DisabledPlugins = {},
	LoweredText = false,
	FlySpeed = 1,
	TweenSpeed = 1,
	KeepAdmin = true,
	Widebar = false
}
local MiscConfig = {Permissions = {}}
local UpdateConfig, UpdateMiscConfig = function() end, function() end
do
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
PluginExtensions = {".luau", ".lua", ".txt", ".da"}

LoadPlugin = function(path, ignore)
	local Success, Plugin = pcall(function()
		return loadstring(readfile(format("dark-admin/plugins/%s", path)))()
	end)
	if not Success then
		Notify(format("plugin error for (%s)\nplease open console (F9) for the error", path))
		for i, v in next, Config.Plugins do
			if v == path then
				Config.Plugins[i] = nil
			end
		end
		UpdateConfig()
		warn("Plugin Error", format("(%s) -", path), Plugin)
		warn("Plugin Error", format("(%s) -", path), "Stack Traceback:", tostring(debug.traceback(Plugin)))
		Plugin = nil
		return
	end
	if Plugin ~= nil then
		spawn(function()
			if Plugin.Commands and type(Plugin.Commands) == "table" then
				for _, v in next, Plugin.Commands do
					if v.Name then
						local Requirements = v.Requirements or {}
						local Category = filterthrough(Requirements, function(_, x)
							return type(x) == "string" and (x == CapitalizeFirstCharacter(x))
						end)[1]
						local ArgsNeeded = tonumber(filterthrough(Requirements, function(_, x)
							return type(x) == "number"
						end)[1])
						local CustomArgs = filterthrough(Requirements, function(_, x)
							return type(x) == "table"
						end)[1]
						if Category == nil then
							if v.Category and type(v.Category) == "string" then
								v.Category = CapitalizeFirstCharacter(v.Category)
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
		if not FindInTable(Config.Plugins, file) then
			for i, v in next, Config.DisabledPlugins do
				if v == file then
					Config.DisabledPlugins[i] = nil
				end
			end
			insert(Config.Plugins, file)
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
		for i, v in next, Config.Plugins do
			if v == file then
				Config.Plugins[i] = nil
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
			if MatchSearch(argument, name) then
				return name
			end
		end
	end)()
end

cons.add(CommandBar.FocusLost, function()
	Prediction.Text = ""
	cons.remove("tab complete")
end)

cons.add(CommandBar:GetPropertyChangedSignal("Text"), function()
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

cons.add(CommandBar.Focused, function()
	cons.add("tab complete", UserInputService.InputBegan, function(input)
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
			cons.remove("tab complete")
		end
	end)
end)

local TweenObj = function(obj, style, direction, cd, goal)
	local tweeninfo = TweenInfo.new(cd, Enum.EasingStyle[style], Enum.EasingDirection[direction])
	local Tween = TweenService:Create(obj, tweeninfo, goal)
	Tween:Play()
	return Tween
end

cons.add(CommandBar.FocusLost, function(enterPressed)
	if enterPressed then
		local Command = gsub(CommandBar.Text, "^" .. "%" .. Config.Prefix, "")
		TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {
			Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, 5)
		})
		spawn(function() ExecuteCommand(Command, LocalPlayer, true) end)
	end
	wait()
	if not CommandBar:IsFocused() then
        CommandBar.Text = ""
    end
end)

cons.add(Mouse.KeyDown, function(Key)
	if Key == Config.Prefix then
		CommandBar:CaptureFocus()
		spawn(function()
			RunService.Stepped:Wait()
			CommandBar.Text = ""
		end)
		TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {
			Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, -110)
		})
	end
end)

-- Commands
AddCommand("debug", "debug", "Toggle the script's debug mode for commands.", {}, {"Core"}, 2, function(args, speaker)
	Admin.Debug = not Admin.Debug
end)

AddCommand("killscript", "killscript", "Completely uninjects the script.", {}, {"Core"}, 2, function(args, speaker)
	cons.wipe()
	Gui.BaseObject:Destroy()
	for _, command in next, Admin.Commands do
		local undo = command.Env[1]
		if undo and type(undo) == "function" then
			spawn(pcall, undo)
		end
	end
end)

AddCommand("reloadscript", "reloadscript", "Completely uninjects the script and re-executes it.", {}, {"Core"}, 2, function(args, speaker)
	ExecuteCommand("killscript")
	coroutine.wrap(function()
		local success, result = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/init.lua")
		end)
		local file, data = pcall(readfile, "dark-admin/init.lua")
		if file then
			loadstring(data)()
		elseif success then
			loadstring(result)()
		end
	end)()
end)

AddCommand("helpmenu", "helpmenu", "Get started using the script.", {"help"}, {"Core"}, 2, function()
	local Section = Gui.New("Help"):AddSection("Section")
	Section:AddItem("Text", {Text = "Get started", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	Section:AddItem("Text", {Text = "Run 'cmds' to view all available commands"})
	Section:AddItem("Text", {Text = "See a command's information", TextXAlignment = Enum.TextXAlignment.Center, ImageTransparency = 1})
	Section:AddItem("Text", {Text = "You should have noticed that the command list does not let you click a command to view more information."})
	Section:AddItem("Text", {Text = "Run 'cmdinfo name' to view a command's information."})
	Section:AddItem("Text", {Text = "Change 'name' to the name of the command you want to view."})
end)

AddCommand("addplugin", "addplugin [name]", "Add a plugin. A plugin is a file in the admin's plugins folder (dark-admin -> plugins) located in your executor's workspace folder. The provided argument is the file name with or without the file extension.", {}, {"Core", 1}, 2, function(args, speaker)
	InstallPlugin(getstring(1), false)
end)

AddCommand("removeplugin", "removeplugin [name]", "Remove a plugin. A plugin is a file in the admin's plugins folder (dark-admin -> plugins) located in your executor's workspace folder. The provided argument is the file name with or without the file extension.", {}, {"Core", 1}, 2, function(args, speaker)
	UninstallPlugin(getstring(1))
end)

AddCommand("commands", "commands", "View the command list.", {"cmds"}, {"Core"}, 2, function()
	local new = {}
	for _, command in next, Admin.Commands do
		local category = command.Category or "Misc"
		if not new[category] then
			new[category] = {}
		end
		new[category][command.Name] = lower(command.Usage)
	end
	Gui.DisplayTable("Commands", new)
end)

AddCommand("commandinfo", "commandinfo [command]", "View more information about [command].", {"cmdinfo", "cinfo"}, {"Core", 1}, 2, function(args)
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

AddCommand("changelogs", "changelogs", "View the changelogs.", {"changelog"}, {"Core"}, 2, function()
	local success, result = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/changelog.json")
	end)
	if success then
		Gui.DisplayTable("Changelog", HttpService:JSONDecode(result))
	end
end)

AddCommand("editpermissions", "editpermissions [command] [number]", "Modify the permission index of [command] to [number].", {"editperms"}, {"Core", 2}, 2, function(args)
	local command = FindCommand(lower(tostring(args[1])))
	if command and args[2] and isNumber(args[2]) then
		local perm = tonumber(args[2])
		if perm >= 2 then
			perm = 2
		end
		command.PermissionIndex = perm
		MiscConfig.Permissions[command.Name] = perm
		UpdateMiscConfig()
		Notify(format("set permission of %s to %d", command.Name, perm))
	end
end)

AddCommand("whitelist", "whitelist [player]", "Whitelist a [player] to use permission index 1 commands.", {}, {"Core", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			Admin.Whitelisted[tostring(target.UserId)] = {Player = target, Value = true}
			Notify(format("whitelisted %s", GetLongUsername(target)))
		end
	end
end)

AddCommand("unwhitelist", "unwhitelist [player]", "Unwhitelist a [player] to use permission index 1 commands.", {}, {"Core", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			Admin.Whitelisted[tostring(target.UserId)] = nil
			Notify(format("removed the whitelist for %s", GetLongUsername(target)))
		end
	end
end)

AddCommand("whitelisted", "whitelisted", "View a list of the current players that can use permission index 1 commands.", {}, {"Core"}, 2, function()
	local new = {}
	for _, v in next, Admin.Whitelisted do
		insert(new, GetLongUsername(v.Player))
	end
	if #new == 0 then
		Notify("no players are currently whitelisted")
	else
		Gui.DisplayTable("Whitelisted", new)
	end
end)

AddCommand("prefix", "prefix [symbol]", "Changes the admin prefix to [symbol].", {}, {"Core", 1}, 2, function(args)
	if #args[1] <= 2 then
		Config.Prefix = args[1]
		UpdateConfig()
		Notify(format("prefix has been changed to %s", Config.Prefix))
	elseif #args[1] > 2 then
		Notify("prefix cannot be longer than 2 characters")
	end
end)

AddCommand("lowercasedcommandbar", "lowercasedcommandbar", "Makes all future text in the command bar lowercased.", {}, {"Core"}, 2, function()
	Config.LoweredText = true
	UpdateConfig()
end)

AddCommand("unlowercasedcommandbar", "unlowercasedcommandbar", "Undoes lowercasedcommandbar.", {}, {"Core"}, 2, function()
	Config.LoweredText = false
	UpdateConfig()
end)

AddCommand("chatlogs", "chatlogs", "View the server's chat history.", {}, {"Core"}, 2, function(_, _, env)
	local Container = Gui.Log("Chatlogs", function() env[1] = nil end, true)
	local Section = Container:AddSection("Section")
	Section:AddItem("Button", {Text = "Save Chatlogs", TextXAlignment = Enum.TextXAlignment.Center, Function = function()
		ExecuteCommand("savechatlogs")
	end})
	spawn(function()
		for _, v in next, ChatHistory do
			local log = format("[%s]: %s", v.Name, v.Message)
			Section:AddItem("ButtonText", {Text = log, Function = function() toexecutorclipboard(log) end})
		end
	end)
	env[1] = {UI = Container, Section = Section}
end)

AddCommand("savechatlogs", "savechatlogs", "If you don't want to scroll up in the chatlogs to save it, this exists.", {}, {"Core"}, 2, function()
	if #ChatHistory == 0 then
		Notify("no chat history available")
		return
	end
	local os = os.date("*t")
	local date = os.hour .. " " .. os.min .. " " .. os.sec .. " " .. os.day .. "." .. os.month .. "." .. os.year
	local name = gsub(Services.MarketplaceService:GetProductInfo(game.PlaceId).Name, "[*\\?:<>|]+", "")
	local data = format("Chatlogs for \"%s\"\n\n\n\n", name)
	for _, v in next, ChatHistory do
		data = data .. format("[%s]: %s\n", v.Name, v.Message)
	end
	local success, result = pcall(function()
		writefile(format("dark-admin/logs/%s - %s.txt", name, date), data)
	end)
	if success then
		Notify("successfully saved chatlogs")
	else
		warn("Save Error:", result)
		Notify("failed to save chatlogs, check console for more info")
	end
end)

cons.add(LocalPlayer.OnTeleport, function()
	if Config.KeepAdmin and queue_on_teleport then
		queue_on_teleport([[local success, result = pcall(function()
	return game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/init.lua")
end)
local file, data = pcall(readfile, "dark-admin/init.lua")
if file then
	loadstring(data)()
elseif success then
	loadstring(result)()
end]])
	end
end)
AddCommand("keepadmin", "keepadmin", "Make it so the script re-executes upon teleporting. This is a toggle and saves.", {}, {"Core"}, 2, function()
	Config.KeepAdmin = not Config.KeepAdmin
	UpdateConfig()
	Notify(format("keep admin has been %s", Config.KeepAdmin and "enabled\nthe script will execute when you teleport" or "disabled"))
end)

AddCommand("widebar", "widebar", "Widen the command bar. This is a toggle and saves.", {}, {"Core"}, 2, function()
	Config.Widebar = not Config.Widebar
	TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {
		Position = UDim2.new(0.5, Config.Widebar and -200 or -100, 1, 5)
	})
	TweenObj(CommandBarFrame, "Quint", "Out", 0.5, {
		Size = UDim2.new(0, Config.Widebar and 400 or 200, 0, 35)
	})
	UpdateConfig()
end)

AddCommand("breakloops", "breakloops", "'Stops all command loops (inf^1^kill).", {}, {"Core"}, 2, function()
	lastBreakTime = tick()
end)

AddCommand("viewtools", "viewtools [player]", "View the tools of [player].", {}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			local backpack, tools = GetBackpack(target), {}
			if backpack then
				for _, v in next, backpack:GetChildren() do
					if v:IsA("Tool") or v:IsA("HopperBin") then
						insert(tools, v.Name)
					end
				end
				Gui.DisplayTable(format("Tools (%s)", GetUsername(target)), tools)
			end
		end
	end
end)

AddCommand("fly", "fly", "Make your character able to fly.", {}, {"Utility", "spawned"}, 2, function(_, _, env)
	ExecuteCommand("unfly")
	local character, humanoid, root = GetCharacter(), GetHumanoid(), GetRoot()
	if not character or not humanoid or not root then
		return
	end

	local BodyGyroName, BodyVelocityName, MaxSpeed = RandomString(), RandomString(), function()
		return Config.FlySpeed * 50
	end
	local Controls = {Front = 0, Back = 0, Left = 0, Right = 0, Down = 0, Up = 0}
	local Keys = {
		[Enum.KeyCode.W] = function(t)
			Controls.Front = clamp(Controls.Front + (t and 1 or -1), 0, MaxSpeed())
		end,
		[Enum.KeyCode.A] = function(t)
			Controls.Left = clamp(Controls.Left + (t and -1 or 1), -MaxSpeed(), 0)
		end,
		[Enum.KeyCode.S] = function(t)
			Controls.Back = clamp(Controls.Back + (t and -1 or 1), -MaxSpeed(), 0)
		end,
		[Enum.KeyCode.D] = function(t)
			Controls.Right = clamp(Controls.Right + (t and 1 or -1), 0, MaxSpeed())
		end,
		[Enum.KeyCode.Space] = function(t)
			Controls.Up = clamp(Controls.Up + (t and 1 or -1), 0, MaxSpeed() * 2)
		end,
		[Enum.KeyCode.LeftControl] = function(t)
			Controls.Down = clamp(Controls.Down + (t and -1 or 1), -(MaxSpeed() * 2), 0)
		end
	}

	if root:FindFirstChild(BodyGyroName) then
		root:FindFirstChild(BodyGyroName):Destroy()
	end
	if root:FindFirstChild(BodyVelocityName) then
		root:FindFirstChild(BodyVelocityName):Destroy()
	end

	local BodyGyro = NewInstance("BodyGyro", {P = 9e4, MaxTorque = Vector3.new(9e9,9e9,9e9), CFrame = root.CFrame, Parent = root, Name = BodyGyroName})
	local BodyVelocity = NewInstance("BodyVelocity", {Velocity = Vector3.new(0, 0, 0), MaxForce = Vector3.new(9e9, 9e9, 9e9), Parent = root, Name = BodyVelocityName})

	env[1] = function()
		env[1] = nil
		cons.remove({"fly", "unfly"})
		if BodyGyro then
			BodyGyro:Destroy()
		end
		if BodyVelocity then
			BodyVelocity:Destroy()
		end
		if GetHumanoid() then
			GetHumanoid().PlatformStand = false
		end
	end

	coroutine.wrap(function()
		cons.add("fly", RunService.Stepped, function()
			if not GetCharacter() or not GetHumanoid() then
				ExecuteCommand("unfly")
			end
			humanoid.PlatformStand = true
			for i, v in next, Keys do
				v(IsKeyDown(i))
			end
			BodyGyro.CFrame = BodyGyro.CFrame:lerp(workspace.CurrentCamera.CFrame, 0.095)
			BodyVelocity.Velocity = ((workspace.CurrentCamera.CFrame.LookVector * (Controls.Front + Controls.Back)) + (workspace.CurrentCamera.CFrame * CFrame.new(Controls.Left + Controls.Right, (Controls.Front + Controls.Back + Controls.Up + Controls.Down) * 0.2, 0).Position) - workspace.CurrentCamera.CFrame.Position)
		end)
	end)()

	cons.add("unfly", humanoid.Died, function()
		ExecuteCommand("unfly")
	end)
end)

AddCommand("unfly", "unfly", "Stop flying.", {}, {"Utility"}, 2, function()
	local env = GetEnvironment("fly")[1]
	if env then
		env()
	end
end)

AddCommand("flyspeed", "flyspeed [number]", "Change your fly speed to [number].", {}, {"Utility", 1}, 2, function(args)
	if args[1] and isNumber(args[1]) then
		Config.FlySpeed = tonumber(args[1])
		UpdateConfig()
	end
end)

AddCommand("walkspeed", "walkspeed [number]", "Change your character's walkspeed to [number].", {"speed", "ws"}, {"Utility", "spawned", 1}, 2, function(args)
	if args[1] and isNumber(args[1]) and GetCharacter() and GetHumanoid() then
		GetHumanoid().WalkSpeed = tonumber(args[1])
	end
end)

AddCommand("jumppower", "jumppower [number]", "Change your character's jump power to [number].", {"jp"}, {"Utility", "spawned", 1}, 2, function(args)
	if args[1] and isNumber(args[1]) and GetCharacter() and GetHumanoid() then
		GetHumanoid().JumpPower = tonumber(args[1])
	end
end)

AddCommand("rejoin", "rejoin", "Rejoin the game.", {"rj"}, {"Utility"}, 2, function()
	if #Players:GetPlayers() <= 1 then
		LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

AddCommand("clearerrors", "clearerrors", "Remove the annoying box and blur that happens when a game kicks you.", {}, {}, 2, function()
	Services.GuiService:ClearError()
end)

AddCommand("net", "net", "N/A", {}, {}, 2, function()
	LocalPlayer.MaximumSimulationRadius = math.huge
end)

AddCommand("esp", "esp", "View all players in the server.", {"tracers", "chams"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unesp")
	local success, esp = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/daximul/asurion/main/init.lua"))()
	end)
	if success then
		local Container = Gui.New("Visuals", function()
			esp:Kill()
		end)
		local Section = Container:AddSection("Section")
		Section:AddItem("Toggle", {Text = "ESP", Default = true, Function = function(callback) esp:Toggle(callback) end})
		Section:AddItem("Toggle", {Text = "Players", Default = true, Function = function(callback) esp.Players = callback end})
		Section:AddItem("Toggle", {Text = "Distance", Default = true, Function = function(callback) esp.Distance = callback end})
		Section:AddItem("Toggle", {Text = "Names", Default = true, Function = function(callback) esp.Names = callback end})
		Section:AddItem("Toggle", {Text = "Boxes", Function = function(callback) esp.Boxes = callback end})
		Section:AddItem("Toggle", {Text = "Tracers", Function = function(callback) esp.Tracers = callback end})
		Section:AddItem("Toggle", {Text = "Health", Function = function(callback) esp.Health = callback end})
		Section:AddItem("Toggle", {Text = "Chams", Function = function(callback) esp:Chams(callback) end})
		local pl, res = pcall(function() return game:HttpGet(format("https://raw.githubusercontent.com/daximul/asurion/main/supported/%d.lua", game.PlaceId)) end)
		local gl, res2 = pcall(function() return game:HttpGet(format("https://raw.githubusercontent.com/daximul/asurion/main/supported/%d.lua", game.GameId)) end)
		if pl and res then loadstring(res)()(Container, Section, esp) elseif gl and res2 then loadstring(res2)()(Container, Section, esp) end
		env[1] = function()
			env[1] = nil
			if Container and Container.Close then
				Container.Close()
			else
				esp:Kill()
			end
		end
	end
end)

AddCommand("unesp", "unesp", "Turns off esp.", {"untracers", "unchams"}, {"Utility"}, 2, function()
	local env = GetEnvironment("esp")[1]
	if env then
		env()
	end
end)

AddCommand("noclip", "noclip", "Makes your character able to walk through walls.", {}, {"Utility", "spawned"}, 2, function()
	ExecuteCommand("unnoclip")
	cons.add("noclip", RunService.Stepped, function()
		local character = GetCharacter()
		if character then
			for _, v in next, character:GetChildren() do
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
				end
			end
		end
	end)
	local humanoid = GetHumanoid()
	if humanoid then
		cons.add("noclip2", humanoid.Died, function()
			ExecuteCommand("unnoclip")
		end)
	end
end)

AddCommand("unnoclip", "unnoclip", "Disables noclip.", {"clip"}, {"Utility"}, 2, function()
	cons.remove({"noclip", "noclip2"})
end)

AddCommand("goto", "goto [player]", "Teleport yourself to [player].", {"to"}, {"Utility", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target and target.Character then
			local root, root2, humanoid = GetRoot(), GetRoot(target.Character), GetHumanoid()
			if root and root2 then
				if humanoid and humanoid.SeatPart then
					humanoid.Sit = false
					wait(0.1)
				end
				root.CFrame = root2.CFrame + Vector3.new(3, 1, 0)
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

AddCommand("fakeout", "fakeout", "Teleport into the void and then teleport back to your original position. Useful for getting rid of players that are attached to your character.", {}, {"Fun"}, 2, function()
	local reset = workspace.FallenPartsDestroyHeight ~= OldFallenPartsDestroyHeight
	ExecuteCommand("antivoid")
	local root = GetRoot()
	if root then
		local oldpos = root.CFrame
		root.CFrame = CFrame.new(Vector3.new(0, -69420, 0))
		wait(0.75)
		root.CFrame = oldpos
	end
	if reset then
		ExecuteCommand("unantivoid")
	end
end)

AddCommand("car", "car [speed]", "Become some form of a car. The car's speed is [speed]. [speed] is an optional argument.", {}, {"Fun"}, 2, function(args)
	local character, humanoid, animate = GetCharacter(), GetHumanoid(), GetCharacter():FindFirstChild("Animate")
	if character and humanoid and animate then
		local speed = 70
		if args[1] and isNumber(args[1]) then
			speed = tonumber(args[1])
		end
		humanoid.WalkSpeed = speed
		humanoid.JumpPower = 15
		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			animate.walk.WalkAnim.AnimationId = "rbxassetid://129342287"
			animate.run.RunAnim.AnimationId = "rbxassetid://129342287"
			animate.fall.FallAnim.AnimationId = "rbxassetid://129342287"
			animate.idle.Animation1.AnimationId = "rbxassetid://129342287"
			animate.idle.Animation2.AnimationId = "rbxassetid://129342287"
			animate.jump.JumpAnim.AnimationId = "rbxassetid://129342287"
			for _, obj in next, character:GetDescendants() do
				if obj:IsA("Part") then
					obj.CustomPhysicalProperties = PhysicalProperties.new(0.025, 0, 0)
				end
			end
			humanoid.HipHeight = -1.03
		end
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			animate.walk.WalkAnim.AnimationId = "rbxassetid://3360694441"
			animate.run.RunAnim.AnimationId = "rbxassetid://3360694441"
			animate.fall.FallAnim.AnimationId = "rbxassetid://3360694441"
			animate.idle.Animation1.AnimationId = "rbxassetid://3360694441"
			animate.idle.Animation2.AnimationId = "rbxassetid://3360694441"
			animate.jump.JumpAnim.AnimationId = "rbxassetid://3360694441"
			for _, obj in next, character:GetDescendants() do
				if obj:IsA("Part") or obj:IsA("MeshPart") then
					obj.CustomPhysicalProperties = PhysicalProperties.new(0.025, 0, 0)
				end
			end
			humanoid.HipHeight = 0.56
		end
	end
end)

AddCommand("gravitygun", "gravitygun", "Oh yeah, maximum trolling capabilities. Kind of cringe since it relies on your network ownership of a part. Tap [E] to push the part away. Tap [Q] to bring the part closer.", {"gravgun", "telekinesis", "tel"}, {"Fun"}, 2, function()
	ExecuteCommand("net")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/gravitygun.lua"))()
end)

AddCommand("tweenspeed", "tweenspeed [number]", "Change the number of how fast tween commands are to [number]. [number] is an optional argument.", {}, {"Utility"}, 2, function(args)
	local speed = 1
	if args[1] and isNumber(args[1]) then
		speed = tonumber(args[1])
	end
	Config.TweenSpeed = speed
	UpdateConfig()
end)

AddCommand("gotocamera", "gotocamera", "Teleport to your camera.", {"tocamera", "gotocam", "tocam"}, {"Utility"}, 2, function()
	local root, camera = GetRoot(), workspace.CurrentCamera
	if root and camera then
		root.CFrame = camera.CFrame
	end
end)

AddCommand("tweengotocamera", "tweengotocamera", "Teleport to your camera.", {"tweentocamera", "tweengotocam", "tweentocam"}, {"Utility"}, 2, function()
	local root, camera = GetRoot(), workspace.CurrentCamera
	if root and camera then
		TweenService:Create(root, TweenInfo.new(Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = camera.CFrame}):Play()
	end
end)

AddCommand("fieldofview", "fieldofview [number]", "Change your camera's field of view to [number]. [number] is an optional argument.", {"fov"}, {"Utility"}, 2, function(args)
	local fov = 70
	if args[1] and isNumber(args[1]) then
		fov = tonumber(args[1])
	end
	workspace.CurrentCamera.FieldOfView = fov
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
	if args[1] and isNumber(args[1]) then
		LocalPlayer.CameraMinZoomDistance = tonumber(args[1])
	end
end)

AddCommand("maximumzoom", "maximumzoom [number]", "Changes your player camera maximum zoom distance to [number].", {"maxzoom"}, {"Utility", 1}, 2, function(args)
	if args[1] and isNumber(args[1]) then
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

AddCommand("exitroblox", "exitroblox", "Close the Roblox program.", {"exit"}, {"Utility"}, 2, function()
	game:Shutdown()
end)

AddCommand("btools", "btools", "Give yourself basic building tools. Other players can not see what is done with this command since it is only visible on your client.", {}, {"Utility"}, 2, function()
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

AddCommand("ping", "ping", "Notify yourself your ping.", {}, {"Utility"}, 2, function(_, speaker)
	Notify("your ping is " .. round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

AddCommand("memory", "memory", "Notify yourself your memory usage.", {}, {"Utility"}, 2, function()
	Notify("your memory usage is " .. round(Services.Stats:GetTotalMemoryUsageMb()) .. " mb")
end)

AddCommand("infinitejump", "infinitejump", "Make your character able to infinitely jump with no cooldown.", {}, {"Utility"}, 2, function()
	ExecuteCommand("uninfinitejump")
	cons.add("infinite jump", UserInputService.JumpRequest, function()
		local humanoid = GetHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end)

AddCommand("uninfinitejump", "uninfinitejump", "Disables infinitejump.", {}, {"Utility"}, 2, function()
	cons.remove("infinite jump")
end)

AddCommand("antiafk", "antiafk", "Prevent yourself from being kicked after being idle for 20 minutes.", {"antiidle"}, {"Utility"}, 2, function()
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

--[[
AddCommand("fling", "fling [player]", "Fling [player].", {}, {"Fun", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			local character, humanoid, root = GetCharacter(target), GetHumanoid(GetCharacter(target)), GetRoot(GetCharacter(target))
			local mycharacter, myhumanoid, myroot = GetCharacter(), GetHumanoid(), GetRoot()
			if mycharacter and myhumanoid and myroot then
				local head, accessory = character:FindFirstChild("Head"), character:FindFirstChildWhichIsA("Accessory")
				local handle = accessory:FindFirstChild("Handle")
				local oldpos = false
				if myroot.Velocity.Magnitude < 50 then
					oldpos = myroot.CFrame
				end
				if humanoid and humanoid.Sit then
					return
				end
				if not character:FindFirstChildWhichIsA("BasePart") then
					return
				end
				local foreach, new, angles, rad, v3 = table.foreach, CFrame.new, CFrame.Angles, math.rad, Vector3.new
				local fpos = function(part, position, angle)
					myroot.CFrame = new(part.Position) * position * angle
					mycharacter:SetPrimaryPartCFrame(new(part.Position) * position * angle)
					myroot.Velocity = v3(9e7, 9e7 * 10, 9e7)
					myroot.RotVelocity = v3(9e8, 9e8, 9e8)
				end
				local sfpart = function(part)
					local TimeToWait, Time, Angle = 2, os.clock(), 0
					repeat
						if myroot and humanoid then
							if part.Velocity.Magnitude < 50 then
								Angle = Angle + 100
								fpos(part, new(0, 1.5, 0) + humanoid.MoveDirection * part.Velocity.Magnitude / 1.25, angles(rad(Angle), 0, 0))
								wait()
								fpos(part, new(0, -1.5, 0) + humanoid.MoveDirection * part.Velocity.Magnitude / 1.25, angles(rad(Angle), 0, 0))
								wait()
								fpos(part, new(2.25, 1.5, -2.25) + humanoid.MoveDirection * part.Velocity.Magnitude / 1.25, angles(rad(Angle), 0, 0))
								wait()
								fpos(part, new(-2.25, -1.5, 2.25) + humanoid.MoveDirection * part.Velocity.Magnitude / 1.25, angles(rad(Angle), 0, 0))
								wait()
								fpos(part, new(0, 1.5, 0) + humanoid.MoveDirection, angles(rad(Angle), 0, 0))
								wait()
								fpos(part, new(0, -1.5, 0) + humanoid.MoveDirection, angles(rad(Angle), 0, 0))
								wait()
							else
								fpos(part, new(0, 1.5, humanoid.WalkSpeed), angles(rad(90), 0, 0))
								wait()
								fpos(part, new(0, -1.5, -humanoid.WalkSpeed), angles(0, 0, 0))
								wait()
								fpos(part, new(0, 1.5, humanoid.WalkSpeed), angles(rad(90), 0, 0))
								wait()
								fpos(part, new(0, 1.5, root.Velocity.Magnitude / 1.25), angles(rad(90), 0, 0))
								wait()
								fpos(part, new(0, -1.5, -root.Velocity.Magnitude / 1.25), angles(0, 0, 0))
								wait()
								fpos(part, new(0, 1.5, root.Velocity.Magnitude / 1.25), angles(rad(90), 0, 0))
								wait()
								fpos(part, new(0, -1.5, 0), angles(rad(90), 0, 0))
								wait()
								fpos(part, new(0, -1.5, 0), angles(0, 0, 0))
								wait()
								fpos(part, new(0, -1.5, 0), angles(rad(-90), 0, 0))
								wait()
								fpos(part, new(0, -1.5, 0), angles(0, 0, 0))
								wait()
							end
						else
							break
						end
					until part.Velocity.Magnitude > 500 or GetCharacter(target) == nil or part.Parent ~= character or target.Parent ~= Players or humanoid.Sit or myhumanoid.Health <= 0 or os.clock() > Time + TimeToWait
				end
				ExecuteCommand("antivoid")
				local bv = NewInstance("BodyVelocity", {Parent = myroot, Name = RandomString(), Velocity = v3(9e8, 9e8, 9e8), MaxForce = v3(1 / 0, 1 / 0, 1 / 0)})
				myhumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
				if root and head then
					if (root.CFrame.p - head.CFrame.p).Magnitude > 5 then
						sfpart(head)
					else
						sfpart(root)
					end
				elseif root and not head then
					sfpart(root)
				elseif not root and head then
					sfpart(head)
				elseif not root and not head and accessory and handle then
					sfpart(handle)
				else
					return
				end
				bv:Destroy()
				myhumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				repeat
					myroot.CFrame = oldpos * new(0, 0.5, 0)
					mycharacter:SetPrimaryPartCFrame(oldpos * new(0, 0.5, 0))
					myhumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					foreach(mycharacter:GetChildren(), function(_, v)
						if v:IsA("BasePart") then
							v.Velocity, v.RotVelocity = v3(), v3()
						end
					end)
					wait()
				until (myroot.Position - oldpos.p).Magnitude < 25
			else
				return
			end
		end
	end
end)
]]

AddCommand("view", "view [player]", "View [player].", {"spectate"}, {"Utility", "spawned", 1}, 2, function(args, speaker, env)
	ExecuteCommand("unview")
	local target = Players[getPlayer(args[1], speaker)[1]]
	local character = GetCharacter(target)
	if target and character then
		workspace.CurrentCamera.CameraSubject = character
		cons.add("spectate1", target.CharacterAdded, function()
			wait(0.2)
			workspace.CurrentCamera.CameraSubject = GetCharacter(target)
		end)
		cons.add("spectate2", LocalPlayer.CharacterAdded, function()
			wait(0.2)
			workspace.CurrentCamera.CameraSubject = GetCharacter(target)
		end)
		env[1] = function()
			env[1] = nil
			cons.remove({"spectate1", "spectate2"})
			if GetCharacter() then
				workspace.CurrentCamera.CameraSubject = GetCharacter()
			end
		end
		Notify(format("now viewing %s", GetLongUsername(target)))
	end
end)

AddCommand("unview", "unview", "Stop viewing.", {"unspectate"}, {"Utility"}, 2, function()
	local env = GetEnvironment("view")[1]
	if env then
		env()
	end
end)

AddCommand("refresh", "refresh", "Refreshes your character. Once you respawn you will be teleported back to your previous spot.", {"re"}, {"Utility"}, 2, function()
	local character, root = GetCharacter(), GetRoot()
	if character and root then
		local oldpos = root.CFrame
		cons.add("refresh", LocalPlayer.CharacterAdded, function()
			wait(0.2)
			root = GetRoot()
			if root then
				root.CFrame = oldpos
			end
			cons.remove("refresh")
		end)
		character:ClearAllChildren()
	end
end)

AddCommand("copyusername", "copyusername [player]", "Copy the full username of [player].", {"copyname"}, {"Utility", 1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target then
		toexecutorclipboard(tostring(target.Name))
	end
end)

AddCommand("copyuserid", "copyuserid [player]", "Copy the user id of [player].", {}, {"Utility", 1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target then
		toexecutorclipboard(tostring(target.UserId))
	end
end)

AddCommand("reach", "reach [number]", "Change the distance your tool can reach to [number].", {}, {"Utility", 1}, 2, function(args, speaker, env)
	local distance, character, backpack = args[1], GetCharacter(), GetBackpack()
	if isNumber(distance) and character and backpack then
		local tool = GetTool(LocalPlayer, true)
		local handle = tool.Handle
		if tool and handle then
			local box = NewInstance("SelectionBox", {Name = RandomString(), Parent = handle, Adornee = handle})
			insert(env, {Tool = tool, Handle = handle, Size = handle.Size, Box = box})
			handle.Size = Vector3.new(handle.Size.X, handle.Size.Y, distance)
			handle.Massless = true
		end
	end
end)

AddCommand("boxreach", "boxreach [number]", "Change the distance your tool can reach to [number] all around you.", {}, {"Utility", 1}, 2, function(args, speaker, env)
	local distance, character, backpack = args[1], GetCharacter(), GetBackpack()
	if isNumber(distance) and character and backpack then
		local tool = GetTool(LocalPlayer, true)
		local handle = tool.Handle
		if tool and handle then
			local box = NewInstance("SelectionBox", {Name = RandomString(), Parent = handle, Adornee = handle})
			insert(env, {Tool = tool, Handle = handle, Size = handle.Size, Box = box})
			handle.Size = Vector3.new(distance, distance, distance)
			handle.Massless = true
		end
	end
end)

AddCommand("unreach", "unreach", "Disables reach.", {"unboxreach"}, {"Utility"}, 2, function()
	local reach, boxreach = FindCommand("reach"), FindCommand("boxreach")
	if reach and boxreach then
		local modified = merge_table(reach.Env, boxreach.Env)
		for _, data in next, modified do
			if data.Tool and data.Handle then
				data.Handle.Size = data.Size
			end
			if data.Box then
				data.Box:Destroy()
			end
		end
		reach.Env = {}
		boxreach.Env = {}
	end
end)

AddCommand("teleporttool", "teleporttool", "Give yourself a tool that teleports you where you click.", {"tweenteleporttool", "tptool", "tweentptool", "clicktp"}, {"Utility"}, 2, function()
	local backpack = GetBackpack()
	if backpack then
		local tool = NewInstance("Tool", {Name = "Click TP", RequiresHandle = false, Parent = backpack})
		cons.add(tool.Activated, function()
			local root, pos = GetRoot(), Mouse.Hit
			if root and pos then
				root.CFrame = pos + Vector3.new(3, 1, 0)
			end
		end)
		local tool2 = NewInstance("Tool", {Name = "Click TweenTP", RequiresHandle = false, Parent = backpack})
		cons.add(tool2.Activated, function()
			local root, pos = GetRoot(), Mouse.Hit
			if root and pos then
				TweenObj(root, "Sine", "Out", 0.5, {CFrame = pos + Vector3.new(3, 1, 0)})
			end
		end)
	end
end)

AddCommand("attach", "attach [player]", "Attach yourself to [player].", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		Attach(Players[available])
	end
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
				repeat wait()
					root.CFrame = CFrame.new(999999, OldFallenPartsDestroyHeight + 5, 999999)
				until not root or not root2
				LocalPlayer.CharacterAdded:Wait()
				wait(0.2)
				root = GetRoot()
				if root then
					root.CFrame = oldpos
				end
			end
		end
	end
end)

AddCommand("spawnpoint", "spawnpoint", "Place a spawn point where you are currently standing.", {}, {"Utility"}, 2, function(_, speaker)
	ExecuteCommand("unspawnpoint")
	local root = GetRoot()
	if root then
		local saved, pos = root.CFrame, root.Position
		Notify(format("set a spawn point at (%s, %s, %s)", tostring(round(pos.X)), tostring(round(pos.Y)), tostring(round(pos.Z))))
		cons.add("spawn point", speaker.CharacterAdded, function()
			wait(0.2)
			root = GetRoot()
			if root then
				root.CFrame = saved
			end
		end)
	end
end)

AddCommand("unspawnpoint", "unspawnpoint", "Remove your placed spawn point.", {}, {"Utility"}, 2, function(_, speaker)
	cons.remove("spawn point")
end)

local lastdeath = nil
cons.add(LocalPlayer.CharacterAdded, function()
	repeat wait() until GetHumanoid() ~= nil
	cons.add(GetHumanoid().Died, function()
		local root = GetRoot()
		if root then
			lastdeath = root.CFrame
		end
	end)
end)
spawn(function()
	repeat wait(1) until GetHumanoid() ~= nil
	cons.add(GetHumanoid().Died, function()
		local root = GetRoot()
		if root then
			lastdeath = root.CFrame
		end
	end)
end)
AddCommand("diedtp", "diedtp", "Teleport to your last position before you died.", {"flashback"}, {"Utility"}, 2, function(_, speaker)
	local root = GetRoot()
	if lastdeath ~= nil and root then
		root.CFrame = lastdeath
	end
end)

AddCommand("control", "control [player]", "Control [player] for a few seconds.", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target and target.Character then
			ExecuteCommand("sit")
			Attach(target)
			cons.add("control", UserInputService.InputBegan, function(input, processed)
				if not processed and input.KeyCode == Enum.KeyCode.Space then
					ExecuteCommand("jump")
				end
			end)
			speaker.CharacterAdded:Wait()
			cons.remove("control")
		end
	end
end)

AddCommand("skydive", "skydive [player]", "Teleport yourself into and the sky and bring [player].", {}, {"Utility", "tool", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target, root = Players[available], GetRoot()
		if target and target.Character and root then
			local oldpos = root.CFrame
			root.CFrame = CFrame.new(Vector3.new(0, 694200, 0))
			wait(0.2)
			Attach(target)
			speaker.CharacterAdded:Wait()
			wait(0.2)
			root = GetRoot()
			if root then
				root.CFrame = oldpos
			end
		end
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
						if not humanoid or humanoid.Health <= 0 then
							break
						end
						for _, obj in next, GetCharacter(target):GetChildren() do
							obj = ((obj:IsA("BasePart") and firerbxtouch(handle, obj, 1, (renderstepped:Wait() and nil) or firerbxtouch(handle, obj, 0)) and nil) or obj) or obj
						end
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
		local saved = {}
		for _, v in next, character:GetChildren() do
			if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") then
				insert(saved, {Object = v, Transparency = v.Transparency})
				v.Transparency = v.Transparency <= 0.3 and 0.4 or v.Transparency
			elseif v:IsA("Accessory") then
				local handle = v:FindFirstChildWhichIsA("MeshPart") or v:FindFirstChildWhichIsA("Part")
				if handle then
					insert(saved, {Object = handle, Transparency = handle.Transparency})
					handle.Transparency = handle.Transparency <= 0.3 and 0.4 or handle.Transparency
				end
			end
		end
		env[1] = function()
			env[1] = nil
			if weld then
				weld.Part0 = nil
				weld.Part1 = nil
				weld:Destroy()
			end
			if seat then
				seat:Destroy()
			end
			for _, v in next, saved do
				if v.Object and v.Transparency then
					v.Object.Transparency = v.Transparency
				end
			end
		end
	end
end)

AddCommand("uninvisible", "uninvisible", "Stop being invisible.", {"uninvis", "visible", "vis"}, {"Utility"}, 2, function()
	local env = GetEnvironment("invisible")[1] or GetEnvironment("toolinvisible")[1]
	if env then
		env()
	end
end)

AddCommand("toolinvisible", "toolinvisible", "Become invisible to other players and be able to use tools.", {"toolinvis", "tinvis"}, {"Utility", "spawned"}, 2, function(_, _, env)
    ExecuteCommand("untoolinvisible")
    local character, root = GetCharacter(), GetRoot()

    if character and root then
        local oldpos = root.CFrame
        root.CFrame = CFrame.new(9e9, 9e9, 9e9)
	wait()

        con = RunService.Heartbeat:Connect(function()
            local old = character.Head.Size
            character.Head.Size = Vector3.new(0, 0, 0)
            RunService.RenderStepped:Wait()
            character.Head.Size = old
        end)
        root.CFrame = oldpos
    end

    env[1] = function()
        env[1] = nil
	con = con:Disconnect()
    end
end)

AddCommand("teleportwalk", "teleportwalk [speed]", "Teleport to your move direction. [speed] is optional.", {"tpwalk"}, {"Utility"}, 2, function(args, _, env)
	ExecuteCommand("unteleportwalk")
	local character, humanoid = GetCharacter(), GetHumanoid()
	if character and humanoid then
		env[1] = function()
			env[1] = nil
		end
		while env[1] and character and humanoid do
			local delta = heartbeat:Wait()
			if humanoid.MoveDirection.Magnitude > 0 then
				if args[1] and isNumber(args[1]) then
					character:TranslateBy(humanoid.MoveDirection * tonumber(args[1]) * delta * 10)
				else
					character:TranslateBy(humanoid.MoveDirection * delta * 10)
				end
			end
		end
	end
end)

AddCommand("unteleportwalk", "unteleportwalk", "Stop teleport walk.", {"untpwalk"}, {"Utility"}, 2, function()
	local env = GetEnvironment("teleportwalk")[1]
	if env then
		env()
	end
end)

AddCommand("f3x", "f3x", "Most known clientsided funny building tool yessir.", {}, {"Fun"}, 2, function()
	loadstring(Services.InsertService:LoadLocalAsset("rbxassetid://6695644299"):Clone().Source)()
end)

AddCommand("swim", "swim", "Why are you swimming in the air? Get down please we need to talk about among us.", {}, {"Utility"}, 2, function(_, speaker, env)
	ExecuteCommand("unswim")
	local character, humanoid, root = GetCharacter(), GetHumanoid(), GetRoot()
	if character and humanoid and root then
		workspace.Gravity = 0
		local enums, v3, v0 = Enum.HumanoidStateType:GetEnumItems(), Vector3.new, Vector3.zero
		remove(enums, tfind(enums, Enum.HumanoidStateType.None))
		for _, state in next, enums do
			humanoid:SetStateEnabled(state, false)
		end
		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		cons.add("swim", heartbeat, function()
			local rootvelo, moving = root.Velocity, humanoid.MoveDirection ~= v3()
			root.Velocity = ((moving or IsKeyDown(Enum.KeyCode.Space)) and v3(moving and rootvelo.X or 0, IsKeyDown(Enum.KeyCode.Space) and 50 or rootvelo.Y, moving and rootvelo.Z or 0) or v0)
		end)
		env[1] = function()
			env[1] = nil
			cons.remove("swim")
			workspace.Gravity = OldGravity
			humanoid = GetHumanoid()
			if humanoid then
				for _, state in next, enums do
					humanoid:SetStateEnabled(state, true)
				end
			end
		end
		speaker.CharacterAdded:Wait()
		heartbeat:Wait()
		ExecuteCommand("unswim")
	end
end)

AddCommand("unswim", "unswim", "Stop swimming.", {}, {"Utility"}, 2, function()
	local env = GetEnvironment("swim")[1]
	if env then
		env()
	end
end)

AddCommand("notifyposition", "notifyposition", "Notify yourself your character's current position (x, y, z).", {"notifypos"}, {"Utility"}, 2, function()
	local root = GetRoot()
	if root then
		local pos = root.Position
		Notify(format("%s, %s, %s", tostring(round(pos.X)), tostring(round(pos.Y)), tostring(round(pos.Z))))
	end
end)

AddCommand("copyposition", "copyposition", "Copy your character's current position (x, y, z).", {"copypos"}, {"Utility"}, 2, function()
	local root = GetRoot()
	if root then
		local pos = root.Position
		toexecutorclipboard(format("%s, %s, %s", tostring(round(pos.X)), tostring(round(pos.Y)), tostring(round(pos.Z))))
	end
end)

AddCommand("serverhop", "serverhop [min / max]", "Join a different server. Optional arguments of min or max, max is the default.", {"shop"}, {"Utility", {"min", "max"}}, 2, function(args)
	if httprequest then
		local order = lower(tostring(args[1]))
		order = (order == "min" and "Asc") or (order == "max" and "Desc") or "Desc"
		local servers = {}
		local list = HttpService:JSONDecode(httprequest({Url = format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100", game.PlaceId, order)}).Body)
		if list and list.data then
			for _, server in next, list.data do
				if type(server) == "table" and tonumber(server.playing) and tonumber(server.maxPlayers) and server.maxPlayers > server.playing and server.id ~= game.JobId then
					insert(servers, {current = server.playing, limit = server.maxPlayers, id = server.id})
				end
			end
		end
		if #servers ~= 0 then
			local server = servers[math.random(1, #servers)]
			Notify(format("joining server (%d/%d players)", server.current, server.limit))
			TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
		else
			Notify("no servers available")
		end
	else
		Notify("your exploit does not support this common. missing http request")
	end
end)

AddCommand("dex", "dex", "Open an explorer similar to the one in Roblox Studio.", {"explorer"}, {"Utility"}, 2, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/dex/main.lua"))()
end)

AddCommand("settime", "settime [number / day / dawn / night]", "Change the time of day to [number]. Optional arguments of day, dawn, or night.", {"time"}, {"Utility", {"day", "dawn", "night"}, 1}, 2, function(args)
	if isNumber(args[1]) then
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
		env[1] = nil
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
	local env = GetEnvironment("fullbright")[1]
	if env then
		env()
	end
end)

AddCommand("enable", "enable [inventory / backpack / playerlist / leaderboard / chat / reset / emotes / all]", "Enable the visibility of CoreGui items. Arguments needed are listed in usage.", {}, {"Utility", {"inventory", "backpack", "playerlist", "leaderboard", "chat", "reset", "emotes", "all"}, 1}, 2, function(args)
	local opt = lower(tostring(args[1]))
	local coretypes = {inventory = Enum.CoreGuiType.Backpack, backpack = Enum.CoreGuiType.Backpack, playerlist = Enum.CoreGuiType.PlayerList, leaderboard = Enum.CoreGuiType.PlayerList, emotes = Enum.CoreGuiType.EmotesMenu, chat = Enum.CoreGuiType.Chat, all = Enum.CoreGuiType.All}
	if opt == "reset" then
		Services.StarterGui:SetCore("ResetButtonCallback", true)
	elseif coretypes[opt] then
		Services.StarterGui:SetCoreGuiEnabled(coretypes[opt], true)
	end
end)

AddCommand("disable", "disable [inventory / backpack / playerlist / leaderboard / chat / reset / emotes / all]", "Disable the visibility of CoreGui items. Arguments needed are listed in usage.", {}, {"Utility", {"inventory", "backpack", "playerlist", "leaderboard", "chat", "reset", "emotes", "all"}, 1}, 2, function(args)
	local opt = lower(tostring(args[1]))
	local coretypes = {inventory = Enum.CoreGuiType.Backpack, backpack = Enum.CoreGuiType.Backpack, playerlist = Enum.CoreGuiType.PlayerList, leaderboard = Enum.CoreGuiType.PlayerList, emotes = Enum.CoreGuiType.EmotesMenu, chat = Enum.CoreGuiType.Chat, all = Enum.CoreGuiType.All}
	if opt == "reset" then
		Services.StarterGui:SetCore("ResetButtonCallback", false)
	elseif coretypes[opt] then
		Services.StarterGui:SetCoreGuiEnabled(coretypes[opt], false)
	end
end)

AddCommand("invisiblecamera", "invisiblecamera", "Makes it so you can put your camera through walls.", {"inviscamera", "inviscam"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("uninvisiblecamera")
	local OldCameraMaxZoomDistance, OldDevCameraOcclusionMode = LocalPlayer.CameraMaxZoomDistance, LocalPlayer.DevCameraOcclusionMode
	LocalPlayer.CameraMaxZoomDistance = 600
	LocalPlayer.DevCameraOcclusionMode = "Invisicam"
	env[1] = function()
		env[1] = nil
		LocalPlayer.CameraMaxZoomDistance = OldCameraMaxZoomDistance
		LocalPlayer.DevCameraOcclusionMode = OldDevCameraOcclusionMode
	end
end)

AddCommand("uninvisiblecamera", "uninvisiblecamera", "Disables invisiblecamera.", {"uninviscamera", "uninviscam"}, {"Utility"}, 2, function()
	local env = GetEnvironment("invisiblecamera")[1]
	if env then
		env()
	end
end)

AddCommand("volume", "volume [number]", "Set your volume to [number].", {}, {1}, 2, function(args)
	if isNumber(args[1]) then
		UserSettings():GetService("UserGameSettings").MasterVolume = tonumber(args[1])
	end
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
		coroutine.wrap(function()
			cons.add("float", heartbeat, function()
				if not obj or not GetCharacter() or not GetRoot() then
					ExecuteCommand("unfloat")
				end
				if IsKeyDown(Enum.KeyCode.E) then
					GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, 0.025, 0)
				elseif IsKeyDown(Enum.KeyCode.Q) then
					GetRoot().CFrame = GetRoot().CFrame * CFrame.new(0, -0.025, 0)
				end
				obj.CFrame = GetRoot().CFrame * CFrame.new(0, -3.1, 0)
			end)
		end)()
		if humanoid then
			cons.add("float2", humanoid.Died, function()
				ExecuteCommand("unfloat")
			end)
		end
		env[1] = function()
			env[1] = nil
			cons.remove({"float", "float2"})
			if obj then
				obj:Destroy()
			end
		end
	end
end)

AddCommand("unfloat", "unfloat", "Disables float.", {}, {"Utility"}, 2, function()
	local env = GetEnvironment("float")[1]
	if env then
		env()
	end
end)

AddCommand("teleportposition", "teleportposition [x, y, z]", "Teleports you to the provided coordinates.", {"tpposition", "tppos"}, {"Utility", 3}, 2, function(args)
	local root = GetRoot()
	if root and isNumber(args[1]) and isNumber(args[2]) and isNumber(args[3]) then
		root.CFrame = CFrame.new(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
	end
end)

AddCommand("spin", "spin [speed]", "Spins your character with a speed of [speed]. [speed] is an optional argument.", {}, {"Utility"}, 2, function(args, _, env)
	ExecuteCommand("unspin")
	local root = GetRoot()
	if root then
		local speed = 20
		if args[1] and isNumber(args[1]) then
			speed = tonumber(args[1])
		end
		local obj = NewInstance("BodyAngularVelocity", {Name = RandomString(), Parent = root, MaxTorque = Vector3.new(0, math.huge, 0), AngularVelocity = Vector3.new(0, speed, 0)})
		env[1] = function()
			env[1] = nil
			if obj then
				obj:Destroy()
			end
		end
	end
end)

AddCommand("unspin", "unspin", "Disables spin.", {}, {"Utility"}, 2, function()
	local env = GetEnvironment("spin")[1]
	if env then
		env()
	end
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
	cons.add(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
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
		local shift = IsKeyDown(Enum.KeyCode.LeftShift)
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
		if Freecam.Active then
			Freecam.Stop()
		end
		local cameraCFrame = pos and pos or Camera.CFrame
		cameraRot, cameraPos, cameraFov = Vector2.new(), cameraCFrame.p, Camera.FieldOfView
		velSpring:Reset(Vector3.new())
		panSpring:Reset(Vector2.new())
		PlayerState.Push()
		RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
		Input.StartCapture()
		Freecam.Active = true
	end
	Freecam.Adjust = function(sp)
		NAV_KEYBOARD_SPEED = Vector3.new(sp, sp, sp)
	end
end

AddCommand("freecam", "freecam", "Allows you to move your camera freely in the game.", {"fc"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unfreecam")
	Freecam.Start()
	env[1] = function()
		env[1] = nil
		Freecam.Stop()
	end
end)

AddCommand("unfreecam", "unfreecam", "Disables freecam.", {"unfc"}, {"Utility"}, 2, function()
	local env = GetEnvironment("freecam")[1]
	if env then
		env()
	end
end)

AddCommand("freecamgoto", "freecamgoto [player]", "Starts freecam at [player].", {"fcgoto"}, {"Utility", 1}, 2, function(args, speaker)
	local target = Players[getPlayer(args[1], speaker)[1]]
	if target and GetCharacter(target) and GetRoot(GetCharacter(target)) then
		ExecuteCommand("unfreecam")
		FindCommand("freecam").Env[1] = function()
			FindCommand("freecam").Env[1] = nil
			Freecam.Stop()
		end
		Freecam.Start(GetRoot(GetCharacter(target)).CFrame * CFrame.new(0, 5, 5))
	end
end)

AddCommand("freecamspeed", "freecamspeed [speed]", "Sets the freecam speed to [speed]. [speed] is an optional argument.", {"fcspeed"}, {"Utility"}, 2, function(args)
	local speed = 1
	if args[1] and isNumber(args[1]) then
		speed = tonumber(args[1])
	end
	Freecam.Adjust(speed)
end)

AddCommand("freecamposition", "freecamposition [x, y, z]", "Starts freecam at the provided coordinates.", {"fcpos"}, {"Utility", 3}, 2, function(args)
	if isNumber(args[1]) and isNumber(args[2]) and isNumber(args[3]) then
		ExecuteCommand("unfreecam")
		FindCommand("freecam").Env[1] = function()
			FindCommand("freecam").Env[1] = nil
			Freecam.Stop()
		end
		Freecam.Start(CFrame.new(tonumber(args[1]), tonumber(args[2]), tonumber(args[3])))
	end
end)

AddCommand("replicationlag", "replicationlag [number]", "Sets IncomingReplicationLag to [number]. [number] is an optional argument.", {"backtrack"}, {}, 2, function(args)
	local num = 0
	if args[1] and isNumber(args[1]) then
		num = tonumber(args[1])
	end
	UserSettings():GetService("NetworkSettings").IncomingReplicationLag = num
end)

AddCommand("xray", "xray", "Allows you to see through walls.", {}, {"Utility"}, 2, function(_, _, env)
	local modified = {}
	for _, v in next, workspace:GetDescendants() do
		if v:IsA("Part") and v.Transparency <= 0.3 then
			insert(modified, {Part = v, Transparency = v.Transparency})
			v.Transparency = 0.3
		end
	end
	env[1] = function()
		env[1] = nil
		for _, v in next, modified do
			if v.Part and v.Transparency then
				v.Part.Transparency = v.Transparency
			end
		end
	end
end)

AddCommand("unxray", "unxray", "Disables xray.", {}, {"Utility"}, 2, function()
	local env = GetEnvironment("xray")[1]
	if env then
		env()
	end
end)

AddCommand("restorelighting", "restorelighting", "Restores Lighting's original properties.", {}, {"Utility"}, 2, function()
	for name, property in next, OldLightingProperties do
		Lighting[name] = property
	end
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

local switchteam = {}
filterthrough(Services.Teams:GetChildren(), function(_, v)
	insert(switchteam, lower(tostring(v.Name)))
end)
AddCommand("switchteam", "switchteam [name]", "Switches to the team of [name].", {"changeteam", "team"}, {"Utility", switchteam, 1}, 2, function()
	local root, team = GetRoot(), filterthrough(Services.Teams:GetChildren(), function(_, v)
		return lower(tostring(v.Name)) == lower(tostring(getstring(1)))
	end)[1]
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
	if character and backpack then
		for _, v in next, backpack:GetChildren() do
			if v:IsA("Tool") then
				v.Parent = character
			end
		end
	end
end)

AddCommand("activatetools", "activatetools", "Equips and activates all your tools.", {}, {"Utility"}, 2, function()
	local character = GetCharacter()
	if character then
		ExecuteCommand("equiptools")
		local activated = 0
		for _, v in next, character:GetChildren() do
			if v:IsA("Tool") then
				activated = activated + 1
				v:Activate()
			end
		end
		Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, activated)
	end
end)

if listfiles then
	local valid = {}
	for _, v in next, listfiles("dark-admin/plugins") do
		if FindInTable(PluginExtensions, "." .. lower(split(v, ".")[#split(v, ".")])) then
			insert(valid, tostring(split(v, "\\")[2]))
		end
	end
	for _, v in next, valid do
		if not FindInTable(Config.DisabledPlugins, v) then
			InstallPlugin(v, true)
		end
	end
else
	for _, v in pairs(Config.Plugins) do
		LoadPlugin(v, true)
	end
end

for name, permission in next, MiscConfig.Permissions do
	local command = FindCommand(name)
	if command then
		if command.PermissionIndex == permission then
			MiscConfig.Permissions[name] = nil
		else
			command.PermissionIndex = permission
		end
	end
end
UpdateMiscConfig()

Notify(format("prefix is %s\nloaded in %.3f seconds\nrun 'help' for help", Config.Prefix, tick() - LoadingTick), 10)
