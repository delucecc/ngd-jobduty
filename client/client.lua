local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    local isOnDuty = PlayerData.job and PlayerData.job.onduty
    TriggerServerEvent('SetInitialDutyStatus', isOnDuty)
    if isOnDuty then
        TriggerServerEvent('SendOnDutyWebhook', PlayerData.job.name)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

for _, jobConfig in pairs(Config.Jobs) do
    if jobConfig.UseCommand and jobConfig.UseCommand.Enabled then
        RegisterCommand(jobConfig.UseCommand.Command, function()
            if PlayerData.job and (PlayerData.job.name == jobConfig.JobName) then
                TriggerServerEvent('QBCore:ToggleDuty')
            end
        end)
        CreateThread(function()
            TriggerEvent('chat:addSuggestion', jobConfig.UseCommand.ChatSuggestion, jobConfig.UseCommand.ChatSuggestionM,
                {})
        end)
    end
end
