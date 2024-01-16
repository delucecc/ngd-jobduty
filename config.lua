Config = {}

Config.Jobs = {
    police = {                                          --Name you must put in server.lua for webhook
        JobName = 'police',                             --Name of job in qb-core>shared>jobs.lua
        SendCallsign = true,                            --Send callsign to webhook (This requires a job setup for the qbcore /callsign command)
        UseCommand = {
            Enabled = true,                             --Enable the use of a / command
            Command = "pdduty",                         --Command to toggle duty
            ChatSuggestion = "/pdduty",                 --Shows the / command suggestion
            ChatSuggestionM = "Duty Toggle For Police", --Shows the / command suggestion description
        },
    },
    ambulance = {
        JobName = 'ambulance',
        SendCallsign = true,
        UseCommand = {
            Enabled = true,
            Command = "emsduty",
            ChatSuggestion = "/emsduty",
            ChatSuggestionM = "Duty Toggle For EMS",
        },
    },
    tobacco = {
        JobName = 'tobacco',
        SendCallsign = false,
        UseCommand = {
            Enabled = false,
            Command = "tobaccoduty",
            ChatSuggestion = "/tobaccoduty",
            ChatSuggestionM = "Duty Toggle For Tobacco Farmer",
        },
    },
    -- Add more jobs following the format above.
}
