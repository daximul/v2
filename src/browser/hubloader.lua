local urls = {
    {"sirius", "Shlex", "https://raw.githubusercontent.com/shlexware/Sirius/request/source"},
    {"darkhub", "RandomAdam", "https://raw.githubusercontent.com/RandomAdamYT/DarkHub_V4/main/init"},
    {"psyhub", "Unknown", "https://pastebin.com/raw/yqTJ402H"},
    {"vxpe", "Alteral", "https://raw.githubusercontent.com/Alteral323/v/main/init.lua"},
    {"ezhub", "debug420", function()
        _G["DISABLEEXELOG"] = true
        loadstring(game:HttpGet("https://raw.githubusercontent.com/debug420/Ez-Industries-Launcher-Data/master/Launcher.lua"))()
    end},
    {"eclipse", "Ethanoj1", function()
        getgenv().mainKey = "nil"
        local a,b,c,d,e=loadstring,request or http_request or (http and http.request) or (syn and syn.request),assert,tostring,"https\58//api.eclipsehub.xyz/auth";c(a and b,"Executor not Supported")a(b({Url=e.."\?\107e\121\61"..d(mainKey),Headers={["User-Agent"]="Eclipse"}}).Body)()
    end}
}

return {
    Name = "Hub Loader",
    Commands = filter(urls, function(_, v)
        return {
            Name = v[1],
            Description = format("Loads the script by %s.", v[2]),
            Function = function()
                if type(v[3]) == "function" then
                    v[3]()
                else
                    loadstring(game:HttpGet(v[3]))()
                end
            end
        }
    end)
}
