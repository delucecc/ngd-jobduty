local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

if Config.UseCommand then
    RegisterCommand(Config.Command, function()
        if PlayerData.job and PlayerData.job.name == Config.PoliceJob or PlayerData.job and PlayerData.job.type == Config.PoliceJobType then
            TriggerServerEvent('QBCore:ToggleDuty')
        end
    end)

    CreateThread(function()
        TriggerEvent('chat:addSuggestion', Config.ChatSuggestion, Config.ChatSuggestionM, {})
    end)
end
