return function(get_secure_script)
    -- Securely load external libraries
    local function safeLoad(url)
        for i = 1, 3 do
            local success, result = pcall(function()
                return loadstring(game:HttpGet(url, true))()
            end)
            if success then
                return result
            end
            task.wait(1)
        end
        error("Failed to load " .. url)
    end

    -- Load whitelist data
    local success, data = pcall(function()
        return safeLoad("https://raw.githubusercontent.com/RedDaGoodScripter12355939292/verbose-goggles/main/WhitelistedData.lua")
    end)
    if not success or type(data) ~= "table" then
        error("Whitelist data failed to load!")
    end

    -- Load notification library
    local success, Notification = pcall(function()
        return safeLoad("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/notification_gui_library.lua")
    end)
    if not success then
        error("Notification library failed to load!")
    end

    -- Function to check if the player is authorized
    local function isAuthorized(player)
        local playerID = player.UserId
        if data[UID] then
            for _, userID in ipairs(data[UID]) do
                if playerID == userID then
                    return true
                end
            end
        end
        return false
    end

    -- Secure Kick function
    local function secureKick(player, reason)
        local oldKick = player.Kick
        task.spawn(function()
            if oldKick then
                oldKick(player, reason)
            end
        end)
        task.wait(9e9)
    end

    -- Block HttpSpy
    local function blockHttpSpy()
        local oldHttpGet = game.HttpGet
        local oldRequest = http_request or request or HttpPost or syn.request

        hookfunction(game.HttpGet, function(...)
            error("HttpSpy Blocked")
        end)

        hookfunction(oldRequest, function(req)
            error("HttpSpy Blocked")
        end)
    end

    -- Secure metamethod protection
    local function protectMetamethods()
        -- Block `hookmetamethod()` attempts
        if hookmetamethod then
            local oldHookMetamethod = hookmetamethod
            hookmetamethod = function(...)
                sendWebhook("🚨 **Exploit Attempt Detected**: `hookmetamethod()` used by " ..
                    game.Players.LocalPlayer.Name)
                error("hookmetamethod is blocked!", 2)
            end
        end

        -- Make sensitive metatables harder to access
        local protected_objects = {debug, getgc, getfenv, setfenv, getrenv, newcclosure}
        for _, obj in ipairs(protected_objects) do
            if typeof(obj) == "table" then
                local meta = getrawmetatable(obj)
                if meta then
                    setreadonly(meta, false)
                    meta.__metatable = "Restricted"
                    setreadonly(meta, true)
                end
            end
        end

        local oldGetRawMeta = getrawmetatable
        getrawmetatable = function(obj)
            sendWebhook("🚨 **Exploit Attempt Detected**: `getrawmetatable()` used by " ..
                game.Players.LocalPlayer.Name)
            error("getrawmetatable is blocked!", 2)
        end
    end

    -- Send webhook on suspicious activity
    local function sendWebhook(message)
        local Request = http_request or request or HttpPost or syn.request
        if Request then
            Request({
                Url = "https://webhook.newstargeted.com/api/webhooks/1331228960230608957/yFOtvN6KnZniPYTHsUXt9q8YCfPbN6H_SYR0Kpa8-sHUMXf-san8L5WRb0VgQELylB6y",
                Body = '{"content": "' .. message .. '"}',
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"}
            })
        else
            warn("No supported HTTP request function found.")
        end
    end

    -- Activate security before script execution
    blockHttpSpy()
    protectMetamethods()

    -- Get player instance
    local player = game.Players.LocalPlayer
    if not player then
        error("Player not found!")
    end

    -- Get the secure script safely
    local secure_script = get_secure_script() -- Only SpheroidV1 can access it

    -- If authorized, execute the script securely
    if isAuthorized(player) then
        Notification.new("success", "Successful Execution", "Authorized")
        loadstring(secure_script)()
    else
        Notification.new("error", "Failed Execution", "You really wanna bypass?")
        secureKick(player, "NOT WHITELISTED!")
        sendWebhook("Unauthorized attempt detected: " .. player.Name)
        error("Unauthorized access detected!")
    end

    -- Destroy `secure_script` after use
    secure_script = nil
end
