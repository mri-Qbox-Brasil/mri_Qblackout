local QBCore = exports['qb-core']:GetCoreObject()
local recentlyHit = false
local blackout = false
local timeTillTurnOn = Config.BlackoutTime
local coolDownTime = Config.Cooldown


local boxModel = CreateObjectNoOffset(GetHashKey("reh_prop_reh_b_computer_04a"), 713.9, 160.55, 79.75, true, false, false)
FreezeEntityPosition(boxModel, true)
SetEntityHeading(boxModel, 239.98)
SetEntityHeading(boxModel, 239.99)


--// Função para definir o estado do blackout
local function SetBlackoutState(state)
    blackout = state
    TriggerClientEvent("ss-blackout:updateState", -1, blackout)
end
--// Evento para desligar a energia
RegisterNetEvent("ss-blackout:blackout", function()
    local src = source
    if not blackout then
        if not recentlyHit then
            SetBlackoutState(true)
            SetEntityCoords(boxModel, 713.9, 160.55, 30.0, true, true, false, false)
            TriggerClientEvent("ss-blackout:enterbox", src)

            Citizen.Wait(17000)
            SetEntityCoords(boxModel, 713.9, 160.55, 79.75, true, true, false, false)

            TriggerEvent("ss-blackout:blackouton")

            Citizen.Wait(Config.BlackoutTime)
            SetBlackoutState(false)
            TriggerEvent("ss-blackout:blackoutoff")

            recentlyHit = true
            Citizen.Wait(Config.Cooldown)
            recentlyHit = false
        else
            TriggerClientEvent("ss-blackout:recentlyhitnotification", src)
        end
    else
        TriggerClientEvent("ss-blackout:blackoutactivenotification", src)
    end
end)


RegisterNetEvent("ss-blackout:blackouton", function()
    exports["qb-weathersync"]:setBlackout(true)
end)

RegisterNetEvent("ss-blackout:blackoutoff", function()
    exports["qb-weathersync"]:setBlackout(false)
end)


--// Evento para ligar a energia manualmente
RegisterNetEvent("ss-blackout:restorepower", function()
    local src = source
    if blackout then
        SetBlackoutState(false)
        SetEntityCoords(boxModel, 713.9, 160.55, 30.0, true, true, false, false)
        TriggerClientEvent("ss-blackout:enterbox", src)

        Citizen.Wait(17000)
        SetEntityCoords(boxModel, 713.9, 160.55, 79.75, true, true, false, false)
        TriggerEvent("ss-blackout:blackoutoff")
    end
end)