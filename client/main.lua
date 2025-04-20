local QBCore = exports['qb-core']:GetCoreObject()
local player = PlayerPedId()
local blackoutActive = false  -- Variável local para armazenar o estado do blackout


--// Models
local box = GetHashKey("reh_prop_reh_b_computer_04a")
RequestModel(box)
while not HasModelLoaded(box) do
    Citizen.Wait(1)
    RequestModel(box)
end

--// Events
RegisterNetEvent("ss-blackout:recentlyhitnotification", function()
QBCore.Functions.Notify(Config.RecentlyHitMessage, "error", 3000)
end)

RegisterNetEvent("ss-blackout:blackoutactivenotification", function()
QBCore.Functions.Notify(Config.AlreadyActiveMessage, "error", 3000)
end)


--// Models
local box = GetHashKey("reh_prop_reh_b_computer_04a")
RequestModel(box)
while not HasModelLoaded(box) do
    Citizen.Wait(1)
    RequestModel(box)
end

--// Eventos
RegisterNetEvent("ss-blackout:updateState", function(state)
    blackoutActive = state
    UpdateBlackoutTarget() -- Atualiza o target quando o estado muda
end)

RegisterNetEvent("ss-blackout:enterbox", function()
    local ped = PlayerPedId()
    SetEntityHeading(ped, 239.88)
    local pedCoords = GetEntityCoords(ped)
    local pedRotation = GetEntityRotation(ped)

    NetworkedScene(vector3(713.9, 160.55, 80.75), pedRotation, {
        { ped = ped, anim = { dict = "anim@scripted@ulp_missions@fuse@male@", anim = "enter" } }
    }, {
        { model = `reh_prop_reh_b_computer_04a`, anim = { dict = "anim@scripted@ulp_missions@fuse@male@", anim = "enter_fusebox" } }
    }, 7500)

    NetworkedScene(vector3(713.9, 160.55, 80.75), pedRotation, {
        { ped = ped, anim = { dict = "anim@scripted@ulp_missions@fuse@male@", anim = "success" } }
    }, {
        { model = `reh_prop_reh_b_computer_04a`, anim = { dict = "anim@scripted@ulp_missions@fuse@male@", anim = "success_fusebox" } }
    }, 9560)
end)






--// Functions
function NetworkedScene(coords, rotation, peds, objects, duration)
    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z-1, rotation, 2, false, false,
        -1,
        0,
        1.0)

    for k, v in pairs(peds) do
        if v.model and not v.ped then
            while not HasModelLoaded(v.model) do
                RequestModel(v.model)
                Wait(1)
            end

            v.ped = CreatePed(23, v.model, coords.x, coords.y, coords.z, 0.0, true, true)
            v.createdByUs = true
        end
        while not HasAnimDictLoaded(v.anim.dict) do
            RequestAnimDict(v.anim.dict)
            Wait(1)
        end
        NetworkAddPedToSynchronisedScene(v.ped, scene, v.anim.dict, v.anim.anim, 1.5,
            -4.0, 1,
            16,
            1148846080, 0)
    end

    for k, v in pairs(objects) do
        if v.model and not v.object then
            while not HasModelLoaded(v.model) do
                RequestModel(v.model)
                Wait(1)
            end
            v.object = CreateObject(v.model, coords, true, true, true)
            v.createdByUs = true
        end
        while not HasAnimDictLoaded(v.anim.dict) do
            RequestAnimDict(v.anim.dict)
            Wait(1)
        end
        NetworkAddEntityToSynchronisedScene(v.object, scene, v.anim.dict, v.anim.anim,
            1.0,
            1.0, 1)
    end

    NetworkStartSynchronisedScene(scene)
    Wait(duration)
    NetworkStopSynchronisedScene(scene)



    for k, v in pairs(peds) do
        if v.createdByUs then
            DeletePed(v.ped)
        end
    end

    for k, v in pairs(objects) do
        if v.createdByUs then
            DeleteEntity(v.object)
        end
    end
end

--// Função para atualizar o alvo de interação
function UpdateBlackoutTarget()
    exports['qb-target']:RemoveZone("BlackoutBoxZone") -- Remove a zona para recriar corretamente

    if blackoutActive then
        -- Target para ligar a energia
        exports['qb-target']:AddBoxZone("BlackoutBoxZone", vector3(713.01, 161.07, 81.10), 1.2, 1, {
            name = "BlackoutBoxZone",
            heading = 331,
            debugPoly = false,
            minZ = 80.5,
            maxZ = 81.9,
        }, {
            options = {
                {
                    type = "server",
                    event = "ss-blackout:restorepower",
                    icon = 'fa-solid fa-power-off',
                    label = 'Ligar a energia da Cidade',
                }
            },
            distance = 3.0
        })
    else
        -- Target para desligar a energia
        exports['qb-target']:AddBoxZone("BlackoutBoxZone", vector3(713.01, 161.07, 81.10), 1.2, 1, {
            name = "BlackoutBoxZone",
            heading = 331,
            debugPoly = false,
            minZ = 80.5,
            maxZ = 81.9,
        }, {
            options = {
                {
                    type = "server",
                    event = "ss-blackout:blackout",
                    icon = 'fa-solid fa-power-off',
                    label = 'Desligar a energia da Cidade',
                }
            },
            distance = 3.0
        })
    end
end

-- Iniciar com a configuração correta
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    UpdateBlackoutTarget()
end)