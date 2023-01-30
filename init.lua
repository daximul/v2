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

local cloneref, getserv = (cloneref or function(...) return ... end), game.GetService
local Services = {}
setmetatable(Services, {
    __index = function(tbl, prop)
        local res, serv = pcall(game.GetService, game, prop)
        if res then
            Services[prop] = cloneref(serv)
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
lower, gsub, len, sub, find, random, insert = string.lower, string.gsub, string.len, string.sub, string.find, math.random, table.insert
remove, gmatch, match, tfind, wait, spawn = table.remove, string.gmatch, string.match, table.find, task.wait, task.spawn
split, format, upper, clamp = string.split, string.format, string.upper, math.clamp
local creatingInstance = Instance.new
NewInstance = function(class, props)
	local inst = creatingInstance(class)
	for prop, value in pairs(props) do
		inst[prop] = value
	end
	return inst
end
local Chatlogs = {}

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
    if cons.connections[name] then
        cons.connections[name]:Disconnect()
        cons.connections[name] = nil
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

FindInTable = function(tbl, val)
	if not tbl then return false end
	for _, v in pairs(tbl) do if v == val then return true end end
	return false
end

GetCharacter = function(player)
    return (player or LocalPlayer).Character
end

GetHumanoid = function(character)
	return (character or GetCharacter()):FindFirstChildOfClass("Humanoid")
end

GetBackpack = function(player)
	return (player or LocalPlayer):FindFirstChildOfClass("Backpack")
end

GetRoot = function(character)
	character = character or GetCharacter()
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

GetUsername = function(player)
	player = player or LocalPlayer
	return player.DisplayName and player.DisplayName or player.Name
end

GetLongUsername = function(player)
	player = player or LocalPlayer
	return player.DisplayName and format("%s (%s)", player.Name, player.DisplayName) or player.Name
end

FindCommand = function(cmd)
	cmd = lower(cmd)
	for _, v in pairs(Admin.Commands) do
		if lower(v.Name) == cmd or FindInTable(v.Alias, cmd) then
			return v
		end
	end
end

RemoveCommand = function(cmd)
	cmd = lower(cmd)
	for i, v in pairs(Admin.Commands) do
		if lower(v.Name) == cmd or FindInTable(v.Alias, cmd) then
			remove(Admin.Commands, i)
		end
	end
end

SendChatMessage = function(str)
	if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest") then
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
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
	for i, v in pairs(matches) do matchTable[v.Name] = true end
	for i, v in pairs(tab) do if matchTable[v.Name] then insert(resultTable, v) end end
	return resultTable
end

removeTableMatches = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then insert(resultTable, v) end end
	return resultTable
end

getPlayersByName = function(Name)
	local Name, Len, Found = string.lower(Name), #Name, {}
	for _, v in pairs(Players:GetPlayers()) do
		if sub(Name, 0, 1) == "@" then
			if sub(string.lower(v.Name), 1, Len - 1) == sub(Name, 2) then
				insert(Found, v)
			end
		else
			if sub(lower(v.Name), 1, Len) == Name or sub(lower(v.DisplayName), 1, Len) == Name then
				insert(Found, v)
			end
		end
	end
	return Found
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
				if (speaker == LocalPlayer) or ((Admin.Whitelisted[tostring(speaker.UserId)] == true) and cmd.PermissionIndex == 1) or (cmd.PermissionIndex == 0) then
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
						        if not success and Admin.Debug then warn("Command Error:", cmdName, err) end
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

GetEnvironment = function(...)
	return FindCommand(...).Env
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
end)

for _, player in next, Players:GetPlayers() do
	if player ~= LocalPlayer then
		cons.add(player.Chatted, function(message)
			spawn(function()
				wait()
				do_exec(message, player)
			end)
		end)
	end
end

cons.add(Players.PlayerAdded, function(player)
	cons.add(player.Chatted, function(message)
		spawn(function()
			wait()
			do_exec(message, player)
		end)
		Chatlogs[#Chatlogs + 1] = {Player = player, Message = message}
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

Admin.CommandRequirements.spawned = {
    func = function() return GetCharacter() ~= nil end,
    warning = "you need to be spawned for this command"
}

AddCommand = function(name, usage, description, alias, reqs, perm, func, plgin)
    local Id = #Admin.Commands + 1
    Admin.Commands[Id] = {
        Name = name,
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
        Plugin = plgin or false
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

-- File system
local Config = {
	Prefix = ";",
	Plugins = {},
	LoweredText = false,
	FlySpeed = 1
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
	local save = "dark-admin/config.json"
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
	local save2 = "dark-admin/misc.json"
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

LoadPlugin = function(path, force)
	local Loaded, Plugin = pcall(readfile, format("dark-admin/plugins/%s", path))
	if not Loaded then
		Notify(format("plugin error for %s\nplease open console (F9) for the error", path))
		for i, v in next, Config.Plugins do
			if v == path then
				remove(Config.Plugins, i)
			end
		end
		UpdateConfig()
		print("Plugin Error, Stack Traceback:", debug.traceback(Plugin))
		return
	else
		Plugin = loadstring(Plugin)()
		spawn(function()
			if Plugin.Commands and type(Plugin.Commands) == "table" then
				for _, v in next, Plugin.Commands do
					if v.Name then
						local Requirements = v.Requirements or {}
						local Category = filterthrough(Requirements, function(_, v)
							return type(v) == "string" and (v == CapitalizeFirstCharacter(v))
						end)[1]
						local ArgsNeeded = tonumber(filterthrough(Requirements, function(_, v)
							return type(v) == "number"
						end)[1])
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
						AddCommand(v.Name, v.Usage or v.Name, v.Description or "No description provided.", v.Aliases or {}, Requirements, v.PermissionIndex or 2, v.Function or v.Func or function() end, path)
					end
				end
			end
		end)
		if not force then
			if Plugin.Description then
				Notify((Plugin.Author and format("Author: %s\nName: %s\nDescription: %s", Plugin.Author, Plugin.Name, Plugin.Description)) or format("Name: %s\nDescription: %s", Plugin.Name, Plugin.Description), 10)
			else
				Notify((Plugin.Author and format("Author: %s\nName: %s", Plugin.Author, Plugin.Name)) or format("Name: %s", Plugin.Name))
			end
			UpdateConfig()
		end
	end
end

InstallPlugin = function(name)
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
			insert(Config.Plugins, file)
			LoadPlugin(file)
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
				remove(Admin.Commands, i)
			end
		end
		for i, v in next, Config.Plugins do
			if v == file then
				remove(Config.Plugins, i)
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
	argument = lower(argument)
	return StringFind(Admin.PredictionCases, argument) or (function()
		for _, v in ipairs(Players:GetPlayers()) do
			local Name = lower(v.Name)
			if MatchSearch(argument, Name) then
				return Name
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
		if MatchSearch(InputText, v.Name) then
			Prediction.Text = v.Name
			break
		end
		for _, v2 in next, v.Alias do
			if MatchSearch(InputText, v2) then
				FoundAlias = true
				Prediction.Text = v2
				break
			end
			if FoundAlias then break end
		end
	end
	for i, v in next, Args do
		if i > 1 and v ~= "" then
			local Predict = ""
			if #CmdArgs >= 1 then
				Predict = PlayerArgs(v) or Predict
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
                    	RunService.RenderStepped:Wait()
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
			Position = UDim2.new(0.5, -100, 1, 5)
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
			Position = UDim2.new(0.5, -100, 1, -60)
		})
	end
end)

-- Commands
AddCommand("debug", "debug", "Enable the admin's debug mode.", {}, {"Core"}, 2, function(args, speaker)
	Admin.Debug = not Admin.Debug
end)

AddCommand("killscript", "killscript", "Completely uninjects the script.", {}, {"Core"}, 2, function(args, speaker)
	cons.wipe()
	Gui.BaseObject:Destroy()
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

AddCommand("addplugin", "addplugin [name]", "Add a plugin. A plugin is a file in the admin's plugins folder (dark-admin -> plugins) located in your executor's workspace folder. The provided argument is the file name with or without the file extension.", {}, {"Core", 1}, 2, function(args, speaker)
	InstallPlugin(getstring(1))
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
		new[category][command.Name] = Config.Prefix .. lower(command.Name)
	end
	Gui.DisplayTable("Commands", new)
end)

AddCommand("commandinfo", "commandinfo [command]", "View more information about [command].", {"cmdinfo", "cinfo"}, {"Core", 1}, 2, function(args)
	local command = FindCommand(args[1])
	if command then
		Gui.DisplayTable("Command Info", {
			format("Name: %s", command.Name),
			format("Category: %s", command.Category),
			format("Permission Index: %d", command.PermissionIndex),
			format("Usage: %s", command.Usage),
			format("This command requires %d argument(s)", command.ArgsNeeded),
			#command.Alias > 0 and {"Aliases", unpack(command.Alias)} or "This command has no aliases",
			{"Description", command.Description},
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

AddCommand("prefix", "prefix [symbol]", "Changes the admin prefix to [symbol].", {}, {"Core", 1}, 2, function(args)
	if #args[1] == 1 then
		Config.Prefix = args[1]
		UpdateConfig()
		Notify(format("prefix has been changed to %s", Config.Prefix))
	elseif args[1] == "\\" then
		Config.Prefix = args[1]
		UpdateConfig()
		Notify(format("prefix has been changed to %s", Config.Prefix))
	else
		Notify("prefix cannot be longer than 2 characters")
	end
end)

AddCommand("viewtools", "viewtools [player]", "View the tools of [player].", {}, {"Fun", 1}, 2, function(args, speaker)
	for _, available in next, getPlayer(args[1], speaker) do
		local target = Players[available]
		if target then
			local tools = {}
			for _, v in next, GetBackpack(target):GetChildren() do
				if v:IsA("Tool") or v:IsA("HopperBin") then
					insert(tools, v.Name)
				end
			end
			Gui.DisplayTable(format("Tools (%s)", GetUsername(target)), tools)
		end
	end
end)

AddCommand("fly", "fly", "Make your character able to fly.", {}, {"Fun", "spawned"}, 2, function(_, _, env)
	ExecuteCommand("unfly")
	local character, humanoid, root = GetCharacter(), GetHumanoid(), GetRoot()
	if not character or not humanoid or not root then
		return
	end

	local BodyGyroName, BodyVelocityName, MaxSpeed = RandomString(), RandomString(), function()
		return Config.FlySpeed * 50
	end
	local IsKeyDown = function(...)
		return UserInputService:IsKeyDown(...)
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
		cons.remove("fly")
		if BodyGyro then
			BodyGyro:Destroy()
		end
		if BodyVelocity then
			BodyVelocity:Destroy()
		end
		if GetHumanoid() then
			GetHumanoid().PlatformStand = false
		end
		env[1] = nil
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

	cons.add(humanoid.Died, function()
		ExecuteCommand("unfly")
	end)
end)

AddCommand("unfly", "unfly", "Stop flying.", {}, {"Fun"}, 2, function()
	local env = GetEnvironment("fly")[1]
	if env then
		env()
	end
end)

AddCommand("flyspeed", "flyspeed [number]", "Change your fly speed to [number].", {}, {1}, 2, function(args)
	if args[1] and isNumber(args[1]) then
		Config.FlySpeed = args[1]
		UpdateConfig()
	end
end)

AddCommand("walkspeed", "walkspeed [number]", "Change your character's walkspeed to [number].", {"speed", "ws"}, {"Core", "spawned", 1}, 2, function(args)
	if args[1] and isNumber(args[1]) and GetCharacter() and GetHumanoid() then
		GetHumanoid().WalkSpeed = args[1]
	end
end)

AddCommand("jumppower", "jumppower [number]", "Change your character's jump power to [number].", {"jp"}, {"Core", "spawned", 1}, 2, function(args)
	if args[1] and isNumber(args[1]) and GetCharacter() and GetHumanoid() then
		GetHumanoid().JumpPower = args[1]
	end
end)

AddCommand("rejoin", "rejoin", "Rejoin the game.", {"rj"}, {"Core"}, 2, function()
	if #Players:GetPlayers() <= 1 then
		LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

AddCommand("clearerrors", "clearerrors", "Remove the annoying box and blur that happens when a game kicks you.", {"clearerror"}, {}, 2, function()
	Services.GuiService:ClearError()
end)

AddCommand("esp", "esp", "View all players in the server.", {"tracers", "chams"}, {"Utility"}, 2, function(_, _, env)
	ExecuteCommand("unesp")
	local success, esp = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/daximul/v2/main/src/esp.lua"))()
	end)
	if success then
		local Container = Gui.New("Visuals", function()
			esp:Kill()
		end)
		local Section = Container:AddSection("Section")
		Section:AddItem("Toggle", {Text = "ESP", Default = true, Function = function(callback) esp:Toggle(callback) end})
		Section:AddItem("Toggle", {Text = "Names", Default = true, Function = function(callback) esp.Names = callback end})
		Section:AddItem("Toggle", {Text = "Boxes", Function = function(callback) esp.Boxes = callback end})
		Section:AddItem("Toggle", {Text = "Tracers", Function = function(callback) esp.Tracers = callback end})
		Section:AddItem("Toggle", {Text = "Health", Function = function(callback) esp.Health = callback end})
		Section:AddItem("Toggle", {Text = "Chams", Function = function(callback) esp:Chams(callback) end})
		env[1] = function()
			if Container and Container.Close then
				Container.Close()
			else
				esp:Kill()
			end
			env[1] = nil
		end
	end
end)

AddCommand("unesp", "unesp", "Turns off esp.", {"untracers", "unchams"}, {"Utility"}, 2, function()
	local env = GetEnvironment("esp")[1]
	if env then
		env()
	end
end)

AddCommand("noclip", "noclip", "Makes your character able to walk through walls.", {}, {"Fun", "spawned"}, 2, function()
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
		cons.add(humanoid.Died, function()
			ExecuteCommand("unnoclip")
		end)
	end
end)

AddCommand("unnoclip", "unnoclip", "Disables noclip.", {"clip"}, {"Fun"}, 2, function()
	cons.remove("noclip")
end)

Notify(format("prefix is %s\nloaded in %.3f seconds", Config.Prefix, tick() - LoadingTick), 10)

if Config.Plugins and type(Config.Plugins) == "table" then
	for _, v in pairs(Config.Plugins) do
		LoadPlugin(v, true)
	end
end

for i, v in next, MiscConfig.Permissions do
	local command = FindCommand(i)
	if command then
		command.PermissionIndex = v
	end
end
