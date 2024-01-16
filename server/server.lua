local QBCore = exports['qb-core']:GetCoreObject()
local onDutyTimes = {}
-- ██     ██ ███████ ██████  ██   ██  ██████   ██████  ██   ██
-- ██     ██ ██      ██   ██ ██   ██ ██    ██ ██    ██ ██  ██
-- ██  █  ██ █████   ██████  ███████ ██    ██ ██    ██ █████
-- ██ ███ ██ ██      ██   ██ ██   ██ ██    ██ ██    ██ ██  ██
--  ███ ███  ███████ ██████  ██   ██  ██████   ██████  ██   ██
local JobWebhooks = {
    police = 'CHANGEME',
    ambulance = 'CHANGEME',
    tobacco = 'CHANGEME',
    --Add more to match config.
}

function sendDutyTimeWebhook(src, playerName, jobName, jobLabel, playerDropped)
    local endTime = os.time()
    local timeOnDuty = os.difftime(endTime, onDutyTimes[src])
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local metadata = xPlayer.PlayerData.metadata
    local callsign = ""
    if Config.Jobs[jobName] and Config.Jobs[jobName].SendCallsign and metadata and metadata.callsign then
        callsign = metadata.callsign
    end
    local dutyStatus = "Off Duty"
    if playerDropped then
        dutyStatus = "Off Duty - Player Dropped"
    end
    sendToDiscord(jobName, playerName, callsign, timeOnDuty, nil, dutyStatus, 16711680, jobLabel)
end

RegisterNetEvent('QBCore:ToggleDuty')
AddEventHandler('QBCore:ToggleDuty', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local jobName = xPlayer.PlayerData.job.name
    local jobLabel = QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label or jobName
    local jobConfig = Config.Jobs[jobName]
    if jobConfig and JobWebhooks[jobName] then
        local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        local metadata = xPlayer.PlayerData.metadata
        local callsign = ""
        if jobConfig.SendCallsign and metadata and metadata.callsign then
            callsign = metadata.callsign
        end
        if onDutyTimes[src] then --Off duty
            sendDutyTimeWebhook(src, playerName, jobName, jobLabel)
            onDutyTimes[src] = nil
        else
            onDutyTimes[src] = os.time() -- On duty
            sendToDiscord(jobName, playerName, callsign, nil, nil, "On Duty", 65280, jobLabel)
        end
    end
end)

RegisterNetEvent('SendOnDutyWebhook')
AddEventHandler('SendOnDutyWebhook', function(jobName)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
    local jobLabel = QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label or jobName
    local metadata = xPlayer.PlayerData.metadata
    local callsign = ""
    if Config.Jobs[jobName].SendCallsign and metadata and metadata.callsign then
        callsign = metadata.callsign
    end
    if JobWebhooks[jobName] then
        local customMessage = "**Player Name:**\n`" .. playerName .. "`\n"
        customMessage = customMessage .. "**Job:**\n`" .. jobLabel .. "`\n"
        if callsign and callsign ~= "" then
            customMessage = customMessage .. "**Callsign:**\n`" .. callsign .. "`\n"
        end
        customMessage = customMessage .. "\n" .. playerName .. " has loaded into the server and was put on duty."
        sendToDiscord(jobName, playerName, callsign, nil, customMessage, "Player Logged In", 65280)
    end
end)

RegisterNetEvent('SetInitialDutyStatus')
AddEventHandler('SetInitialDutyStatus', function(isOnDuty)
    local src = source
    if isOnDuty then
        onDutyTimes[src] = os.time()
    else
        onDutyTimes[src] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if onDutyTimes[src] then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local playerName = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        local jobName = xPlayer.PlayerData.job.name
        local jobLabel = QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label or jobName
        sendDutyTimeWebhook(src, playerName, jobName, jobLabel, true)
        onDutyTimes[src] = nil
    end
end)


function sendToDiscord(jobName, playerName, callsign, timeOnDuty, customMessage, dutyStatus, color, jobLabel)
    local webhook = JobWebhooks[jobName]
    if not webhook or webhook == 'CHANGEME' then
        print('Webhook URL is not set for job: ' .. jobName)
        return
    end
    local title = "Duty Status Update"
    if dutyStatus then
        title = title .. " (" .. dutyStatus .. ")"
    end
    local message
    if customMessage then
        message = customMessage
    else
        message = "**Player Name:**\n`" .. playerName .. "`\n"
        message = message .. "**Job:**\n`" .. (jobLabel or jobName) .. "`\n"
        if callsign and callsign ~= "" then
            message = message .. "**Callsign:**\n`" .. callsign .. "`\n"
        end
        if timeOnDuty then
            local hours = math.floor(timeOnDuty / 3600)
            local minutes = math.floor((timeOnDuty % 3600) / 60)
            local seconds = timeOnDuty % 60
            message = message .. "**Time on Duty:**\n`" .. hours .. "H " .. minutes .. "M " .. seconds .. "S`"
        end
    end
    local currentDateTime = os.date("%m-%d-%Y %H:%M:%S")
    local connect = {
        {
            ["color"] = color or 255,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["icon_url"] =
                "https://media.discordapp.net/attachments/1077462714902917171/1077462755625418862/96Logo.png",
                ["text"] = "www.nemesisGD.com | " .. currentDateTime,
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
        json.encode({
            username = 'Nemesis Gaming Development | Duty Status',
            embeds = connect,
            avatar_url = 'https://media.discordapp.net/attachments/1077462714902917171/1077462755625418862/96Logo.png'
        }),
        { ['Content-Type'] = 'application/json' })
end
