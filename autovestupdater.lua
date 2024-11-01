script_name("guardnear")
script_author("akacross")
script_version("0.0.2")  -- Increment version to indicate update

require"lib.moonloader"
require"lib.sampfuncs"
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Variables
local serverURL = "https://raw.githubusercontent.com/Valdichi/Vaibhav-autovester/refs/heads/main/autovestupdater.lua"  -- URL to check for updates
Activate = false

-- Function to fetch updates from the server
function updateCheck()
    local response_body = {}
    local res, code, response_headers = http.request{
        url = serverURL,
        sink = ltn12.sink.table(response_body)
    }

    if code == 200 then
        local updateData = table.concat(response_body)
        sampAddChatMessage(string.format("{F8F9F9}Update from server: %s", updateData))
        -- Here you can add logic to process `updateData` (e.g., parse commands, update variables)
    else
        sampAddChatMessage("{FF0000}Failed to fetch update from server.")
    end
end

-- Toggle function for activation
function cmd()
    Activate = not Activate
    sampAddChatMessage(string.format("{F8F9F9}Auto Vest is %s", Activate and "enabled" or "disabled"))
end

-- Main function
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage("{808080}(Autovest for BHT/TC/LA (Edited by Vaibhav) - /avest)")
    sampRegisterChatCommand("avest", cmd)

    -- Initial check for updates on startup
    updateCheck()

    while true do
        wait(100)
        
        -- Check for updates every 10 minutes (600000 milliseconds)
        if os.time() % 600 == 0 then
            updateCheck()
        end

        if isKeyControlAvailable() and Activate == true then
            local playerid = getClosestPlayerId(7, true)
            if sampIsPlayerConnected(playerid) then 
                sampSendChat(string.format("/guard %d 200", playerid))
                wait(11500)
            end
        end
    end
end

-- Function for key availability check
function isKeyControlAvailable()
    if not isSampLoaded() then return true end
    if not isSampfuncsLoaded() then return not sampIsChatInputActive() and not sampIsDialogActive() end
    return not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive()
end

-- Function to get the closest player ID with specific conditions
function getClosestPlayerId(maxdist, ArmorCheck)
    local GangSkins = {303,214,94,240,124,93,229,170,121,228,224,231,235,108,109,110,292,56,236,90,234,120,141,169,208,294,117,118}
    local maxplayerid = sampGetMaxPlayerId(false)
    for i = 0, maxplayerid do
        if sampIsPlayerConnected(i) then
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and not sampIsPlayerPaused(i) then
                local dist = get_distance_to_player(i)
                if (dist < maxdist and sampGetPlayerArmor(i) < 48) then
                    if has_value(GangSkins, getCharModel(ped)) then
                        return i
                    end
                end
            end
        end
    end
    return -1
end

-- Function to calculate distance to player
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

-- Helper function to check if a value exists in a table
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
