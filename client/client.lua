local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterCommand(Config.Command, function()
    if PlayerData.job and PlayerData.job.name == Config.PoliceJob then
        TriggerServerEvent('QBCore:ToggleDuty')
        TriggerServerEvent('ngd-policeduty:Server:Log')
    end
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', Config.ChatSuggestion, Config.ChatSuggestionM, {})
end)