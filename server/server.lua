Config.Webhook = 'https://discord.com/api/webhooks/1119678233198207086/0dGlQPqWMiEWJ6mn7EvMosYDoq5gjZrZZjjVfEDU6ywyH5ShbprV27vgobMzF8WPXCD0'

local QBCore = exports['qb-core']:GetCoreObject()
local onDutyTimes = {}

RegisterNetEvent('ngd-policeduty:Server:Log', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
    local metadata = xPlayer.PlayerData.metadata
    if metadata and metadata.callsign then
        playerName = playerName .. " (Callsign: " .. metadata.callsign .. ")"
    end
    if onDutyTimes[src] then
        sendDutyTimeWebhook(src, playerName)
        onDutyTimes[src] = nil
    else
        onDutyTimes[src] = os.time()
        sendToDiscord(playerName .. " went on duty.")
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if onDutyTimes[src] then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        sendDutyTimeWebhook(src, playerName)
        onDutyTimes[src] = nil
    end
end)

function sendDutyTimeWebhook(src, playerName)
    local endTime = os.time()
    local timeOnDuty = os.difftime(endTime, onDutyTimes[src])
    local hours = math.floor(timeOnDuty / 3600)
    local minutes = math.floor((timeOnDuty % 3600) / 60)
    local seconds = timeOnDuty % 60
    sendToDiscord(playerName ..
    " went off duty. Total time on duty: " .. hours .. "H " .. minutes .. "M " .. seconds .. "S")
end

function sendToDiscord(message)
    local webhook = Config.Webhook
    if webhook == '' or webhook == 'CHANGEME' then
        print('Please put webhook into editableserver.lua')
        return
    end
    local connect = {
        {
            ["color"] = 255,
            ["title"] = "Police Duty",
            ["description"] = message,
            ["footer"] = {
                ["icon_url"] = "https://media.discordapp.net/attachments/1077462714902917171/1077462755625418862/96Logo.png",
                ["text"] = "www.nemesisGD.com",
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
        json.encode({
            username = 'Nemesis Gaming Development | Police Duty',
            embeds = connect,
            avatar_url = 'https://media.discordapp.net/attachments/1077462714902917171/1077462755625418862/96Logo.png'
        }),
        { ['Content-Type'] = 'application/json' })
end
