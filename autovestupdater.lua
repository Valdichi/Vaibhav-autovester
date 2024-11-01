script_name("guardnear")
script_author("akacross")
script_version("0.0.1")

require "lib.moonloader"
require "lib.sampfuncs"
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Replace with your GitHub raw file URL (without the token in the URL itself)
local serverurl = "https://raw.githubusercontent.com/Valdichi/Vaibhav-autovester/main/autovestupdater.lua"

-- Replace with your GitHub personal access token
local github_token = "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"

local Activate = true  -- Enable auto-update check

function cmd()
    Activate = not Activate
    sampAddChatMessage(string.format("{F8F9F9}Auto Vest is %s", Activate))
end

function fetchUpdate()
    local response_body = {}
    local res, code, response_headers = http.request{
        url = serverurl,
        headers = {
            ["Authorization"] = "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" .. github_token  -- Use the personal access token
        },
        sink = ltn12.sink.table(response_body)
    }

    if code == 200 then
        return table.concat(response_body)  -- Successfully fetched update file
    else
        return nil, code  -- Error occurred while fetching update
    end
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    
    sampAddChatMessage("{808080}(Autovest for BHT/TC/LA (Edited by Vaibhav) - /avest)")
    sampRegisterChatCommand("avest", cmd)

    -- Check for updates if Activate is true
    if Activate then
        local updateData, err = fetchUpdate()
        if updateData then
            print("Update fetched successfully:", updateData)
            -- Optionally, process the fetched data here, such as reloading updated logic.
        else
            print("Failed to fetch update. HTTP Code:", err)
        end
    end

    -- Main functionality loop
    while true do
        wait(100)
        if isKeyControlAvailable() and Activate then
            local playerid = getClosestPlayerId(7, true)
            if sampIsPlayerConnected(playerid) then 
                sampSendChat(string.format("/guard %d 200", playerid))
                wait(11500)
            end
        end
    end	
end

function isKeyControlAvailable()
    if not isSampLoaded() then return true end
    if not isSampfuncsLoaded() then return not sampIsChatInputActive() and not sampIsDialogActive() end
    return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end

function getClosestPlayerId(maxdist, ArmorCheck)
    local GangSkins = {303,214,94,240,124,93,229,170,121,228,224,231,235,108,109,110,292,56,236,90,234,120,141,169,208,294,59,117,118}
    local maxplayerid = sampGetMaxPlayerId(false)
    for i = 0, maxplayerid do
        if sampIsPlayerConnected(i) then
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and not sampIsPlayerPaused(i) then
                local dist = get_distance_to_player(i)
                if dist < maxdist and sampGetPlayerArmor(i) < 48 then
                    if GangSkins and has_value(GangSkins, getCharModel(ped)) then
                        return i
                    end
                end
            end
        end
    end
    return -1  -- No player found within range
end

function get_distance_to_player(playerId)
    local dist = -1
    if sampIsPlayerConnected(playerId) then
        local result, ped = sampGetCharHandleBySampPlayerId(playerId)
        if result then
            local myX, myY, myZ = getCharCoordinates(playerPed)
            local playerX, playerY, playerZ = getCharCoordinates(ped)
            dist = getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
        end
    end
    return dist
end

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
